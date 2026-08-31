use crate::{
    achdl::AcHdlInterface_Run, bms::BmsInterface_Run, brkhdl::BrkHdlInterface_Run,
    esc::EscInterface_Run, vd18mt::VD18MTInterface_Run,
};

use super::McuManager;

pub extern "C" fn tsk_0_1ms(tstmp: u64) {
    EscInterface_Run(tstmp);
}

pub extern "C" fn tsk_1_5ms(tstmp: u64) {
    let analogInputs = McuManager::AnalogInput_ReadFrame();
    BrkHdlInterface_Run(tstmp, analogInputs.Brake);
    AcHdlInterface_Run(tstmp, analogInputs.AcHdl);
    McuManager::BoardLed_Step(tstmp);
}

pub extern "C" fn tsk_2_10ms(tstmp: u64) {
    VD18MTInterface_Run(tstmp);
    BmsInterface_Run(tstmp);
}

pub extern "C" fn tsk_program_flow_10ms(tstmp: u64) {
    McuManager::ProgramFlow_ValidateAndServiceWatchdog(tstmp);
}

pub extern "C" fn background(_tstmp: u64) {
    loop {
        core::hint::spin_loop();
    }
}
