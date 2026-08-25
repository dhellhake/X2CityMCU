use crate::bms::BmsInterface_Run;

use super::McuManager;

pub extern "C" fn tsk_1_5ms(tstmp: u64) {
    McuManager::BoardLed_Step(tstmp);
}

pub extern "C" fn tsk_2_10ms(tstmp: u64) {
    BmsInterface_Run(tstmp);
}

pub extern "C" fn background(_tstmp: u64) {
    loop {
        core::hint::spin_loop();
    }
}
