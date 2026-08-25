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

static GPIO1: Shared<Gpio> = Shared::new(Gpio::new(GPIO_INSTANCE::GPIO1));
static IOMUXC: Shared<Iomuxc> = Shared::new(Iomuxc::new());

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
    pub fn BoardLed_Set(isOn: bool) {
        let pinState = if isOn {
            GPIO_PIN_STATE::LOW
        } else {
            GPIO_PIN_STATE::HIGH
        };
        GPIO1.with(|gpio| gpio.WritePin(BOARD_LED_PIN, pinState));
    }
}
