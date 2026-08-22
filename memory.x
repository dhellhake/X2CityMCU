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
 * i.MX RT1061 RAM execution layout.
 *
 * The debugger writes one contiguous image to the dedicated OCRAM block. The
 * reset trampoline runs there while it configures FlexRAM, then copies the
 * complete vector/code image to ITCM and initialized data to DTCM.
 *
 * GPR17 value 0xAAAAFFFF assigns banks 0-7 to ITCM and banks 8-15 to
 * DTCM, giving 256 KiB of each and no configurable OCRAM. The 512 KiB
 * OCRAM_BOOT block is dedicated SRAM and is not affected by FlexRAM.
 */
__flexram_bank_config = 0xAAAAFFFF;

STACK_SIZE      = DEFINED(STACK_SIZE)      ? STACK_SIZE      : 0x1000;
BOOT_STACK_SIZE = DEFINED(BOOT_STACK_SIZE) ? BOOT_STACK_SIZE : 0x0400;

MEMORY
{
    ITCM       (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00040000
    DTCM       (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00040000
    OCRAM_BOOT (rwx) : ORIGIN = 0x20200000, LENGTH = 0x00080000
}

SECTIONS
{
    /*
     * The first two words are consumed by the debugger before Reset runs.
     * Reset itself and all literals used before relocation must remain here.
     */
    .boot ORIGIN(OCRAM_BOOT) :
    {
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

        /* Keep VTOR valid even if a fault occurs during the trampoline. */
        . = __boot_vector_table + 0x400;
        __boot_text_start = .;
        KEEP(*(.boot.reset));
        KEEP(*(.boot.reset.*));
        KEEP(*(.boot.fault));
        KEEP(*(.boot.fault.*));
        . = ALIGN(4);
        __boot_text_end = .;
    } > OCRAM_BOOT

    __itcm_load_start = ALIGN(LOADADDR(.boot) + SIZEOF(.boot), 1024);

    /* One contiguous image: vectors, all executable code, and all constants. */
    .itcm_image ORIGIN(ITCM) : AT(__itcm_load_start)
    {
        __itcm_start = .;
        __vector_table = .;

        /* Initial application stack pointer. */
        LONG(__stack_top);
        KEEP(*(.vectors.exception_table));
        KEEP(*(.vectors.interrupt_table));

        /* 174 vectors need 696 bytes; reserve 1 KiB for VTOR alignment. */
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

    /* ARM unwind indexes have a distinct ELF section type. */
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

    .data ORIGIN(DTCM) : AT(__data_load_start)
    {
        . = ALIGN(4);
        __data_start = .;
        *(.data .data.*);
        . = ALIGN(4);
        __data_end = .;
    } > DTCM

    __data_load_end = __data_load_start + SIZEOF(.data);

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

    /* A debugger-safe bootstrap stack in fixed OCRAM. Reset itself is stackless. */
    __boot_stack_top = ORIGIN(OCRAM_BOOT) + LENGTH(OCRAM_BOOT);
    __boot_stack_bottom = __boot_stack_top - BOOT_STACK_SIZE;

    .boot_stack __boot_stack_bottom (NOLOAD) :
    {
        . = ALIGN(8);
        __boot_stack_limit = .;
        . += BOOT_STACK_SIZE;
        . = ALIGN(8);
    } > OCRAM_BOOT

    __ram_image_start = ORIGIN(OCRAM_BOOT);
    __ram_image_end = __data_load_end;

    /DISCARD/ :
    {
        *(.comment);
        *(.ARM.attributes);
    }

    ASSERT(__boot_vector_table == ORIGIN(OCRAM_BOOT),
           "bootstrap vector table must start at fixed OCRAM base")
    ASSERT(__boot_text_end <= __itcm_load_start,
           "bootstrap overlaps the staged ITCM image")
    ASSERT(__itcm_end <= ORIGIN(ITCM) + LENGTH(ITCM),
           "application code and vectors exceed 256 KiB ITCM")
    ASSERT(__dtcm_used_end <= __stack_bottom,
           "DTCM data overlaps the reserved stack")
    ASSERT(__ram_image_end <= __boot_stack_bottom,
           "debugger load image exceeds fixed OCRAM staging space")
    ASSERT((__stack_top & 7) == 0, "application stack must be 8-byte aligned")
    ASSERT((__boot_stack_top & 7) == 0, "bootstrap stack must be 8-byte aligned")
}
