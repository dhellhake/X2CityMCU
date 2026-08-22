//! Board-specific Boot ROM metadata for the FET1061-S primary FlexSPI1 NOR.
//!
//! This deliberately targets the documented 4 MiB Winbond W25Q32JVSIQ on
//! FlexSPI1 Port A1. The `IQ` ordering option has Quad Enable factory-fixed,
//! so the ROM does not need a status-register write before using command EBh.
//! Because the SoM schematic does not document an external DQS loopback, the
//! initial read clock is conservatively limited to 60 MHz and sampled with the
//! controller's internal loopback. These assumptions must be revisited for a
//! different flash ordering code or the optional 16 MiB module variant.

use core::{mem::size_of, ptr};

const FLASH_SIZE_BYTES: u32 = 4 * 1024 * 1024;

const FLEXSPI_CONFIGURATION_TAG: u32 = 0x4246_4346; // "FCFB"
const FLEXSPI_CONFIGURATION_VERSION: u32 = 0x5601_0400; // V1.4.0

const LUT_STOP: u8 = 0x00;
const LUT_COMMAND_SDR: u8 = 0x01;
const LUT_ROW_ADDRESS_SDR: u8 = 0x02;
const LUT_WRITE_SDR: u8 = 0x08;
const LUT_READ_SDR: u8 = 0x09;
const LUT_DUMMY_SDR: u8 = 0x0C;

const LUT_ONE_PAD: u8 = 0;
const LUT_FOUR_PADS: u8 = 2;

const fn lut_sequence(
    opcode0: u8,
    pads0: u8,
    operand0: u8,
    opcode1: u8,
    pads1: u8,
    operand1: u8,
) -> u32 {
    (operand0 as u32)
        | ((pads0 as u32) << 8)
        | ((opcode0 as u32) << 10)
        | ((operand1 as u32) << 16)
        | ((pads1 as u32) << 24)
        | ((opcode1 as u32) << 26)
}

const fn w25q32_configuration_words() -> [u32; 128] {
    let mut words = [0; 128];

    // Common FlexSPI memory configuration, offsets 0x000..0x07f.
    words[0] = FLEXSPI_CONFIGURATION_TAG;
    words[1] = FLEXSPI_CONFIGURATION_VERSION;
    words[3] = 0x0003_0300; // internal sample loopback, CS hold/setup = 3
    words[16] = 1 << 4; // safe configuration frequency while ROM initializes
    words[17] = 0x0003_0401; // serial NOR, four pads, 60 MHz, standard LUT
    words[20] = FLASH_SIZE_BYTES; // only FlexSPI1 Port A1 is populated

    // ROM LUT starts at byte offset 0x080 (word 32), four words per sequence.
    words[32] = lut_sequence(
        LUT_COMMAND_SDR,
        LUT_ONE_PAD,
        0xEB,
        LUT_ROW_ADDRESS_SDR,
        LUT_FOUR_PADS,
        0x18,
    );
    words[33] = lut_sequence(
        LUT_DUMMY_SDR,
        LUT_FOUR_PADS,
        0x06,
        LUT_READ_SDR,
        LUT_FOUR_PADS,
        0x04,
    );
    words[32 + 4] = lut_sequence(
        LUT_COMMAND_SDR,
        LUT_ONE_PAD,
        0x05,
        LUT_READ_SDR,
        LUT_ONE_PAD,
        0x04,
    );
    words[32 + 12] = lut_sequence(LUT_COMMAND_SDR, LUT_ONE_PAD, 0x06, LUT_STOP, LUT_ONE_PAD, 0);
    words[32 + 20] = lut_sequence(
        LUT_COMMAND_SDR,
        LUT_ONE_PAD,
        0x20,
        LUT_ROW_ADDRESS_SDR,
        LUT_ONE_PAD,
        0x18,
    );
    words[32 + 32] = lut_sequence(
        LUT_COMMAND_SDR,
        LUT_ONE_PAD,
        0xD8,
        LUT_ROW_ADDRESS_SDR,
        LUT_ONE_PAD,
        0x18,
    );
    words[32 + 36] = lut_sequence(
        LUT_COMMAND_SDR,
        LUT_ONE_PAD,
        0x02,
        LUT_ROW_ADDRESS_SDR,
        LUT_ONE_PAD,
        0x18,
    );
    words[32 + 37] = lut_sequence(LUT_WRITE_SDR, LUT_ONE_PAD, 0x04, LUT_STOP, LUT_ONE_PAD, 0);
    words[32 + 44] = lut_sequence(LUT_COMMAND_SDR, LUT_ONE_PAD, 0x60, LUT_STOP, LUT_ONE_PAD, 0);

    // Serial NOR extension, offsets 0x1c0..0x1ff.
    words[112] = 256; // page size
    words[113] = 4 * 1024; // sector size
    words[114] = 1; // IP-command serial clock selector; non-uniform block sizes
    words[116] = 64 * 1024; // block size

    words
}

#[repr(C, align(4))]
struct FlexSpiNorConfigurationBlock([u32; 128]);

#[used]
#[unsafe(link_section = ".boot_header.flash_config")]
static FLEXSPI_NOR_CONFIGURATION: FlexSpiNorConfigurationBlock =
    FlexSpiNorConfigurationBlock(w25q32_configuration_words());

#[repr(C, align(4))]
struct BootData {
    start: *const u8,
    size: u32,
    plugin: u32,
    placeholder: u32,
}

// The pointer is immutable boot metadata resolved completely by the linker.
unsafe impl Sync for BootData {}

#[repr(C, align(4))]
struct ImageVectorTable {
    header: u32,
    entry: *const u32,
    reserved1: u32,
    dcd: *const u32,
    boot_data: *const BootData,
    self_address: *const ImageVectorTable,
    csf: *const u32,
    reserved2: u32,
}

// The pointers are immutable boot metadata resolved completely by the linker.
unsafe impl Sync for ImageVectorTable {}

unsafe extern "C" {
    static __boot_vector_table: u32;
    static __flash_image_start: u8;
}

#[used]
#[unsafe(link_section = ".boot_header.boot_data")]
static BOOT_DATA: BootData = BootData {
    start: ptr::addr_of!(__flash_image_start),
    // NXP's RT1061 XIP header convention advertises the complete device size.
    size: FLASH_SIZE_BYTES,
    plugin: 0,
    placeholder: u32::MAX,
};

#[used]
#[unsafe(link_section = ".boot_header.ivt")]
static IMAGE_VECTOR_TABLE: ImageVectorTable = ImageVectorTable {
    // Bytes in flash: D1 (tag), 00 20 (big-endian length), 41 (version).
    header: 0x4120_00D1,
    // A word-aligned entry tells the ROM to consume this as a Cortex vector.
    entry: ptr::addr_of!(__boot_vector_table),
    reserved1: 0,
    dcd: ptr::null(),
    boot_data: ptr::addr_of!(BOOT_DATA),
    self_address: ptr::addr_of!(IMAGE_VECTOR_TABLE),
    // This first implementation targets an unsigned image on an open device.
    csf: ptr::null(),
    reserved2: 0,
};

const _: () = {
    assert!(size_of::<FlexSpiNorConfigurationBlock>() == 512);
    assert!(size_of::<ImageVectorTable>() == 32);
    assert!(size_of::<BootData>() == 16);
};
