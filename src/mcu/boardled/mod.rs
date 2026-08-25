use crate::drv::{
    cortex::Shared,
    gpio::{Gpio, GPIO_INSTANCE, GPIO_PIN_STATE},
    iomuxc::{
        Iomuxc, IOMUXC_DRIVE_STRENGTH, IOMUXC_MUX_MODE, IOMUXC_PULL, IOMUXC_SLEW_RATE,
        IOMUXC_SPEED, SW_MUX_CTL_PAD, SW_PAD_CTL_PAD,
    },
    BIT,
};

use super::{clocktree, McuManager};

// FET1061-S software LED0: GPIO_AD_B0_09, ALT5 GPIO1_IO09.
const BOARD_LED_PAD: u8 = 51;
const BOARD_LED_PIN: u8 = 9;

const TASK_5MS_FIRST_RELEASE_US: u64 = 5_000;
const HEARTBEAT_PERIOD_US: u64 = 1_000_000;
const HEARTBEAT_FIRST_PULSE_END_US: u64 = 100_000;
const HEARTBEAT_SECOND_PULSE_START_US: u64 = 200_000;
const HEARTBEAT_SECOND_PULSE_END_US: u64 = 300_000;

static GPIO1: Shared<Gpio> = Shared::new(Gpio::new(GPIO_INSTANCE::GPIO1));
static IOMUXC: Shared<Iomuxc> = Shared::new(Iomuxc::new());

const fn HeartbeatLedIsOn(scheduledTimestampUs: u64) -> bool {
    let phaseUs =
        scheduledTimestampUs.saturating_sub(TASK_5MS_FIRST_RELEASE_US) % HEARTBEAT_PERIOD_US;
    phaseUs < HEARTBEAT_FIRST_PULSE_END_US
        || (phaseUs >= HEARTBEAT_SECOND_PULSE_START_US && phaseUs < HEARTBEAT_SECOND_PULSE_END_US)
}

// Verify all task-aligned waveform edges at compile time: 100 ms on, 100 ms
// off, 100 ms on, then 700 ms off for one 60 BPM heartbeat cycle.
const _: () = {
    assert!(HeartbeatLedIsOn(5_000));
    assert!(HeartbeatLedIsOn(100_000));
    assert!(!HeartbeatLedIsOn(105_000));
    assert!(!HeartbeatLedIsOn(200_000));
    assert!(HeartbeatLedIsOn(205_000));
    assert!(HeartbeatLedIsOn(300_000));
    assert!(!HeartbeatLedIsOn(305_000));
    assert!(!HeartbeatLedIsOn(1_000_000));
    assert!(HeartbeatLedIsOn(1_005_000));
};

impl McuManager {
    pub fn BoardLed_Init() {
        clocktree::EnableGpio1AndIomuxcClocks();

        GPIO1.with(|gpio| {
            // LED0 is active-low. Preload high before enabling the output so
            // initialization cannot produce a visible flash.
            gpio.ConfigureOutput(BOARD_LED_PIN, GPIO_PIN_STATE::HIGH);
        });

        IOMUXC.with(|iomuxc| {
            iomuxc.Write_SW_PAD_CTL_PAD(
                BOARD_LED_PAD,
                SW_PAD_CTL_PAD {
                    SRE: IOMUXC_SLEW_RATE::SLOW,
                    DSE: IOMUXC_DRIVE_STRENGTH::R0_DIV_6,
                    SPEED: IOMUXC_SPEED::FAST_150MHZ,
                    ODE: BIT::VALUE_0,
                    PKE: BIT::VALUE_0,
                    PUE: BIT::VALUE_0,
                    PUS: IOMUXC_PULL::DOWN_100K,
                    HYS: BIT::VALUE_0,
                },
            );
            iomuxc.Write_SW_MUX_CTL_PAD(
                BOARD_LED_PAD,
                SW_MUX_CTL_PAD {
                    MUX_MODE: IOMUXC_MUX_MODE::ALT5,
                    SION: BIT::VALUE_0,
                },
            );
        });
    }

    #[inline]
    pub fn BoardLed_Step(scheduledTimestampUs: u64) {
        Self::BoardLed_Set(HeartbeatLedIsOn(scheduledTimestampUs));
    }

    #[inline]
    fn BoardLed_Set(isOn: bool) {
        let pinState = if isOn {
            GPIO_PIN_STATE::LOW
        } else {
            GPIO_PIN_STATE::HIGH
        };
        GPIO1.with(|gpio| gpio.WritePin(BOARD_LED_PIN, pinState));
    }
}
