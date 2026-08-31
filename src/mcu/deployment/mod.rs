use crate::mcu::McuManager;

#[unsafe(link_section = ".itcm_text.deployment")]
#[inline(never)]
pub extern "C" fn tsk_1_5ms(tstmp: u64) {
    McuManager::BoardLed_Step(tstmp);
}

#[unsafe(link_section = ".itcm_text.deployment")]
#[inline(never)]
pub extern "C" fn tsk_pfm_10ms(_tstmp: u64) {
    McuManager::PFM_ValidateAndServiceWatchdog();
}
