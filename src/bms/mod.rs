#![allow(non_snake_case)]

use crate::mcu::McuManager;

mod frame;

pub use frame::{
    BmsAlarmStatusFlags, BmsBasicPackData, BmsCellVoltageData, BmsDiagnostics,
    BmsManufacturingDate, BmsMosfetStatusFlags, BmsProtectionStatusFlags, BMS_MAX_CELL_COUNT,
    BMS_MAX_TEMPERATURE_SENSOR_COUNT,
};

const JDB_START_BYTE: u8 = 0xDD;
const JDB_READ_OPERATION: u8 = 0xA5;
const JDB_END_BYTE: u8 = 0x77;
const JDB_SUCCESS_STATUS: u8 = 0x00;
const JDB_REQUEST_LENGTH: usize = 7;
const JDB_BASIC_PACK_MINIMUM_PAYLOAD_LENGTH: usize = 23;
const JDB_BASIC_PACK_EXTENSION_LENGTH: usize = 9;
const JDB_BASIC_PACK_EXTENDED_PAYLOAD_LENGTH: usize = 36;
const JDB_MAX_RESPONSE_PAYLOAD_LENGTH: usize = JDB_BASIC_PACK_EXTENDED_PAYLOAD_LENGTH;
const JDB_BASIC_PACK_REQUEST_PERIOD_US: u64 = 500_000;
const JDB_CELL_VOLTAGE_REQUEST_PERIOD_US: u64 = 1_000_000;
const JDB_PARTIAL_FRAME_TIMEOUT_US: u64 = 50_000;
const JDB_RESPONSE_TIMEOUT_US: u64 = 250_000;
const JDB_TRANSMIT_TIMEOUT_US: u64 = 100_000;
const JDB_MAX_RECEIVE_BYTES_PER_STEP: usize = 32;

#[repr(u8)]
#[derive(Copy, Clone, PartialEq, Eq)]
enum JdbReadCommand {
    None = 0,
    BasicPack = 0x03,
    CellVoltages = 0x04,
}

impl JdbReadCommand {
    const fn FromByte(byte: u8) -> Self {
        match byte {
            0x03 => JdbReadCommand::BasicPack,
            0x04 => JdbReadCommand::CellVoltages,
            _ => JdbReadCommand::None,
        }
    }
}

#[repr(u8)]
#[derive(Copy, Clone, PartialEq, Eq)]
enum JdbReceiveState {
    WaitingForStart,
    Command,
    Status,
    Length,
    Payload,
    ChecksumHigh,
    ChecksumLow,
    End,
}

#[repr(C)]
pub struct BmsInterface {
    _receiveState: JdbReceiveState,
    _receiveCommand: u8,
    _receiveStatus: u8,
    _receiveLength: usize,
    _receiveIndex: usize,
    _receivePayload: [u8; JDB_MAX_RESPONSE_PAYLOAD_LENGTH],
    _receiveChecksumAccumulator: u16,
    _receivedChecksum: u16,
    _lastReceiveByteTimestampUs: u64,
    _responseReady: bool,
    _responseTimestampUs: u64,
    _transmitBuffer: [u8; JDB_REQUEST_LENGTH],
    _transmitIndex: usize,
    _transmitRequest: JdbReadCommand,
    _transmitStartTimestampUs: u64,
    _pendingRequest: JdbReadCommand,
    _pendingRequestTimestampUs: u64,
    _requestSchedulingStarted: bool,
    _nextBasicPackRequestTimestampUs: u64,
    _nextCellVoltageRequestTimestampUs: u64,
    pub LatestBasicPackData: BmsBasicPackData,
    pub LatestCellVoltageData: BmsCellVoltageData,
    pub LatestBasicPackDataTimestampUs: u64,
    pub LatestCellVoltageDataTimestampUs: u64,
    pub NewBasicPackDataAvailable: bool,
    pub NewCellVoltageDataAvailable: bool,
    pub Diagnostics: BmsDiagnostics,
    pub LastStepTimestampUs: u64,
}

impl BmsInterface {
    pub const fn new() -> Self {
        BmsInterface {
            _receiveState: JdbReceiveState::WaitingForStart,
            _receiveCommand: 0,
            _receiveStatus: 0,
            _receiveLength: 0,
            _receiveIndex: 0,
            _receivePayload: [0; JDB_MAX_RESPONSE_PAYLOAD_LENGTH],
            _receiveChecksumAccumulator: 0,
            _receivedChecksum: 0,
            _lastReceiveByteTimestampUs: 0,
            _responseReady: false,
            _responseTimestampUs: 0,
            _transmitBuffer: [0; JDB_REQUEST_LENGTH],
            _transmitIndex: 0,
            _transmitRequest: JdbReadCommand::None,
            _transmitStartTimestampUs: 0,
            _pendingRequest: JdbReadCommand::None,
            _pendingRequestTimestampUs: 0,
            _requestSchedulingStarted: false,
            _nextBasicPackRequestTimestampUs: 0,
            _nextCellVoltageRequestTimestampUs: 0,
            LatestBasicPackData: BmsBasicPackData::new(),
            LatestCellVoltageData: BmsCellVoltageData::new(),
            LatestBasicPackDataTimestampUs: 0,
            LatestCellVoltageDataTimestampUs: 0,
            NewBasicPackDataAvailable: false,
            NewCellVoltageDataAvailable: false,
            Diagnostics: BmsDiagnostics::new(),
            LastStepTimestampUs: 0,
        }
    }

    pub fn BmsInterface_Step(&mut self, tstmp: u64) {
        self.LastStepTimestampUs = tstmp;
        if self._responseReady {
            self._responseReady = false;
            self.BmsInterface_HandleResponse(self._responseTimestampUs);
        }
        self.BmsInterface_ProcessReceive(tstmp);
        self.BmsInterface_ProcessTimeouts(tstmp);
        self.BmsInterface_ScheduleRequest(tstmp);
        self.BmsInterface_ProcessTransmission(tstmp);
    }

    pub fn BmsInterface_ReceiveByte(&mut self, byte: u8, timestampUs: u64) {
        self._lastReceiveByteTimestampUs = timestampUs;

        match self._receiveState {
            JdbReceiveState::WaitingForStart => {
                if byte == JDB_START_BYTE {
                    self._receiveState = JdbReceiveState::Command;
                } else {
                    self.Diagnostics.RejectedByteCount =
                        self.Diagnostics.RejectedByteCount.saturating_add(1);
                }
            }
            JdbReceiveState::Command => {
                if byte == JDB_START_BYTE {
                    self.Diagnostics.ReceiveResynchronizationCount = self
                        .Diagnostics
                        .ReceiveResynchronizationCount
                        .saturating_add(1);
                    return;
                }

                self._receiveCommand = byte;
                // JDB response checksums start at the status byte. The command
                // is included only in host request checksums.
                self._receiveChecksumAccumulator = 0;
                self._receiveState = JdbReceiveState::Status;
            }
            JdbReceiveState::Status => {
                self._receiveStatus = byte;
                self._receiveChecksumAccumulator = self
                    ._receiveChecksumAccumulator
                    .wrapping_add(u16::from(byte));
                self._receiveState = JdbReceiveState::Length;
            }
            JdbReceiveState::Length => {
                self._receiveLength = usize::from(byte);
                self._receiveChecksumAccumulator = self
                    ._receiveChecksumAccumulator
                    .wrapping_add(u16::from(byte));

                if self._receiveLength > JDB_MAX_RESPONSE_PAYLOAD_LENGTH {
                    self.Diagnostics.InvalidFrameCount =
                        self.Diagnostics.InvalidFrameCount.saturating_add(1);
                    self.Diagnostics.InvalidLengthCount =
                        self.Diagnostics.InvalidLengthCount.saturating_add(1);
                    self.BmsInterface_ResetReceiveAndUsePossibleStart(byte);
                } else if self._receiveLength == 0 {
                    self._receiveState = JdbReceiveState::ChecksumHigh;
                } else {
                    self._receiveIndex = 0;
                    self._receiveState = JdbReceiveState::Payload;
                }
            }
            JdbReceiveState::Payload => {
                self._receivePayload[self._receiveIndex] = byte;
                self._receiveIndex += 1;
                self._receiveChecksumAccumulator = self
                    ._receiveChecksumAccumulator
                    .wrapping_add(u16::from(byte));

                if self._receiveIndex == self._receiveLength {
                    self._receiveState = JdbReceiveState::ChecksumHigh;
                }
            }
            JdbReceiveState::ChecksumHigh => {
                self._receivedChecksum = u16::from(byte) << 8;
                self._receiveState = JdbReceiveState::ChecksumLow;
            }
            JdbReceiveState::ChecksumLow => {
                self._receivedChecksum |= u16::from(byte);
                self._receiveState = JdbReceiveState::End;
            }
            JdbReceiveState::End => {
                if byte != JDB_END_BYTE {
                    self.Diagnostics.InvalidFrameCount =
                        self.Diagnostics.InvalidFrameCount.saturating_add(1);
                    self.Diagnostics.InvalidEndByteCount =
                        self.Diagnostics.InvalidEndByteCount.saturating_add(1);
                    self.BmsInterface_ResetReceiveAndUsePossibleStart(byte);
                    return;
                }

                let expectedChecksum = 0u16.wrapping_sub(self._receiveChecksumAccumulator);
                if self._receivedChecksum != expectedChecksum {
                    self.Diagnostics.InvalidFrameCount =
                        self.Diagnostics.InvalidFrameCount.saturating_add(1);
                    self.Diagnostics.ChecksumErrorCount =
                        self.Diagnostics.ChecksumErrorCount.saturating_add(1);
                } else {
                    self._responseReady = true;
                    self._responseTimestampUs = timestampUs;
                }

                self.BmsInterface_ResetReceive();
            }
        }
    }

    pub fn BmsInterface_TakeLatestBasicPackData(&mut self) -> Option<BmsBasicPackData> {
        if !self.NewBasicPackDataAvailable {
            return None;
        }

        self.NewBasicPackDataAvailable = false;
        Some(self.LatestBasicPackData)
    }

    pub fn BmsInterface_TakeLatestCellVoltageData(&mut self) -> Option<BmsCellVoltageData> {
        if !self.NewCellVoltageDataAvailable {
            return None;
        }

        self.NewCellVoltageDataAvailable = false;
        Some(self.LatestCellVoltageData)
    }

    fn BmsInterface_ProcessReceive(&mut self, tstmp: u64) {
        for _ in 0..JDB_MAX_RECEIVE_BYTES_PER_STEP {
            let readResult = McuManager::BmsCommunication_TryReadByteWithErrors();

            if readResult.HasError() {
                self.Diagnostics.UartErrorCount = self.Diagnostics.UartErrorCount.saturating_add(1);
                if readResult.Errors.parityError {
                    self.Diagnostics.UartParityErrorCount =
                        self.Diagnostics.UartParityErrorCount.saturating_add(1);
                }
                if readResult.Errors.framingError {
                    self.Diagnostics.UartFramingErrorCount =
                        self.Diagnostics.UartFramingErrorCount.saturating_add(1);
                }
                if readResult.Errors.noiseDetected {
                    self.Diagnostics.UartNoiseErrorCount =
                        self.Diagnostics.UartNoiseErrorCount.saturating_add(1);
                }
                if readResult.Errors.overrunError {
                    self.Diagnostics.UartOverrunErrorCount =
                        self.Diagnostics.UartOverrunErrorCount.saturating_add(1);
                }
                if readResult.Byte.is_some() {
                    self.Diagnostics.RejectedByteCount =
                        self.Diagnostics.RejectedByteCount.saturating_add(1);
                }
                self.BmsInterface_ResetReceive();
                continue;
            }

            let Some(byte) = readResult.Byte else {
                break;
            };
            self.BmsInterface_ReceiveByte(byte, tstmp);
            if self._responseReady {
                break;
            }
        }
    }

    fn BmsInterface_ProcessTimeouts(&mut self, tstmp: u64) {
        if self._receiveState != JdbReceiveState::WaitingForStart
            && tstmp.saturating_sub(self._lastReceiveByteTimestampUs) > JDB_PARTIAL_FRAME_TIMEOUT_US
        {
            self.BmsInterface_ResetReceive();
            self.Diagnostics.InvalidFrameCount =
                self.Diagnostics.InvalidFrameCount.saturating_add(1);
            self.Diagnostics.PartialFrameTimeoutCount =
                self.Diagnostics.PartialFrameTimeoutCount.saturating_add(1);
        }

        if !self._responseReady
            && self._pendingRequest != JdbReadCommand::None
            && tstmp.saturating_sub(self._pendingRequestTimestampUs) > JDB_RESPONSE_TIMEOUT_US
        {
            self._pendingRequest = JdbReadCommand::None;
            self.BmsInterface_ResetReceive();
            self.Diagnostics.ResponseTimeoutCount =
                self.Diagnostics.ResponseTimeoutCount.saturating_add(1);
        }

        if self._transmitRequest != JdbReadCommand::None
            && tstmp.saturating_sub(self._transmitStartTimestampUs) > JDB_TRANSMIT_TIMEOUT_US
        {
            self._transmitRequest = JdbReadCommand::None;
            self._transmitIndex = 0;
            self.Diagnostics.TransmitTimeoutCount =
                self.Diagnostics.TransmitTimeoutCount.saturating_add(1);
        }
    }

    fn BmsInterface_ScheduleRequest(&mut self, tstmp: u64) {
        if !self._requestSchedulingStarted {
            self._requestSchedulingStarted = true;
            self._nextBasicPackRequestTimestampUs = tstmp;
            self._nextCellVoltageRequestTimestampUs = tstmp;
        }

        if self._responseReady
            || self._transmitRequest != JdbReadCommand::None
            || self._pendingRequest != JdbReadCommand::None
            || self._receiveState != JdbReceiveState::WaitingForStart
        {
            return;
        }

        let request = if tstmp >= self._nextBasicPackRequestTimestampUs
            && (tstmp < self._nextCellVoltageRequestTimestampUs
                || self._nextBasicPackRequestTimestampUs <= self._nextCellVoltageRequestTimestampUs)
        {
            JdbReadCommand::BasicPack
        } else if tstmp >= self._nextCellVoltageRequestTimestampUs {
            JdbReadCommand::CellVoltages
        } else {
            JdbReadCommand::None
        };

        match request {
            JdbReadCommand::BasicPack => {
                self._nextBasicPackRequestTimestampUs = Self::BmsInterface_AdvanceDeadline(
                    self._nextBasicPackRequestTimestampUs,
                    tstmp,
                    JDB_BASIC_PACK_REQUEST_PERIOD_US,
                );
            }
            JdbReadCommand::CellVoltages => {
                self._nextCellVoltageRequestTimestampUs = Self::BmsInterface_AdvanceDeadline(
                    self._nextCellVoltageRequestTimestampUs,
                    tstmp,
                    JDB_CELL_VOLTAGE_REQUEST_PERIOD_US,
                );
            }
            JdbReadCommand::None => return,
        }

        self.BmsInterface_StartRequest(request, tstmp);
    }

    fn BmsInterface_StartRequest(&mut self, request: JdbReadCommand, tstmp: u64) {
        let command = request as u8;
        let checksum = 0u16.wrapping_sub(u16::from(command));
        let checksumBytes = checksum.to_be_bytes();

        self._transmitBuffer = [
            JDB_START_BYTE,
            JDB_READ_OPERATION,
            command,
            0,
            checksumBytes[0],
            checksumBytes[1],
            JDB_END_BYTE,
        ];
        self._transmitIndex = 0;
        self._transmitRequest = request;
        self._transmitStartTimestampUs = tstmp;
    }

    fn BmsInterface_ProcessTransmission(&mut self, tstmp: u64) {
        while self._transmitRequest != JdbReadCommand::None
            && self._transmitIndex < JDB_REQUEST_LENGTH
        {
            if !McuManager::BmsCommunication_TryWriteByte(self._transmitBuffer[self._transmitIndex])
            {
                break;
            }
            self._transmitIndex += 1;
        }

        if self._transmitRequest != JdbReadCommand::None
            && self._transmitIndex == JDB_REQUEST_LENGTH
        {
            self._pendingRequest = self._transmitRequest;
            self._pendingRequestTimestampUs = tstmp;

            match self._transmitRequest {
                JdbReadCommand::BasicPack => {
                    self.Diagnostics.BasicPackRequestCount =
                        self.Diagnostics.BasicPackRequestCount.saturating_add(1);
                }
                JdbReadCommand::CellVoltages => {
                    self.Diagnostics.CellVoltageRequestCount =
                        self.Diagnostics.CellVoltageRequestCount.saturating_add(1);
                }
                JdbReadCommand::None => {}
            }

            self._transmitRequest = JdbReadCommand::None;
            self._transmitIndex = 0;
        }
    }

    fn BmsInterface_HandleResponse(&mut self, timestampUs: u64) {
        self.Diagnostics.ReceivedFrameCount = self.Diagnostics.ReceivedFrameCount.saturating_add(1);

        let response = JdbReadCommand::FromByte(self._receiveCommand);
        if response == JdbReadCommand::None || response != self._pendingRequest {
            self.Diagnostics.UnexpectedResponseCount =
                self.Diagnostics.UnexpectedResponseCount.saturating_add(1);
            self.Diagnostics.LastUnexpectedCommand = self._receiveCommand;
            return;
        }

        self._pendingRequest = JdbReadCommand::None;

        if self._receiveStatus != JDB_SUCCESS_STATUS {
            self.Diagnostics.BmsStatusErrorCount =
                self.Diagnostics.BmsStatusErrorCount.saturating_add(1);
            self.Diagnostics.LastBmsStatusCode = self._receiveStatus;
            return;
        }

        let payloadValid = match response {
            JdbReadCommand::BasicPack => self.BmsInterface_DecodeBasicPackData(timestampUs),
            JdbReadCommand::CellVoltages => self.BmsInterface_DecodeCellVoltageData(timestampUs),
            JdbReadCommand::None => false,
        };

        if !payloadValid {
            self.Diagnostics.InvalidFrameCount =
                self.Diagnostics.InvalidFrameCount.saturating_add(1);
            self.Diagnostics.InvalidPayloadCount =
                self.Diagnostics.InvalidPayloadCount.saturating_add(1);
        }
    }

    fn BmsInterface_DecodeBasicPackData(&mut self, timestampUs: u64) -> bool {
        if self._receiveLength < JDB_BASIC_PACK_MINIMUM_PAYLOAD_LENGTH {
            return false;
        }

        let cellCount = usize::from(self._receivePayload[21]);
        let temperatureSensorCount = usize::from(self._receivePayload[22]);
        let requiredLength = JDB_BASIC_PACK_MINIMUM_PAYLOAD_LENGTH
            .saturating_add(temperatureSensorCount.saturating_mul(2));
        let hasExtendedData =
            self._receiveLength == requiredLength.saturating_add(JDB_BASIC_PACK_EXTENSION_LENGTH);

        if cellCount == 0
            || cellCount > BMS_MAX_CELL_COUNT
            || temperatureSensorCount > BMS_MAX_TEMPERATURE_SENSOR_COUNT
            || (self._receiveLength != requiredLength && !hasExtendedData)
            || self._receivePayload[19] > 100
        {
            return false;
        }

        let date = Self::BmsInterface_ReadU16(&self._receivePayload, 10);
        let balanceLow = Self::BmsInterface_ReadU16(&self._receivePayload, 12);
        let balanceHigh = Self::BmsInterface_ReadU16(&self._receivePayload, 14);
        let mosfetStatus = BmsMosfetStatusFlags::FromBits(self._receivePayload[20]);
        let currentAndCapacityMultiplier =
            if mosfetStatus.Contains(BmsMosfetStatusFlags::HighRangeCurrentAndCapacityUnits) {
                100
            } else {
                10
            };
        let mut temperatures = [0i32; BMS_MAX_TEMPERATURE_SENSOR_COUNT];
        let mut temperatureIndex = 0;
        while temperatureIndex < temperatureSensorCount {
            let rawTemperature = Self::BmsInterface_ReadU16(
                &self._receivePayload,
                JDB_BASIC_PACK_MINIMUM_PAYLOAD_LENGTH + (temperatureIndex * 2),
            );
            temperatures[temperatureIndex] = i32::from(rawTemperature) - 2731;
            temperatureIndex += 1;
        }

        let mut humidityPercent = 0;
        let mut alarmStatus = BmsAlarmStatusFlags::None;
        let mut fullChargeCapacityMilliampereHours = 0;
        let mut extendedRemainingCapacityMilliampereHours = 0;
        let mut balanceCurrentMilliamperes = 0;
        if hasExtendedData {
            let extensionIndex = requiredLength;
            humidityPercent = self._receivePayload[extensionIndex];
            if humidityPercent > 100 {
                return false;
            }
            alarmStatus = BmsAlarmStatusFlags::FromBits(Self::BmsInterface_ReadU16(
                &self._receivePayload,
                extensionIndex + 1,
            ));
            fullChargeCapacityMilliampereHours = u32::from(Self::BmsInterface_ReadU16(
                &self._receivePayload,
                extensionIndex + 3,
            )) * currentAndCapacityMultiplier;
            extendedRemainingCapacityMilliampereHours = u32::from(Self::BmsInterface_ReadU16(
                &self._receivePayload,
                extensionIndex + 5,
            )) * currentAndCapacityMultiplier;
            balanceCurrentMilliamperes = i32::from(Self::BmsInterface_ReadI16(
                &self._receivePayload,
                extensionIndex + 7,
            ));
        }

        self.LatestBasicPackData = BmsBasicPackData {
            PackVoltageMillivolts: u32::from(Self::BmsInterface_ReadU16(&self._receivePayload, 0))
                * 10,
            PackCurrentMilliamperes: i32::from(Self::BmsInterface_ReadI16(
                &self._receivePayload,
                2,
            )) * currentAndCapacityMultiplier as i32,
            RemainingCapacityMilliampereHours: u32::from(Self::BmsInterface_ReadU16(
                &self._receivePayload,
                4,
            )) * currentAndCapacityMultiplier,
            NominalCapacityMilliampereHours: u32::from(Self::BmsInterface_ReadU16(
                &self._receivePayload,
                6,
            )) * currentAndCapacityMultiplier,
            CycleCount: Self::BmsInterface_ReadU16(&self._receivePayload, 8),
            ManufacturingDate: BmsManufacturingDate {
                Year: 2000 + (date >> 9),
                Month: ((date >> 5) & 0x0F) as u8,
                Day: (date & 0x1F) as u8,
            },
            BalancingCellMask: u32::from(balanceLow) | (u32::from(balanceHigh) << 16),
            ProtectionStatus: BmsProtectionStatusFlags::FromBits(Self::BmsInterface_ReadU16(
                &self._receivePayload,
                16,
            )),
            SoftwareVersionTenths: self._receivePayload[18],
            StateOfChargePercent: self._receivePayload[19],
            MosfetStatus: mosfetStatus,
            CellCount: cellCount as u8,
            TemperatureSensorCount: temperatureSensorCount as u8,
            TemperaturesDeciDegreesCelsius: temperatures,
            HasExtendedData: hasExtendedData,
            HumidityPercent: humidityPercent,
            AlarmStatus: alarmStatus,
            FullChargeCapacityMilliampereHours: fullChargeCapacityMilliampereHours,
            ExtendedRemainingCapacityMilliampereHours: extendedRemainingCapacityMilliampereHours,
            BalanceCurrentMilliamperes: balanceCurrentMilliamperes,
        };
        self.LatestBasicPackDataTimestampUs = timestampUs;
        self.NewBasicPackDataAvailable = true;
        self.Diagnostics.BasicPackResponseCount =
            self.Diagnostics.BasicPackResponseCount.saturating_add(1);
        true
    }

    fn BmsInterface_DecodeCellVoltageData(&mut self, timestampUs: u64) -> bool {
        if self._receiveLength == 0 || (self._receiveLength & 1) != 0 {
            return false;
        }

        let cellCount = self._receiveLength / 2;
        if cellCount > BMS_MAX_CELL_COUNT
            || (self.LatestBasicPackData.CellCount != 0
                && usize::from(self.LatestBasicPackData.CellCount) != cellCount)
        {
            return false;
        }

        let mut cellVoltages = [0u16; BMS_MAX_CELL_COUNT];
        let mut cellIndex = 0;
        while cellIndex < cellCount {
            cellVoltages[cellIndex] =
                Self::BmsInterface_ReadU16(&self._receivePayload, cellIndex * 2);
            cellIndex += 1;
        }

        self.LatestCellVoltageData = BmsCellVoltageData {
            CellCount: cellCount as u8,
            CellVoltageMillivolts: cellVoltages,
        };
        self.LatestCellVoltageDataTimestampUs = timestampUs;
        self.NewCellVoltageDataAvailable = true;
        self.Diagnostics.CellVoltageResponseCount =
            self.Diagnostics.CellVoltageResponseCount.saturating_add(1);
        true
    }

    fn BmsInterface_ResetReceive(&mut self) {
        self._receiveState = JdbReceiveState::WaitingForStart;
        self._receiveIndex = 0;
        self._receiveChecksumAccumulator = 0;
        self._receivedChecksum = 0;
    }

    fn BmsInterface_ResetReceiveAndUsePossibleStart(&mut self, byte: u8) {
        self.BmsInterface_ResetReceive();
        if byte == JDB_START_BYTE {
            self._receiveState = JdbReceiveState::Command;
            self.Diagnostics.ReceiveResynchronizationCount = self
                .Diagnostics
                .ReceiveResynchronizationCount
                .saturating_add(1);
        }
    }

    #[inline]
    fn BmsInterface_ReadU16(payload: &[u8], index: usize) -> u16 {
        u16::from_be_bytes([payload[index], payload[index + 1]])
    }

    #[inline]
    fn BmsInterface_ReadI16(payload: &[u8], index: usize) -> i16 {
        i16::from_be_bytes([payload[index], payload[index + 1]])
    }

    fn BmsInterface_AdvanceDeadline(deadline: u64, now: u64, period: u64) -> u64 {
        let elapsedPeriods = now.saturating_sub(deadline) / period;
        deadline.saturating_add(elapsedPeriods.saturating_add(1).saturating_mul(period))
    }
}
