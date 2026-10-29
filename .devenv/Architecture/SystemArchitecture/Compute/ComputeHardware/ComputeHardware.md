# ComputeHardware
## ComputeHardware requirements

**Type:** Abstract Hardware Requirement. **Target:** `LE-COMPUTE-HW`. **Status:** Draft.


The conditioned wake input remains available while the CPU sleeps; ComputeHardware provides the direct wake path and does not interpret vehicle On/Off. Wake does not establish a software setting receipt, vehicle startup completion, Ready state or drive authorization. Sleep-entry implementation and all electrical values remain open derivation inputs. The current common startup and Ready guards apply after every wake, including when the selected mode retains memory.

## Specification

- [Requirements](Specification/Requirements.sysml)
