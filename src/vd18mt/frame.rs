#![allow(non_snake_case)]

use core::ops::BitOr;

pub const VD18MT_FRAME_LENGTH: usize = 7;
pub const VT8MT_FRAME_LENGTH: usize = 9;
pub const VT8MT_STATIONARY_WHEEL_PULSE_PERIOD: u16 = 0x0707;

const VT8MT_BATTERY_CURRENT_PROTOCOL_UNITS_PER_AMPERE: f32 = 5.0;
const VT8MT_BATTERY_CURRENT_QUANTIZATION_TOLERANCE: f32 = 0.001;

#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum VT8MTBatteryIndication {
    Empty = 0x00,
    OneSixth = 0x02,
    TwoSixths = 0x04,
    ThreeSixths = 0x06,
    FourSixths = 0x08,
    FiveSixths = 0x0A,
    Full = 0x0C,
}

#[repr(transparent)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct VT8MTControllerStatusFlags(u8);

impl VT8MTControllerStatusFlags {
    pub const None: Self = Self(0x00);
    pub const BatteryUndervoltage: Self = Self(0x01);
    pub const UnknownBit1: Self = Self(0x02);
    pub const ControllerWorking: Self = Self(0x04);
    pub const PedalActivity: Self = Self(0x08);
    pub const UnknownBit4: Self = Self(0x10);

    pub const fn Bits(self) -> u8 {
        self.0
    }
}

impl BitOr for VT8MTControllerStatusFlags {
    type Output = Self;

    fn bitor(self, rhs: Self) -> Self::Output {
        Self(self.0 | rhs.0)
    }
}

#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum VT8MTErrorCode {
    NoError = 0,
    UnderOrOvervoltage = 1,
    TorqueSensorError = 2,
    SpeedSensorError = 3,
    MotorBlocked = 4,
    Unknown5 = 5,
    Overtemperature = 6,
    BatteryOvercurrent = 7,
    EepromCheckError = 9,
    ThrottleSensorError = 10,
    Unknown11 = 11,
    CadenceSensorError = 13,
}

#[repr(transparent)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct VT8MTBatteryCurrent(u8);

impl VT8MTBatteryCurrent {
    pub const Zero: Self = Self(0);

    pub fn FromAmperes(amperes: f32) -> Self {
        assert!(amperes >= 0.0);

        let protocolUnits = amperes * VT8MT_BATTERY_CURRENT_PROTOCOL_UNITS_PER_AMPERE;
        assert!(protocolUnits <= f32::from(u8::MAX));

        let roundedProtocolUnits = (protocolUnits + 0.5) as u8;
        let quantizationError = protocolUnits - f32::from(roundedProtocolUnits);
        assert!(quantizationError.abs() <= VT8MT_BATTERY_CURRENT_QUANTIZATION_TOLERANCE);

        Self(roundedProtocolUnits)
    }

    pub fn Amperes(self) -> f32 {
        f32::from(self.0) / VT8MT_BATTERY_CURRENT_PROTOCOL_UNITS_PER_AMPERE
    }

    pub(super) const fn ProtocolUnits(self) -> u8 {
        self.0
    }
}

#[repr(C)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct VT8MTData {
    pub BatteryIndication: VT8MTBatteryIndication,
    pub ControllerStatus: VT8MTControllerStatusFlags,
    pub BatteryCurrentAmperes: VT8MTBatteryCurrent,
    pub ErrorCode: VT8MTErrorCode,
    pub SpeedKmh: u16,
}

impl VT8MTData {
    pub const fn new() -> Self {
        VT8MTData {
            BatteryIndication: VT8MTBatteryIndication::Empty,
            ControllerStatus: VT8MTControllerStatusFlags::None,
            BatteryCurrentAmperes: VT8MTBatteryCurrent::Zero,
            ErrorCode: VT8MTErrorCode::NoError,
            SpeedKmh: 0,
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct VT8MTFrame {
    pub bytes: [u8; VT8MT_FRAME_LENGTH],
    pub timestamp_us: u64,
}

impl VT8MTFrame {
    pub const fn new() -> Self {
        VT8MTFrame {
            bytes: [0; VT8MT_FRAME_LENGTH],
            timestamp_us: 0,
        }
    }
}

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
    pub(super) const fn FromAssistFlag(assistFlag: u8) -> Option<Self> {
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
    pub HeadlightRequested: bool,
    pub WheelDiameterInches: u8,
    pub SpeedLimitKmh: u8,
}

impl VD18MTData {
    pub const fn new() -> Self {
        VD18MTData {
            AssistLevel: VD18MTAssistLevel::Level0,
            HeadlightRequested: false,
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
