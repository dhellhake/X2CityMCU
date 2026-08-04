use core::{cell::RefCell, ops::DerefMut};

use crate::{bms::BmsInterface, mcu::McuManager, os::Mutex, vd18mt::VD18MTInterface};

pub(crate) static VD18MT: Mutex<RefCell<Option<VD18MTInterface>>> = Mutex::new(RefCell::new(None));
pub(crate) static BMS: Mutex<RefCell<Option<BmsInterface>>> = Mutex::new(RefCell::new(None));

#[unsafe(link_section = ".itcm_text.deployment")]
#[inline(never)]
pub fn tsk_1_5ms(_tstmp: u64) {}

#[unsafe(link_section = ".itcm_text.deployment")]
#[inline(never)]
pub fn tsk_2_10ms(tstmp: u64) {
    if let Some(ref mut vd18mt) = VD18MT.borrow().borrow_mut().deref_mut() {
        vd18mt.VD18MTInterface_Step(tstmp);
    }

    if let Some(ref mut bms) = BMS.borrow().borrow_mut().deref_mut() {
        bms.BmsInterface_Step(tstmp);
    }
}

#[unsafe(link_section = ".itcm_text.deployment")]
#[inline(never)]
pub fn tsk_pfm_10ms(_tstmp: u64) {
    McuManager::PFM_ValidateAndServiceWatchdog();
}
