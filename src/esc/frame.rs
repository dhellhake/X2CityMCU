#![allow(non_snake_case)]

pub const VESC_COMMAND_FW_VERSION: u8 = 0;
pub const VESC_COMMAND_SET_CURRENT: u8 = 6;
pub const VESC_COMMAND_GET_VALUES_SELECTIVE: u8 = 50;

pub const VESC_SHORT_FRAME_START: u8 = 2;
pub const VESC_FRAME_END: u8 = 3;
pub const VESC_MAX_PAYLOAD_LENGTH: usize = 80;
pub const VESC_MAX_SHORT_FRAME_LENGTH: usize = VESC_MAX_PAYLOAD_LENGTH + 5;

pub const VESC_SELECTIVE_VALUES_MASK: u32 = (1 << 0)
    | (1 << 1)
    | (1 << 2)
    | (1 << 3)
    | (1 << 6)
    | (1 << 7)
    | (1 << 8)
    | (1 << 15)
    | (1 << 21);

pub const ESC_HARDWARE_NAME_CAPACITY: usize = 32;

#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum EscState {
    PoweredOff = 0,
    Starting = 1,
    Qualifying = 2,
    Ready = 3,
    Fault = 4,
}

#[repr(C)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct EscFirmwareInfo {
    pub Valid: bool,
    pub Compatible: bool,
    pub Major: u8,
    pub Minor: u8,
    pub HardwareNameLength: u8,
    pub HardwareName: [u8; ESC_HARDWARE_NAME_CAPACITY],
    pub TimestampUs: u64,
}

impl EscFirmwareInfo {
    pub const fn new() -> Self {
        Self {
            Valid: false,
            Compatible: false,
            Major: 0,
            Minor: 0,
            HardwareNameLength: 0,
            HardwareName: [0; ESC_HARDWARE_NAME_CAPACITY],
            TimestampUs: 0,
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct EscTelemetry {
    /// MOSFET temperature in 0.1 degree Celsius protocol units.
    pub FetTemperatureDeciCelsius: i16,
    /// Motor temperature in 0.1 degree Celsius protocol units.
    pub MotorTemperatureDeciCelsius: i16,
    /// Averaged motor current in 0.01 ampere protocol units.
    pub MotorCurrentCentiAmperes: i32,
    /// Averaged input current in 0.01 ampere protocol units.
    pub InputCurrentCentiAmperes: i32,
    /// Present duty ratio in permille.
    pub DutyPermille: i16,
    pub ElectricalRpm: i32,
    /// ESC input voltage in 0.1 volt protocol units.
    pub InputVoltageDecivolts: u16,
    pub FaultCode: u8,
    pub TimedOut: bool,
    pub KillSwitchActive: bool,
    pub Sequence: u32,
    pub TimestampUs: u64,
}

impl EscTelemetry {
    pub const fn new() -> Self {
        Self {
            FetTemperatureDeciCelsius: 0,
            MotorTemperatureDeciCelsius: 0,
            MotorCurrentCentiAmperes: 0,
            InputCurrentCentiAmperes: 0,
            DutyPermille: 0,
            ElectricalRpm: 0,
            InputVoltageDecivolts: 0,
            FaultCode: 0,
            TimedOut: false,
            KillSwitchActive: false,
            Sequence: 0,
            TimestampUs: 0,
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct EscDiagnostics {
    pub AcceptedCurrentRequestCount: u32,
    pub RejectedCurrentRequestCount: u32,
    pub ExpiredCurrentRequestCount: u32,
    pub CurrentCommandCount: u32,
    pub ZeroCurrentCommandCount: u32,
    pub CurrentCommandDeadlineMissCount: u32,
    pub FirmwareRequestCount: u32,
    pub FirmwareResponseCount: u32,
    pub UnsupportedFirmwareCount: u32,
    pub TelemetryRequestCount: u32,
    pub TelemetryResponseCount: u32,
    pub ReceivedFrameCount: u32,
    pub InvalidFrameCount: u32,
    pub InvalidLengthCount: u32,
    pub InvalidEndByteCount: u32,
    pub ChecksumErrorCount: u32,
    pub InvalidPayloadCount: u32,
    pub UnexpectedResponseCount: u32,
    pub RejectedByteCount: u32,
    pub PartialFrameTimeoutCount: u32,
    pub ResponseTimeoutCount: u32,
    pub TransmitFailureCount: u32,
    pub UartErrorCount: u32,
    pub UartParityErrorCount: u32,
    pub UartFramingErrorCount: u32,
    pub UartNoiseErrorCount: u32,
    pub UartOverrunErrorCount: u32,
    pub LastUnexpectedCommand: u8,
}

impl EscDiagnostics {
    pub const fn new() -> Self {
        Self {
            AcceptedCurrentRequestCount: 0,
            RejectedCurrentRequestCount: 0,
            ExpiredCurrentRequestCount: 0,
            CurrentCommandCount: 0,
            ZeroCurrentCommandCount: 0,
            CurrentCommandDeadlineMissCount: 0,
            FirmwareRequestCount: 0,
            FirmwareResponseCount: 0,
            UnsupportedFirmwareCount: 0,
            TelemetryRequestCount: 0,
            TelemetryResponseCount: 0,
            ReceivedFrameCount: 0,
            InvalidFrameCount: 0,
            InvalidLengthCount: 0,
            InvalidEndByteCount: 0,
            ChecksumErrorCount: 0,
            InvalidPayloadCount: 0,
            UnexpectedResponseCount: 0,
            RejectedByteCount: 0,
            PartialFrameTimeoutCount: 0,
            ResponseTimeoutCount: 0,
            TransmitFailureCount: 0,
            UartErrorCount: 0,
            UartParityErrorCount: 0,
            UartFramingErrorCount: 0,
            UartNoiseErrorCount: 0,
            UartOverrunErrorCount: 0,
            LastUnexpectedCommand: 0,
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct EscSnapshot {
    pub State: EscState,
    pub PowerOn: bool,
    pub CommunicationReady: bool,
    pub PropulsionCommandPermitted: bool,
    pub CurrentRequestFresh: bool,
    /// Immutable application ceiling. Zero means nonzero propulsion demand is
    /// deliberately disabled for this deployed component.
    pub MotorCurrentLimitMilliamperes: u32,
    pub RequestedMotorCurrentMilliamperes: i32,
    pub LastQueuedMotorCurrentMilliamperes: i32,
    pub LastQueuedCurrentTimestampUs: u64,
    pub Firmware: EscFirmwareInfo,
    pub Telemetry: EscTelemetry,
    pub Diagnostics: EscDiagnostics,
    pub LastStepTimestampUs: u64,
}

/// VESC CRC-16/CCITT with polynomial 0x1021 and initial value zero.
pub fn VescCrc16(payload: &[u8]) -> u16 {
    let mut crc = 0u16;

    for byte in payload {
        crc ^= u16::from(*byte) << 8;
        for _ in 0..8 {
            crc = if crc & 0x8000 != 0 {
                (crc << 1) ^ 0x1021
            } else {
                crc << 1
            };
        }
    }

    crc
}

/// Appends one canonical short VESC frame and returns the new write index.
/// Nothing is written when the payload or output capacity is invalid.
pub fn VescAppendShortFrame(payload: &[u8], output: &mut [u8], writeIndex: usize) -> Option<usize> {
    if payload.is_empty() || payload.len() > u8::MAX as usize {
        return None;
    }

    let frameLength = payload.len().checked_add(5)?;
    let endIndex = writeIndex.checked_add(frameLength)?;
    if endIndex > output.len() {
        return None;
    }

    let crc = VescCrc16(payload);
    output[writeIndex] = VESC_SHORT_FRAME_START;
    output[writeIndex + 1] = payload.len() as u8;
    output[writeIndex + 2..writeIndex + 2 + payload.len()].copy_from_slice(payload);
    output[writeIndex + 2 + payload.len()] = (crc >> 8) as u8;
    output[writeIndex + 3 + payload.len()] = crc as u8;
    output[writeIndex + 4 + payload.len()] = VESC_FRAME_END;
    Some(endIndex)
}
