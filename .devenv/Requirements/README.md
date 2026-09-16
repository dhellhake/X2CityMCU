# Item Definition & Requirements

**Current successor:** [REQ-001](REQ-001_Requirements.md) maintains the Draft catalogue in its canonical records and does not assert a maintained aggregate count. The Draft traction interconnection/runtime records do not change any Approved body. The [runtime integration contract](../Architecture/SoftwareArchitecture/Runtime_Integration_Contract.md) is the implementation-facing allocation reference.

**Released baseline:** REQ-001-R2.0 (2026-09-14) remains the 228-record release and approves five Hall-position/FOC-control records. Completion B, characterization, safety/design and executed verification remain open; Git preserves earlier baselines.

| Document | Release / content |
|---|---|
| [PD-001](../../README.md) | Current Draft project definition; PD-001-R1.1 remains the released baseline |
| [ID-001](ID-001_Item_Definition.md) | Current item context; ID-001-R1.0 remains the released baseline |
| [REQ-001](REQ-001_Requirements.md) | Current catalogue, requirement model and canonical clusters |
| [HARA-001 / SG-001 release](../Safety/HARA-001_Hazard_Analysis.md#release-record) | Released qualitative hazard analysis and 11 safety goals; physical safety evidence remains open |
| [DEC-001](DEC-001_Decisions_and_Open_Issues.md) | Current owner decisions and open issue register; `WS-OI-020(B)` remains open |
| [ARCH-001](../Architecture/SystemArchitecture/ARCH-001_System_Architecture.md) | **Released ARCH-001-R1.0, 2026-09-13**: 38 logical components, composition, 13 interface contracts and realization mappings; Draft0.3/0.2 remain FC/R1.6 snapshots; approved requirement bindings unchanged |
| [ARCH-002 / ARCH-003](../Architecture/ARCH-002_Hardware_Architecture.md) | **Released ARCH-002-R1.1 / ARCH-003-R1.1, 2026-09-14**: Hall evidence and Hall-sensored FOC allocation refinement; final components, timing, protection and physical acceptance remain open |
| [FC-001 / FC-002](../Architecture/FC-001_Functional_Concept.md#release-record) | **Released FC-001-R1.1 / FC-002-R1.1, 2026-09-14**: Hall/FOC functional contribution refinement; the 12 Draft FSC requirements remain Draft |
| [Selected battery/BMS reference](../Battery/BAT-001_Selected_Pack_and_BMS.md) | Frozen source snapshot: Draft0.1; selected components, manufacturer evidence and qualified derivations; no integration acceptance claimed |
| [Brake interface evidence](evidence/Brake_Input_Reference.md) | Revision 1.0: fixed shared coded interface, provenance, values and diagnostic limitations |
| [VD18MT implementation evidence](evidence/VD18MT_Implementation_Reference.md) | Revision 1.0: historical tested source and evidence qualifications |
| [Independent VD18MT reference](../VD18MT/VD18MT_Tongsheng_UART_Interface.md) | Revision 1.0: project-independent device/interface definition |

## Authority and maintenance

The PD controls project obligations. ID-001 supplies item context; REQ-001 defines the requirement model, indexes the canonical cluster records and carries [PD obligation disposition](REQ-001_Requirements.md#pd-obligation-disposition); DEC-001 preserves owner intent and required issue resolution. Keep facts, approved obligations, derived interpretations, assumptions and executed evidence distinct.

All explicit parameters, assumptions, exclusions and evidence gates retain their qualifications. The provisional 35% neutral and exponential-like preference are not validated calibration. Deferred/Withdrawn requirements are inactive. Document release does not establish vehicle verification or close outstanding engineering.

Update the controlling decision and affected requirements/context together. Preserve stable IDs, assess technical changes and obtain applicable owner approval. The requirement Type/Target and stated allocation bindings are approved in REQ-001-R1.6; ARCH-001/002/003-R1.0 separately approves the reviewed architecture allocation; complete B coverage, sensing realization, safety derivation and vehicle verification retain their gates. Later source changes do not silently alter this released baseline; assess impacts and revise affected requirements under change control.

## Release and history

`REQ-001-R2.0` was released by Dominik on 2026-09-14. Its Git snapshot identifies the five Hall-position/FOC-control records; the current successor maintains Draft records by their canonical status rather than a maintained aggregate count. Requirements and document release do not establish implementation, physical verification, vehicle qualification, or Completion B.

Prior requirements, item-definition, architecture and safety releases retain their own scope and status in Git. Current authoritative obligations, status, targets, parent trace and planned verification are the canonical records linked above. Substantive changes require controlled revision, owner approval and affected re-verification.
