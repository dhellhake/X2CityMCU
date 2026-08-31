#![allow(non_snake_case)]

use crate::{
    drv::wwdg::Wwdg, mcu::peripherals::wwdg::WWDG_RELOAD_COUNTER, os::task::TaskConfiguration,
};

pub const SUPERVISION_CYCLE_US: u32 = 10_000;
pub const WATCHDOG_SERVICE_MIN_US: u32 = 8_500;
pub const WATCHDOG_SERVICE_MAX_US: u32 = 15_500;

const MAX_EXPECTED_CHECKPOINTS: usize = 16;
const CHECKPOINT_EARLY_TOLERANCE_US: u32 = 1_000;
const CHECKPOINT_START_LATE_TOLERANCE_US: u32 = 2_000;
const CHECKPOINT_END_AFTER_START_US: u32 = 500;
const SAME_RELEASE_PRIORITY_SLOT_US: u32 = 2_000;

#[repr(u32)]
#[derive(Copy, Clone, PartialEq, Eq)]
pub enum ProgramFlowCheckpointKind {
    None = 0,
    Start = 1,
    End = 2,
    Unknown = 0xFFFF_FFFF,
}

#[repr(C)]
#[derive(Copy, Clone, PartialEq, Eq)]
pub struct ProgramFlowCheckpoint {
    pub taskId: u32,
    pub kind: ProgramFlowCheckpointKind,
}

impl ProgramFlowCheckpoint {
    pub const fn new(taskId: u32, kind: ProgramFlowCheckpointKind) -> Self {
        ProgramFlowCheckpoint { taskId, kind }
    }

    pub const fn none() -> Self {
        ProgramFlowCheckpoint::new(u32::MAX, ProgramFlowCheckpointKind::None)
    }

    pub const fn unknown() -> Self {
        ProgramFlowCheckpoint::new(u32::MAX, ProgramFlowCheckpointKind::Unknown)
    }
}

#[repr(u32)]
#[derive(Copy, Clone, PartialEq, Eq)]
pub enum ProgramFlowState {
    Uninitialized = 0,
    Running = 1,
    ServiceAuthorized = 2,
    Faulted = 3,
}

#[repr(u32)]
#[derive(Copy, Clone, PartialEq, Eq)]
pub enum ProgramFlowFault {
    None = 0,
    StartupIncomplete = 1,
    OmittedExecution = 2,
    DuplicateExecution = 3,
    IncorrectSequence = 4,
    IncompleteExecution = 5,
    TimingTooEarly = 6,
    TimingTooLate = 7,
    WatchdogWindowClosed = 8,
    InternalMonitorFailure = 9,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct ProgramFlowDiagnostic {
    pub fault: ProgramFlowFault,
    pub expected: ProgramFlowCheckpoint,
    pub received: ProgramFlowCheckpoint,
    pub sequenceIndex: u32,
    pub cycleCount: u32,
    pub timestamp_us: u64,
    pub relative_us: u32,
}

impl ProgramFlowDiagnostic {
    pub const fn new() -> Self {
        ProgramFlowDiagnostic {
            fault: ProgramFlowFault::None,
            expected: ProgramFlowCheckpoint::none(),
            received: ProgramFlowCheckpoint::none(),
            sequenceIndex: 0,
            cycleCount: 0,
            timestamp_us: 0,
            relative_us: 0,
        }
    }
}

#[derive(Copy, Clone)]
struct CheckpointSpec {
    checkpoint: ProgramFlowCheckpoint,
    release_us: u32,
    min_us: u32,
    max_us: u32,
}

impl CheckpointSpec {
    const fn empty() -> Self {
        CheckpointSpec {
            checkpoint: ProgramFlowCheckpoint::none(),
            release_us: 0,
            min_us: 0,
            max_us: 0,
        }
    }

    const fn new(
        checkpoint: ProgramFlowCheckpoint,
        release_us: u32,
        min_us: u32,
        max_us: u32,
    ) -> Self {
        CheckpointSpec {
            checkpoint,
            release_us,
            min_us,
            max_us,
        }
    }
}

pub struct ProgramFlowMonitor {
    _state: ProgramFlowState,
    _expectedCheckpoints: [CheckpointSpec; MAX_EXPECTED_CHECKPOINTS],
    _expectedCheckpointCount: u32,
    _expectedCheckpointCountInv: u32,
    _expectedIndex: u32,
    _expectedIndexInv: u32,
    _cycleStartUs: u64,
    _cycleStartUsInv: u64,
    _cycleCount: u32,
    _cycleCountInv: u32,
    _lastCheckpoint: ProgramFlowCheckpoint,
    _diagnostic: ProgramFlowDiagnostic,
}

impl ProgramFlowMonitor {
    pub const fn new() -> Self {
        ProgramFlowMonitor {
            _state: ProgramFlowState::Uninitialized,
            _expectedCheckpoints: [CheckpointSpec::empty(); MAX_EXPECTED_CHECKPOINTS],
            _expectedCheckpointCount: 0,
            _expectedCheckpointCountInv: !0,
            _expectedIndex: 0,
            _expectedIndexInv: !0,
            _cycleStartUs: 0,
            _cycleStartUsInv: !0,
            _cycleCount: 0,
            _cycleCountInv: !0,
            _lastCheckpoint: ProgramFlowCheckpoint::none(),
            _diagnostic: ProgramFlowDiagnostic::new(),
        }
    }

    pub fn ConfigureFromTasks<const TASK_COUNT: usize>(
        &mut self,
        tasks: &[TaskConfiguration; TASK_COUNT],
        start_us: u64,
    ) {
        self._state = ProgramFlowState::Running;
        self._expectedCheckpoints = [CheckpointSpec::empty(); MAX_EXPECTED_CHECKPOINTS];
        self.SetExpectedCheckpointCount(0);
        self.SetExpectedIndex(0);
        self.SetCycleStart(start_us);
        self.SetCycleCount(0);
        self._lastCheckpoint = ProgramFlowCheckpoint::none();
        self._diagnostic = ProgramFlowDiagnostic::new();

        let mut pfmTaskCount = 0;
        let mut pfmTaskIndex = TASK_COUNT;

        for taskIdx in 0..TASK_COUNT {
            if tasks[taskIdx].role.IsUnsupervised()
                && tasks[taskIdx].cycletime.period_us() == Some(SUPERVISION_CYCLE_US as u64)
            {
                pfmTaskCount += 1;

                pfmTaskIndex = taskIdx;
                continue;
            }

            if !tasks[taskIdx]
                .role
                .ReportsProgramFlowCheckpoints(tasks[taskIdx].cycletime)
            {
                continue;
            }

            let Some(period_us) = tasks[taskIdx].cycletime.period_us() else {
                self.RecordFault(
                    ProgramFlowFault::StartupIncomplete,
                    ProgramFlowCheckpoint::unknown(),
                    ProgramFlowCheckpoint::new(
                        tasks[taskIdx].id,
                        ProgramFlowCheckpointKind::Unknown,
                    ),
                    start_us,
                );
                return;
            };

            if period_us == 0
                || period_us > SUPERVISION_CYCLE_US as u64
                || (SUPERVISION_CYCLE_US as u64 % period_us) != 0
            {
                self.RecordFault(
                    ProgramFlowFault::StartupIncomplete,
                    ProgramFlowCheckpoint::unknown(),
                    ProgramFlowCheckpoint::new(
                        tasks[taskIdx].id,
                        ProgramFlowCheckpointKind::Unknown,
                    ),
                    start_us,
                );
                return;
            }

            let mut release_us = period_us as u32;
            while release_us <= SUPERVISION_CYCLE_US {
                let prioritySlot = Self::SameReleasePrioritySlot(tasks, taskIdx, release_us);
                self.InsertTaskReleaseCheckpoints(
                    tasks[taskIdx].id,
                    release_us,
                    prioritySlot,
                    start_us,
                );

                if self.IsFaulted() {
                    return;
                }

                release_us = release_us.saturating_add(period_us as u32);
            }
        }

        if pfmTaskCount != 1 {
            self.RecordFault(
                ProgramFlowFault::StartupIncomplete,
                ProgramFlowCheckpoint::unknown(),
                ProgramFlowCheckpoint::none(),
                start_us,
            );
            return;
        }

        for taskIdx in (pfmTaskIndex + 1)..TASK_COUNT {
            if tasks[taskIdx]
                .role
                .ReportsProgramFlowCheckpoints(tasks[taskIdx].cycletime)
            {
                self.RecordFault(
                    ProgramFlowFault::StartupIncomplete,
                    ProgramFlowCheckpoint::unknown(),
                    ProgramFlowCheckpoint::new(
                        tasks[taskIdx].id,
                        ProgramFlowCheckpointKind::Unknown,
                    ),
                    start_us,
                );
                return;
            }
        }

        if self._expectedCheckpointCount == 0 {
            self.RecordFault(
                ProgramFlowFault::StartupIncomplete,
                ProgramFlowCheckpoint::unknown(),
                ProgramFlowCheckpoint::none(),
                start_us,
            );
        }
    }

    pub fn ReportTaskStart(&mut self, taskId: u32, now_us: u64) {
        self.ReportCheckpoint(
            ProgramFlowCheckpoint::new(taskId, ProgramFlowCheckpointKind::Start),
            now_us,
        );
    }

    pub fn ReportTaskEnd(&mut self, taskId: u32, now_us: u64) {
        self.ReportCheckpoint(
            ProgramFlowCheckpoint::new(taskId, ProgramFlowCheckpointKind::End),
            now_us,
        );
    }

    #[inline]
    pub fn GetDiagnostic(&self) -> ProgramFlowDiagnostic {
        self._diagnostic
    }

    #[inline]
    pub fn IsFaulted(&self) -> bool {
        matches!(self._state, ProgramFlowState::Faulted)
    }

    fn InsertTaskReleaseCheckpoints(
        &mut self,
        taskId: u32,
        release_us: u32,
        prioritySlot: u32,
        now_us: u64,
    ) {
        let min_us = release_us.saturating_sub(CHECKPOINT_EARLY_TOLERANCE_US);
        let slotDelay_us = prioritySlot.saturating_mul(SAME_RELEASE_PRIORITY_SLOT_US);
        let startMax_us = release_us
            .saturating_add(CHECKPOINT_START_LATE_TOLERANCE_US)
            .saturating_add(slotDelay_us);
        let endMax_us = startMax_us.saturating_add(CHECKPOINT_END_AFTER_START_US);

        self.InsertCheckpointSpec(
            CheckpointSpec::new(
                ProgramFlowCheckpoint::new(taskId, ProgramFlowCheckpointKind::Start),
                release_us,
                min_us,
                startMax_us,
            ),
            now_us,
        );

        self.InsertCheckpointSpec(
            CheckpointSpec::new(
                ProgramFlowCheckpoint::new(taskId, ProgramFlowCheckpointKind::End),
                release_us,
                min_us,
                endMax_us,
            ),
            now_us,
        );
    }

    fn InsertCheckpointSpec(&mut self, spec: CheckpointSpec, now_us: u64) {
        let count = self._expectedCheckpointCount as usize;
        if count >= MAX_EXPECTED_CHECKPOINTS {
            self.RecordFault(
                ProgramFlowFault::StartupIncomplete,
                ProgramFlowCheckpoint::unknown(),
                spec.checkpoint,
                now_us,
            );
            return;
        }

        let mut insertIdx = count;
        while insertIdx > 0
            && Self::CheckpointComesBefore(spec, self._expectedCheckpoints[insertIdx - 1])
        {
            self._expectedCheckpoints[insertIdx] = self._expectedCheckpoints[insertIdx - 1];
            insertIdx -= 1;
        }

        self._expectedCheckpoints[insertIdx] = spec;
        self.SetExpectedCheckpointCount(self._expectedCheckpointCount + 1);
    }

    #[inline]
    fn CheckpointComesBefore(left: CheckpointSpec, right: CheckpointSpec) -> bool {
        if left.release_us != right.release_us {
            return left.release_us < right.release_us;
        }

        if left.checkpoint.taskId != right.checkpoint.taskId {
            return left.checkpoint.taskId < right.checkpoint.taskId;
        }

        (left.checkpoint.kind as u32) < (right.checkpoint.kind as u32)
    }

    fn SameReleasePrioritySlot<const TASK_COUNT: usize>(
        tasks: &[TaskConfiguration; TASK_COUNT],
        taskIdx: usize,
        release_us: u32,
    ) -> u32 {
        let mut slot = 0;

        for otherIdx in 0..taskIdx {
            if let Some(period_us) = tasks[otherIdx].cycletime.period_us() {
                if period_us != 0 && (release_us as u64 % period_us) == 0 {
                    slot += 1;
                }
            }
        }

        slot
    }

    fn ReportCheckpoint(&mut self, checkpoint: ProgramFlowCheckpoint, now_us: u64) {
        if self.IsFaulted() {
            return;
        }

        if !self.CheckInternalState() {
            self.RecordFault(
                ProgramFlowFault::InternalMonitorFailure,
                ProgramFlowCheckpoint::unknown(),
                checkpoint,
                now_us,
            );
            return;
        }

        if !matches!(self._state, ProgramFlowState::Running) {
            self.RecordFault(
                ProgramFlowFault::StartupIncomplete,
                ProgramFlowCheckpoint::unknown(),
                checkpoint,
                now_us,
            );
            return;
        }

        let expectedIndex = self._expectedIndex as usize;
        if expectedIndex >= self._expectedCheckpointCount as usize {
            self.RecordFault(
                ProgramFlowFault::DuplicateExecution,
                ProgramFlowCheckpoint::none(),
                checkpoint,
                now_us,
            );
            return;
        }

        let expected = self._expectedCheckpoints[expectedIndex];
        if checkpoint != expected.checkpoint {
            let fault = if expectedIndex > 0
                && checkpoint == self._expectedCheckpoints[expectedIndex - 1].checkpoint
            {
                ProgramFlowFault::DuplicateExecution
            } else {
                ProgramFlowFault::IncorrectSequence
            };

            self.RecordFault(fault, expected.checkpoint, checkpoint, now_us);
            return;
        }

        let relative_us = self.RelativeTimestamp(now_us);
        if relative_us < expected.min_us {
            self.RecordFault(
                ProgramFlowFault::TimingTooEarly,
                expected.checkpoint,
                checkpoint,
                now_us,
            );
            return;
        }

        if relative_us > expected.max_us {
            self.RecordFault(
                ProgramFlowFault::TimingTooLate,
                expected.checkpoint,
                checkpoint,
                now_us,
            );
            return;
        }

        self._lastCheckpoint = checkpoint;
        self.SetExpectedIndex(self._expectedIndex + 1);
    }

    pub fn ValidateAndServiceWatchdog(&mut self, now_us: u64, watchdog: &mut Wwdg) {
        if self.IsFaulted() {
            return;
        }

        if !self.CheckInternalState() {
            self.RecordFault(
                ProgramFlowFault::InternalMonitorFailure,
                ProgramFlowCheckpoint::unknown(),
                ProgramFlowCheckpoint::none(),
                now_us,
            );
            return;
        }

        if !self.IsCycleComplete() {
            let expected = self.ExpectedCheckpoint();
            self.RecordFault(
                ProgramFlowFault::IncompleteExecution,
                expected,
                ProgramFlowCheckpoint::none(),
                now_us,
            );
            return;
        }

        let relative_us = self.RelativeTimestamp(now_us);
        if relative_us < WATCHDOG_SERVICE_MIN_US {
            self.RecordFault(
                ProgramFlowFault::TimingTooEarly,
                ProgramFlowCheckpoint::none(),
                ProgramFlowCheckpoint::none(),
                now_us,
            );
            return;
        }

        if relative_us > WATCHDOG_SERVICE_MAX_US {
            self.RecordFault(
                ProgramFlowFault::WatchdogWindowClosed,
                ProgramFlowCheckpoint::none(),
                ProgramFlowCheckpoint::none(),
                now_us,
            );
            return;
        }

        self._state = ProgramFlowState::ServiceAuthorized;
        watchdog.Refresh(WWDG_RELOAD_COUNTER);
        self.StartNextCycle();
    }

    #[inline]
    fn IsCycleComplete(&self) -> bool {
        self._expectedIndex == self._expectedCheckpointCount
    }

    #[inline]
    fn StartNextCycle(&mut self) {
        self._state = ProgramFlowState::Running;
        self.SetExpectedIndex(0);
        self.SetCycleStart(
            self._cycleStartUs
                .saturating_add(SUPERVISION_CYCLE_US as u64),
        );
        self.SetCycleCount(self._cycleCount.saturating_add(1));
        self._lastCheckpoint = ProgramFlowCheckpoint::none();
    }

    #[inline]
    fn RelativeTimestamp(&self, now_us: u64) -> u32 {
        now_us
            .saturating_sub(self._cycleStartUs)
            .min(u32::MAX as u64) as u32
    }

    #[inline]
    fn ExpectedCheckpoint(&self) -> ProgramFlowCheckpoint {
        let expectedIndex = self._expectedIndex as usize;
        if expectedIndex < self._expectedCheckpointCount as usize {
            self._expectedCheckpoints[expectedIndex].checkpoint
        } else {
            ProgramFlowCheckpoint::none()
        }
    }

    fn RecordFault(
        &mut self,
        fault: ProgramFlowFault,
        expected: ProgramFlowCheckpoint,
        received: ProgramFlowCheckpoint,
        now_us: u64,
    ) {
        self._diagnostic = ProgramFlowDiagnostic {
            fault,
            expected,
            received,
            sequenceIndex: self._expectedIndex,
            cycleCount: self._cycleCount,
            timestamp_us: now_us,
            relative_us: self.RelativeTimestamp(now_us),
        };
        self._state = ProgramFlowState::Faulted;
    }

    #[inline]
    fn CheckInternalState(&self) -> bool {
        self._expectedCheckpointCount == !self._expectedCheckpointCountInv
            && self._expectedIndex == !self._expectedIndexInv
            && self._cycleStartUs == !self._cycleStartUsInv
            && self._cycleCount == !self._cycleCountInv
    }

    #[inline]
    fn SetExpectedCheckpointCount(&mut self, expectedCheckpointCount: u32) {
        self._expectedCheckpointCount = expectedCheckpointCount;
        self._expectedCheckpointCountInv = !expectedCheckpointCount;
    }

    #[inline]
    fn SetExpectedIndex(&mut self, expectedIndex: u32) {
        self._expectedIndex = expectedIndex;
        self._expectedIndexInv = !expectedIndex;
    }

    #[inline]
    fn SetCycleStart(&mut self, cycleStartUs: u64) {
        self._cycleStartUs = cycleStartUs;
        self._cycleStartUsInv = !cycleStartUs;
    }

    #[inline]
    fn SetCycleCount(&mut self, cycleCount: u32) {
        self._cycleCount = cycleCount;
        self._cycleCountInv = !cycleCount;
    }
}
unsafe impl Send for ProgramFlowMonitor {}
