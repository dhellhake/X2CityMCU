# Retained mechanical control

**Type:** Abstract Hardware Requirement. **Target:** [LE-MECH](../../Architecture/ARCH-001_System_Architecture.md#le-mech), realized by the retained steering and front/rear mechanical brake assemblies (HC-MECH).

Part of **REQ-001-R1.6 — 2026-09-11**. [Model and shared verification](../REQ-001_Requirements.md). The release preserves each requirement's ID, wording, sources and acceptance. The hardware allocation is approved. Integration remains responsible for interference, mounting, expanded-duty suitability and vehicle-level acceptance; no new brake mechanism or electrical brake-input sensing is selected.

| ID | Requirement | Planned verification / distinguishing cases | Sources | Open dependencies / qualifications |
|---|---|---|---|---|
| <a id="req-veh-brk-001"></a>`REQ-VEH-BRK-001` | Front and rear mechanical braking shall remain independent of EPCS operation, electrical power and regeneration availability. | `I`, `T-SYS`. Demonstrate both brakes with EPCS on/off, regeneration unavailable and battery removed. | [DEC-BRK-001](../DEC-001_Decisions_and_Open_Issues.md#dec-brk-001), `OBJ-004`, `CON-008`, `PERF-006`, `EXC-024` | `WS-OI-012`, `WS-OI-013`: Vehicle brake acceptance remains upstream; no stopping distance is invented. |
| <a id="req-veh-mec-001"></a>`REQ-VEH-MEC-001` | Retained mechanical steering shall remain usable independently of EPCS operation and electrical power. | `I`, `T-SYS`. Demonstrate the qualified steering function with EPCS powered, switched off, fault-inhibited and with the battery removed; inspect integration for interference with steering movement. | `OBJ-004`, [ID §2.2](../ID-001_Item_Definition.md#22-actors-and-boundary-interactions) | `OI-010`, `OI-012`, `OI-052`: Establish donor condition, required travel/effort/clearance and loaded acceptance before dependent integration tests. Electrical independence does not establish complete structural or dynamic suitability. |
