use crate::{bms::BmsInterface, drv::cortex::Shared, mcu::McuManager, vd18mt::VD18MTInterface};

pub(crate) static VD18MT: Shared<VD18MTInterface> = Shared::new(VD18MTInterface::new());
pub(crate) static BMS: Shared<BmsInterface> = Shared::new(BmsInterface::new());

#[unsafe(link_section = ".itcm_text.deployment")]
#[inline(never)]
pub extern "C" fn tsk_1_5ms(_tstmp: u64) {}

#[unsafe(link_section = ".itcm_text.deployment")]
#[inline(never)]
pub extern "C" fn tsk_2_10ms(tstmp: u64) {
    VD18MT.with(|vd18mt| vd18mt.VD18MTInterface_Step(tstmp));
    BMS.with(|bms| bms.BmsInterface_Step(tstmp));
}

#[unsafe(link_section = ".itcm_text.deployment")]
#[inline(never)]
pub extern "C" fn tsk_pfm_10ms(_tstmp: u64) {
    McuManager::PFM_ValidateAndServiceWatchdog();
}
