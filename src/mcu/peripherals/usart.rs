#![allow(non_snake_case)]

use crate::drv::{
    gpio::{Gpio, GPIO_OUTPUT_SPEED, GPIO_OUTPUT_TYPE, GPIO_PULL},
    rcc::{Rcc, RCC_AHB4_GPIO_PORT, RCC_USART16_CLOCK_SOURCE},
    usart::{
        Usart, USART_ASYNC_CONFIG, USART_DIRECTION, USART_PARITY, USART_PRESCALER, USART_STOP_BITS,
        USART_WORD_LENGTH,
    },
};

pub const USART1_KERNEL_CLOCK_HZ: u32 = 120_000_000;
pub const USART1_BAUD_RATE: u32 = 115_200;

/// Selects the 120 MHz PCLK2 kernel clock and enables GPIOA and USART1.
pub fn ConfigureUsart1DebugHeaderClocks(rcc: &Rcc) {
    rcc.SetUsart16ClockSource(RCC_USART16_CLOCK_SOURCE::PCLK2);
    rcc.EnableGpioClock(RCC_AHB4_GPIO_PORT::GPIOA);
    rcc.EnableUsart1Clock();
}

/// Configures PA9 as USART1_TX and PA10 as USART1_RX on alternate function 7.
pub fn ConfigureUsart1DebugHeaderPins(gpioa: &Gpio) {
    gpioa.ConfigureAlternateFunction(
        9,
        7,
        GPIO_OUTPUT_SPEED::VERY_HIGH,
        GPIO_OUTPUT_TYPE::PUSH_PULL,
        GPIO_PULL::NONE,
    );

    gpioa.ConfigureAlternateFunction(
        10,
        7,
        GPIO_OUTPUT_SPEED::VERY_HIGH,
        GPIO_OUTPUT_TYPE::PUSH_PULL,
        GPIO_PULL::PULL_UP,
    );
}

/// Configures USART1 on the board's P1 debug header: 115200 baud, 8 data bits,
/// no parity, one stop bit, transmit and receive enabled.
pub fn ConfigureUsart1DebugHeader115200(usart1: &Usart) {
    usart1.ConfigureAsync(
        USART1_KERNEL_CLOCK_HZ,
        USART1_BAUD_RATE,
        USART_ASYNC_CONFIG {
            direction: USART_DIRECTION::TRANSMIT_RECEIVE,
            wordLength: USART_WORD_LENGTH::BITS_8,
            parity: USART_PARITY::NONE,
            stopBits: USART_STOP_BITS::STOP_1,
            prescaler: USART_PRESCALER::DIV1,
            fifoEnabled: true,
        },
    );
}
