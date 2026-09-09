# Item Definition & Requirements

**Released 2026-09-09 by Dominik, project owner**, after review of all generated files. This baseline is approved for downstream hazard analysis, requirements refinement, architecture and verification planning with controlled open issues.

| Document | Release / content |
|---|---|
| [PD-001](../../README.md) | PD-001-R1.1: controlling project scope, mission, constraints and qualification basis |
| [ID-001](ID-001_Item_Definition.md) | ID-001-R1.0: item boundary, interfaces, states, lifecycle coverage and safety-analysis inputs |
| [REQ-001](REQ-001_Requirements.md) | REQ-001-R1.0: 110 active requirements, 3 Deferred and 2 Withdrawn records; PD obligation disposition and planned verification |
| [DEC-001](DEC-001_Decisions_and_Open_Issues.md) | DEC-001-R1.0: owner decisions, supersessions and 18 open workstream issues; WS-OI-004 closed |
| [Brake interface evidence](evidence/Brake_Input_Reference.md) | Revision 1.0: fixed shared coded interface, provenance, values and diagnostic limitations |
| [VD18MT implementation evidence](evidence/VD18MT_Implementation_Reference.md) | Revision 1.0: historical tested source and evidence qualifications |
| [Independent VD18MT reference](../VD18MT/VD18MT_Tongsheng_UART_Interface.md) | Revision 1.0: project-independent device/interface definition |

## Authority and maintenance

The PD controls project obligations. ID-001 supplies item context; REQ-001 carries requirements and [PD obligation disposition](REQ-001_Requirements.md#pd-obligation-disposition); DEC-001 preserves owner intent and required issue resolution. Keep facts, approved obligations, derived interpretations, assumptions and executed evidence distinct.

All explicit parameters, assumptions, exclusions and evidence gates retain their qualifications. The provisional 35% neutral and exponential-like preference are not validated calibration. Deferred/Withdrawn requirements are inactive. Document release does not establish vehicle verification or close outstanding engineering.

Update the controlling decision and affected requirements/context together. Preserve stable IDs, assess technical changes and obtain applicable owner approval. Architecture, sensing/control realization, safety analysis and vehicle verification remain downstream.

## Release and history

Dominik, project owner, confirmed review of all generated files on 2026-09-09 and authorized their release, a comprehensive commit and cleanup using Git history. The item-definition stage and requirement handoff are accepted with their recorded open issues, planned verification and downstream assignments. No independent review, completed implementation, safety assessment or vehicle qualification is claimed.

**Release snapshot:** `c01f432eef58571e4e5ce64ddc3ac7d39c9ff5b6` — `Release item definition and requirements with reviewed project baseline`.

This commit preserves the released workstream and all seven removed PD sidecars: the Rev1.0/1.1 definitions, Rev1.1 reviewed copy, both release records, Rev1.1 administrative patch and checksum manifest. README is the sole current PD; this index and the six supporting documents listed above remain the current workstream/reference set. Cleanup changed administrative records/links, not approved technical behavior.

Retrieve historical content directly, for example:

```text
git show c01f432eef58571e4e5ce64ddc3ac7d39c9ff5b6:PD-001_Project_Definition_Rev1.0.md
git show c01f432eef58571e4e5ce64ddc3ac7d39c9ff5b6:PD-001_Project_Definition_Rev1.1.md
git show c01f432eef58571e4e5ce64ddc3ac7d39c9ff5b6:PD-001_Release_Record_Rev1.1.md
git show c01f432eef58571e4e5ce64ddc3ac7d39c9ff5b6:.devenv/Requirements/REQ-001_Requirements.md
```

The original PD release packages retain the scope/status of their own release dates; the later workstream release records the separate approval of requirements. Earlier Rev0.7 source/promotion/checksum artifacts were already unavailable and are not recreated by this cleanup (WS-OI-014). Future substantive changes require controlled revision and applicable owner approval.
