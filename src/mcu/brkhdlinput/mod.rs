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
const BRAKE_ADC_B_PAD: u8 = 73;
const BRAKE_ADC_A_GPIO_PIN: u8 = 28;
const BRAKE_ADC_B_GPIO_PIN: u8 = 31;
const BRAKE_ADC_A_CHANNEL: u8 = 1;
const BRAKE_ADC_B_CHANNEL: u8 = 4;
const ADC_CLOCK_DIVISOR: u32 = 8;
const ADC_EXPECTED_CLOCK_HZ: u32 = 18_750_000;
const ADC_CALIBRATION_MAX_POLL_ITERATIONS: u32 = 1_000_000;
const ADC_PAIR_TIMEOUT_US: u64 = 300;

const BRAKE_ADC_CONFIGURATION: ADC_CONFIGURATION = ADC_CONFIGURATION {
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
};

#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum BrkHdlAdcPairStatus {
    Complete = 0,
    NotInitialized = 1,
    CalibrationFailed = 2,
    Timeout = 3,
    Stale = 4,
}

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
    const fn Error(status: BrkHdlAdcPairStatus, sequence: u32) -> Self {
        Self {
            Status: status,
            RawA: 0,
            RawB: 0,
            Sequence: sequence,
            CompletionTimestampUs: 0,
        }
    }
}

struct BrkHdlInputState {
    initializationStatus: BrkHdlAdcPairStatus,
    sequence: u32,
}

impl BrkHdlInputState {
    const fn new() -> Self {
        Self {
            initializationStatus: BrkHdlAdcPairStatus::NotInitialized,
            sequence: 0,
        }
    }

    fn Reset(&mut self) {
        *self = Self::new();
    }

    fn SetInitializationStatus(&mut self, status: BrkHdlAdcPairStatus) {
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
static BRAKE_INPUT_STATE: Shared<BrkHdlInputState> = Shared::new(BrkHdlInputState::new());

impl McuManager {
    pub fn BrkHdlInput_Init() {
        BRAKE_INPUT_STATE.with(BrkHdlInputState::Reset);
        clocktree::EnableAdc2Gpio1AndIomuxcClocks();

        GPIO1.with(|gpio| {
            gpio.SetPinDirection(BRAKE_ADC_A_GPIO_PIN, GPIO_DIRECTION::INPUT);
            gpio.SetPinDirection(BRAKE_ADC_B_GPIO_PIN, GPIO_DIRECTION::INPUT);
        });

        IOMUXC.with(|iomuxc| {
            // GPIO_AD_B1_12/_15 can be controlled by GPIO1 or their GPIO6
            // aliases. Force GPIO1 explicitly so a prior RAM image cannot
            // leave a fast-GPIO output driving either analog input.
            iomuxc.Set_GPR26_GPIO_MUX(BRAKE_ADC_A_GPIO_PIN, IOMUXC_GPIO_MUX::GPIO1);
            iomuxc.Set_GPR26_GPIO_MUX(BRAKE_ADC_B_GPIO_PIN, IOMUXC_GPIO_MUX::GPIO1);

            let analogInputPad = SW_PAD_CTL_PAD {
                SRE: IOMUXC_SLEW_RATE::SLOW,
                DSE: IOMUXC_DRIVE_STRENGTH::DISABLED,
                SPEED: IOMUXC_SPEED::LOW_50MHZ,
                ODE: BIT::VALUE_0,
                PKE: BIT::VALUE_0,
                PUE: BIT::VALUE_0,
                PUS: IOMUXC_PULL::DOWN_100K,
                HYS: BIT::VALUE_0,
            };
            iomuxc.Write_SW_PAD_CTL_PAD(BRAKE_ADC_A_PAD, analogInputPad);
            iomuxc.Write_SW_PAD_CTL_PAD(
                BRAKE_ADC_B_PAD,
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
                BRAKE_ADC_A_PAD,
                SW_MUX_CTL_PAD {
                    MUX_MODE: IOMUXC_MUX_MODE::ALT5,
                    SION: BIT::VALUE_0,
                },
            );
            iomuxc.Write_SW_MUX_CTL_PAD(
                BRAKE_ADC_B_PAD,
                SW_MUX_CTL_PAD {
                    MUX_MODE: IOMUXC_MUX_MODE::ALT5,
                    SION: BIT::VALUE_0,
                },
            );
        });

        let calibrated = ADC2.with(|adc| {
            adc.ConfigureSoftwareTriggered(BRAKE_ADC_CONFIGURATION)
                && adc.Calibrate(ADC_CALIBRATION_MAX_POLL_ITERATIONS)
        });

        let status = if calibrated {
            BrkHdlAdcPairStatus::Complete
        } else {
            BrkHdlAdcPairStatus::CalibrationFailed
        };
        BRAKE_INPUT_STATE.with(|state| state.SetInitializationStatus(status));
    }

    pub fn BrkHdlInput_ReadPair() -> BrkHdlAdcPair {
        let (initializationStatus, currentSequence) =
            BRAKE_INPUT_STATE.with(|state| (state.initializationStatus, state.sequence));
        if initializationStatus != BrkHdlAdcPairStatus::Complete {
            return BrkHdlAdcPair::Error(initializationStatus, currentSequence);
        }

        let startTimestampUs = SYSTICK.with(|systick| systick.GetElapsedMicroseconds());
        ADC2.with(|adc| adc.StartSoftwareConversion(BRAKE_ADC_A_CHANNEL));
        let Some((rawA, _)) = Self::BrkHdlInput_WaitForResult(startTimestampUs) else {
            ADC2.with(|adc| adc.AbortSoftwareConversion());
            return BrkHdlAdcPair::Error(BrkHdlAdcPairStatus::Timeout, currentSequence);
        };

        ADC2.with(|adc| adc.StartSoftwareConversion(BRAKE_ADC_B_CHANNEL));
        let Some((rawB, completionTimestampUs)) = Self::BrkHdlInput_WaitForResult(startTimestampUs)
        else {
            ADC2.with(|adc| adc.AbortSoftwareConversion());
            return BrkHdlAdcPair::Error(BrkHdlAdcPairStatus::Timeout, currentSequence);
        };

        let sequence = BRAKE_INPUT_STATE.with(BrkHdlInputState::NextSequence);
        BrkHdlAdcPair {
            Status: BrkHdlAdcPairStatus::Complete,
            RawA: rawA,
            RawB: rawB,
            Sequence: sequence,
            CompletionTimestampUs: completionTimestampUs,
        }
    }

    fn BrkHdlInput_WaitForResult(startTimestampUs: u64) -> Option<(u16, u64)> {
        loop {
            let result = ADC2.with(|adc| adc.TryReadConversionResult());
            let nowUs = SYSTICK.with(|systick| systick.GetElapsedMicroseconds());
            if nowUs.saturating_sub(startTimestampUs) > ADC_PAIR_TIMEOUT_US {
                return None;
            }
            if let Some(result) = result {
                return Some((result, nowUs));
            }
            core::hint::spin_loop();
        }
    }
}
