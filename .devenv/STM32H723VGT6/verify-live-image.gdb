# Verify a running release image without losing the relocated vectors/task RAM.
# Uses STM32H723VGT6.cfg with -work-area-backup 1; writes snapshots under target.
# arm-none-eabi-gdb -q -batch target/thumbv7em-none-eabihf/release/X2CityMCU -x .devenv/STM32H723VGT6/verify-live-image.gdb
set pagination off
set confirm off
set remotetimeout 30
target extended-remote localhost:3333
monitor halt
maintenance flush register-cache
set language rust
set $cycles_before = X2CityMCU::mcu::PFM.inner.value._cycleCount
set $hardfault_vector_before = *(0x2000000c as *const u32)
dump binary memory target/dtcm-before-verify.bin 0x20000000 0x20010000
compare-sections
dump binary memory target/dtcm-after-verify.bin 0x20000000 0x20010000
monitor mdw 0x20000000 8
if *(0x2000000c as *const u32) != $hardfault_vector_before
  echo FAIL: checksum algorithm corrupted the RAM vector table\n
  quit 1
end
monitor resume
monitor sleep 30000
monitor halt
maintenance flush register-cache
p X2CityMCU::mcu::PFM.inner.value._cycleCount
p X2CityMCU::mcu::PFM.inner.value._diagnostic.fault
monitor mdw 0xe000ed24 3
if X2CityMCU::mcu::PFM.inner.value._cycleCount < $cycles_before + 2900 || X2CityMCU::mcu::PFM.inner.value._diagnostic.fault as u32 != 0 || *(0xe000ed28 as *const u32) != 0 || *(0xe000ed2c as *const u32) != 0
  echo FAIL: firmware did not resume safely after live image verification\n
  quit 1
end
echo PASS: live image verification preserved vectors and sustained scheduling\n
monitor resume
monitor sleep 2000
disconnect
quit 0
