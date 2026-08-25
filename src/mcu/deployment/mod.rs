use super::McuManager;

const TASK_5MS_FIRST_RELEASE_US: u64 = 5_000;
const HEARTBEAT_PERIOD_US: u64 = 1_000_000;
const HEARTBEAT_FIRST_PULSE_END_US: u64 = 100_000;
const HEARTBEAT_SECOND_PULSE_START_US: u64 = 200_000;
const HEARTBEAT_SECOND_PULSE_END_US: u64 = 300_000;

const fn heartbeat_led_is_on(scheduledTimestampUs: u64) -> bool {
    let phaseUs =
        scheduledTimestampUs.saturating_sub(TASK_5MS_FIRST_RELEASE_US) % HEARTBEAT_PERIOD_US;
    phaseUs < HEARTBEAT_FIRST_PULSE_END_US
        || (phaseUs >= HEARTBEAT_SECOND_PULSE_START_US && phaseUs < HEARTBEAT_SECOND_PULSE_END_US)
}

// Verify all task-aligned waveform edges at compile time: 100 ms on, 100 ms
// off, 100 ms on, then 700 ms off for one 60 BPM heartbeat cycle.
const _: () = {
    assert!(heartbeat_led_is_on(5_000));
    assert!(heartbeat_led_is_on(100_000));
    assert!(!heartbeat_led_is_on(105_000));
    assert!(!heartbeat_led_is_on(200_000));
    assert!(heartbeat_led_is_on(205_000));
    assert!(heartbeat_led_is_on(300_000));
    assert!(!heartbeat_led_is_on(305_000));
    assert!(!heartbeat_led_is_on(1_000_000));
    assert!(heartbeat_led_is_on(1_005_000));
};

pub extern "C" fn tsk_1_5ms(tstmp: u64) {
    McuManager::BoardLed_Set(heartbeat_led_is_on(tstmp));
}

pub extern "C" fn background(_tstmp: u64) {
    loop {
        core::hint::spin_loop();
    }
}
