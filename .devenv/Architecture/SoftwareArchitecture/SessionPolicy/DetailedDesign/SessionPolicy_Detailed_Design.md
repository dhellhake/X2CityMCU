# DD-001 — Software unit design: SessionPolicy

## Caller supplied execution time

Invocation timing follows the canonical caller supplied `ExecutionTime` contract in [Runtime Integration Contract](../../Runtime_Integration_Contract.md). Component-specific age, expiry and timeout ownership remains defined by each unit contract.


### U-SESSION-ELIGIBILITY and U-SESSION-REPORT

Eligibility starts ineligible in each new vehicle context. `U-SESSION-ELIGIBILITY` receives the concrete `AcceleratorPosition` once on `acceleratorPositionIn`, the exact software-refined `BrakeLeverState` once on `brakeLeverStateIn`, and the estimator's complete `MotorPositionRecord` once on `motorPositionIn`; it evaluates each contained qualification and retains diagnostic evidence even when semantic State or Position is unavailable. Motor-position Qualification preserves its source/reason/event-time/configuration/reset context and continues through this typed input without adding a new Ready guard or generic health route. Brake fault ordering uses Qualification's inherited source context and software recognition time/reason/configuration/reset context, never State measurement time. A recognized brake measurement fault reaches this unit in the full composite and latches current-session inhibition even if U-BRAKE-QUALIFY later requalifies live. Only the complete parent Ready guard issues an authority token with current context and expiry; any absent, invalid, expired or mismatched prerequisite withdraws it. A recognized parent-defined riding fault latches current-session inhibition, which cleared observation alone cannot remove. The unit consumes self-test results and does not claim their diagnostic coverage or physical inhibition.

Report selection starts empty per context. With no selection, retain the earliest recognized reportable group fault; for an indistinguishable earliest set retain the lowest assigned code. Retain it until restart, above low-charge `0x01`; it cannot rank physical severity, clear inhibition or establish display receipt.
