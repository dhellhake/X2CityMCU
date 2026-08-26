#![allow(non_snake_case)]

use crate::os::task::{TaskConfiguration, TaskRole};

pub const SUPERVISION_CYCLE_US: u32 = 10_000;
pub const WATCHDOG_SERVICE_MIN_US: u32 = SUPERVISION_CYCLE_US;
// The next 5 ms task release occurs at +15 ms and has higher scheduler
// priority than the still-pending service task. Keep the service deadline
// strictly before that release so the declared window is actually reachable.
pub const WATCHDOG_SERVICE_MAX_US: u32 = 14_900;

const _: () = assert!(WATCHDOG_SERVICE_MAX_US < 15_000);

const MAX_EXPECTED_CHECKPOINTS: usize = 16;
const CHECKPOINT_EARLY_TOLERANCE_US: u32 = 1_000;
const CHECKPOINT_START_LATE_TOLERANCE_US: u32 = 2_000;
const CHECKPOINT_END_AFTER_START_US: u32 = 500;
const SAME_RELEASE_PRIORITY_SLOT_US: u32 = 2_000;

// Deliberately distant bit patterns reduce the chance that a single memory
// fault can turn one valid controller phase into another valid phase.
const CONTROLLER_PHASE_UNINITIALIZED: u32 = 0x4E2B_91C7;
const CONTROLLER_PHASE_RUNTIME: u32 = 0x2BEE_AEFD;
const CONTROLLER_PHASE_FAULTED: u32 = 0xD962_4B70;

const _: () = {
    let phases = [
        CONTROLLER_PHASE_UNINITIALIZED,
        CONTROLLER_PHASE_RUNTIME,
        CONTROLLER_PHASE_FAULTED,
    ];
    let mut left = 0;
    while left < phases.len() {
        let mut right = left + 1;
        while right < phases.len() {
            assert!((phases[left] ^ phases[right]).count_ones() >= 16);
            // A two-word transposition of (phase, !phase) must not become a
            // different valid phase codeword.
            assert!(phases[left] != !phases[right]);
            right += 1;
        }
        left += 1;
    }
};

/// One-way guard around scheduler supervision activation. Re-entering
/// Scheduler_Start must never restart RTWDOG independently from the cyclic
/// release timeline that authorizes its subsequent refreshes.
pub(crate) struct ProgramFlowStartGuard {
    _phase: u32,
    _phaseInv: u32,
}

impl ProgramFlowStartGuard {
    pub const fn new() -> Self {
        Self {
            _phase: CONTROLLER_PHASE_UNINITIALIZED,
            _phaseInv: !CONTROLLER_PHASE_UNINITIALIZED,
        }
    }

    pub fn EnterRunning(&mut self) -> bool {
        self.Transition(CONTROLLER_PHASE_UNINITIALIZED, CONTROLLER_PHASE_RUNTIME)
    }

    fn Transition(&mut self, expected: u32, next: u32) -> bool {
        if self._phase != !self._phaseInv || self._phase != expected {
            self._phase = CONTROLLER_PHASE_FAULTED;
            self._phaseInv = !CONTROLLER_PHASE_FAULTED;
            return false;
        }

        self._phase = next;
        self._phaseInv = !next;
        true
    }
}

unsafe impl Send for ProgramFlowStartGuard {}

#[repr(u32)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum ProgramFlowCheckpointKind {
    None = 0,
    Start = 1,
    End = 2,
    Unknown = 0xFFFF_FFFF,
}

#[repr(C)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct ProgramFlowCheckpoint {
    pub taskId: u32,
    pub kind: ProgramFlowCheckpointKind,
}

impl ProgramFlowCheckpoint {
    pub const fn new(taskId: u32, kind: ProgramFlowCheckpointKind) -> Self {
        Self { taskId, kind }
    }

    pub const fn none() -> Self {
        Self::new(u32::MAX, ProgramFlowCheckpointKind::None)
    }

    pub const fn unknown() -> Self {
        Self::new(u32::MAX, ProgramFlowCheckpointKind::Unknown)
    }
}

#[repr(u32)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum ProgramFlowState {
    Uninitialized = 0,
    Running = 1,
    ServiceAuthorized = 2,
    Faulted = 3,
    Corrupted = 0xFFFF_FFFF,
}

#[repr(u32)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
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
    ServiceReleaseMismatch = 10,
    Corrupted = 0xFFFF_FFFF,
}

#[repr(C)]
#[derive(Copy, Clone, Debug)]
pub struct ProgramFlowDiagnostic {
    pub fault: ProgramFlowFault,
    pub expected: ProgramFlowCheckpoint,
    pub received: ProgramFlowCheckpoint,
    pub sequenceIndex: u32,
    pub cycleCount: u32,
    pub timestampUs: u64,
    pub relativeUs: u32,
}

impl ProgramFlowDiagnostic {
    pub const fn new() -> Self {
        Self {
            fault: ProgramFlowFault::None,
            expected: ProgramFlowCheckpoint::none(),
            received: ProgramFlowCheckpoint::none(),
            sequenceIndex: 0,
            cycleCount: 0,
            timestampUs: 0,
            relativeUs: 0,
        }
    }
}

impl Default for ProgramFlowDiagnostic {
    fn default() -> Self {
        Self::new()
    }
}

#[repr(C)]
#[derive(Copy, Clone, PartialEq, Eq)]
struct StoredCheckpoint {
    taskId: u32,
    kind: u32,
}

impl StoredCheckpoint {
    const fn Store(checkpoint: ProgramFlowCheckpoint) -> Self {
        Self {
            taskId: checkpoint.taskId,
            kind: checkpoint.kind as u32,
        }
    }

    const fn none() -> Self {
        Self::Store(ProgramFlowCheckpoint::none())
    }

    fn Decode(self) -> ProgramFlowCheckpoint {
        ProgramFlowCheckpoint::new(self.taskId, DecodeCheckpointKind(self.kind))
    }

    fn Matches(self, checkpoint: ProgramFlowCheckpoint) -> bool {
        self.taskId == checkpoint.taskId && self.kind == checkpoint.kind as u32
    }
}

#[repr(C)]
#[derive(Copy, Clone)]
struct StoredDiagnostic {
    fault: u32,
    expected: StoredCheckpoint,
    received: StoredCheckpoint,
    sequenceIndex: u32,
    cycleCount: u32,
    timestampUs: u64,
    relativeUs: u32,
}

impl StoredDiagnostic {
    const fn new() -> Self {
        Self {
            fault: ProgramFlowFault::None as u32,
            expected: StoredCheckpoint::none(),
            received: StoredCheckpoint::none(),
            sequenceIndex: 0,
            cycleCount: 0,
            timestampUs: 0,
            relativeUs: 0,
        }
    }

    fn Decode(self) -> ProgramFlowDiagnostic {
        ProgramFlowDiagnostic {
            fault: DecodeFault(self.fault),
            expected: self.expected.Decode(),
            received: self.received.Decode(),
            sequenceIndex: self.sequenceIndex,
            cycleCount: self.cycleCount,
            timestampUs: self.timestampUs,
            relativeUs: self.relativeUs,
        }
    }
}

const fn DecodeCheckpointKind(kind: u32) -> ProgramFlowCheckpointKind {
    match kind {
        0 => ProgramFlowCheckpointKind::None,
        1 => ProgramFlowCheckpointKind::Start,
        2 => ProgramFlowCheckpointKind::End,
        _ => ProgramFlowCheckpointKind::Unknown,
    }
}

const fn DecodeFault(fault: u32) -> ProgramFlowFault {
    match fault {
        0 => ProgramFlowFault::None,
        1 => ProgramFlowFault::StartupIncomplete,
        2 => ProgramFlowFault::OmittedExecution,
        3 => ProgramFlowFault::DuplicateExecution,
        4 => ProgramFlowFault::IncorrectSequence,
        5 => ProgramFlowFault::IncompleteExecution,
        6 => ProgramFlowFault::TimingTooEarly,
        7 => ProgramFlowFault::TimingTooLate,
        8 => ProgramFlowFault::WatchdogWindowClosed,
        9 => ProgramFlowFault::InternalMonitorFailure,
        10 => ProgramFlowFault::ServiceReleaseMismatch,
        _ => ProgramFlowFault::Corrupted,
    }
}

#[repr(C)]
#[derive(Copy, Clone, Debug)]
pub struct ProgramFlowSnapshot {
    pub state: ProgramFlowState,
    pub expectedCheckpointCount: u32,
    pub expectedIndex: u32,
    pub cycleCount: u32,
    pub cycleStartUs: u64,
    pub watchdogAlignmentTimestampUs: u64,
    pub lastServiceTimestampUs: u64,
    pub resetStatusAtStartup: u32,
    pub lastCheckpoint: ProgramFlowCheckpoint,
    pub diagnostic: ProgramFlowDiagnostic,
}

#[repr(C)]
#[derive(Copy, Clone)]
struct CheckpointSpec {
    checkpoint: StoredCheckpoint,
    releaseUs: u32,
    minUs: u32,
    maxUs: u32,
}

impl CheckpointSpec {
    const fn empty() -> Self {
        Self {
            checkpoint: StoredCheckpoint::none(),
            releaseUs: 0,
            minUs: 0,
            maxUs: 0,
        }
    }

    const fn new(
        checkpoint: ProgramFlowCheckpoint,
        releaseUs: u32,
        minUs: u32,
        maxUs: u32,
    ) -> Self {
        Self {
            checkpoint: StoredCheckpoint::Store(checkpoint),
            releaseUs,
            minUs,
            maxUs,
        }
    }
}

#[repr(C)]
pub struct ProgramFlowMonitor {
    // Integrity-protected control values are stored as integers. Reading an
    // invalid Rust enum discriminant would itself be undefined behavior,
    // preventing the inverse check from safely detecting memory corruption.
    _state: u32,
    _stateInv: u32,
    _expectedCheckpoints: [CheckpointSpec; MAX_EXPECTED_CHECKPOINTS],
    _expectedCheckpointCount: u32,
    _expectedCheckpointCountInv: u32,
    _expectedCheckpointsSignature: u32,
    _expectedCheckpointsSignatureInv: u32,
    _expectedIndex: u32,
    _expectedIndexInv: u32,
    _cycleStartUs: u64,
    _cycleStartUsInv: u64,
    _watchdogAlignmentTimestampUs: u64,
    _watchdogAlignmentTimestampUsInv: u64,
    _cycleCount: u32,
    _cycleCountInv: u32,
    _lastServiceTimestampUs: u64,
    _lastServiceTimestampUsInv: u64,
    _resetStatusAtStartup: u32,
    _lastCheckpoint: StoredCheckpoint,
    _diagnostic: StoredDiagnostic,
}

impl ProgramFlowMonitor {
    pub const fn new() -> Self {
        Self {
            _state: ProgramFlowState::Uninitialized as u32,
            _stateInv: !(ProgramFlowState::Uninitialized as u32),
            _expectedCheckpoints: [CheckpointSpec::empty(); MAX_EXPECTED_CHECKPOINTS],
            _expectedCheckpointCount: 0,
            _expectedCheckpointCountInv: !0,
            _expectedCheckpointsSignature: 0,
            _expectedCheckpointsSignatureInv: !0,
            _expectedIndex: 0,
            _expectedIndexInv: !0,
            _cycleStartUs: 0,
            _cycleStartUsInv: !0,
            _watchdogAlignmentTimestampUs: 0,
            _watchdogAlignmentTimestampUsInv: !0,
            _cycleCount: 0,
            _cycleCountInv: !0,
            _lastServiceTimestampUs: 0,
            _lastServiceTimestampUsInv: !0,
            _resetStatusAtStartup: 0,
            _lastCheckpoint: StoredCheckpoint::none(),
            _diagnostic: StoredDiagnostic::new(),
        }
    }

    /// Builds the expected cyclic flow at the same epoch used for both the
    /// scheduler release base and RTWDOG's explicit alignment refresh.
    pub fn ConfigureAtSchedulerEpoch<const TASK_COUNT: usize>(
        &mut self,
        tasks: &[TaskConfiguration; TASK_COUNT],
        schedulerEpochUs: u64,
        resetStatus: u32,
    ) -> bool {
        self.SetState(ProgramFlowState::Running);
        self._expectedCheckpoints = [CheckpointSpec::empty(); MAX_EXPECTED_CHECKPOINTS];
        self.SetExpectedCheckpointCount(0);
        self.SetExpectedCheckpointsSignature(0);
        self.SetExpectedIndex(0);
        self.SetCycleStart(schedulerEpochUs);
        self.SetWatchdogAlignmentTimestamp(schedulerEpochUs);
        self.SetCycleCount(0);
        self.SetLastServiceTimestamp(0);
        self._resetStatusAtStartup = resetStatus;
        self._lastCheckpoint = StoredCheckpoint::none();
        self._diagnostic = StoredDiagnostic::new();

        let mut serviceTaskCount = 0u32;
        let mut serviceTaskIndex = TASK_COUNT;

        for (taskIdx, task) in tasks.iter().enumerate() {
            if task.id != taskIdx as u32 {
                self.RecordFault(
                    ProgramFlowFault::StartupIncomplete,
                    ProgramFlowCheckpoint::unknown(),
                    ProgramFlowCheckpoint::new(task.id, ProgramFlowCheckpointKind::Unknown),
                    schedulerEpochUs,
                );
                return false;
            }

            if task.role.IsUnsupervised()
                && task.cycletime.period_us() == Some(SUPERVISION_CYCLE_US as u64)
            {
                serviceTaskCount = serviceTaskCount.saturating_add(1);
                serviceTaskIndex = taskIdx;
                continue;
            }

            if matches!(task.role, TaskRole::Supervised)
                && !task.role.ReportsProgramFlowCheckpoints(task.cycletime)
            {
                self.RecordFault(
                    ProgramFlowFault::StartupIncomplete,
                    ProgramFlowCheckpoint::unknown(),
                    ProgramFlowCheckpoint::new(task.id, ProgramFlowCheckpointKind::Unknown),
                    schedulerEpochUs,
                );
                return false;
            }

            if !task.role.ReportsProgramFlowCheckpoints(task.cycletime) {
                continue;
            }

            let Some(periodUs) = task.cycletime.period_us() else {
                self.RecordFault(
                    ProgramFlowFault::StartupIncomplete,
                    ProgramFlowCheckpoint::unknown(),
                    ProgramFlowCheckpoint::new(task.id, ProgramFlowCheckpointKind::Unknown),
                    schedulerEpochUs,
                );
                return false;
            };

            if periodUs == 0
                || periodUs > SUPERVISION_CYCLE_US as u64
                || !(SUPERVISION_CYCLE_US as u64).is_multiple_of(periodUs)
            {
                self.RecordFault(
                    ProgramFlowFault::StartupIncomplete,
                    ProgramFlowCheckpoint::unknown(),
                    ProgramFlowCheckpoint::new(task.id, ProgramFlowCheckpointKind::Unknown),
                    schedulerEpochUs,
                );
                return false;
            }

            let mut releaseUs = periodUs as u32;
            while releaseUs <= SUPERVISION_CYCLE_US {
                let prioritySlot = Self::SameReleasePrioritySlot(tasks, taskIdx, releaseUs);
                self.InsertTaskReleaseCheckpoints(
                    task.id,
                    releaseUs,
                    prioritySlot,
                    schedulerEpochUs,
                );

                if self.IsFaulted() {
                    return false;
                }

                releaseUs = releaseUs.saturating_add(periodUs as u32);
            }
        }

        if serviceTaskCount != 1 || self._expectedCheckpointCount == 0 {
            self.RecordFault(
                ProgramFlowFault::StartupIncomplete,
                ProgramFlowCheckpoint::unknown(),
                ProgramFlowCheckpoint::none(),
                schedulerEpochUs,
            );
            return false;
        }

        // Scheduler priority follows task index. The service task must run
        // after every supervised task due in the same supervision cycle.
        for task in tasks.iter().skip(serviceTaskIndex + 1) {
            if task.role.ReportsProgramFlowCheckpoints(task.cycletime) {
                self.RecordFault(
                    ProgramFlowFault::StartupIncomplete,
                    ProgramFlowCheckpoint::unknown(),
                    ProgramFlowCheckpoint::new(task.id, ProgramFlowCheckpointKind::Unknown),
                    schedulerEpochUs,
                );
                return false;
            }
        }

        let signature = self.CalculateExpectedCheckpointsSignature();
        self.SetExpectedCheckpointsSignature(signature);
        true
    }

    pub fn ReportTaskStart(&mut self, taskId: u32, nowUs: u64) {
        self.ReportCheckpoint(
            ProgramFlowCheckpoint::new(taskId, ProgramFlowCheckpointKind::Start),
            nowUs,
        );
    }

    pub fn ReportTaskEnd(&mut self, taskId: u32, nowUs: u64) {
        self.ReportCheckpoint(
            ProgramFlowCheckpoint::new(taskId, ProgramFlowCheckpointKind::End),
            nowUs,
        );
    }

    /// Validates one supervision cycle and transitions to a one-shot service
    /// authorization. The MCU layer must refresh RTWDOG and immediately call
    /// ConfirmWatchdogService while still in the same critical section.
    pub fn AuthorizeWatchdogService(&mut self, scheduledReleaseUs: u64, nowUs: u64) -> bool {
        if self.IsFaulted() {
            return false;
        }

        if !self.CheckInternalState() {
            self.RecordFault(
                ProgramFlowFault::InternalMonitorFailure,
                ProgramFlowCheckpoint::unknown(),
                ProgramFlowCheckpoint::none(),
                nowUs,
            );
            return false;
        }

        if !self.StateIs(ProgramFlowState::Running) {
            self.RecordFault(
                ProgramFlowFault::InternalMonitorFailure,
                ProgramFlowCheckpoint::unknown(),
                ProgramFlowCheckpoint::none(),
                nowUs,
            );
            return false;
        }

        if self._expectedIndex != self._expectedCheckpointCount {
            self.RecordFault(
                ProgramFlowFault::IncompleteExecution,
                self.ExpectedCheckpoint(),
                ProgramFlowCheckpoint::none(),
                nowUs,
            );
            return false;
        }

        let Some(expectedReleaseUs) = self._cycleStartUs.checked_add(SUPERVISION_CYCLE_US as u64)
        else {
            self.RecordFault(
                ProgramFlowFault::InternalMonitorFailure,
                ProgramFlowCheckpoint::unknown(),
                ProgramFlowCheckpoint::none(),
                nowUs,
            );
            return false;
        };
        if scheduledReleaseUs != expectedReleaseUs {
            self.RecordFault(
                ProgramFlowFault::ServiceReleaseMismatch,
                ProgramFlowCheckpoint::none(),
                ProgramFlowCheckpoint::none(),
                nowUs,
            );
            return false;
        }

        if nowUs < scheduledReleaseUs {
            self.RecordFault(
                ProgramFlowFault::TimingTooEarly,
                ProgramFlowCheckpoint::none(),
                ProgramFlowCheckpoint::none(),
                nowUs,
            );
            return false;
        }

        // The first ordinary refresh is measured from the explicit RTWDOG /
        // scheduler alignment epoch. Later refreshes use the fixed 10 ms
        // cycle grid advanced by StartNextCycle (never `now + period`).
        let serviceRelativeUs = if self._cycleCount == 0 {
            nowUs
                .saturating_sub(self._watchdogAlignmentTimestampUs)
                .min(u32::MAX as u64) as u32
        } else {
            self.RelativeTimestamp(nowUs)
        };

        if serviceRelativeUs < WATCHDOG_SERVICE_MIN_US {
            self.RecordFault(
                ProgramFlowFault::TimingTooEarly,
                ProgramFlowCheckpoint::none(),
                ProgramFlowCheckpoint::none(),
                nowUs,
            );
            return false;
        }

        if serviceRelativeUs > WATCHDOG_SERVICE_MAX_US {
            self.RecordFault(
                ProgramFlowFault::WatchdogWindowClosed,
                ProgramFlowCheckpoint::none(),
                ProgramFlowCheckpoint::none(),
                nowUs,
            );
            return false;
        }

        self.SetState(ProgramFlowState::ServiceAuthorized);
        true
    }

    pub fn ConfirmWatchdogService(&mut self, nowUs: u64) {
        if !self.StateIs(ProgramFlowState::ServiceAuthorized) {
            self.RecordFault(
                ProgramFlowFault::InternalMonitorFailure,
                ProgramFlowCheckpoint::unknown(),
                ProgramFlowCheckpoint::none(),
                nowUs,
            );
            return;
        }

        self.SetLastServiceTimestamp(nowUs);
        self.StartNextCycle(nowUs);
    }

    pub fn RejectWatchdogService(&mut self, nowUs: u64) {
        self.RecordFault(
            ProgramFlowFault::InternalMonitorFailure,
            ProgramFlowCheckpoint::none(),
            ProgramFlowCheckpoint::none(),
            nowUs,
        );
    }

    #[inline]
    pub fn GetSnapshot(&self) -> ProgramFlowSnapshot {
        ProgramFlowSnapshot {
            state: Self::DecodeState(self._state).unwrap_or(ProgramFlowState::Corrupted),
            expectedCheckpointCount: self._expectedCheckpointCount,
            expectedIndex: self._expectedIndex,
            cycleCount: self._cycleCount,
            cycleStartUs: self._cycleStartUs,
            watchdogAlignmentTimestampUs: self._watchdogAlignmentTimestampUs,
            lastServiceTimestampUs: self._lastServiceTimestampUs,
            resetStatusAtStartup: self._resetStatusAtStartup,
            lastCheckpoint: self._lastCheckpoint.Decode(),
            diagnostic: self._diagnostic.Decode(),
        }
    }

    #[inline]
    pub fn IsFaulted(&self) -> bool {
        self.StateIs(ProgramFlowState::Faulted)
    }

    fn InsertTaskReleaseCheckpoints(
        &mut self,
        taskId: u32,
        releaseUs: u32,
        prioritySlot: u32,
        nowUs: u64,
    ) {
        let minUs = releaseUs.saturating_sub(CHECKPOINT_EARLY_TOLERANCE_US);
        let slotDelayUs = prioritySlot.saturating_mul(SAME_RELEASE_PRIORITY_SLOT_US);
        let startMaxUs = releaseUs
            .saturating_add(CHECKPOINT_START_LATE_TOLERANCE_US)
            .saturating_add(slotDelayUs);
        let endMaxUs = startMaxUs.saturating_add(CHECKPOINT_END_AFTER_START_US);

        self.InsertCheckpointSpec(
            CheckpointSpec::new(
                ProgramFlowCheckpoint::new(taskId, ProgramFlowCheckpointKind::Start),
                releaseUs,
                minUs,
                startMaxUs,
            ),
            nowUs,
        );
        self.InsertCheckpointSpec(
            CheckpointSpec::new(
                ProgramFlowCheckpoint::new(taskId, ProgramFlowCheckpointKind::End),
                releaseUs,
                minUs,
                endMaxUs,
            ),
            nowUs,
        );
    }

    fn InsertCheckpointSpec(&mut self, specification: CheckpointSpec, nowUs: u64) {
        let count = self._expectedCheckpointCount as usize;
        if count >= MAX_EXPECTED_CHECKPOINTS {
            self.RecordFault(
                ProgramFlowFault::StartupIncomplete,
                ProgramFlowCheckpoint::unknown(),
                specification.checkpoint.Decode(),
                nowUs,
            );
            return;
        }

        let mut insertIdx = count;
        while insertIdx > 0
            && Self::CheckpointComesBefore(specification, self._expectedCheckpoints[insertIdx - 1])
        {
            self._expectedCheckpoints[insertIdx] = self._expectedCheckpoints[insertIdx - 1];
            insertIdx -= 1;
        }

        self._expectedCheckpoints[insertIdx] = specification;
        self.SetExpectedCheckpointCount(self._expectedCheckpointCount + 1);
    }

    #[inline]
    fn CheckpointComesBefore(left: CheckpointSpec, right: CheckpointSpec) -> bool {
        if left.releaseUs != right.releaseUs {
            return left.releaseUs < right.releaseUs;
        }
        if left.checkpoint.taskId != right.checkpoint.taskId {
            return left.checkpoint.taskId < right.checkpoint.taskId;
        }

        left.checkpoint.kind < right.checkpoint.kind
    }

    fn SameReleasePrioritySlot<const TASK_COUNT: usize>(
        tasks: &[TaskConfiguration; TASK_COUNT],
        taskIdx: usize,
        releaseUs: u32,
    ) -> u32 {
        let mut slot = 0;

        for task in tasks.iter().take(taskIdx) {
            if !task.role.ReportsProgramFlowCheckpoints(task.cycletime) {
                continue;
            }

            if let Some(periodUs) = task.cycletime.period_us() {
                if periodUs != 0 && (releaseUs as u64).is_multiple_of(periodUs) {
                    slot += 1;
                }
            }
        }

        slot
    }

    fn ReportCheckpoint(&mut self, checkpoint: ProgramFlowCheckpoint, nowUs: u64) {
        if self.IsFaulted() {
            return;
        }

        if !self.CheckInternalState() {
            self.RecordFault(
                ProgramFlowFault::InternalMonitorFailure,
                ProgramFlowCheckpoint::unknown(),
                checkpoint,
                nowUs,
            );
            return;
        }

        if !self.StateIs(ProgramFlowState::Running) {
            self.RecordFault(
                ProgramFlowFault::StartupIncomplete,
                ProgramFlowCheckpoint::unknown(),
                checkpoint,
                nowUs,
            );
            return;
        }

        let expectedIndex = self._expectedIndex as usize;
        if expectedIndex >= self._expectedCheckpointCount as usize {
            self.RecordFault(
                ProgramFlowFault::DuplicateExecution,
                ProgramFlowCheckpoint::none(),
                checkpoint,
                nowUs,
            );
            return;
        }

        let expected = self._expectedCheckpoints[expectedIndex];
        if !expected.checkpoint.Matches(checkpoint) {
            let fault = if expectedIndex > 0
                && self._expectedCheckpoints[expectedIndex - 1]
                    .checkpoint
                    .Matches(checkpoint)
            {
                ProgramFlowFault::DuplicateExecution
            } else if matches!(checkpoint.kind, ProgramFlowCheckpointKind::End) {
                ProgramFlowFault::OmittedExecution
            } else {
                ProgramFlowFault::IncorrectSequence
            };

            self.RecordFault(fault, expected.checkpoint.Decode(), checkpoint, nowUs);
            return;
        }

        let relativeUs = self.RelativeTimestamp(nowUs);
        if relativeUs < expected.minUs {
            self.RecordFault(
                ProgramFlowFault::TimingTooEarly,
                expected.checkpoint.Decode(),
                checkpoint,
                nowUs,
            );
            return;
        }
        if relativeUs > expected.maxUs {
            self.RecordFault(
                ProgramFlowFault::TimingTooLate,
                expected.checkpoint.Decode(),
                checkpoint,
                nowUs,
            );
            return;
        }

        self._lastCheckpoint = StoredCheckpoint::Store(checkpoint);
        self.SetExpectedIndex(self._expectedIndex + 1);
    }

    #[inline]
    fn StartNextCycle(&mut self, nowUs: u64) {
        let Some(nextCycleStartUs) = self._cycleStartUs.checked_add(SUPERVISION_CYCLE_US as u64)
        else {
            self.RecordFault(
                ProgramFlowFault::InternalMonitorFailure,
                ProgramFlowCheckpoint::unknown(),
                ProgramFlowCheckpoint::none(),
                nowUs,
            );
            return;
        };
        self.SetState(ProgramFlowState::Running);
        self.SetExpectedIndex(0);
        self.SetCycleStart(nextCycleStartUs);
        self.SetCycleCount(self._cycleCount.saturating_add(1));
        self._lastCheckpoint = StoredCheckpoint::none();
    }

    #[inline]
    fn RelativeTimestamp(&self, nowUs: u64) -> u32 {
        nowUs
            .saturating_sub(self._cycleStartUs)
            .min(u32::MAX as u64) as u32
    }

    #[inline]
    fn ExpectedCheckpoint(&self) -> ProgramFlowCheckpoint {
        let expectedIndex = self._expectedIndex as usize;
        if expectedIndex < self._expectedCheckpointCount as usize {
            self._expectedCheckpoints[expectedIndex].checkpoint.Decode()
        } else {
            ProgramFlowCheckpoint::none()
        }
    }

    fn RecordFault(
        &mut self,
        fault: ProgramFlowFault,
        expected: ProgramFlowCheckpoint,
        received: ProgramFlowCheckpoint,
        nowUs: u64,
    ) {
        self._diagnostic = StoredDiagnostic {
            fault: fault as u32,
            expected: StoredCheckpoint::Store(expected),
            received: StoredCheckpoint::Store(received),
            sequenceIndex: self._expectedIndex,
            cycleCount: self._cycleCount,
            timestampUs: nowUs,
            relativeUs: self.RelativeTimestamp(nowUs),
        };
        self.SetState(ProgramFlowState::Faulted);
    }

    #[inline]
    fn CheckInternalState(&self) -> bool {
        let firstCycleTimelineIsConsistent = self._cycleCount != 0
            || (self._watchdogAlignmentTimestampUs == self._cycleStartUs
                && self._lastServiceTimestampUs == 0);

        Self::DecodeState(self._state).is_some()
            && self._state == !self._stateInv
            && self._expectedCheckpointCount == !self._expectedCheckpointCountInv
            && (self._expectedCheckpointCount as usize) <= MAX_EXPECTED_CHECKPOINTS
            && self._expectedCheckpointsSignature == !self._expectedCheckpointsSignatureInv
            && self._expectedCheckpointsSignature == self.CalculateExpectedCheckpointsSignature()
            && self._expectedIndex == !self._expectedIndexInv
            && self._expectedIndex <= self._expectedCheckpointCount
            && self._cycleStartUs == !self._cycleStartUsInv
            && self._watchdogAlignmentTimestampUs == !self._watchdogAlignmentTimestampUsInv
            && self._cycleCount == !self._cycleCountInv
            && self._lastServiceTimestampUs == !self._lastServiceTimestampUsInv
            && firstCycleTimelineIsConsistent
    }

    #[inline]
    fn SetState(&mut self, state: ProgramFlowState) {
        self._state = state as u32;
        self._stateInv = !self._state;
    }

    #[inline]
    fn StateIs(&self, state: ProgramFlowState) -> bool {
        self._state == state as u32
    }

    #[inline]
    const fn DecodeState(state: u32) -> Option<ProgramFlowState> {
        match state {
            0 => Some(ProgramFlowState::Uninitialized),
            1 => Some(ProgramFlowState::Running),
            2 => Some(ProgramFlowState::ServiceAuthorized),
            3 => Some(ProgramFlowState::Faulted),
            _ => None,
        }
    }

    #[inline]
    fn SetExpectedCheckpointCount(&mut self, count: u32) {
        self._expectedCheckpointCount = count;
        self._expectedCheckpointCountInv = !count;
    }

    #[inline]
    fn SetExpectedIndex(&mut self, index: u32) {
        self._expectedIndex = index;
        self._expectedIndexInv = !index;
    }

    #[inline]
    fn SetExpectedCheckpointsSignature(&mut self, signature: u32) {
        self._expectedCheckpointsSignature = signature;
        self._expectedCheckpointsSignatureInv = !signature;
    }

    fn CalculateExpectedCheckpointsSignature(&self) -> u32 {
        let mut signature = 0x811C_9DC5u32;
        signature = Self::MixSignature(signature, self._expectedCheckpointCount);

        for specification in self
            ._expectedCheckpoints
            .iter()
            .take(self._expectedCheckpointCount as usize)
        {
            signature = Self::MixSignature(signature, specification.checkpoint.taskId);
            signature = Self::MixSignature(signature, specification.checkpoint.kind);
            signature = Self::MixSignature(signature, specification.releaseUs);
            signature = Self::MixSignature(signature, specification.minUs);
            signature = Self::MixSignature(signature, specification.maxUs);
        }

        signature
    }

    #[inline]
    const fn MixSignature(signature: u32, value: u32) -> u32 {
        (signature ^ value).wrapping_mul(0x0100_0193)
    }

    #[inline]
    fn SetCycleStart(&mut self, cycleStartUs: u64) {
        self._cycleStartUs = cycleStartUs;
        self._cycleStartUsInv = !cycleStartUs;
    }

    #[inline]
    fn SetWatchdogAlignmentTimestamp(&mut self, timestampUs: u64) {
        self._watchdogAlignmentTimestampUs = timestampUs;
        self._watchdogAlignmentTimestampUsInv = !timestampUs;
    }

    #[inline]
    fn SetCycleCount(&mut self, cycleCount: u32) {
        self._cycleCount = cycleCount;
        self._cycleCountInv = !cycleCount;
    }

    #[inline]
    fn SetLastServiceTimestamp(&mut self, timestampUs: u64) {
        self._lastServiceTimestampUs = timestampUs;
        self._lastServiceTimestampUsInv = !timestampUs;
    }
}

unsafe impl Send for ProgramFlowMonitor {}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::os::task::TaskCycleTime;

    fn ValidConfiguration() -> [TaskConfiguration; 4] {
        [
            TaskConfiguration::new(0, TaskCycleTime::_5MS, TaskRole::Supervised),
            TaskConfiguration::new(1, TaskCycleTime::_10MS, TaskRole::Supervised),
            TaskConfiguration::new(2, TaskCycleTime::_10MS, TaskRole::Unsupervised),
            TaskConfiguration::new(3, TaskCycleTime::NonCyclic, TaskRole::Background),
        ]
    }

    fn ConfiguredMonitor() -> ProgramFlowMonitor {
        let mut monitor = ProgramFlowMonitor::new();
        assert!(monitor.ConfigureAtSchedulerEpoch(&ValidConfiguration(), 0, 0x81));
        monitor
    }

    #[test]
    fn SchedulerSupervisionStartIsOneWayAndIntegrityProtected() {
        let mut guard = ProgramFlowStartGuard::new();
        assert!(guard.EnterRunning());
        assert!(!guard.EnterRunning());
        assert_eq!(guard._phase, CONTROLLER_PHASE_FAULTED);

        let mut corrupted = ProgramFlowStartGuard::new();
        corrupted._phaseInv = corrupted._phase;
        assert!(!corrupted.EnterRunning());
    }

    fn ReportValidCycle(monitor: &mut ProgramFlowMonitor, baseUs: u64) {
        monitor.ReportTaskStart(0, baseUs + 5_000);
        monitor.ReportTaskEnd(0, baseUs + 5_100);
        monitor.ReportTaskStart(0, baseUs + 10_000);
        monitor.ReportTaskEnd(0, baseUs + 10_100);
        monitor.ReportTaskStart(1, baseUs + 10_200);
        monitor.ReportTaskEnd(1, baseUs + 10_300);
    }

    #[test]
    fn ConfiguresExpectedSequenceAndServicesConsecutiveCycles() {
        let mut monitor = ConfiguredMonitor();
        assert_eq!(monitor._expectedCheckpointCount, 6);
        assert_eq!(monitor._resetStatusAtStartup, 0x81);

        ReportValidCycle(&mut monitor, 0);
        assert!(monitor.AuthorizeWatchdogService(10_000, 10_400));
        monitor.ConfirmWatchdogService(10_400);
        assert_eq!(monitor._cycleCount, 1);
        assert_eq!(monitor._lastServiceTimestampUs, 10_400);

        ReportValidCycle(&mut monitor, 10_000);
        assert!(monitor.AuthorizeWatchdogService(20_000, 20_400));
        monitor.ConfirmWatchdogService(20_400);
        assert_eq!(monitor._cycleCount, 2);
        assert!(!monitor.IsFaulted());
    }

    #[test]
    fn FirstServiceUsesTheExplicitSchedulerWatchdogEpoch() {
        const EPOCH_US: u64 = 42_000;

        let mut monitor = ProgramFlowMonitor::new();
        assert!(monitor.ConfigureAtSchedulerEpoch(&ValidConfiguration(), EPOCH_US, 0));
        assert_eq!(monitor.GetSnapshot().watchdogAlignmentTimestampUs, EPOCH_US);

        ReportValidCycle(&mut monitor, EPOCH_US);
        assert!(monitor.AuthorizeWatchdogService(
            EPOCH_US + SUPERVISION_CYCLE_US as u64,
            EPOCH_US + SUPERVISION_CYCLE_US as u64,
        ));
        monitor.ConfirmWatchdogService(EPOCH_US + SUPERVISION_CYCLE_US as u64);
        assert_eq!(
            monitor.GetSnapshot().cycleStartUs,
            EPOCH_US + SUPERVISION_CYCLE_US as u64
        );
    }

    #[test]
    fn LatchesDuplicateCheckpoint() {
        let mut monitor = ConfiguredMonitor();
        monitor.ReportTaskStart(0, 5_000);
        monitor.ReportTaskStart(0, 5_100);
        assert_eq!(
            monitor.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::DuplicateExecution
        );
    }

    #[test]
    fn LatchesEndWithoutExpectedStartAsOmission() {
        let mut monitor = ConfiguredMonitor();
        monitor.ReportTaskEnd(0, 5_000);
        assert_eq!(
            monitor.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::OmittedExecution
        );
    }

    #[test]
    fn RefusesIncompleteCycle() {
        let mut monitor = ConfiguredMonitor();
        monitor.ReportTaskStart(0, 5_000);
        monitor.ReportTaskEnd(0, 5_100);
        assert!(!monitor.AuthorizeWatchdogService(10_000, 10_000));
        assert_eq!(
            monitor.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::IncompleteExecution
        );
    }

    #[test]
    fn EnforcesCheckpointTiming() {
        let mut early = ConfiguredMonitor();
        early.ReportTaskStart(0, 3_999);
        assert_eq!(
            early.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::TimingTooEarly
        );

        let mut late = ConfiguredMonitor();
        late.ReportTaskStart(0, 7_001);
        assert_eq!(
            late.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::TimingTooLate
        );
    }

    #[test]
    fn RejectsMissingOrMisorderedServiceTask() {
        let mut missing = ProgramFlowMonitor::new();
        let missingService = [
            TaskConfiguration::new(0, TaskCycleTime::_5MS, TaskRole::Supervised),
            TaskConfiguration::new(1, TaskCycleTime::_10MS, TaskRole::Supervised),
            TaskConfiguration::new(2, TaskCycleTime::NonCyclic, TaskRole::Background),
        ];
        assert!(!missing.ConfigureAtSchedulerEpoch(&missingService, 0, 0));
        assert_eq!(
            missing.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::StartupIncomplete
        );

        let mut misordered = ProgramFlowMonitor::new();
        let misorderedService = [
            TaskConfiguration::new(0, TaskCycleTime::_5MS, TaskRole::Supervised),
            TaskConfiguration::new(1, TaskCycleTime::_10MS, TaskRole::Unsupervised),
            TaskConfiguration::new(2, TaskCycleTime::_10MS, TaskRole::Supervised),
            TaskConfiguration::new(3, TaskCycleTime::NonCyclic, TaskRole::Background),
        ];
        assert!(!misordered.ConfigureAtSchedulerEpoch(&misorderedService, 0, 0));
        assert_eq!(
            misordered.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::StartupIncomplete
        );
    }

    #[test]
    fn DetectsMonitorStateCorruption() {
        let mut monitor = ConfiguredMonitor();
        monitor._expectedIndexInv = 0;
        monitor.ReportTaskStart(0, 5_000);
        assert_eq!(
            monitor.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::InternalMonitorFailure
        );
    }

    #[test]
    fn DetectsAnInconsistentFirstCycleAlignmentEpoch() {
        let mut monitor = ConfiguredMonitor();
        monitor._watchdogAlignmentTimestampUs = 1;
        monitor._watchdogAlignmentTimestampUsInv = !1;

        monitor.ReportTaskStart(0, 5_000);
        assert_eq!(
            monitor.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::InternalMonitorFailure
        );
    }

    #[test]
    fn DetectsInvalidStateWithoutReadingAnInvalidEnum() {
        let mut monitor = ConfiguredMonitor();
        monitor._state = 0xA5A5_5A5A;
        monitor._stateInv = !monitor._state;

        monitor.ReportTaskStart(0, 5_000);

        assert_eq!(
            monitor.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::InternalMonitorFailure
        );
        assert_eq!(monitor.GetSnapshot().state, ProgramFlowState::Faulted);
    }

    #[test]
    fn DetectsExpectedSequenceCorruptionAndSafelyDecodesDiagnostics() {
        let mut monitor = ConfiguredMonitor();
        monitor._expectedCheckpoints[0].checkpoint.kind = 0xA5A5_5A5A;

        monitor.ReportTaskStart(0, 5_000);

        assert_eq!(
            monitor.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::InternalMonitorFailure
        );

        monitor._diagnostic.fault = 0xA5A5_5A5A;
        monitor._diagnostic.received.kind = 0x5A5A_A5A5;
        let diagnostic = monitor.GetSnapshot().diagnostic;
        assert_eq!(diagnostic.fault, ProgramFlowFault::Corrupted);
        assert_eq!(diagnostic.received.kind, ProgramFlowCheckpointKind::Unknown);
    }

    #[test]
    fn EnforcesWatchdogServiceStateAndLateBoundary() {
        let mut late = ConfiguredMonitor();
        ReportValidCycle(&mut late, 0);
        assert!(!late.AuthorizeWatchdogService(
            SUPERVISION_CYCLE_US as u64,
            WATCHDOG_SERVICE_MAX_US as u64 + 1,
        ));
        assert_eq!(
            late.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::WatchdogWindowClosed
        );

        let mut doubleAuthorization = ConfiguredMonitor();
        ReportValidCycle(&mut doubleAuthorization, 0);
        assert!(doubleAuthorization.AuthorizeWatchdogService(10_000, 10_400));
        assert!(!doubleAuthorization.AuthorizeWatchdogService(10_000, 10_401));
        assert_eq!(
            doubleAuthorization.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::InternalMonitorFailure
        );

        let mut confirmationWithoutAuthorization = ConfiguredMonitor();
        confirmationWithoutAuthorization.ConfirmWatchdogService(10_000);
        assert_eq!(
            confirmationWithoutAuthorization
                .GetSnapshot()
                .diagnostic
                .fault,
            ProgramFlowFault::InternalMonitorFailure
        );

        let mut rejectedHardwareService = ConfiguredMonitor();
        ReportValidCycle(&mut rejectedHardwareService, 0);
        assert!(rejectedHardwareService.AuthorizeWatchdogService(10_000, 10_400));
        rejectedHardwareService.RejectWatchdogService(10_400);
        assert_eq!(
            rejectedHardwareService.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::InternalMonitorFailure
        );
    }

    #[test]
    fn RejectsAStaleOrCollapsedWatchdogTaskRelease() {
        let mut monitor = ConfiguredMonitor();
        ReportValidCycle(&mut monitor, 0);

        assert!(!monitor.AuthorizeWatchdogService(0, 10_400));
        assert_eq!(
            monitor.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::ServiceReleaseMismatch
        );
    }

    #[test]
    fn FirstFaultRemainsLatched() {
        let mut monitor = ConfiguredMonitor();
        monitor.ReportTaskStart(0, 5_000);
        monitor.ReportTaskStart(0, 5_100);
        let firstDiagnostic = monitor.GetSnapshot().diagnostic;

        monitor.ReportTaskEnd(1, 10_000);

        let finalDiagnostic = monitor.GetSnapshot().diagnostic;
        assert_eq!(finalDiagnostic.fault, firstDiagnostic.fault);
        assert_eq!(finalDiagnostic.timestampUs, firstDiagnostic.timestampUs);
        assert_eq!(finalDiagnostic.received, firstDiagnostic.received);
    }

    #[test]
    fn RejectsInvalidTaskMetadataAndCheckpointOverflow() {
        let mut invalidId = ProgramFlowMonitor::new();
        let mut invalidIdConfiguration = ValidConfiguration();
        invalidIdConfiguration[1].id = 7;
        assert!(!invalidId.ConfigureAtSchedulerEpoch(&invalidIdConfiguration, 0, 0));
        assert_eq!(
            invalidId.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::StartupIncomplete
        );

        let mut nonCyclicSupervised = ProgramFlowMonitor::new();
        let nonCyclicConfiguration = [
            TaskConfiguration::new(0, TaskCycleTime::NonCyclic, TaskRole::Supervised),
            TaskConfiguration::new(1, TaskCycleTime::_10MS, TaskRole::Unsupervised),
            TaskConfiguration::new(2, TaskCycleTime::NonCyclic, TaskRole::Background),
        ];
        assert!(!nonCyclicSupervised.ConfigureAtSchedulerEpoch(&nonCyclicConfiguration, 0, 0,));
        assert_eq!(
            nonCyclicSupervised.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::StartupIncomplete
        );

        let mut unsupportedPeriod = ProgramFlowMonitor::new();
        let unsupportedPeriodConfiguration = [
            TaskConfiguration::new(0, TaskCycleTime::_20MS, TaskRole::Supervised),
            TaskConfiguration::new(1, TaskCycleTime::_10MS, TaskRole::Unsupervised),
            TaskConfiguration::new(2, TaskCycleTime::NonCyclic, TaskRole::Background),
        ];
        assert!(!unsupportedPeriod.ConfigureAtSchedulerEpoch(
            &unsupportedPeriodConfiguration,
            0,
            0,
        ));
        assert_eq!(
            unsupportedPeriod.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::StartupIncomplete
        );

        let mut overflow = ProgramFlowMonitor::new();
        let overflowConfiguration = [
            TaskConfiguration::new(0, TaskCycleTime::_5MS, TaskRole::Supervised),
            TaskConfiguration::new(1, TaskCycleTime::_5MS, TaskRole::Supervised),
            TaskConfiguration::new(2, TaskCycleTime::_5MS, TaskRole::Supervised),
            TaskConfiguration::new(3, TaskCycleTime::_5MS, TaskRole::Supervised),
            TaskConfiguration::new(4, TaskCycleTime::_5MS, TaskRole::Supervised),
            TaskConfiguration::new(5, TaskCycleTime::_10MS, TaskRole::Unsupervised),
            TaskConfiguration::new(6, TaskCycleTime::NonCyclic, TaskRole::Background),
        ];
        assert!(!overflow.ConfigureAtSchedulerEpoch(&overflowConfiguration, 0, 0));
        assert_eq!(
            overflow.GetSnapshot().diagnostic.fault,
            ProgramFlowFault::StartupIncomplete
        );
    }
}
