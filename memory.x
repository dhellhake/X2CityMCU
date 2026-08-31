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

MEMORY
{
    /* STM32H743IIT6 internal memory grouped by domain/features. */
    itcm        (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00010000
    rom         (rx)  : ORIGIN = 0x08000000, LENGTH = 0x00200000
    dtcm        (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00020000
    axi_sram    (rwx) : ORIGIN = 0x24000000, LENGTH = 0x00080000
    d2_sram     (rwx) : ORIGIN = 0x30000000, LENGTH = 0x00048000
    d3_sram     (rwx) : ORIGIN = 0x38000000, LENGTH = 0x00010000
    backup_sram (rwx) : ORIGIN = 0x38800000, LENGTH = 0x00001000
}

STACK_SIZE = DEFINED(STACK_SIZE) ? STACK_SIZE :
             DEFINED(__stack_size__) ? __stack_size__ : 0x1000;

SECTIONS
{
    PROVIDE(_axi_sram_start    = ORIGIN(axi_sram));
    PROVIDE(_axi_sram_end      = ORIGIN(axi_sram) + LENGTH(axi_sram));
    PROVIDE(_axisram_start     = _axi_sram_start);
    PROVIDE(_axisram_end       = _axi_sram_end);
    PROVIDE(_d2_sram_start     = ORIGIN(d2_sram));
    PROVIDE(_d2_sram_end       = ORIGIN(d2_sram) + LENGTH(d2_sram));
    PROVIDE(_d3_sram_start     = ORIGIN(d3_sram));
    PROVIDE(_d3_sram_end       = ORIGIN(d3_sram) + LENGTH(d3_sram));
    PROVIDE(_backup_sram_start = ORIGIN(backup_sram));
    PROVIDE(_backup_sram_end   = ORIGIN(backup_sram) + LENGTH(backup_sram));
    PROVIDE(_dtcm_start        = ORIGIN(dtcm));
    PROVIDE(_dtcm_end          = ORIGIN(dtcm) + LENGTH(dtcm));
    PROVIDE(_ram_end           = _axi_sram_end);
    PROVIDE(_stack_start       = _dtcm_end);

    .vectors ORIGIN(rom) :
    {
        . = ALIGN(1024);
        __vector_table_flash_start = .;

        /* Initial stack pointer */
        LONG(_stack_start);

        KEEP(*(.vectors.exception_table));
        KEEP(*(.vectors.interrupt_table));

        __vector_table_flash_end = .;
    } > rom

    .text :
    {
        . = ALIGN(4);
        __stext = .;

        *(.text .text.*)
        *(.rodata .rodata.*)

        . = ALIGN(4);
        __etext = .;
    } > rom

    .ARM.extab :
    {
        . = ALIGN(4);
        *(.ARM.extab* .gnu.linkonce.armextab.*)
        . = ALIGN(4);
    } > rom

    .ARM.exidx :
    {
        . = ALIGN(4);
        __exidx_start = .;
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
        __exidx_end = .;
        . = ALIGN(4);
    } > rom

    .itcm_text :
    {
        . = ALIGN(8);
        __itcm_text_start = .;
        KEEP(*(.itcm_text .itcm_text.*))
        . = ALIGN(8);
        __itcm_text_end = .;
    } > itcm AT > rom

    __itcm_text_load_start = LOADADDR(.itcm_text);

    .ram_vector_table (NOLOAD) :
    {
        . = ALIGN(1024);
        __vector_table_ram_start = .;
        . += __vector_table_flash_end - __vector_table_flash_start;
        . = ALIGN(4);
        __vector_table_ram_end = .;
    } > dtcm

    .dtcm_data :
    {
        . = ALIGN(8);
        __dtcm_data_start = .;
        *(.dtcm_data .dtcm_data.*)
        . = ALIGN(8);
        __dtcm_data_end = .;
    } > dtcm AT > rom

    __dtcm_data_load_start = LOADADDR(.dtcm_data);

    .dtcm_bss (NOLOAD) :
    {
        . = ALIGN(8);
        __dtcm_bss_start = .;
        *(.dtcm_bss .dtcm_bss.*)
        . = ALIGN(8);
        __dtcm_bss_end = .;
    } > dtcm

    __dtcm_used_end = .;

    .data :
    {
        . = ALIGN(4);
        _srelocate = .;
        *(.data .data.*)
        . = ALIGN(4);
        _erelocate = .;
    } > axi_sram AT > rom

    _sidata = LOADADDR(.data);

    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        _sbss = .;
        _szero = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
        _ezero = .;
    } > axi_sram

    . = ALIGN(4);
    _end = .;

    .stack ORIGIN(dtcm) + LENGTH(dtcm) - STACK_SIZE (NOLOAD) :
    {
        . = ALIGN(8);
        _sstack = .;
        . += STACK_SIZE;
        . = ALIGN(8);
        _estack = .;
    } > dtcm

    ASSERT(__itcm_text_end <= ORIGIN(itcm) + LENGTH(itcm), "ITCM text exceeds available ITCM")
    ASSERT(__dtcm_used_end <= _sstack, "DTCM sections overlap reserved stack or exceed DTCM")
    ASSERT(_estack == _stack_start, "reserved stack end does not match initial MSP")
    ASSERT(_end <= ORIGIN(axi_sram) + LENGTH(axi_sram), "AXI SRAM data sections exceed AXI SRAM")
}
