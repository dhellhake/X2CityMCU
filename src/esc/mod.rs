#![allow(non_snake_case)]

use crate::{drv::cortex::Shared, mcu::McuManager};

mod frame;

pub use frame::{
    EscDiagnostics, EscFirmwareInfo, EscSnapshot, EscState, EscTelemetry, VescAppendShortFrame,
    VescCrc16, ESC_HARDWARE_NAME_CAPACITY, VESC_SELECTIVE_VALUES_MASK,
};

use frame::{
    VESC_COMMAND_FW_VERSION, VESC_COMMAND_GET_VALUES_SELECTIVE, VESC_COMMAND_SET_CURRENT,
    VESC_FRAME_END, VESC_MAX_PAYLOAD_LENGTH, VESC_SHORT_FRAME_START,
};

const ESC_SUPPORTED_FIRMWARE_MAJOR: u8 = 6;
const ESC_SUPPORTED_FIRMWARE_MINOR: u8 = 2;
const ESC_SUPPORTED_HARDWARE_NAME: &[u8] = b"75_300_R2";
// The vehicle-level current limit has not been selected yet. Keep the deployed
// component incapable of accepting nonzero propulsion demand until that
// application decision is made explicitly.
const ESC_CONFIGURED_MOTOR_CURRENT_LIMIT_MILLIAMPERES: u32 = 0;
const ESC_CURRENT_REQUEST_LEASE_US: u64 = 5_000;
const ESC_TELEMETRY_PERIOD_US: u64 = 10_000;
const ESC_FIRMWARE_REQUEST_PERIOD_US: u64 = 100_000;
const ESC_RESPONSE_TIMEOUT_US: u64 = 20_000;
const ESC_PARTIAL_FRAME_TIMEOUT_US: u64 = 5_000;
const ESC_TELEMETRY_STALE_AFTER_US: u64 = 30_000;
const ESC_RUN_STALE_AFTER_US: u64 = 2_000;
const ESC_MAX_RECEIVE_BYTES_PER_STEP: usize = 128;
const ESC_TRANSMIT_BATCH_CAPACITY: usize = 32;
const ESC_SELECTIVE_RESPONSE_PAYLOAD_LENGTH: usize = 27;

const _: () = {
    // One current frame plus either supported request fits one atomic batch.
    assert!(ESC_TRANSMIT_BATCH_CAPACITY >= 20);
    assert!(ESC_SELECTIVE_RESPONSE_PAYLOAD_LENGTH <= VESC_MAX_PAYLOAD_LENGTH);
    assert!(ESC_SUPPORTED_HARDWARE_NAME.len() <= ESC_HARDWARE_NAME_CAPACITY);
};

#[repr(u8)]
#[derive(Copy, Clone, PartialEq, Eq)]
enum EscReceiveState {
    WaitingForStart,
    Length,
    Payload,
    CrcHigh,
    CrcLow,
    End,
}

#[repr(u8)]
#[derive(Copy, Clone, PartialEq, Eq)]
enum EscPendingRequest {
    None,
    Firmware,
    Telemetry,
}

#[repr(C)]
pub struct EscInterface {
    _receiveState: EscReceiveState,
    _receiveLength: usize,
    _receiveIndex: usize,
    _receivePayload: [u8; VESC_MAX_PAYLOAD_LENGTH],
    _receivedCrc: u16,
    _lastReceiveByteTimestampUs: u64,
    _pendingRequest: EscPendingRequest,
    _pendingRequestTimestampUs: u64,
    _nextFirmwareRequestTimestampUs: u64,
    _nextTelemetryRequestTimestampUs: u64,
    _currentRequestValid: bool,
    _currentRequestTimestampUs: u64,
    _firmwareReceived: bool,
    _firmwareCompatible: bool,
    _telemetryReceived: bool,
    _transportFault: bool,
    _everReady: bool,
    _motorCurrentLimitMilliamperes: u32,
    pub State: EscState,
    pub PowerOn: bool,
    pub RequestedMotorCurrentMilliamperes: i32,
    pub LastQueuedMotorCurrentMilliamperes: i32,
    pub LastQueuedCurrentTimestampUs: u64,
    pub Firmware: EscFirmwareInfo,
    pub Telemetry: EscTelemetry,
    pub Diagnostics: EscDiagnostics,
    pub LastStepTimestampUs: u64,
}

/// Single debugger-visible application instance.
#[unsafe(no_mangle)]
static ESC: Shared<EscInterface> = Shared::new(EscInterface::newWithMotorCurrentLimit(
    ESC_CONFIGURED_MOTOR_CURRENT_LIMIT_MILLIAMPERES,
));

#[inline]
pub fn EscInterface_Run(tstmp: u64) {
    ESC.with(|interface| interface.EscInterface_Step(tstmp));
}

/// Publishes a non-negative propulsion-current request with a fixed 5 ms
/// lease. This lets a 200 Hz producer publish after the simultaneous 1 ms ESC
/// release: the previous request remains valid through the next simultaneous
/// release and becomes invalid on the following 1 ms release if not renewed.
/// The ESC runnable sends zero when the request is absent, stale, or
/// communication has not been qualified. Braking is deliberately outside
/// this API and must later use a separately modelled command.
pub fn EscInterface_RequestMotorCurrent(tstmp: u64, currentMilliamperes: u32) -> bool {
    ESC.with(|interface| interface.EscInterface_RequestMotorCurrent(tstmp, currentMilliamperes))
}

pub fn EscInterface_ClearMotorCurrentRequest() {
    ESC.with(EscInterface::EscInterface_ClearMotorCurrentRequest);
}

pub fn EscInterface_SetPowerOn(powerOn: bool) {
    ESC.with(|interface| interface.EscInterface_SetPowerOn(powerOn));
}

pub fn EscInterface_GetSnapshot(tstmp: u64) -> EscSnapshot {
    ESC.with(|interface| interface.EscInterface_GetSnapshot(tstmp))
}

impl EscInterface {
    pub const fn new() -> Self {
        Self::newWithMotorCurrentLimit(0)
    }

    /// Creates an interface with an immutable application current ceiling.
    /// Production deployment deliberately uses zero until the vehicle-level
    /// propulsion limit has been selected and qualified.
    pub const fn newWithMotorCurrentLimit(motorCurrentLimitMilliamperes: u32) -> Self {
        assert!(motorCurrentLimitMilliamperes <= i32::MAX as u32);

        Self {
            _receiveState: EscReceiveState::WaitingForStart,
            _receiveLength: 0,
            _receiveIndex: 0,
            _receivePayload: [0; VESC_MAX_PAYLOAD_LENGTH],
            _receivedCrc: 0,
            _lastReceiveByteTimestampUs: 0,
            _pendingRequest: EscPendingRequest::None,
            _pendingRequestTimestampUs: 0,
            _nextFirmwareRequestTimestampUs: 0,
            _nextTelemetryRequestTimestampUs: 0,
            _currentRequestValid: false,
            _currentRequestTimestampUs: 0,
            _firmwareReceived: false,
            _firmwareCompatible: false,
            _telemetryReceived: false,
            _transportFault: false,
            _everReady: false,
            _motorCurrentLimitMilliamperes: motorCurrentLimitMilliamperes,
            State: EscState::Starting,
            PowerOn: true,
            RequestedMotorCurrentMilliamperes: 0,
            LastQueuedMotorCurrentMilliamperes: 0,
            LastQueuedCurrentTimestampUs: 0,
            Firmware: EscFirmwareInfo::new(),
            Telemetry: EscTelemetry::new(),
            Diagnostics: EscDiagnostics::new(),
            LastStepTimestampUs: 0,
        }
    }

    pub fn EscInterface_Step(&mut self, tstmp: u64) {
        self.LastStepTimestampUs = tstmp;

        if !self.PowerOn {
            self.State = EscState::PoweredOff;
            return;
        }

        self.EscInterface_ProcessReceive(tstmp);
        self.EscInterface_ProcessTimeouts(tstmp);
        self.EscInterface_ExpireCurrentRequest(tstmp);
        self.EscInterface_UpdateState(tstmp);

        let currentMilliamperes = if self.State == EscState::Ready && self._currentRequestValid {
            self.RequestedMotorCurrentMilliamperes
        } else {
            0
        };

        let request = self.EscInterface_SelectRequest(tstmp);
        let mut transmitBatch = [0u8; ESC_TRANSMIT_BATCH_CAPACITY];
        let Some(mut transmitLength) =
            Self::EscInterface_AppendCurrentFrame(currentMilliamperes, &mut transmitBatch, 0)
        else {
            self.EscInterface_RecordTransmitFailure(tstmp);
            return;
        };

        if request != EscPendingRequest::None {
            let Some(newLength) =
                Self::EscInterface_AppendRequestFrame(request, &mut transmitBatch, transmitLength)
            else {
                self.EscInterface_RecordTransmitFailure(tstmp);
                return;
            };
            transmitLength = newLength;
        }

        if !McuManager::EscCommunication_TryWriteFrame(&transmitBatch[..transmitLength]) {
            self.EscInterface_RecordTransmitFailure(tstmp);
            return;
        }

        self.LastQueuedMotorCurrentMilliamperes = currentMilliamperes;
        self.LastQueuedCurrentTimestampUs = tstmp;
        self.Diagnostics.CurrentCommandCount =
            self.Diagnostics.CurrentCommandCount.saturating_add(1);
        if currentMilliamperes == 0 {
            self.Diagnostics.ZeroCurrentCommandCount =
                self.Diagnostics.ZeroCurrentCommandCount.saturating_add(1);
        }

        self.EscInterface_CommitRequest(request, tstmp);
    }

    pub fn EscInterface_RequestMotorCurrent(
        &mut self,
        tstmp: u64,
        currentMilliamperes: u32,
    ) -> bool {
        if !self.PowerOn
            || tstmp < self.LastStepTimestampUs
            || currentMilliamperes > self._motorCurrentLimitMilliamperes
            || !self.EscInterface_IsCommunicationQualifiedAt(tstmp)
        {
            self.Diagnostics.RejectedCurrentRequestCount = self
                .Diagnostics
                .RejectedCurrentRequestCount
                .saturating_add(1);
            return false;
        }

        self.RequestedMotorCurrentMilliamperes = currentMilliamperes as i32;
        self._currentRequestTimestampUs = tstmp;
        self._currentRequestValid = true;
        self.Diagnostics.AcceptedCurrentRequestCount = self
            .Diagnostics
            .AcceptedCurrentRequestCount
            .saturating_add(1);
        true
    }

    pub fn EscInterface_ClearMotorCurrentRequest(&mut self) {
        self._currentRequestValid = false;
        self.RequestedMotorCurrentMilliamperes = 0;
    }

    pub fn EscInterface_SetPowerOn(&mut self, powerOn: bool) {
        if self.PowerOn == powerOn {
            return;
        }

        // Clear demand before changing the hardware power state. PWR_ON is a
        // lifecycle control, not the immediate torque-removal mechanism.
        self.EscInterface_ClearMotorCurrentRequest();
        McuManager::EscCommunication_ResetTransport();
        McuManager::EscCommunication_SetPowerOn(powerOn);
        self.PowerOn = powerOn;
        self.EscInterface_ResetCommunicationSession();
        self.State = if powerOn {
            EscState::Starting
        } else {
            EscState::PoweredOff
        };
    }

    pub fn EscInterface_GetSnapshot(&self, tstmp: u64) -> EscSnapshot {
        let runFresh = self.LastStepTimestampUs != 0
            && tstmp >= self.LastStepTimestampUs
            && tstmp - self.LastStepTimestampUs <= ESC_RUN_STALE_AFTER_US;
        let telemetryFresh = self._telemetryReceived
            && tstmp >= self.Telemetry.TimestampUs
            && tstmp - self.Telemetry.TimestampUs <= ESC_TELEMETRY_STALE_AFTER_US;
        let requestFresh = self._currentRequestValid
            && tstmp >= self._currentRequestTimestampUs
            && tstmp - self._currentRequestTimestampUs <= ESC_CURRENT_REQUEST_LEASE_US;
        let communicationReady = runFresh
            && telemetryFresh
            && self.State == EscState::Ready
            && self._firmwareCompatible
            && !self._transportFault;

        EscSnapshot {
            State: if self.PowerOn && !runFresh {
                EscState::Fault
            } else {
                self.State
            },
            PowerOn: self.PowerOn,
            CommunicationReady: communicationReady,
            PropulsionCommandPermitted: communicationReady
                && requestFresh
                && self.Telemetry.FaultCode == 0
                && !self.Telemetry.TimedOut
                && !self.Telemetry.KillSwitchActive,
            CurrentRequestFresh: requestFresh,
            MotorCurrentLimitMilliamperes: self._motorCurrentLimitMilliamperes,
            RequestedMotorCurrentMilliamperes: if requestFresh {
                self.RequestedMotorCurrentMilliamperes
            } else {
                0
            },
            LastQueuedMotorCurrentMilliamperes: self.LastQueuedMotorCurrentMilliamperes,
            LastQueuedCurrentTimestampUs: self.LastQueuedCurrentTimestampUs,
            Firmware: self.Firmware,
            Telemetry: self.Telemetry,
            Diagnostics: self.Diagnostics,
            LastStepTimestampUs: self.LastStepTimestampUs,
        }
    }

    pub fn EscInterface_ReceiveByte(&mut self, byte: u8, timestampUs: u64) {
        self._lastReceiveByteTimestampUs = timestampUs;

        match self._receiveState {
            EscReceiveState::WaitingForStart => {
                if byte == VESC_SHORT_FRAME_START {
                    self._receiveState = EscReceiveState::Length;
                } else {
                    self.Diagnostics.RejectedByteCount =
                        self.Diagnostics.RejectedByteCount.saturating_add(1);
                }
            }
            EscReceiveState::Length => {
                let length = usize::from(byte);
                if length == 0 || length > VESC_MAX_PAYLOAD_LENGTH {
                    self.Diagnostics.InvalidFrameCount =
                        self.Diagnostics.InvalidFrameCount.saturating_add(1);
                    self.Diagnostics.InvalidLengthCount =
                        self.Diagnostics.InvalidLengthCount.saturating_add(1);
                    self.EscInterface_RecordCommunicationFault();
                    self.EscInterface_ResetReceiveAndUsePossibleStart(byte);
                } else {
                    self._receiveLength = length;
                    self._receiveIndex = 0;
                    self._receiveState = EscReceiveState::Payload;
                }
            }
            EscReceiveState::Payload => {
                self._receivePayload[self._receiveIndex] = byte;
                self._receiveIndex += 1;
                if self._receiveIndex == self._receiveLength {
                    self._receiveState = EscReceiveState::CrcHigh;
                }
            }
            EscReceiveState::CrcHigh => {
                self._receivedCrc = u16::from(byte) << 8;
                self._receiveState = EscReceiveState::CrcLow;
            }
            EscReceiveState::CrcLow => {
                self._receivedCrc |= u16::from(byte);
                self._receiveState = EscReceiveState::End;
            }
            EscReceiveState::End => {
                if byte != VESC_FRAME_END {
                    self.Diagnostics.InvalidFrameCount =
                        self.Diagnostics.InvalidFrameCount.saturating_add(1);
                    self.Diagnostics.InvalidEndByteCount =
                        self.Diagnostics.InvalidEndByteCount.saturating_add(1);
                    self.EscInterface_RecordCommunicationFault();
                    self.EscInterface_ResetReceiveAndUsePossibleStart(byte);
                    return;
                }

                if VescCrc16(&self._receivePayload[..self._receiveLength]) != self._receivedCrc {
                    self.Diagnostics.InvalidFrameCount =
                        self.Diagnostics.InvalidFrameCount.saturating_add(1);
                    self.Diagnostics.ChecksumErrorCount =
                        self.Diagnostics.ChecksumErrorCount.saturating_add(1);
                    self.EscInterface_RecordCommunicationFault();
                    self.EscInterface_ResetReceive();
                    return;
                }

                self.Diagnostics.ReceivedFrameCount =
                    self.Diagnostics.ReceivedFrameCount.saturating_add(1);
                self.EscInterface_HandlePayload(timestampUs);
                self.EscInterface_ResetReceive();
            }
        }
    }

    fn EscInterface_ProcessReceive(&mut self, tstmp: u64) {
        for _ in 0..ESC_MAX_RECEIVE_BYTES_PER_STEP {
            let readResult = McuManager::EscCommunication_TryReadByteWithErrors();
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
                self.EscInterface_RecordCommunicationFault();
                self.EscInterface_ResetReceive();
                continue;
            }

            let Some(byte) = readResult.Byte else {
                break;
            };
            self.EscInterface_ReceiveByte(byte, tstmp);
        }
    }

    fn EscInterface_ProcessTimeouts(&mut self, tstmp: u64) {
        if self._receiveState != EscReceiveState::WaitingForStart
            && tstmp.saturating_sub(self._lastReceiveByteTimestampUs) > ESC_PARTIAL_FRAME_TIMEOUT_US
        {
            self.Diagnostics.InvalidFrameCount =
                self.Diagnostics.InvalidFrameCount.saturating_add(1);
            self.Diagnostics.PartialFrameTimeoutCount =
                self.Diagnostics.PartialFrameTimeoutCount.saturating_add(1);
            self.EscInterface_RecordCommunicationFault();
            self.EscInterface_ResetReceive();
        }

        if self._pendingRequest != EscPendingRequest::None
            && tstmp.saturating_sub(self._pendingRequestTimestampUs) > ESC_RESPONSE_TIMEOUT_US
        {
            match self._pendingRequest {
                EscPendingRequest::Firmware => {
                    self._nextFirmwareRequestTimestampUs = tstmp;
                }
                EscPendingRequest::Telemetry => {
                    self._nextTelemetryRequestTimestampUs = tstmp;
                }
                EscPendingRequest::None => {}
            }
            self._pendingRequest = EscPendingRequest::None;
            self.Diagnostics.ResponseTimeoutCount =
                self.Diagnostics.ResponseTimeoutCount.saturating_add(1);
            self.EscInterface_RecordCommunicationFault();
        }
    }

    fn EscInterface_ExpireCurrentRequest(&mut self, tstmp: u64) {
        if self._currentRequestValid
            && (tstmp < self._currentRequestTimestampUs
                || tstmp - self._currentRequestTimestampUs > ESC_CURRENT_REQUEST_LEASE_US)
        {
            self._currentRequestValid = false;
            self.RequestedMotorCurrentMilliamperes = 0;
            self.Diagnostics.ExpiredCurrentRequestCount = self
                .Diagnostics
                .ExpiredCurrentRequestCount
                .saturating_add(1);
        }
    }

    fn EscInterface_SelectRequest(&self, tstmp: u64) -> EscPendingRequest {
        if self._pendingRequest != EscPendingRequest::None {
            return EscPendingRequest::None;
        }

        if !self._firmwareReceived && tstmp >= self._nextFirmwareRequestTimestampUs {
            EscPendingRequest::Firmware
        } else if self._firmwareCompatible && tstmp >= self._nextTelemetryRequestTimestampUs {
            EscPendingRequest::Telemetry
        } else {
            EscPendingRequest::None
        }
    }

    fn EscInterface_CommitRequest(&mut self, request: EscPendingRequest, tstmp: u64) {
        match request {
            EscPendingRequest::None => {}
            EscPendingRequest::Firmware => {
                self._pendingRequest = request;
                self._pendingRequestTimestampUs = tstmp;
                self._nextFirmwareRequestTimestampUs = Self::EscInterface_AdvanceDeadline(
                    self._nextFirmwareRequestTimestampUs,
                    tstmp,
                    ESC_FIRMWARE_REQUEST_PERIOD_US,
                );
                self.Diagnostics.FirmwareRequestCount =
                    self.Diagnostics.FirmwareRequestCount.saturating_add(1);
            }
            EscPendingRequest::Telemetry => {
                self._pendingRequest = request;
                self._pendingRequestTimestampUs = tstmp;
                self._nextTelemetryRequestTimestampUs = Self::EscInterface_AdvanceDeadline(
                    self._nextTelemetryRequestTimestampUs,
                    tstmp,
                    ESC_TELEMETRY_PERIOD_US,
                );
                self.Diagnostics.TelemetryRequestCount =
                    self.Diagnostics.TelemetryRequestCount.saturating_add(1);
            }
        }
    }

    fn EscInterface_HandlePayload(&mut self, timestampUs: u64) {
        let command = self._receivePayload[0];
        match command {
            VESC_COMMAND_FW_VERSION if self._pendingRequest == EscPendingRequest::Firmware => {
                self._pendingRequest = EscPendingRequest::None;
                self.EscInterface_DecodeFirmware(timestampUs);
            }
            VESC_COMMAND_GET_VALUES_SELECTIVE
                if self._pendingRequest == EscPendingRequest::Telemetry =>
            {
                self._pendingRequest = EscPendingRequest::None;
                self.EscInterface_DecodeTelemetry(timestampUs);
            }
            _ => {
                self.Diagnostics.UnexpectedResponseCount =
                    self.Diagnostics.UnexpectedResponseCount.saturating_add(1);
                self.Diagnostics.LastUnexpectedCommand = command;
                self.EscInterface_RecordCommunicationFault();
            }
        }
    }

    fn EscInterface_DecodeFirmware(&mut self, timestampUs: u64) {
        if self._receiveLength < 4 {
            self.EscInterface_RecordInvalidPayload();
            return;
        }

        let mut nameEnd = 3;
        while nameEnd < self._receiveLength && self._receivePayload[nameEnd] != 0 {
            nameEnd += 1;
        }
        if nameEnd == self._receiveLength {
            self.EscInterface_RecordInvalidPayload();
            return;
        }

        let receivedHardwareName = &self._receivePayload[3..nameEnd];
        let nameLength = receivedHardwareName.len().min(ESC_HARDWARE_NAME_CAPACITY);
        let mut hardwareName = [0u8; ESC_HARDWARE_NAME_CAPACITY];
        hardwareName[..nameLength].copy_from_slice(&receivedHardwareName[..nameLength]);
        let major = self._receivePayload[1];
        let minor = self._receivePayload[2];
        let compatible = major == ESC_SUPPORTED_FIRMWARE_MAJOR
            && minor == ESC_SUPPORTED_FIRMWARE_MINOR
            && receivedHardwareName == ESC_SUPPORTED_HARDWARE_NAME;

        self.Firmware = EscFirmwareInfo {
            Valid: true,
            Compatible: compatible,
            Major: major,
            Minor: minor,
            HardwareNameLength: nameLength as u8,
            HardwareName: hardwareName,
            TimestampUs: timestampUs,
        };
        self._firmwareReceived = true;
        self._firmwareCompatible = compatible;
        self.Diagnostics.FirmwareResponseCount =
            self.Diagnostics.FirmwareResponseCount.saturating_add(1);
        if !compatible {
            self.Diagnostics.UnsupportedFirmwareCount =
                self.Diagnostics.UnsupportedFirmwareCount.saturating_add(1);
            self.EscInterface_RecordCommunicationFault();
        } else {
            self._nextTelemetryRequestTimestampUs = timestampUs;
        }
    }

    fn EscInterface_DecodeTelemetry(&mut self, timestampUs: u64) {
        if self._receiveLength != ESC_SELECTIVE_RESPONSE_PAYLOAD_LENGTH
            || Self::EscInterface_ReadU32(&self._receivePayload, 1) != VESC_SELECTIVE_VALUES_MASK
        {
            self.EscInterface_RecordInvalidPayload();
            return;
        }

        let inputVoltage = Self::EscInterface_ReadI16(&self._receivePayload, 23);
        if inputVoltage < 0 {
            self.EscInterface_RecordInvalidPayload();
            return;
        }

        let status = self._receivePayload[26];
        self.Telemetry = EscTelemetry {
            FetTemperatureDeciCelsius: Self::EscInterface_ReadI16(&self._receivePayload, 5),
            MotorTemperatureDeciCelsius: Self::EscInterface_ReadI16(&self._receivePayload, 7),
            MotorCurrentCentiAmperes: Self::EscInterface_ReadI32(&self._receivePayload, 9),
            InputCurrentCentiAmperes: Self::EscInterface_ReadI32(&self._receivePayload, 13),
            DutyPermille: Self::EscInterface_ReadI16(&self._receivePayload, 17),
            ElectricalRpm: Self::EscInterface_ReadI32(&self._receivePayload, 19),
            InputVoltageDecivolts: inputVoltage as u16,
            FaultCode: self._receivePayload[25],
            TimedOut: status & 0x01 != 0,
            KillSwitchActive: status & 0x02 != 0,
            Sequence: self.Telemetry.Sequence.wrapping_add(1),
            TimestampUs: timestampUs,
        };
        self._telemetryReceived = true;
        self._transportFault = false;
        self.Diagnostics.TelemetryResponseCount =
            self.Diagnostics.TelemetryResponseCount.saturating_add(1);
    }

    fn EscInterface_UpdateState(&mut self, tstmp: u64) {
        let previousState = self.State;
        let nextState = if !self.PowerOn {
            EscState::PoweredOff
        } else if self._transportFault {
            EscState::Fault
        } else if !self._firmwareReceived {
            EscState::Starting
        } else if !self._firmwareCompatible {
            EscState::Fault
        } else if !self._telemetryReceived {
            EscState::Qualifying
        } else if tstmp < self.Telemetry.TimestampUs
            || tstmp - self.Telemetry.TimestampUs > ESC_TELEMETRY_STALE_AFTER_US
        {
            if self._everReady {
                EscState::Fault
            } else {
                EscState::Qualifying
            }
        } else if self.Telemetry.FaultCode != 0
            || self.Telemetry.TimedOut
            || self.Telemetry.KillSwitchActive
        {
            EscState::Fault
        } else {
            self._everReady = true;
            EscState::Ready
        };

        // A demand accepted in an earlier Ready interval must never become
        // active automatically after a communication or ESC fault clears.
        if previousState == EscState::Ready && nextState != EscState::Ready {
            self.EscInterface_ClearMotorCurrentRequest();
        }
        self.State = nextState;
    }

    fn EscInterface_RecordTransmitFailure(&mut self, tstmp: u64) {
        self.Diagnostics.TransmitFailureCount =
            self.Diagnostics.TransmitFailureCount.saturating_add(1);
        self.Diagnostics.CurrentCommandDeadlineMissCount = self
            .Diagnostics
            .CurrentCommandDeadlineMissCount
            .saturating_add(1);
        self.EscInterface_RecordCommunicationFault();
        // Preserve the last successfully queued command and its timestamp.
        // The deadline-miss counters above describe that no replacement was
        // accepted by the transport.
        self.EscInterface_UpdateState(tstmp);
    }

    #[inline]
    fn EscInterface_IsCommunicationQualifiedAt(&self, tstmp: u64) -> bool {
        self.State == EscState::Ready
            && self._firmwareCompatible
            && self._telemetryReceived
            && !self._transportFault
            && tstmp >= self.Telemetry.TimestampUs
            && tstmp - self.Telemetry.TimestampUs <= ESC_TELEMETRY_STALE_AFTER_US
            && self.Telemetry.FaultCode == 0
            && !self.Telemetry.TimedOut
            && !self.Telemetry.KillSwitchActive
    }

    fn EscInterface_RecordInvalidPayload(&mut self) {
        self.Diagnostics.InvalidFrameCount = self.Diagnostics.InvalidFrameCount.saturating_add(1);
        self.Diagnostics.InvalidPayloadCount =
            self.Diagnostics.InvalidPayloadCount.saturating_add(1);
        self.EscInterface_RecordCommunicationFault();
    }

    fn EscInterface_RecordCommunicationFault(&mut self) {
        self._transportFault = true;
    }

    fn EscInterface_ResetCommunicationSession(&mut self) {
        self.EscInterface_ResetReceive();
        self._pendingRequest = EscPendingRequest::None;
        self._pendingRequestTimestampUs = 0;
        self._nextFirmwareRequestTimestampUs = 0;
        self._nextTelemetryRequestTimestampUs = 0;
        self._firmwareReceived = false;
        self._firmwareCompatible = false;
        self._telemetryReceived = false;
        self._transportFault = false;
        self._everReady = false;
        self.Firmware = EscFirmwareInfo::new();
        self.Telemetry = EscTelemetry::new();
        self.LastQueuedMotorCurrentMilliamperes = 0;
        self.LastQueuedCurrentTimestampUs = 0;
    }

    fn EscInterface_ResetReceive(&mut self) {
        self._receiveState = EscReceiveState::WaitingForStart;
        self._receiveLength = 0;
        self._receiveIndex = 0;
        self._receivedCrc = 0;
    }

    fn EscInterface_ResetReceiveAndUsePossibleStart(&mut self, byte: u8) {
        self.EscInterface_ResetReceive();
        if byte == VESC_SHORT_FRAME_START {
            self._receiveState = EscReceiveState::Length;
        }
    }

    fn EscInterface_AppendCurrentFrame(
        currentMilliamperes: i32,
        output: &mut [u8],
        writeIndex: usize,
    ) -> Option<usize> {
        let current = currentMilliamperes.to_be_bytes();
        let payload = [
            VESC_COMMAND_SET_CURRENT,
            current[0],
            current[1],
            current[2],
            current[3],
        ];
        VescAppendShortFrame(&payload, output, writeIndex)
    }

    fn EscInterface_AppendRequestFrame(
        request: EscPendingRequest,
        output: &mut [u8],
        writeIndex: usize,
    ) -> Option<usize> {
        match request {
            EscPendingRequest::None => Some(writeIndex),
            EscPendingRequest::Firmware => {
                VescAppendShortFrame(&[VESC_COMMAND_FW_VERSION], output, writeIndex)
            }
            EscPendingRequest::Telemetry => {
                let mask = VESC_SELECTIVE_VALUES_MASK.to_be_bytes();
                VescAppendShortFrame(
                    &[
                        VESC_COMMAND_GET_VALUES_SELECTIVE,
                        mask[0],
                        mask[1],
                        mask[2],
                        mask[3],
                    ],
                    output,
                    writeIndex,
                )
            }
        }
    }

    #[inline]
    fn EscInterface_ReadI16(buffer: &[u8], index: usize) -> i16 {
        i16::from_be_bytes([buffer[index], buffer[index + 1]])
    }

    #[inline]
    fn EscInterface_ReadI32(buffer: &[u8], index: usize) -> i32 {
        i32::from_be_bytes([
            buffer[index],
            buffer[index + 1],
            buffer[index + 2],
            buffer[index + 3],
        ])
    }

    #[inline]
    fn EscInterface_ReadU32(buffer: &[u8], index: usize) -> u32 {
        u32::from_be_bytes([
            buffer[index],
            buffer[index + 1],
            buffer[index + 2],
            buffer[index + 3],
        ])
    }

    fn EscInterface_AdvanceDeadline(deadline: u64, now: u64, period: u64) -> u64 {
        if deadline == 0 {
            return now.saturating_add(period);
        }
        let elapsedPeriods = now.saturating_sub(deadline) / period;
        deadline.saturating_add(elapsedPeriods.saturating_add(1).saturating_mul(period))
    }
}
