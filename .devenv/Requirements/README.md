# Item Definition & Requirements

**Current successor:** [REQ-001](REQ-001_Requirements.md) and affected item/decision records are Draft, updated 2026-10-06 to scope the project to the E/E retrofit on a supplied BMW mechanical platform. The 2026-10-06 owner scope decision is not a release; prior released snapshots remain in Git. Software realization and detailed design are pending; this index retains System and abstract requirement obligations while future realization is derived.

**Released baseline:** REQ-001-R2.0 (2026-09-14) remains the 228-record release and approves five Hall-position/FOC-control records. Completion B, characterization, safety/design and executed verification remain open; Git preserves earlier baselines.

| Document | Release / content |
|---|---|
| [PD-001](../../README.md) | Current Draft project definition; PD-001-R1.1 remains the released baseline |
| [ID-001](ID-001_Item_Definition.md) | Current item context; ID-001-R1.0 remains the released baseline |
| [REQ-001](REQ-001_Requirements.md) | Current 316-record catalogue (five inactive records retained), requirement model and canonical clusters |
| [HARA-001 / SG-001](../Safety/HARA-001_Hazard_Analysis.md) | Prior release contains 11 goals; current Draft successor retains 8 goals and 28 events after scope change; physical electrical safety evidence remains open |
| [DEC-001](DEC-001_Decisions_and_Open_Issues.md) | Current owner decisions and open issue register; `WS-OI-020(B)` remains open |
| [ARCH-001](../Architecture/SystemArchitecture/ARCH-001_System_Architecture.md) | Prior release ARCH-001-R1.0 remains historical; current Draft successor removes mechanical-only elements and reallocates surviving E/E responsibilities |
| [ARCH-002](../Architecture/ARCH-002_Hardware_Architecture.md) | Prior release remains historical; current Draft successor aligns hardware scope to the E/E retrofit; software realization is pending |
| [FC-001 / FC-002](../Architecture/FC-001_Functional_Concept.md) | Prior releases remain historical; current Draft trace aligns to surviving requirements and the active 8-goal safety set; 9 FSC requirements remain Draft |
| [Selected battery/BMS reference](../Battery/BAT-001_Selected_Pack_and_BMS.md) | Frozen source snapshot: Draft0.1; selected components, manufacturer evidence and qualified derivations; no integration acceptance claimed |
| [Brake interface evidence](evidence/Brake_Input_Reference.md) | Revision 1.0: fixed shared coded interface, provenance, values and diagnostic limitations |
| [VD18MT implementation evidence](evidence/VD18MT_Implementation_Reference.md) | Revision 1.0: historical tested source and evidence qualifications |
| [Independent VD18MT reference](../VD18MT/VD18MT_Tongsheng_UART_Interface.md) | Revision 1.0: project-independent device/interface definition |

## Authority and maintenance

The PD controls project obligations. ID-001 supplies item context and the canonical external mechanical-platform assumption; REQ-001 defines the current Draft requirement model/index/disposition; DEC-001 preserves owner intent and issue resolution. Keep prior approvals, current draft obligations, assumptions and executed evidence distinct.

All explicit parameters, assumptions, exclusions and evidence gates retain their qualifications. The provisional 35% neutral and exponential-like preference are not validated calibration. Deferred/Withdrawn requirements are inactive. Document release does not establish vehicle verification or close outstanding engineering.

Update the controlling decision and affected requirements/context together. Preserve IDs for retained/reframed requirements and remove active references to removed rows. The 2026-10-06 scope change is Draft; no earlier REQ/ARCH/FC/HARA release approves it. Complete E/E allocation, software realization, sensing realization, safety derivation and electrical verification remain open gates.

## Release and history

`REQ-001-R2.0` was released by Dominik on 2026-09-14. Its Git snapshot identifies the five Hall-position/FOC-control records; the current successor maintains Draft records by their canonical status rather than a maintained aggregate count. Requirements and document release do not establish implementation, physical verification, vehicle qualification, or Completion B.

Prior requirements, item-definition, architecture and safety releases retain their own scope and status in Git. Current authoritative obligations, status, targets, parent trace and planned verification are the canonical records linked above. Substantive changes require controlled revision, owner approval and affected re-verification.
