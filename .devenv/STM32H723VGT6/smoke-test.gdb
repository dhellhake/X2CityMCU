# Run from the workspace root with an OpenOCD server using STM32H723VGT6.cfg.
# This PROGRAMS the ELF supplied on the GDB command line and leaves it running.
# Release build needs symbols: cargo build --release --config profile.release.debug=2
# arm-none-eabi-gdb -q -batch <ELF> -x .devenv/STM32H723VGT6/smoke-test.gdb
set pagination off
set confirm off
set remotetimeout 30
target extended-remote localhost:3333
monitor reset halt
load
compare-sections
monitor reset run
monitor sleep 30000
monitor halt
maintenance flush register-cache
set language rust

echo \n--- H723 register snapshot after 30 seconds ---\n
monitor mdw 0x5c001000 1
monitor mdh 0x1ff1e880 1
monitor mdw 0x58024800 7
monitor mdw 0x58024400 14
monitor mdw 0x52002000 1
monitor mdw 0x52002070 2
monitor mdw 0x58000748 1
monitor mdw 0x58021000 6
monitor mdw 0x40011000 12
monitor mdw 0x50003000 3
monitor mdw 0x580244a0 1
monitor mdw 0xe000ed24 3
monitor mdw 0xe000ed08 1
monitor mdw 0xe000ef34 1
info registers pc msp psp control primask xpsr
p X2CityMCU::mcu::PFM.inner.value._state
p X2CityMCU::mcu::PFM.inner.value._diagnostic.fault
p X2CityMCU::mcu::PFM.inner.value._cycleCount
p X2CityMCU::mcu::SYSTICK.inner.value._elapsedTicks
p X2CityMCU::mcu::TASK_5MS.control.value
p X2CityMCU::mcu::TASK_PROGRAM_FLOW.control.value

if (*(0x5c001000 as *const u32) & 0xfff) != 0x483
  echo FAIL: unexpected MCU device ID\n
  quit 1
end
if *(0x1ff1e880 as *const u16) != 1024
  echo FAIL: unexpected flash size\n
  quit 1
end
if (*(0x52002000 as *const u32) & 0x3f) != 0x33
  echo FAIL: flash timing\n
  quit 1
end
if (*(0x52002070 as *const u32) & 4) == 0 || (*(0x58000748 as *const u32) & 1) == 0
  echo FAIL: CPU frequency boost required for 550 MHz\n
  quit 1
end
if (*(0x58024818 as *const u32) & 0xc000) != 0
  echo FAIL: voltage scale\n
  quit 1
end
if (*(0x58024804 as *const u32) & 0x2000) == 0
  echo FAIL: supply not ready\n
  quit 1
end
if (*(0x58024410 as *const u32) & 0x3f) != 0x1b
  echo FAIL: PLL1 system clock\n
  quit 1
end
if (*(0x58024418 as *const u32) & 0xf7f) != 0x48
  echo FAIL: CPU/AHB/APB3 dividers\n
  quit 1
end
if *(0x5802441c as *const u32) != 0x440 || *(0x58024420 as *const u32) != 0x40
  echo FAIL: APB1/APB2/APB4 dividers\n
  quit 1
end
if (*(0x58024428 as *const u32) & 0x3f3) != 0x52 || *(0x58024430 as *const u32) != 0x0101006d
  echo FAIL: PLL1 source or dividers\n
  quit 1
end
if *(0xe000ed08 as *const u32) != 0x20000000
  echo FAIL: vector relocation\n
  quit 1
end
if *(0xe000ed28 as *const u32) != 0 || *(0xe000ed2c as *const u32) != 0
  echo FAIL: core fault status\n
  quit 1
end
if (*(0x58021000 as *const u32) & 0xc0) != 0x40
  echo FAIL: PE3 output mode\n
  quit 1
end
if *(0x4001100c as *const u32) != 1194
  echo FAIL: USART1 baud divider\n
  quit 1
end
if *(0x50003004 as *const u32) != 0x1861 || (*(0x50003000 as *const u32) & 0x80) == 0
  echo FAIL: watchdog inactive or wrong window\n
  quit 1
end
if (*(0x580244a0 as *const u32) & 1) == 0
  echo FAIL: WWDG1 system reset scope not configured\n
  quit 1
end
if X2CityMCU::mcu::PFM.inner.value._cycleCount < 2500
  echo FAIL: scheduler/PFM did not survive 30-second soak\n
  quit 1
end
if X2CityMCU::mcu::SYSTICK.inner.value._ticksPerSecond != 550000000
  echo FAIL: scheduler time conversion clock\n
  quit 1
end
if X2CityMCU::mcu::PFM.inner.value._diagnostic.fault as u32 != 0
  echo FAIL: program flow fault\n
  quit 1
end
if *(0xe000ef34 as *const u32) != 0x80000000
  echo FAIL: eager FPU context policy\n
  quit 1
end
if X2CityMCU::mcu::TASK_5MS.stack.value[0] != 0xdeadbeef || X2CityMCU::mcu::TASK_5MS.stack.value[3] != 0xdeadbeef || X2CityMCU::mcu::TASK_PROGRAM_FLOW.stack.value[0] != 0xdeadbeef || X2CityMCU::mcu::TASK_PROGRAM_FLOW.stack.value[3] != 0xdeadbeef || X2CityMCU::mcu::TASK_BACKGROUND.stack.value[0] != 0xdeadbeef || X2CityMCU::mcu::TASK_BACKGROUND.stack.value[3] != 0xdeadbeef
  echo FAIL: task stack guard\n
  quit 1
end
if X2CityMCU::mcu::TASK_5MS.control.value.missed_releases != 0 || X2CityMCU::mcu::TASK_PROGRAM_FLOW.control.value.missed_releases != 0
  echo FAIL: missed task releases\n
  quit 1
end

set $previous_cycles = X2CityMCU::mcu::PFM.inner.value._cycleCount
monitor resume
monitor sleep 2000
monitor halt
maintenance flush register-cache
if X2CityMCU::mcu::PFM.inner.value._cycleCount < $previous_cycles + 150
  echo FAIL: scheduler stopped or reset during second sample\n
  quit 1
end
p X2CityMCU::mcu::PFM.inner.value._cycleCount
echo PASS: H723 clock, memory, GPIO, UART configuration and scheduler/watchdog soak\n

# Inhibit interrupt-driven watchdog servicing; WWDG must reset the MCU.
monitor mww 0x580244d0 0x00010000
set $primask = 1
monitor resume
monitor sleep 200
monitor halt
maintenance flush register-cache
monitor mdw 0x580244d0 1
p X2CityMCU::mcu::PFM.inner.value._cycleCount
if (*(0x580244d0 as *const u32) & 0x10420000) != 0x10420000
  echo FAIL: omitted servicing did not cause a complete WWDG system reset\n
  quit 1
end
if X2CityMCU::mcu::PFM.inner.value._cycleCount > 100
  echo FAIL: firmware did not restart after watchdog reset\n
  quit 1
end
echo PASS: watchdog reset and firmware restart after omitted servicing\n
monitor resume
monitor sleep 2000
monitor halt
maintenance flush register-cache
if X2CityMCU::mcu::PFM.inner.value._cycleCount < 150 || X2CityMCU::mcu::PFM.inner.value._diagnostic.fault as u32 != 0
  echo FAIL: firmware did not recover sustained scheduling after watchdog reset\n
  quit 1
end
p X2CityMCU::mcu::PFM.inner.value._cycleCount
echo PASS: scheduling recovered after watchdog reset\n

set $led_states = 0
set $led_samples = 0
while $led_samples < 15
  monitor resume
  monitor sleep 80
  monitor halt
  set $led_states = $led_states | (1 << ((*(0x58021014 as *const u32) >> 3) & 1))
  set $led_samples = $led_samples + 1
end
if $led_states != 3
  echo FAIL: PE3 heartbeat did not toggle\n
  quit 1
end
echo PASS: PE3 heartbeat high and low states observed\n
monitor resume
detach
quit 0
