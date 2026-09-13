# Item Definition & Requirements

**Historical baseline released 2026-09-09 by Dominik, project owner**, after review of all generated files. That baseline is approved for downstream hazard analysis, requirements refinement, architecture and verification planning with controlled open issues.

**Current requirements baseline: REQ-001-R1.8, released 2026-09-13 by Dominik after review of the technical/HSI requirement results.** The **197 records** comprise **180 approved, 12 Draft, 3 Deferred and 2 Withdrawn** in **24 clusters: 176 System, 17 Abstract Software and 4 Abstract Hardware**; the abstract types remain System-level. The R1.8 release approves exactly eight HSI contracts and one retained-mechanics refinement; the 12 earlier FSC rows remain Draft. All active approved records have provenance, a responsible target and planned verification; all 317 PD records have dispositions. **Completion point A is released; B remains open.** Numerical, characterization, safety/design and executed-verification gates remain as recorded. [Release scope and source snapshot](#req-001-r18-technical-hsi-requirements-release).

The separately released [FC-001/002-R1.0 package](../Architecture/FC-001_Functional_Concept.md#release-record), dated 2026-09-13, defines 19 functions and references 12 Draft safety-derived System Requirements. Its [function trace](../Architecture/FC-002_Function_Trace.md) also covers the 11 separately approved safety goals. The concept release preserved those Draft requirement statuses and then-provisional logical ownership. The subsequent [architecture release](../Architecture/ARCH-001_System_Architecture.md#release-record) approves the reviewed component structure, interfaces and host roles. REQ-001-R1.8 separately approves the nine technical refinements without promoting the FSC rows; B remains open. R1.6 and HARA/SG release snapshots remain unchanged in Git.

| Document | Release / content |
|---|---|
| [PD-001](../../README.md) | Working Draft1.3: separate mobile-charger placement; R1.6 used Draft1.2 and historical PD-001-R1.1 remains its released baseline |
| [ID-001](ID-001_Item_Definition.md) | Working Draft1.2: charger placement and architecture context; R1.6 used Draft1.1 and historical ID-001-R1.0 remains its released baseline |
| [REQ-001](REQ-001_Requirements.md) | **Released R1.8:** 24 clusters including 12 Draft FSC rows and nine approved technical refinements; R1.6 remains the earlier 20-cluster baseline in Git |
| [HARA-001 / SG-001 release](../Safety/HARA-001_Hazard_Analysis.md#release-record) | **Released HARA-001-R1.0 / SG-001-R1.0, 2026-09-12**: qualitative hazard analysis and 11 additional approved top-level safety goals, in a separate controlled baseline; the R1.6 counts above remain unchanged |
| [DEC-001](DEC-001_Decisions_and_Open_Issues.md) | Working Draft1.7: records R1.8 technical-refinement evidence gates; Draft1.5 remains the R1.6 source snapshot; 19 workstream issues open, including WS-OI-020(B); WS-OI-004 closed |
| [ARCH-001](../Architecture/ARCH-001_System_Architecture.md) | **Released ARCH-001-R1.0, 2026-09-13**: 38 logical components, composition, 13 interface contracts and realization mappings; Draft0.3/0.2 remain FC/R1.6 snapshots; approved requirement bindings unchanged |
| [ARCH-002 / ARCH-003](../Architecture/ARCH-002_Hardware_Architecture.md) | **Released ARCH-002-R1.0 / ARCH-003-R1.0, 2026-09-13**: 27 physical HW components and [software architecture](../Architecture/ARCH-003_Software_Architecture.md) with 14 project component types, two supplied firmware types and local vehicle/charger deployment |
| [FC-001 / FC-002](../Architecture/FC-001_Functional_Concept.md#release-record) | **Released FC-001-R1.0 / FC-002-R1.0, 2026-09-13**: functional definition, contracts, diagrams, modes, response strategy, document walkthroughs and contribution trace; the concept-release snapshot retained Draft architecture and 12 Draft FSC requirements; the subsequent architecture release is separate |
| [Selected battery/BMS reference](../Battery/BAT-001_Selected_Pack_and_BMS.md) | Frozen source snapshot: Draft0.1; selected components, manufacturer evidence and qualified derivations; no integration acceptance claimed |
| [Brake interface evidence](evidence/Brake_Input_Reference.md) | Revision 1.0: fixed shared coded interface, provenance, values and diagnostic limitations |
| [VD18MT implementation evidence](evidence/VD18MT_Implementation_Reference.md) | Revision 1.0: historical tested source and evidence qualifications |
| [Independent VD18MT reference](../VD18MT/VD18MT_Tongsheng_UART_Interface.md) | Revision 1.0: project-independent device/interface definition |

## Authority and maintenance

The PD controls project obligations. ID-001 supplies item context; REQ-001 defines the requirement model, indexes the canonical cluster records and carries [PD obligation disposition](REQ-001_Requirements.md#pd-obligation-disposition); DEC-001 preserves owner intent and required issue resolution. Keep facts, approved obligations, derived interpretations, assumptions and executed evidence distinct.

All explicit parameters, assumptions, exclusions and evidence gates retain their qualifications. The provisional 35% neutral and exponential-like preference are not validated calibration. Deferred/Withdrawn requirements are inactive. Document release does not establish vehicle verification or close outstanding engineering.

Update the controlling decision and affected requirements/context together. Preserve stable IDs, assess technical changes and obtain applicable owner approval. The requirement Type/Target and stated allocation bindings are approved in REQ-001-R1.6; ARCH-001/002/003-R1.0 separately approves the reviewed architecture allocation; complete B coverage, sensing realization, safety derivation and vehicle verification retain their gates. Later source changes do not silently alter this released baseline; assess impacts and revise affected requirements under change control.

## Release and history

### ARCH-001/002/003-R1.0 — Component architecture release

Released 2026-09-13 following owner review and explicit release instruction. The canonical [release record](../Architecture/ARCH-001_System_Architecture.md#release-record) defines the approved structure, interfaces, host/state ownership and trace, the preserved source snapshots, checks and Git retrieval. REQ-001 Draft1.7 and its 12 FSC rows retain their statuses; supporting PD1.3, ID1.2 and DEC1.6 remain Draft. Completion B and physical acceptance remain open.

<a id="req-001-r18-technical-hsi-requirements-release"></a>
### REQ-001-R1.8 — Technical/HSI requirements release

On 2026-09-13 Dominik confirmed: “I have reviewed the results. release it.” In the context of the reviewed technical/HSI refinement, this authorizes exactly `REQ-SYS-HSI-001` through `REQ-SYS-HSI-008` and `REQ-VEH-MECH-003`, including their stated parents/sources, responsible targets and planned verification. These nine Draft records are approved. The 171 records approved in R1.6 and the five inactive records retain their identities and status.

**Scope:** REQ-001, the new System hardware/software interface cluster, the retained-mechanical-control cluster amendment, and the release/index metadata. The resulting catalogue contains 197 records in 24 clusters: 180 Approved, 12 Draft, 3 Deferred and 2 Withdrawn (176 System, 17 Abstract Software and 4 Abstract Hardware). The 12 earlier safety-derived FSC rows remain Draft and are explicitly outside this approval. DEC-001 Draft1.7 is retained as a supporting snapshot that records evidence gates; PD1.3, ID1.2, DEC1.7, BAT0.1 and the separately released ARCH-001/002/003-R1.0 are not globally promoted by this release.

**Release checks:** exactly nine Draft-to-Approved promotions; all original 188 rows preserved; 197 records reconciled to the type and cluster indexes; explicit HSI/mechanical parents, sources, targets and planned verification retained; FSC rows and their Draft status preserved; local links and Markdown structure checked. No runtime, hardware or vehicle test is represented as executed.

**Git snapshot:** the commit titled `Release technical HSI requirements baseline REQ-001-R1.8` contains the complete controlled baseline and supporting snapshots above. Resolve it from history with `git log --all --format=%H --fixed-strings --grep="Release technical HSI requirements baseline REQ-001-R1.8"`. Use that commit when retrieving released files; later working-tree changes are not the release. Git remains the archive; no duplicate release copies or generated manifests are required.


<a id="req-001-r16-system-requirements-release"></a>
### REQ-001-R1.6 — System Requirements release

On 2026-09-11 Dominik confirmed: “I have reviewed all System Requirements. Prepare and conduct the release.” This authorizes the reviewed requirement baseline, its model/interpretation, all 171 active records including their Type/Target and allocation bindings, and planned verification with the documented open parameters and commitment gates. All 61 previously Draft requirements are now approved; the 110 earlier approved requirements and five inactive records retain their identities. Completion point A is recorded as released. WS-OI-020 stays open for B; neither a completed architecture nor physical verification or vehicle release is claimed.

**Scope:** REQ-001 and its 20 canonical clusters under System_Requirements, Abstract_Software_Requirements and Abstract_Hardware_Requirements. No Unit Requirements exist. Supporting PD1.2, ID1.1, DEC1.5, ARCH0.2 and BAT0.1 are captured in the same Git snapshot with their then-current Draft statuses. Their cited content is the traceability basis accepted for this requirements release; the snapshot does not globally release those documents or promote assumptions, reported ratings, open limits or unexecuted checks to verified facts. The independent brake/VD18MT evidence remains unchanged.

**Release checks:** canonical IDs and obligation text preserved; exactly 61 Draft-to-approved promotions; 176 records reconciled to type/cluster indexes; all active source/target/verification fields and derivation chains checked; 317 PD dispositions and all eight OS/26 FM scenarios covered; local links and Markdown structure checked. Release preparation changes approval/formatting metadata and corrects stale folder-summary counts (159/11 to 156/17); technical obligations are preserved. No runtime or vehicle test is represented as executed.

**Git snapshot:** the commit titled `Release system requirements baseline REQ-001-R1.6` contains the complete baseline and the source snapshots above. Resolve it from history with `git log --all --format=%H --fixed-strings --grep="Release system requirements baseline REQ-001-R1.6"`. Use that commit when retrieving released files; later working-tree changes are not the release. Git remains the archive; no duplicate release copies or generated manifests are required.

### Earlier item-definition release

Dominik, project owner, confirmed review of all generated files on 2026-09-09 and authorized their release, a comprehensive commit and cleanup using Git history. The item-definition stage and requirement handoff are accepted with their recorded open issues, planned verification and downstream assignments. No independent review, completed implementation, safety assessment or vehicle qualification is claimed.

**Release snapshot:** `c01f432eef58571e4e5ce64ddc3ac7d39c9ff5b6` — `Release item definition and requirements with reviewed project baseline`.

This commit preserves the released workstream and all seven removed PD sidecars: the Rev1.0/1.1 definitions, Rev1.1 reviewed copy, both release records, Rev1.1 administrative patch and checksum manifest. README is the sole current PD; the table above and REQ-001's cluster index identify the current workstream/reference set. Cleanup changed administrative records/links, not approved technical behavior.

Retrieve historical content directly, for example:

```text
git show c01f432eef58571e4e5ce64ddc3ac7d39c9ff5b6:PD-001_Project_Definition_Rev1.0.md
git show c01f432eef58571e4e5ce64ddc3ac7d39c9ff5b6:PD-001_Project_Definition_Rev1.1.md
git show c01f432eef58571e4e5ce64ddc3ac7d39c9ff5b6:PD-001_Release_Record_Rev1.1.md
git show c01f432eef58571e4e5ce64ddc3ac7d39c9ff5b6:.devenv/Requirements/REQ-001_Requirements.md
```

The original PD release packages retain the scope/status of their own release dates; the later workstream release records the separate approval of requirements. Earlier Rev0.7 source/promotion/checksum artifacts were already unavailable and are not recreated by this cleanup (WS-OI-014). Future substantive changes require controlled revision and applicable owner approval.
