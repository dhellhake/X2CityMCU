# Fixed cell bank

**Type:** Abstract Hardware Requirement. **Target:** [LE-CELLS](../../Architecture/SystemArchitecture/ARCH-001_System_Architecture.md#le-cells), realized by HC-CELLS, the built cell bank.

Part of **REQ-001-R1.6**. [Model and verification rules](../REQ-001_Requirements.md) apply. This physical allocation does not allocate the supplied BMS firmware to hardware.

| ID | Requirement | Planned verification | Derived from | Sources / qualifications |
|---|---|---|---|---|
| <a id="req-sys-cell-001"></a>`REQ-SYS-CELL-001` | The energy-storage cell bank shall comprise 14 series-connected groups, each containing five parallel Samsung INR18650-35E cells. | `I`, `A`. Record as-built identity/connections and 70-cell inventory; relate accessible voltage observations to the 14 parallel groups. | [REQ-SYS-BAT-002](../System_Requirements/Battery_Integration.md#req-sys-bat-002) | [DEC-BAT-002](../DEC-001_Decisions_and_Open_Issues.md#dec-bat-002), [BAT-001](../../Battery/BAT-001_Selected_Pack_and_BMS.md). Owner-confirmed construction; interconnection, insulation, thermal and integration acceptance remain system work. |
