#![allow(non_snake_case)]

use crate::mcu::McuManager;

pub const BMS_FRAME_LENGTH: usize = 7;
pub const BMS_FRAME: [u8; BMS_FRAME_LENGTH] = [0xDD, 0xA5, 0x03, 0x00, 0xFF, 0xFD, 0x77];

const BMS_TRANSMISSION_PERIOD_US: u64 = 500_000;

#[repr(C)]
pub struct BmsInterface {
    _transmitIndex: usize,
    _transmitActive: bool,
    _nextTransmitTimestampUs: u64,
    pub LastStepTimestampUs: u64,
    pub LatestTransmissionTimestampUs: u64,
    pub TransmittedFrameCount: u32,
}

impl BmsInterface {
    pub const fn new() -> Self {
        BmsInterface {
            _transmitIndex: 0,
            _transmitActive: false,
            _nextTransmitTimestampUs: 0,
            LastStepTimestampUs: 0,
            LatestTransmissionTimestampUs: 0,
            TransmittedFrameCount: 0,
        }
    }

    pub fn BmsInterface_Step(&mut self, tstmp: u64) {
        self.LastStepTimestampUs = tstmp;

        if self._nextTransmitTimestampUs == 0 {
            self._nextTransmitTimestampUs = tstmp;
        }

        if !self._transmitActive && tstmp >= self._nextTransmitTimestampUs {
            self._transmitIndex = 0;
            self._transmitActive = true;
            self.LatestTransmissionTimestampUs = tstmp;

            while self._nextTransmitTimestampUs <= tstmp {
                self._nextTransmitTimestampUs = self
                    ._nextTransmitTimestampUs
                    .saturating_add(BMS_TRANSMISSION_PERIOD_US);
            }
        }

        while self._transmitActive && self._transmitIndex < BMS_FRAME_LENGTH {
            if !McuManager::BmsCommunication_TryWriteByte(BMS_FRAME[self._transmitIndex]) {
                break;
            }

            self._transmitIndex += 1;
        }

        if self._transmitActive && self._transmitIndex == BMS_FRAME_LENGTH {
            self._transmitActive = false;
            self.TransmittedFrameCount = self.TransmittedFrameCount.saturating_add(1);
        }
    }
}
