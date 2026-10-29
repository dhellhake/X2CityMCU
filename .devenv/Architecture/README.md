# Architecture and requirements

The current scope is the Draft E/E retrofit on a supplied BMW mechanical platform. The 2026-10-06 owner scope decision is not a release; software realization, electrical allocation and verification remain open.

- [Project definition (PD-001)](../../README.md) controls project obligations.
- [Item definition (ID-001)](ID-001_Item_Definition.md) supplies item context and the external mechanical-platform assumption.
- [Decisions and open issues (DEC-001)](DEC-001_Decisions_and_Open_Issues.md) preserves owner intent, resolutions and outstanding work.
- [Requirements guidance (REQ-001)](REQ-001_Requirements.md) describes the model, traceability, verification, disposition and acceptance gates. Canonical product requirements are the SysML records indexed by [System Architecture](SystemArchitecture/X2CityMCU.md).
- [Hardware architecture](ARCH-002_Hardware_Architecture.md), [functional concept](FC-001_Functional_Concept.md), [safety analysis](../Safety/HARA-001_Hazard_Analysis.md), and [selected battery/BMS reference](SystemArchitecture/BatteryControl/BatteryAssembly/BatteryAssembly.md#fixed-inputs-and-provenance) retain their own scope and status.
- [Brake interface evidence](SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/BrakeSignalMeasurement/BrakeSignalMeasurement.md), [VD18MT implementation evidence](SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md), and the [independent VD18MT reference](SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#vd18mt-device-reference-vd18mt-tongsheng-uart-interface) retain their evidence qualifications.

## Authority and maintenance

Keep current Draft obligations, earlier approvals, assumptions, exclusions and executed evidence distinct. Deferred and Withdrawn requirements are inactive. Update the controlling decision and affected requirements and context together; preserve retained identifiers and review the impact of substantive changes. Provisional calibration and component data are not validation or vehicle acceptance.

## Release and history

REQ-001-R2.0 was released by Dominik on 2026-09-14; prior requirements, item-definition, architecture and safety releases retain their own scope and status in Git. No earlier release approves the 2026-10-06 scope change. Release does not establish implementation, physical verification, vehicle qualification or Completion B. Substantive changes require controlled revision, owner approval and affected re-verification.
