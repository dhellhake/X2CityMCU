#![allow(non_snake_case)]

use crate::mcu::McuManager;

pub const VD18MT_FRAME_LENGTH: usize = 7;
const VD18MT_START_BYTE: u8 = 0x59;
const VD18MT_ASSIST_FLAG_INDEX: usize = 1;
const VD18MT_WHEEL_DIAMETER_INDEX: usize = 3;
const VD18MT_SPEED_LIMIT_INDEX: usize = 5;
const VD18MT_CHECKSUM_INDEX: usize = 6;
const VD18MT_MIN_WHEEL_DIAMETER_INCHES: u8 = 4;
const VD18MT_MAX_WHEEL_DIAMETER_INCHES: u8 = 35;
const VD18MT_PARTIAL_FRAME_TIMEOUT_US: u64 = 20_000;
const VD18MT_MAX_RECEIVE_BYTES_PER_STEP: usize = 16;

#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum VD18MTAssistLevel {
    Level0 = 0,
    Level1 = 1,
    Level2 = 2,
    Level3 = 3,
    Level4 = 4,
    Level5 = 5,
}

impl VD18MTAssistLevel {
    const fn FromAssistFlag(assistFlag: u8) -> Option<Self> {
        match assistFlag {
            0x10 => Some(VD18MTAssistLevel::Level0),
            0x80 => Some(VD18MTAssistLevel::Level1),
            0x40 => Some(VD18MTAssistLevel::Level2),
            0x02 => Some(VD18MTAssistLevel::Level3),
            0x04 => Some(VD18MTAssistLevel::Level4),
            0x08 => Some(VD18MTAssistLevel::Level5),
            _ => None,
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct VD18MTData {
    pub AssistLevel: VD18MTAssistLevel,
    pub WheelDiameterInches: u8,
    pub SpeedLimitKmh: u8,
}

impl VD18MTData {
    pub const fn new() -> Self {
        VD18MTData {
            AssistLevel: VD18MTAssistLevel::Level0,
            WheelDiameterInches: 0,
            SpeedLimitKmh: 0,
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct VD18MTFrame {
    pub bytes: [u8; VD18MT_FRAME_LENGTH],
    pub timestamp_us: u64,
}

impl VD18MTFrame {
    pub const fn new() -> Self {
        VD18MTFrame {
            bytes: [0; VD18MT_FRAME_LENGTH],
            timestamp_us: 0,
        }
    }
}

#[repr(C)]
pub struct VD18MTInterface {
    _receiveBuffer: [u8; VD18MT_FRAME_LENGTH],
    _receiveIndex: usize,
    _lastByteTimestampUs: u64,
    pub LatestFrame: VD18MTFrame,
    pub LatestData: VD18MTData,
    pub ReceivedFrameCount: u32,
    pub InvalidFrameCount: u32,
    pub ChecksumErrorCount: u32,
    pub InvalidAssistFlagCount: u32,
    pub InvalidWheelDiameterCount: u32,
    pub RejectedByteCount: u32,
    pub PartialFrameTimeoutCount: u32,
    pub NewFrameAvailable: bool,
    pub LastStepTimestampUs: u64,
}

impl VD18MTInterface {
    pub const fn new() -> Self {
        VD18MTInterface {
            _receiveBuffer: [0; VD18MT_FRAME_LENGTH],
            _receiveIndex: 0,
            _lastByteTimestampUs: 0,
            LatestFrame: VD18MTFrame::new(),
            LatestData: VD18MTData::new(),
            ReceivedFrameCount: 0,
            InvalidFrameCount: 0,
            ChecksumErrorCount: 0,
            InvalidAssistFlagCount: 0,
            InvalidWheelDiameterCount: 0,
            RejectedByteCount: 0,
            PartialFrameTimeoutCount: 0,
            NewFrameAvailable: false,
            LastStepTimestampUs: 0,
        }
    }

    pub fn VD18MTInterface_ReceiveByte(&mut self, byte: u8, timestamp_us: u64) {
        self._lastByteTimestampUs = timestamp_us;

        match self._receiveIndex {
            0 => {
                if byte == VD18MT_START_BYTE {
                    self._receiveBuffer[0] = byte;
                    self._receiveIndex = 1;
                } else {
                    self.RejectedByteCount = self.RejectedByteCount.saturating_add(1);
                }
            }
            _ => {
                self._receiveBuffer[self._receiveIndex] = byte;
                self._receiveIndex += 1;

                if self._receiveIndex == VD18MT_FRAME_LENGTH {
                    self.VD18MTInterface_InterpretFrame(timestamp_us);
                    self._receiveIndex = 0;
                }
            }
        }
    }

    pub fn VD18MTInterface_Step(&mut self, tstmp: u64) {
        for _ in 0..VD18MT_MAX_RECEIVE_BYTES_PER_STEP {
            let Some(byte) = McuManager::VD18MTCommunication_TryReadByte() else {
                break;
            };

            self.VD18MTInterface_ReceiveByte(byte, tstmp);
        }

        self.LastStepTimestampUs = tstmp;

        if self._receiveIndex != 0
            && tstmp.saturating_sub(self._lastByteTimestampUs) > VD18MT_PARTIAL_FRAME_TIMEOUT_US
        {
            self._receiveIndex = 0;
            self.PartialFrameTimeoutCount = self.PartialFrameTimeoutCount.saturating_add(1);
        }
    }

    pub fn VD18MTInterface_TakeLatestFrame(&mut self) -> Option<VD18MTFrame> {
        if !self.NewFrameAvailable {
            return None;
        }

        self.NewFrameAvailable = false;
        Some(self.LatestFrame)
    }

    fn VD18MTInterface_InterpretFrame(&mut self, timestamp_us: u64) {
        if Self::VD18MTInterface_CalculateChecksum(&self._receiveBuffer)
            != self._receiveBuffer[VD18MT_CHECKSUM_INDEX]
        {
            self.InvalidFrameCount = self.InvalidFrameCount.saturating_add(1);
            self.ChecksumErrorCount = self.ChecksumErrorCount.saturating_add(1);
            return;
        }

        let Some(assistLevel) =
            VD18MTAssistLevel::FromAssistFlag(self._receiveBuffer[VD18MT_ASSIST_FLAG_INDEX])
        else {
            self.InvalidFrameCount = self.InvalidFrameCount.saturating_add(1);
            self.InvalidAssistFlagCount = self.InvalidAssistFlagCount.saturating_add(1);
            return;
        };

        let wheelDiameterInches = self._receiveBuffer[VD18MT_WHEEL_DIAMETER_INDEX];
        if !(VD18MT_MIN_WHEEL_DIAMETER_INCHES..=VD18MT_MAX_WHEEL_DIAMETER_INCHES)
            .contains(&wheelDiameterInches)
        {
            self.InvalidFrameCount = self.InvalidFrameCount.saturating_add(1);
            self.InvalidWheelDiameterCount = self.InvalidWheelDiameterCount.saturating_add(1);
            return;
        }

        self.LatestFrame = VD18MTFrame {
            bytes: self._receiveBuffer,
            timestamp_us,
        };
        self.LatestData = VD18MTData {
            AssistLevel: assistLevel,
            WheelDiameterInches: wheelDiameterInches,
            SpeedLimitKmh: self._receiveBuffer[VD18MT_SPEED_LIMIT_INDEX],
        };
        self.ReceivedFrameCount = self.ReceivedFrameCount.saturating_add(1);
        self.NewFrameAvailable = true;
    }

    fn VD18MTInterface_CalculateChecksum(frame: &[u8; VD18MT_FRAME_LENGTH]) -> u8 {
        let mut checksum = 0u8;
        let mut byteIndex = 0;

        while byteIndex < VD18MT_CHECKSUM_INDEX {
            checksum = checksum.wrapping_add(frame[byteIndex]);
            byteIndex += 1;
        }

        checksum
    }
}
