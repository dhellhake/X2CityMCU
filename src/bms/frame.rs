#![allow(non_upper_case_globals)]

use core::ops::BitOr;

pub const BMS_MAX_CELL_COUNT: usize = 14;
pub const BMS_MAX_TEMPERATURE_SENSOR_COUNT: usize = 2;

#[repr(C)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct BmsManufacturingDate {
    pub Year: u16,
    pub Month: u8,
    pub Day: u8,
}

impl BmsManufacturingDate {
    pub const fn new() -> Self {
        BmsManufacturingDate {
            Year: 2000,
            Month: 0,
            Day: 0,
        }
    }
}

#[repr(transparent)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct BmsProtectionStatusFlags(u16);

impl BmsProtectionStatusFlags {
    pub const None: Self = Self(0);
    pub const CellOvervoltage: Self = Self(1 << 0);
    pub const CellUndervoltage: Self = Self(1 << 1);
    pub const PackOvervoltage: Self = Self(1 << 2);
    pub const PackUndervoltage: Self = Self(1 << 3);
    pub const ChargeOvertemperature: Self = Self(1 << 4);
    pub const ChargeUndertemperature: Self = Self(1 << 5);
    pub const DischargeOvertemperature: Self = Self(1 << 6);
    pub const DischargeUndertemperature: Self = Self(1 << 7);
    pub const ChargeOvercurrent: Self = Self(1 << 8);
    pub const DischargeOvercurrent: Self = Self(1 << 9);
    pub const ShortCircuit: Self = Self(1 << 10);
    pub const AnalogFrontEndError: Self = Self(1 << 11);
    pub const SoftwareLockedMosfet: Self = Self(1 << 12);
    pub const ChargeMosfetFailure: Self = Self(1 << 13);
    pub const DischargeMosfetFailure: Self = Self(1 << 14);

    pub const fn FromBits(bits: u16) -> Self {
        Self(bits)
    }

    pub const fn Bits(self) -> u16 {
        self.0
    }

    pub const fn Contains(self, flags: Self) -> bool {
        (self.0 & flags.0) == flags.0
    }
}

impl BitOr for BmsProtectionStatusFlags {
    type Output = Self;

    fn bitor(self, rhs: Self) -> Self::Output {
        Self(self.0 | rhs.0)
    }
}

#[repr(transparent)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct BmsAlarmStatusFlags(u16);

impl BmsAlarmStatusFlags {
    pub const None: Self = Self(0);
    pub const CellOvervoltage: Self = Self(1 << 0);
    pub const CellUndervoltage: Self = Self(1 << 1);
    pub const PackOvervoltage: Self = Self(1 << 2);
    pub const PackUndervoltage: Self = Self(1 << 3);
    pub const ChargeOvertemperature: Self = Self(1 << 4);
    pub const ChargeUndertemperature: Self = Self(1 << 5);
    pub const DischargeOvertemperature: Self = Self(1 << 6);
    pub const DischargeUndertemperature: Self = Self(1 << 7);
    pub const ChargeOvercurrent: Self = Self(1 << 8);
    pub const DischargeOvercurrent: Self = Self(1 << 9);
    pub const CellVoltageDifference: Self = Self(1 << 10);
    pub const LowCapacity: Self = Self(1 << 11);

    pub const fn FromBits(bits: u16) -> Self {
        Self(bits)
    }

    pub const fn Bits(self) -> u16 {
        self.0
    }

    pub const fn Contains(self, flags: Self) -> bool {
        (self.0 & flags.0) == flags.0
    }
}

impl BitOr for BmsAlarmStatusFlags {
    type Output = Self;

    fn bitor(self, rhs: Self) -> Self::Output {
        Self(self.0 | rhs.0)
    }
}

#[repr(transparent)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct BmsMosfetStatusFlags(u8);

impl BmsMosfetStatusFlags {
    pub const None: Self = Self(0);
    pub const ChargeEnabled: Self = Self(1 << 0);
    pub const DischargeEnabled: Self = Self(1 << 1);
    pub const CurrentLimitingEnabled: Self = Self(1 << 2);
    pub const HeatingEnabled: Self = Self(1 << 3);
    pub const HighRangeCurrentAndCapacityUnits: Self = Self(1 << 7);

    pub const fn FromBits(bits: u8) -> Self {
        Self(bits)
    }

    pub const fn Bits(self) -> u8 {
        self.0
    }

    pub const fn Contains(self, flags: Self) -> bool {
        (self.0 & flags.0) == flags.0
    }
}

impl BitOr for BmsMosfetStatusFlags {
    type Output = Self;

    fn bitor(self, rhs: Self) -> Self::Output {
        Self(self.0 | rhs.0)
    }
}

#[repr(C)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct BmsBasicPackData {
    pub PackVoltageMillivolts: u32,
    pub PackCurrentMilliamperes: i32,
    pub RemainingCapacityMilliampereHours: u32,
    pub NominalCapacityMilliampereHours: u32,
    pub CycleCount: u16,
    pub ManufacturingDate: BmsManufacturingDate,
    pub BalancingCellMask: u32,
    pub ProtectionStatus: BmsProtectionStatusFlags,
    pub SoftwareVersionTenths: u8,
    pub StateOfChargePercent: u8,
    pub MosfetStatus: BmsMosfetStatusFlags,
    pub CellCount: u8,
    pub TemperatureSensorCount: u8,
    pub TemperaturesDeciDegreesCelsius: [i32; BMS_MAX_TEMPERATURE_SENSOR_COUNT],
    pub HasExtendedData: bool,
    pub HumidityPercent: u8,
    pub AlarmStatus: BmsAlarmStatusFlags,
    pub FullChargeCapacityMilliampereHours: u32,
    pub ExtendedRemainingCapacityMilliampereHours: u32,
    pub BalanceCurrentMilliamperes: i32,
}

impl BmsBasicPackData {
    pub const fn new() -> Self {
        BmsBasicPackData {
            PackVoltageMillivolts: 0,
            PackCurrentMilliamperes: 0,
            RemainingCapacityMilliampereHours: 0,
            NominalCapacityMilliampereHours: 0,
            CycleCount: 0,
            ManufacturingDate: BmsManufacturingDate::new(),
            BalancingCellMask: 0,
            ProtectionStatus: BmsProtectionStatusFlags::None,
            SoftwareVersionTenths: 0,
            StateOfChargePercent: 0,
            MosfetStatus: BmsMosfetStatusFlags::None,
            CellCount: 0,
            TemperatureSensorCount: 0,
            TemperaturesDeciDegreesCelsius: [0; BMS_MAX_TEMPERATURE_SENSOR_COUNT],
            HasExtendedData: false,
            HumidityPercent: 0,
            AlarmStatus: BmsAlarmStatusFlags::None,
            FullChargeCapacityMilliampereHours: 0,
            ExtendedRemainingCapacityMilliampereHours: 0,
            BalanceCurrentMilliamperes: 0,
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct BmsCellVoltageData {
    pub CellCount: u8,
    pub CellVoltageMillivolts: [u16; BMS_MAX_CELL_COUNT],
}

impl BmsCellVoltageData {
    pub const fn new() -> Self {
        BmsCellVoltageData {
            CellCount: 0,
            CellVoltageMillivolts: [0; BMS_MAX_CELL_COUNT],
        }
    }
}

#[repr(C)]
pub struct BmsDiagnostics {
    pub BasicPackRequestCount: u32,
    pub CellVoltageRequestCount: u32,
    pub ReceivedFrameCount: u32,
    pub BasicPackResponseCount: u32,
    pub CellVoltageResponseCount: u32,
    pub InvalidFrameCount: u32,
    pub RejectedByteCount: u32,
    pub ReceiveResynchronizationCount: u32,
    pub PartialFrameTimeoutCount: u32,
    pub ResponseTimeoutCount: u32,
    pub TransmitTimeoutCount: u32,
    pub InvalidLengthCount: u32,
    pub InvalidEndByteCount: u32,
    pub ChecksumErrorCount: u32,
    pub UnexpectedResponseCount: u32,
    pub BmsStatusErrorCount: u32,
    pub InvalidPayloadCount: u32,
    pub UartErrorCount: u32,
    pub UartParityErrorCount: u32,
    pub UartFramingErrorCount: u32,
    pub UartNoiseErrorCount: u32,
    pub UartOverrunErrorCount: u32,
    pub LastBmsStatusCode: u8,
    pub LastUnexpectedCommand: u8,
}

impl BmsDiagnostics {
    pub const fn new() -> Self {
        BmsDiagnostics {
            BasicPackRequestCount: 0,
            CellVoltageRequestCount: 0,
            ReceivedFrameCount: 0,
            BasicPackResponseCount: 0,
            CellVoltageResponseCount: 0,
            InvalidFrameCount: 0,
            RejectedByteCount: 0,
            ReceiveResynchronizationCount: 0,
            PartialFrameTimeoutCount: 0,
            ResponseTimeoutCount: 0,
            TransmitTimeoutCount: 0,
            InvalidLengthCount: 0,
            InvalidEndByteCount: 0,
            ChecksumErrorCount: 0,
            UnexpectedResponseCount: 0,
            BmsStatusErrorCount: 0,
            InvalidPayloadCount: 0,
            UartErrorCount: 0,
            UartParityErrorCount: 0,
            UartFramingErrorCount: 0,
            UartNoiseErrorCount: 0,
            UartOverrunErrorCount: 0,
            LastBmsStatusCode: 0,
            LastUnexpectedCommand: 0,
        }
    }
}
