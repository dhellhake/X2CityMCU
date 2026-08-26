#![allow(dead_code)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

// This small host crate compiles the production task metadata and program-flow
// monitor directly. It avoids pulling the ARM-only startup/scheduler assembly
// into the native Rust test harness.
#[path = "../src/os/task/mod.rs"]
mod os_task;

mod os {
    pub mod task {
        pub use crate::os_task::{TaskConfiguration, TaskCycleTime, TaskRole};
    }
}

#[path = "../src/mcu/programflow/mod.rs"]
mod programflow;
