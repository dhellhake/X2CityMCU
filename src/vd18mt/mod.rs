#![allow(non_snake_case)]

use crate::mcu::McuManager;

mod frame;

pub use frame::{
    VD18MTAssistLevel, VD18MTData, VD18MTFrame, VT8MTBatteryCurrent, VT8MTBatteryIndication,
    VT8MTControllerStatusFlags, VT8MTData, VT8MTErrorCode, VT8MTFrame, VD18MT_FRAME_LENGTH,
    VT8MT_FRAME_LENGTH, VT8MT_STATIONARY_WHEEL_PULSE_PERIOD,
};

const VD18MT_START_BYTE: u8 = 0x59;
const VD18MT_ASSIST_FLAG_INDEX: usize = 1;
const VD18MT_HEADLIGHT_REQUEST_MASK: u8 = 0x01;
const VD18MT_ASSIST_FLAG_MASK: u8 = !VD18MT_HEADLIGHT_REQUEST_MASK;
const VD18MT_WHEEL_DIAMETER_INDEX: usize = 3;
const VD18MT_SPEED_LIMIT_INDEX: usize = 5;
const VD18MT_CHECKSUM_INDEX: usize = 6;
const VD18MT_MIN_WHEEL_DIAMETER_INCHES: u8 = 4;
const VD18MT_MAX_WHEEL_DIAMETER_INCHES: u8 = 35;
const VD18MT_PARTIAL_FRAME_TIMEOUT_US: u64 = 20_000;
const VD18MT_MAX_RECEIVE_BYTES_PER_STEP: usize = 16;
const VT8MT_START_BYTE: u8 = 0x43;
const VT8MT_TRANSMISSION_PERIOD_US: u64 = 100_000;
const VT8MT_CHECKSUM_INDEX: usize = 8;
const WHEEL_CIRCUMFERENCE_METRES_PER_SIZE_UNIT_NUMERATOR: u64 = 4;
const WHEEL_CIRCUMFERENCE_METRES_PER_SIZE_UNIT_DENOMINATOR: u64 = 100;
const KMH_PERIOD_CONVERSION_FACTOR: u64 = 3_600;

#[repr(C)]
pub struct VD18MTInterface {
    _receiveBuffer: [u8; VD18MT_FRAME_LENGTH],
    _receiveIndex: usize,
    _lastByteTimestampUs: u64,
    _transmitBuffer: [u8; VT8MT_FRAME_LENGTH],
    _transmitIndex: usize,
    _transmitActive: bool,
    _nextTransmitTimestampUs: u64,
    pub LatestFrame: VD18MTFrame,
    pub LatestData: VD18MTData,
    pub TransmitData: VT8MTData,
    pub LatestTransmittedFrame: VT8MTFrame,
    pub ReceivedFrameCount: u32,
    pub TransmittedFrameCount: u32,
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
            _transmitBuffer: [0; VT8MT_FRAME_LENGTH],
            _transmitIndex: 0,
            _transmitActive: false,
            _nextTransmitTimestampUs: 0,
            LatestFrame: VD18MTFrame::new(),
            LatestData: VD18MTData::new(),
            TransmitData: VT8MTData::new(),
            LatestTransmittedFrame: VT8MTFrame::new(),
            ReceivedFrameCount: 0,
            TransmittedFrameCount: 0,
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

        self.VD18MTInterface_ProcessTransmission(tstmp);
    }

    pub fn VD18MTInterface_SetVT8MTData(&mut self, data: VT8MTData) {
        self.TransmitData = data;
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

        let assistAndHeadlightFlags = self._receiveBuffer[VD18MT_ASSIST_FLAG_INDEX];
        let Some(assistLevel) =
            VD18MTAssistLevel::FromAssistFlag(assistAndHeadlightFlags & VD18MT_ASSIST_FLAG_MASK)
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
            HeadlightRequested: (assistAndHeadlightFlags & VD18MT_HEADLIGHT_REQUEST_MASK) != 0,
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

    fn VD18MTInterface_ProcessTransmission(&mut self, tstmp: u64) {
        if self._nextTransmitTimestampUs == 0 {
            self._nextTransmitTimestampUs = tstmp;
        }

        if !self._transmitActive && tstmp >= self._nextTransmitTimestampUs {
            let frame = self.VD18MTInterface_EncodeVT8MTFrame(tstmp);
            self._transmitBuffer = frame.bytes;
            self.LatestTransmittedFrame = frame;
            self._transmitIndex = 0;
            self._transmitActive = true;

            while self._nextTransmitTimestampUs <= tstmp {
                self._nextTransmitTimestampUs = self
                    ._nextTransmitTimestampUs
                    .saturating_add(VT8MT_TRANSMISSION_PERIOD_US);
            }
        }

        while self._transmitActive && self._transmitIndex < VT8MT_FRAME_LENGTH {
            if !McuManager::VD18MTCommunication_TryWriteByte(
                self._transmitBuffer[self._transmitIndex],
            ) {
                break;
            }

            self._transmitIndex += 1;
        }

        if self._transmitActive && self._transmitIndex == VT8MT_FRAME_LENGTH {
            self._transmitActive = false;
            self.TransmittedFrameCount = self.TransmittedFrameCount.saturating_add(1);
        }
    }

    fn VD18MTInterface_EncodeVT8MTFrame(&self, timestamp_us: u64) -> VT8MTFrame {
        let wheelPulsePeriod = Self::VD18MTInterface_CalculateWheelPulsePeriod(
            self.TransmitData.SpeedKmh,
            self.LatestData.WheelDiameterInches,
        );
        let wheelPulsePeriodBytes = wheelPulsePeriod.to_le_bytes();
        let mut bytes = [
            VT8MT_START_BYTE,
            self.TransmitData.BatteryIndication as u8,
            self.TransmitData.ControllerStatus.Bits(),
            0,
            self.TransmitData.BatteryCurrentAmperes.ProtocolUnits(),
            self.TransmitData.ErrorCode as u8,
            wheelPulsePeriodBytes[0],
            wheelPulsePeriodBytes[1],
            0,
        ];

        bytes[VT8MT_CHECKSUM_INDEX] = Self::VD18MTInterface_CalculateVT8MTChecksum(&bytes);

        VT8MTFrame {
            bytes,
            timestamp_us,
        }
    }

    fn VD18MTInterface_CalculateWheelPulsePeriod(speedKmh: u16, wheelDiameterInches: u8) -> u16 {
        if speedKmh == 0
            || !(VD18MT_MIN_WHEEL_DIAMETER_INCHES..=VD18MT_MAX_WHEEL_DIAMETER_INCHES)
                .contains(&wheelDiameterInches)
        {
            return VT8MT_STATIONARY_WHEEL_PULSE_PERIOD;
        }

        // The display maps each received wheel-size unit to 0.04 m circumference.
        // N_ms = circumference_m * 3600 / speed_km/h.
        let numerator = u64::from(wheelDiameterInches)
            * WHEEL_CIRCUMFERENCE_METRES_PER_SIZE_UNIT_NUMERATOR
            * KMH_PERIOD_CONVERSION_FACTOR;
        let denominator =
            u64::from(speedKmh) * WHEEL_CIRCUMFERENCE_METRES_PER_SIZE_UNIT_DENOMINATOR;
        let roundedPeriod = (numerator + (denominator / 2)) / denominator;
        let boundedPeriod = roundedPeriod.clamp(1, u64::from(u16::MAX));
        let period = boundedPeriod as u16;

        if period == VT8MT_STATIONARY_WHEEL_PULSE_PERIOD {
            period - 1
        } else {
            period
        }
    }

    fn VD18MTInterface_CalculateVT8MTChecksum(frame: &[u8; VT8MT_FRAME_LENGTH]) -> u8 {
        let mut checksum = 0u8;
        let mut byteIndex = 0;

        while byteIndex < VT8MT_CHECKSUM_INDEX {
            checksum = checksum.wrapping_add(frame[byteIndex]);
            byteIndex += 1;
        }

        checksum
    }
}
