# DD-001 — Software unit design: HallInterface

## Input, traction and platform derivation gates

`U-HALL-CAPTURE` owns current sampled-state/edge evidence and capture health, and `U-HALL-POSITION` publishes electrical position only with accepted map/alignment. These units invalidate their own result on producer/reset/configuration/health failure and preserve no prior value as a substitute.
