# One-time CPU_FREQ_BOOST provisioning for STM32H723VGT6.
# This persists across reset and disables ITCM/DTCM ECC, as required above 520 MHz.
# All other option bits are preserved. Leaves the target halted after reset.
# Run with the OpenOCD server configured by STM32H723VGT6.cfg:
# arm-none-eabi-gdb -q -batch -x .devenv/STM32H723VGT6/enable-550mhz.gdb
set pagination off
set confirm off
set remotetimeout 30
target extended-remote localhost:3333
monitor reset halt
set language rust
if (*(0x5c001000 as *const u32) & 0xfff) != 0x483 || *(0x1ff1e880 as *const u16) != 1024
  echo FAIL: expected STM32H723/73 with 1 MiB flash\n
  quit 1
end
set $options_before = *(0x52002070 as *const u32)
set $security_before = *(0x5200201c as *const u32)
echo Option state before provisioning:\n
monitor mdw 0x5200201c 2
monitor mdw 0x52002070 2
if ($options_before & 4) == 0
  monitor stm32h7x option_write 0 0x74 0x4 0x4
end
monitor reset halt
# Enable SYSCFG to inspect its runtime user-option mirror.
set *(0x580244f4 as *mut u32) = *(0x580244f4 as *const u32) | 2
monitor mdw 0x5200201c 2
monitor mdw 0x52002070 2
monitor mdw 0x58000748 1
if *(0x52002070 as *const u32) != ($options_before | 4)
  echo FAIL: CPU frequency boost option readback\n
  quit 1
end
if *(0x5200201c as *const u32) != $security_before
  echo FAIL: unrelated option state changed\n
  quit 1
end
if (*(0x58000748 as *const u32) & 1) == 0
  echo FAIL: runtime CPU frequency boost mirror\n
  quit 1
end
echo PASS: CPU_FREQ_BOOST enabled and other option bits preserved\n
disconnect
quit 0
