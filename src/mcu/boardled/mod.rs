use crate::drv::{
    gpio::{GPIO_MODE, GPIO_OUTPUT_SPEED, GPIO_OUTPUT_TYPE, GPIO_PIN_STATE, GPIO_PULL},
    rcc::RCC_AHB4_GPIO_PORT,
};

use super::{McuManager, GPIOH, RCC};

// FK743M2-IIT6 V1.1 onboard user LED: PH7, active-low.
const BOARD_LED_PIN: u8 = 7;

const TASK_5MS_FIRST_RELEASE_US: u64 = 5_000;
const HEARTBEAT_PERIOD_US: u64 = 1_000_000;
const HEARTBEAT_FIRST_PULSE_END_US: u64 = 100_000;
const HEARTBEAT_SECOND_PULSE_START_US: u64 = 200_000;
const HEARTBEAT_SECOND_PULSE_END_US: u64 = 300_000;

const fn HeartbeatLedIsOn(scheduledTimestampUs: u64) -> bool {
    let phaseUs =
        scheduledTimestampUs.saturating_sub(TASK_5MS_FIRST_RELEASE_US) % HEARTBEAT_PERIOD_US;
    phaseUs < HEARTBEAT_FIRST_PULSE_END_US
        || (phaseUs >= HEARTBEAT_SECOND_PULSE_START_US && phaseUs < HEARTBEAT_SECOND_PULSE_END_US)
}

// Verify every task-aligned edge: 100 ms on, 100 ms off, 100 ms on,
// then 700 ms off for one 60 BPM heartbeat cycle.
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
        RCC.with(|rcc| {
            rcc.EnableGpioClock(RCC_AHB4_GPIO_PORT::GPIOH);
        });

        GPIOH.with(|gpioh| {
            // Preload the active-low LED's off state before changing PH7 to
            // output mode so initialization cannot produce a visible flash.
            gpioh.WritePin(BOARD_LED_PIN, GPIO_PIN_STATE::HIGH);
            gpioh.SetPinOutputType(BOARD_LED_PIN, GPIO_OUTPUT_TYPE::PUSH_PULL);
            gpioh.SetPinOutputSpeed(BOARD_LED_PIN, GPIO_OUTPUT_SPEED::LOW);
            gpioh.SetPinPull(BOARD_LED_PIN, GPIO_PULL::NONE);
            gpioh.SetPinMode(BOARD_LED_PIN, GPIO_MODE::OUTPUT);
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
        GPIOH.with(|gpioh| gpioh.WritePin(BOARD_LED_PIN, pinState));
    }
}
