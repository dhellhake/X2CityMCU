# Program a raw RT1061 FlexSPI1 boot image with NXP's CMSIS FLM algorithm.
# Required X2_* variables are supplied by .devenv/program-qspi.ps1.

foreach required_variable {
    X2_IMAGE
    X2_ALGORITHM
    X2_IMAGE_LENGTH
    X2_ERASE_LENGTH
    X2_BACKUP
    X2_READBACK
} {
    if {![info exists $required_variable]} {
        error "missing required variable $required_variable"
    }
}

set X2_FLASH_BASE       0x60000000
set X2_SECTOR_SIZE      0x1000
set X2_PAGE_SIZE        0x100
set X2_ALGORITHM_BASE   0x20000000
set X2_BUFFER           0x20001000
set X2_STACK_TOP        0x20008000
set X2_RETURN_TRAP      0x20000001
set X2_SRC_SCR          0x400f8000

# These addresses come from the pinned MIMXRT106x_QSPI_4KB_SEC.FLM. The
# four-byte return trap prepended by setup-qspi-flm.ps1 accounts for the +4.
set X2_INIT             0x20000005
set X2_UNINIT           0x2000018d
set X2_ERASE_SECTOR     0x200001b5
set X2_PROGRAM_PAGE     0x200001e5
set X2_STATIC_BASE      0x2000037c
set X2_BSS_BASE         0x20000384
set X2_BSS_WORDS        132

proc x2_assert_rtwdog_reset_route_masked {} {
    global X2_SRC_SCR

    set source_control [lindex [read_memory $X2_SRC_SCR 32 1] 0]
    if {(($source_control >> 28) & 0xf) != 0x5} {
        error [format "RTWDOG reset route is not masked during programming: SRC.SCR=0x%08x" $source_control]
    }
}

proc x2_mask_rtwdog_reset_route {} {
    global X2_SRC_SCR

    # Programming replaces a potentially supervised running application. The
    # locked RTWDOG may expire while the flash algorithm runs, so suppress its
    # reset route instead of adopting or servicing the application's watchdog.
    # POR_B after verification restores the hardware reset value.
    set source_control [lindex [read_memory $X2_SRC_SCR 32 1] 0]
    set source_control [expr {($source_control & 0x0fffffff) | 0x50000000}]
    write_memory $X2_SRC_SCR 32 [list $source_control]
    x2_assert_rtwdog_reset_route_masked
}

proc x2_call_flm {operation entry r0 r1 r2 timeout_ms} {
    global X2_STACK_TOP X2_RETURN_TRAP X2_STATIC_BASE

    x2_assert_rtwdog_reset_route_masked

    set_reg [list \
        r0 $r0 \
        r1 $r1 \
        r2 $r2 \
        r9 $X2_STATIC_BASE \
        sp $X2_STACK_TOP \
        lr $X2_RETURN_TRAP \
        xpsr 0x01000000 \
        primask 1 \
        basepri 0 \
        faultmask 0]

    resume $entry
    wait_halt $timeout_ms

    set result [lindex [dict values [get_reg -force r0]] 0]
    if {$result != 0} {
        error [format "%s failed with FLM result 0x%08x" $operation $result]
    }
}

proc x2_init_flm {function_code} {
    global X2_INIT X2_FLASH_BASE
    # Init(address, clock_hz, function): clock_hz=0 selects the algorithm's
    # board-specific clock setup.
    x2_call_flm Init $X2_INIT $X2_FLASH_BASE 0 $function_code 30000
}

proc x2_uninit_flm {function_code} {
    global X2_UNINIT
    x2_call_flm UnInit $X2_UNINIT $function_code 0 0 10000
}

init
halt
x2_mask_rtwdog_reset_route

# Once the reset route is masked, every failure path must first contain the
# target. In particular, a wait_halt timeout must not leave an FLM routine
# executing after OpenOCD disconnects while RTWDOG reset is suppressed.
set X2_PROGRAM_RESULT [catch {
    echo "Loading the pinned NXP FlexSPI flash algorithm"
    load_image $X2_ALGORITHM $X2_ALGORITHM_BASE bin
    write_memory $X2_BSS_BASE 32 [lrepeat $X2_BSS_WORDS 0]

    x2_init_flm 1

    if {$X2_BACKUP ne ""} {
        echo [format "Backing up 0x%x bytes from QSPI before erase" $X2_ERASE_LENGTH]
        dump_image $X2_BACKUP $X2_FLASH_BASE $X2_ERASE_LENGTH
    }

    echo [format "Erasing 0x%x bytes in 4 KiB sectors" $X2_ERASE_LENGTH]
    for {set offset 0} {$offset < $X2_ERASE_LENGTH} {incr offset $X2_SECTOR_SIZE} {
        set address [expr {$X2_FLASH_BASE + $offset}]
        x2_call_flm EraseSector $X2_ERASE_SECTOR $address 0 0 30000
    }
    x2_uninit_flm 1

    x2_init_flm 2
    echo [format "Programming 0x%x bytes in 256-byte pages" $X2_IMAGE_LENGTH]
    for {set offset 0} {$offset < $X2_IMAGE_LENGTH} {incr offset $X2_PAGE_SIZE} {
        set address [expr {$X2_FLASH_BASE + $offset}]

        # load_image maps raw-file offset N to address (base + N). Shift its
        # base backwards by the current offset to load just this page.
        load_image $X2_IMAGE [expr {$X2_BUFFER - $offset}] bin $X2_BUFFER $X2_PAGE_SIZE
        x2_call_flm ProgramPage $X2_PROGRAM_PAGE $address $X2_PAGE_SIZE $X2_BUFFER 10000

        if {($offset & 0xfff) == 0} {
            echo [format "  programmed through flash +0x%08x" $offset]
        }
    }
    x2_uninit_flm 2

    # Reinitialize for read-back so the algorithm applies its FlexSPI mapping
    # and invalidates any state retained from IP-command programming.
    x2_init_flm 3
    echo "Reading the complete erased prefix back through the FlexSPI memory map"
    dump_image $X2_READBACK $X2_FLASH_BASE $X2_ERASE_LENGTH
    x2_uninit_flm 3
} X2_PROGRAM_ERROR]

if {$X2_PROGRAM_RESULT != 0} {
    set X2_CONTAINMENT_RESULT [catch {
        halt
        wait_halt 5000
        x2_assert_rtwdog_reset_route_masked
    } X2_CONTAINMENT_ERROR]

    if {$X2_CONTAINMENT_RESULT == 0} {
        echo "QSPI FAILURE CONTAINED: target is halted with RTWDOG reset masked; do not resume it"
    } else {
        echo [format "QSPI FAILURE CONTAINMENT COULD NOT BE PROVEN: %s" $X2_CONTAINMENT_ERROR]
    }

    error $X2_PROGRAM_ERROR
}

echo "QSPI erase, program, and read-back completed; target remains halted"

shutdown
