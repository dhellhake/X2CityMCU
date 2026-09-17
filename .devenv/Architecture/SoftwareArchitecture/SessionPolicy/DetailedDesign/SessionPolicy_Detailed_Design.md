# DD-001 — Software unit design: SessionPolicy

### U-SESSION-ELIGIBILITY and U-SESSION-REPORT

Eligibility starts ineligible in each new vehicle context. `U-SESSION-ELIGIBILITY` receives the concrete `AcceleratorPosition` once on `acceleratorPositionIn`; it evaluates contained qualification and retains health/diagnostic evidence even when Position is unavailable. Only the complete parent Ready guard issues an authority token with current context and expiry; any absent, invalid, expired or mismatched prerequisite withdraws it. A recognized parent-defined riding fault latches current-session inhibition, which cleared observation alone cannot remove. The unit consumes self-test results and does not claim their diagnostic coverage or physical inhibition.

Report selection starts empty per context. With no selection, retain the earliest recognized reportable group fault; for an indistinguishable earliest set retain the lowest assigned code. Retain it until restart, above low-charge `0x01`; it cannot rank physical severity, clear inhibition or establish display receipt.
