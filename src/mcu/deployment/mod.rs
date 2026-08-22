pub extern "C" fn tsk_1_5ms(_tstmp: u64) {}

pub extern "C" fn background(_tstmp: u64) {
    loop {
        core::hint::spin_loop();
    }
}
