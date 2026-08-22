ENTRY(Reset);

EXTERN(DefaultHandler);

PROVIDE(NonMaskableInt = DefaultHandler);
PROVIDE(HardFault      = DefaultHandler);
PROVIDE(MemManage      = DefaultHandler);
PROVIDE(BusFault       = DefaultHandler);
PROVIDE(UsageFault     = DefaultHandler);
PROVIDE(SVCall         = DefaultHandler);
PROVIDE(DebugMonitor   = DefaultHandler);
PROVIDE(PendSV         = DefaultHandler);
PROVIDE(SysTick_Isr    = DefaultHandler);
PROVIDE(DefaultHandler = DefaultHandler_);

/*
 * i.MX RT1061 FlexSPI1 NOR boot layout.
 *
 * The Boot ROM reads the FlexSPI Configuration Block at 0x60000000 and
 * the Image Vector Table at 0x60001000. It then enters the bootstrap Cortex
 * vector at 0x60002000. Reset executes in place only long enough to configure
 * FlexRAM and copy the complete application into ITCM/DTCM.
 *
 * The default flash geometry is the 4 MiB W25Q32JV fitted to the documented
 * FET1061-S module. A module carrying the optional 16 MiB device needs both
 * this memory length and the Rust Boot Data/FCB geometry reviewed together.
 */
__flexram_bank_config = 0xAAAAFFFF;

STACK_SIZE      = DEFINED(STACK_SIZE)      ? STACK_SIZE      : 0x1000;
BOOT_STACK_SIZE = DEFINED(BOOT_STACK_SIZE) ? BOOT_STACK_SIZE : 0x0400;

MEMORY
{
    QSPI_FLASH (rx)  : ORIGIN = 0x60000000, LENGTH = 0x00400000
    ITCM       (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00040000
    DTCM       (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00040000
    OCRAM_BOOT (rwx) : ORIGIN = 0x20200000, LENGTH = 0x00080000
}

SECTIONS
{
    /* Boot ROM FlexSPI Configuration Block; the structure itself is 512 B. */
    .flash_config ORIGIN(QSPI_FLASH) :
    {
        FILL(0xFFFFFFFF);
        __flash_image_start = .;
        __flash_config_start = .;
        KEEP(*(.boot_header.flash_config));
        __flash_config_payload_end = .;
        . = ORIGIN(QSPI_FLASH) + 0x1000;
        __flash_config_end = .;
    } > QSPI_FLASH

    /* Boot ROM IVT (32 B), immediately followed by Boot Data (16 B). */
    .boot_rom_header (ORIGIN(QSPI_FLASH) + 0x1000) :
    {
        FILL(0xFFFFFFFF);
        __boot_rom_ivt_start = .;
        KEEP(*(.boot_header.ivt));
        __boot_rom_ivt_end = .;
        __boot_data_start = .;
        KEEP(*(.boot_header.boot_data));
        __boot_data_end = .;
        . = ORIGIN(QSPI_FLASH) + 0x2000;
        __boot_rom_header_end = .;
    } > QSPI_FLASH

    /*
     * The ROM IVT enters this Cortex vector table. Keeping a conventional
     * vector handoff also lets a debugger launch this bootstrap directly.
     */
    .boot (ORIGIN(QSPI_FLASH) + 0x2000) :
    {
        FILL(0xFFFFFFFF);
        . = ALIGN(1024);
        __boot_vector_table = .;
        LONG(__boot_stack_top);
        LONG(Reset);
        LONG(BootFault);
        LONG(BootFault);
        LONG(BootFault);
        LONG(BootFault);
        LONG(BootFault);
        LONG(0);
        LONG(0);
        LONG(0);
        LONG(0);
        LONG(BootFault);
        LONG(BootFault);
        LONG(0);
        LONG(BootFault);
        LONG(BootFault);

        . = __boot_vector_table + 0x400;
        __boot_text_start = .;
        KEEP(*(.boot.reset));
        KEEP(*(.boot.reset.*));
        KEEP(*(.boot.fault));
        KEEP(*(.boot.fault.*));
        . = ALIGN(4);
        __boot_text_end = .;
    } > QSPI_FLASH

    __itcm_load_start = ALIGN(LOADADDR(.boot) + SIZEOF(.boot), 1024);
    __itcm_load_source = __itcm_load_start;

    /* Runtime vectors, executable code, and constants are copied to ITCM. */
    .itcm_image ORIGIN(ITCM) : AT(__itcm_load_start)
    {
        __itcm_start = .;
        __vector_table = .;

        LONG(__stack_top);
        KEEP(*(.vectors.exception_table));
        KEEP(*(.vectors.interrupt_table));

        . = __vector_table + 0x400;
        __text_start = .;

        *(.text .text.*);
        *(.rodata .rodata.*);
        *(.glue_7 .glue_7t);
        *(.ARM.extab* .gnu.linkonce.armextab.*);
        *(.eh_frame*);

        . = ALIGN(4);
        __text_end = .;
    } > ITCM

    .ARM.exidx : AT(__itcm_load_start + (ADDR(.ARM.exidx) - __itcm_start))
    {
        . = ALIGN(4);
        __exidx_start = .;
        *(.ARM.exidx* .gnu.linkonce.armexidx.*);
        __exidx_end = .;
        . = ALIGN(4);
        __itcm_end = .;
    } > ITCM

    __itcm_load_end = __itcm_load_start + (__itcm_end - __itcm_start);
    __data_load_start = ALIGN(__itcm_load_end, 4);
    __data_load_source = __data_load_start;

    .data ORIGIN(DTCM) : AT(__data_load_start)
    {
        . = ALIGN(4);
        __data_start = .;
        *(.data .data.*);
        . = ALIGN(4);
        __data_end = .;
    } > DTCM

    __data_load_end = __data_load_start + SIZEOF(.data);
    __flash_image_end = __data_load_end;
    __flash_image_size = __flash_image_end - __flash_image_start;

    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        __bss_start = .;
        *(.bss .bss.*);
        *(COMMON);
        . = ALIGN(4);
        __bss_end = .;
    } > DTCM

    .uninit (NOLOAD) :
    {
        . = ALIGN(4);
        __uninit_start = .;
        *(.uninit .uninit.*);
        . = ALIGN(4);
        __uninit_end = .;
    } > DTCM

    __dtcm_used_end = .;
    _end = .;

    __stack_top = ORIGIN(DTCM) + LENGTH(DTCM);
    __stack_bottom = __stack_top - STACK_SIZE;

    .stack __stack_bottom (NOLOAD) :
    {
        . = ALIGN(8);
        __stack_limit = .;
        . += STACK_SIZE;
        . = ALIGN(8);
    } > DTCM

    /* Bootstrap exceptions always use fixed OCRAM, never configurable FlexRAM. */
    __boot_stack_top = ORIGIN(OCRAM_BOOT) + LENGTH(OCRAM_BOOT);
    __boot_stack_bottom = __boot_stack_top - BOOT_STACK_SIZE;

    .boot_stack __boot_stack_bottom (NOLOAD) :
    {
        . = ALIGN(8);
        __boot_stack_limit = .;
        . += BOOT_STACK_SIZE;
        . = ALIGN(8);
    } > OCRAM_BOOT

    /DISCARD/ :
    {
        *(.comment);
        *(.ARM.attributes);
    }

    ASSERT(__flash_config_start == ORIGIN(QSPI_FLASH),
           "FlexSPI configuration must start at 0x60000000")
    ASSERT((__flash_config_payload_end - __flash_config_start) == 0x200,
           "FlexSPI NOR Configuration Block must be exactly 512 bytes")
    ASSERT(__boot_rom_ivt_start == ORIGIN(QSPI_FLASH) + 0x1000,
           "Boot ROM IVT must start at flash offset 0x1000")
    ASSERT((__boot_rom_ivt_end - __boot_rom_ivt_start) == 0x20,
           "Boot ROM IVT must be exactly 32 bytes")
    ASSERT((__boot_data_end - __boot_data_start) == 0x10,
           "Boot Data must be exactly 16 bytes")
    ASSERT(__boot_vector_table == ORIGIN(QSPI_FLASH) + 0x2000,
           "bootstrap vector table must start at flash offset 0x2000")
    ASSERT(__boot_text_start == ORIGIN(QSPI_FLASH) + 0x2400,
           "bootstrap code must start at flash offset 0x2400")
    ASSERT(__boot_text_end <= __itcm_load_start,
           "bootstrap overlaps the staged ITCM image")
    ASSERT(__flash_image_end <= ORIGIN(QSPI_FLASH) + LENGTH(QSPI_FLASH),
           "boot image exceeds the configured 4 MiB QSPI NOR")
    ASSERT(__itcm_end <= ORIGIN(ITCM) + LENGTH(ITCM),
           "application code and vectors exceed 256 KiB ITCM")
    ASSERT(__dtcm_used_end <= __stack_bottom,
           "DTCM data overlaps the reserved stack")
    ASSERT((__stack_top & 7) == 0, "application stack must be 8-byte aligned")
    ASSERT((__boot_stack_top & 7) == 0, "bootstrap stack must be 8-byte aligned")
}
