EXTERN(DefaultHandler);

PROVIDE(NonMaskableInt = DefaultHandler);
PROVIDE(HardFault      = DefaultHandler);
PROVIDE(SVCall         = DefaultHandler);
PROVIDE(PendSV         = DefaultHandler);
PROVIDE(SysTick_Isr    = DefaultHandler);
PROVIDE(DefaultHandler = DefaultHandler_);

MEMORY
{
    rom (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00040000
    ram (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00008000
}

STACK_SIZE = DEFINED(STACK_SIZE) ? STACK_SIZE :
             DEFINED(__stack_size__) ? __stack_size__ : 0x1000;

SECTIONS
{
    PROVIDE(_ram_end     = ORIGIN(ram) + LENGTH(ram));
    PROVIDE(_stack_start = _ram_end);

    .vectors ORIGIN(rom) :
    {
        . = ALIGN(4);
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

    .data :
    {
        . = ALIGN(4);
        _srelocate = .;
        *(.data .data.*)
        . = ALIGN(4);
        _erelocate = .;
    } > ram AT > rom

    _sidata = LOADADDR(.data);

    .ram_vector_table (NOLOAD) :
    {
        . = ALIGN(512);
        __vector_table_ram_start = .;
        . += 0x200;
    } > ram

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
    } > ram

    . = ALIGN(4);
    _end = .;

    .stack ORIGIN(ram) + LENGTH(ram) - STACK_SIZE (NOLOAD) :
    {
        . = ALIGN(8);
        _sstack = .;
        . += STACK_SIZE;
        . = ALIGN(8);
        _estack = .;
    } > ram

    ASSERT(_end <= _sstack, "RAM data sections overlap reserved stack")
    ASSERT(_estack == _stack_start, "reserved stack end does not match initial MSP")
}
