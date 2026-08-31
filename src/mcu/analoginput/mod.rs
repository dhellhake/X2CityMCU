#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

use crate::drv::{
    adc::{
        Adc, ADC_CLOCK_DIVIDER, ADC_CLOCK_SOURCE, ADC_CONFIGURATION, ADC_HARDWARE_AVERAGE,
        ADC_INSTANCE, ADC_RESOLUTION, ADC_SAMPLE_TIME,
    },
    cortex::Shared,
    gpio::{Gpio, GPIO_DIRECTION, GPIO_INSTANCE},
    iomuxc::{
        Iomuxc, IOMUXC_DRIVE_STRENGTH, IOMUXC_GPIO_MUX, IOMUXC_MUX_MODE, IOMUXC_PULL,
        IOMUXC_SLEW_RATE, IOMUXC_SPEED, SW_MUX_CTL_PAD, SW_PAD_CTL_PAD,
    },
    BIT,
};

use super::{clocktree, McuManager, SYSTICK};

const BRAKE_ADC_A_PAD: u8 = 70;
const ACHDL_ADC_SIGNAL_PAD: u8 = 71;
const ACHDL_ADC_SUPPLY_PAD: u8 = 72;
const BRAKE_ADC_B_PAD: u8 = 73;

const BRAKE_ADC_A_GPIO_PIN: u8 = 28;
const ACHDL_ADC_SIGNAL_GPIO_PIN: u8 = 29;
const ACHDL_ADC_SUPPLY_GPIO_PIN: u8 = 30;
const BRAKE_ADC_B_GPIO_PIN: u8 = 31;

const BRAKE_ADC_A_CHANNEL: u8 = 1;
const ACHDL_ADC_SIGNAL_CHANNEL: u8 = 2;
const ACHDL_ADC_SUPPLY_CHANNEL: u8 = 3;
const BRAKE_ADC_B_CHANNEL: u8 = 4;

const ANALOG_INPUT_PADS: [(u8, u8); 4] = [
    (BRAKE_ADC_A_PAD, BRAKE_ADC_A_GPIO_PIN),
    (ACHDL_ADC_SIGNAL_PAD, ACHDL_ADC_SIGNAL_GPIO_PIN),
    (ACHDL_ADC_SUPPLY_PAD, ACHDL_ADC_SUPPLY_GPIO_PIN),
    (BRAKE_ADC_B_PAD, BRAKE_ADC_B_GPIO_PIN),
];

const ADC_CLOCK_DIVISOR: u32 = 8;
const ADC_EXPECTED_CLOCK_HZ: u32 = 18_750_000;
const ADC_CALIBRATION_MAX_POLL_ITERATIONS: u32 = 1_000_000;
const ADC_BRAKE_PAIR_TIMEOUT_US: u64 = 300;
const ADC_FRAME_TIMEOUT_US: u64 = 600;

const ANALOG_INPUT_CONFIGURATION: ADC_CONFIGURATION = ADC_CONFIGURATION {
    clockSource: ADC_CLOCK_SOURCE::IPG,
    clockDivider: ADC_CLOCK_DIVIDER::DIVIDE_8,
    resolution: ADC_RESOLUTION::BITS_12,
    sampleTime: ADC_SAMPLE_TIME::LONG_24_CLOCKS,
    hardwareAverage: ADC_HARDWARE_AVERAGE::COUNT_32,
    enableLowPower: false,
    enableHighSpeed: false,
    enableOverwrite: false,
};

const _: () = {
    assert!(clocktree::IPG_CLOCK_HZ / ADC_CLOCK_DIVISOR == ADC_EXPECTED_CLOCK_HZ);
    assert!(ADC_BRAKE_PAIR_TIMEOUT_US < ADC_FRAME_TIMEOUT_US);
};

#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum AnalogInputStatus {
    Complete = 0,
    NotInitialized = 1,
    CalibrationFailed = 2,
    Timeout = 3,
    Stale = 4,
}

pub type BrkHdlAdcPairStatus = AnalogInputStatus;
pub type AcHdlAdcPairStatus = AnalogInputStatus;

#[repr(C)]
#[derive(Copy, Clone)]
pub struct BrkHdlAdcPair {
    pub Status: BrkHdlAdcPairStatus,
    pub RawA: u16,
    pub RawB: u16,
    pub Sequence: u32,
    pub CompletionTimestampUs: u64,
}

impl BrkHdlAdcPair {
    const fn Error(status: AnalogInputStatus, sequence: u32) -> Self {
        Self {
            Status: status,
            RawA: 0,
            RawB: 0,
            Sequence: sequence,
            CompletionTimestampUs: 0,
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct AcHdlAdcPair {
    pub Status: AcHdlAdcPairStatus,
    pub RawSignal: u16,
    pub RawSupply: u16,
    pub Sequence: u32,
    pub CompletionTimestampUs: u64,
}

impl AcHdlAdcPair {
    const fn Error(status: AnalogInputStatus, sequence: u32) -> Self {
        Self {
            Status: status,
            RawSignal: 0,
            RawSupply: 0,
            Sequence: sequence,
            CompletionTimestampUs: 0,
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct AnalogInputFrame {
    pub Brake: BrkHdlAdcPair,
    pub AcHdl: AcHdlAdcPair,
}

impl AnalogInputFrame {
    const fn Error(status: AnalogInputStatus, sequence: u32) -> Self {
        Self {
            Brake: BrkHdlAdcPair::Error(status, sequence),
            AcHdl: AcHdlAdcPair::Error(status, sequence),
        }
    }
}

struct AnalogInputState {
    initializationStatus: AnalogInputStatus,
    sequence: u32,
}

impl AnalogInputState {
    const fn new() -> Self {
        Self {
            initializationStatus: AnalogInputStatus::NotInitialized,
            sequence: 0,
        }
    }

    fn Reset(&mut self) {
        *self = Self::new();
    }

    fn SetInitializationStatus(&mut self, status: AnalogInputStatus) {
        self.initializationStatus = status;
    }

    fn NextSequence(&mut self) -> u32 {
        self.sequence = self.sequence.wrapping_add(1);
        self.sequence
    }
}

static ADC2: Shared<Adc> = Shared::new(Adc::new(ADC_INSTANCE::ADC2));
static GPIO1: Shared<Gpio> = Shared::new(Gpio::new(GPIO_INSTANCE::GPIO1));
static IOMUXC: Shared<Iomuxc> = Shared::new(Iomuxc::new());
static ANALOG_INPUT_STATE: Shared<AnalogInputState> = Shared::new(AnalogInputState::new());

impl McuManager {
    pub fn AnalogInput_Init() {
        ANALOG_INPUT_STATE.with(AnalogInputState::Reset);
        clocktree::EnableAdc2Gpio1AndIomuxcClocks();

        GPIO1.with(|gpio| {
            for (_, gpioPin) in ANALOG_INPUT_PADS {
                gpio.SetPinDirection(gpioPin, GPIO_DIRECTION::INPUT);
            }
        });

        IOMUXC.with(|iomuxc| {
            for (pad, gpioPin) in ANALOG_INPUT_PADS {
                // GPIO_AD_B1_12..15 can be controlled by GPIO1 or their GPIO6
                // aliases. Force GPIO1 so a prior RAM image cannot leave a
                // fast-GPIO output driving an analog input.
                iomuxc.Set_GPR26_GPIO_MUX(gpioPin, IOMUXC_GPIO_MUX::GPIO1);
                iomuxc.Write_SW_PAD_CTL_PAD(
                    pad,
                    SW_PAD_CTL_PAD {
                        SRE: IOMUXC_SLEW_RATE::SLOW,
                        DSE: IOMUXC_DRIVE_STRENGTH::DISABLED,
                        SPEED: IOMUXC_SPEED::LOW_50MHZ,
                        ODE: BIT::VALUE_0,
                        PKE: BIT::VALUE_0,
                        PUE: BIT::VALUE_0,
                        PUS: IOMUXC_PULL::DOWN_100K,
                        HYS: BIT::VALUE_0,
                    },
                );
                iomuxc.Write_SW_MUX_CTL_PAD(
                    pad,
                    SW_MUX_CTL_PAD {
                        MUX_MODE: IOMUXC_MUX_MODE::ALT5,
                        SION: BIT::VALUE_0,
                    },
                );
            }
        });

        let calibrated = ADC2.with(|adc| {
            adc.ConfigureSoftwareTriggered(ANALOG_INPUT_CONFIGURATION)
                && adc.Calibrate(ADC_CALIBRATION_MAX_POLL_ITERATIONS)
        });

        let status = if calibrated {
            AnalogInputStatus::Complete
        } else {
            AnalogInputStatus::CalibrationFailed
        };
        ANALOG_INPUT_STATE.with(|state| state.SetInitializationStatus(status));
    }

    /// Acquires the complete ADC2 application frame in one fixed order.
    ///
    /// Publication is fail-atomic: a timeout on any channel invalidates both
    /// feature pairs and does not advance the shared sequence.
    pub fn AnalogInput_ReadFrame() -> AnalogInputFrame {
        let (initializationStatus, currentSequence) =
            ANALOG_INPUT_STATE.with(|state| (state.initializationStatus, state.sequence));
        if initializationStatus != AnalogInputStatus::Complete {
            return AnalogInputFrame::Error(initializationStatus, currentSequence);
        }

        let startTimestampUs = SYSTICK.with(|systick| systick.GetElapsedMicroseconds());

        ADC2.with(|adc| adc.StartSoftwareConversion(BRAKE_ADC_A_CHANNEL));
        let Some((rawBrakeA, _)) =
            Self::AnalogInput_WaitForResult(startTimestampUs, ADC_BRAKE_PAIR_TIMEOUT_US)
        else {
            return Self::AnalogInput_AbortWithError(currentSequence);
        };

        ADC2.with(|adc| adc.StartSoftwareConversion(BRAKE_ADC_B_CHANNEL));
        let Some((rawBrakeB, brakeCompletionTimestampUs)) =
            Self::AnalogInput_WaitForResult(startTimestampUs, ADC_BRAKE_PAIR_TIMEOUT_US)
        else {
            return Self::AnalogInput_AbortWithError(currentSequence);
        };

        ADC2.with(|adc| adc.StartSoftwareConversion(ACHDL_ADC_SIGNAL_CHANNEL));
        let Some((rawAcHdlSignal, _)) =
            Self::AnalogInput_WaitForResult(startTimestampUs, ADC_FRAME_TIMEOUT_US)
        else {
            return Self::AnalogInput_AbortWithError(currentSequence);
        };

        ADC2.with(|adc| adc.StartSoftwareConversion(ACHDL_ADC_SUPPLY_CHANNEL));
        let Some((rawAcHdlSupply, frameCompletionTimestampUs)) =
            Self::AnalogInput_WaitForResult(startTimestampUs, ADC_FRAME_TIMEOUT_US)
        else {
            return Self::AnalogInput_AbortWithError(currentSequence);
        };

        let sequence = ANALOG_INPUT_STATE.with(AnalogInputState::NextSequence);
        AnalogInputFrame {
            Brake: BrkHdlAdcPair {
                Status: AnalogInputStatus::Complete,
                RawA: rawBrakeA,
                RawB: rawBrakeB,
                Sequence: sequence,
                CompletionTimestampUs: brakeCompletionTimestampUs,
            },
            AcHdl: AcHdlAdcPair {
                Status: AnalogInputStatus::Complete,
                RawSignal: rawAcHdlSignal,
                RawSupply: rawAcHdlSupply,
                Sequence: sequence,
                CompletionTimestampUs: frameCompletionTimestampUs,
            },
        }
    }

    fn AnalogInput_AbortWithError(currentSequence: u32) -> AnalogInputFrame {
        ADC2.with(|adc| adc.AbortSoftwareConversion());
        AnalogInputFrame::Error(AnalogInputStatus::Timeout, currentSequence)
    }

    fn AnalogInput_WaitForResult(startTimestampUs: u64, timeoutUs: u64) -> Option<(u16, u64)> {
        loop {
            let result = ADC2.with(|adc| adc.TryReadConversionResult());
            let nowUs = SYSTICK.with(|systick| systick.GetElapsedMicroseconds());
            if nowUs.saturating_sub(startTimestampUs) > timeoutUs {
                return None;
            }
            if let Some(result) = result {
                return Some((result, nowUs));
            }
            core::hint::spin_loop();
        }
    }
}
