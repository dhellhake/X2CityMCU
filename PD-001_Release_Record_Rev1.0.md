# PD-001 — Release Record

## First Official Release — Revision 1.0

| Field | Record |
|---|---|
| Release record | **RR-PD-001-R1.0** |
| Document / release | **PD-001 / PD-001-R1.0** |
| Release date | **2026-09-05** |
| Reviewer and approver | **Dominik — project owner** |
| Content-reviewed input | **PD-001 Revision 0.7** |
| Approval basis | The project owner confirmed successful content review, accepted Revision 0.7 in full, and instructed preparation of the official release |
| Release status | **Approved and released for downstream development with controlled open issues** |
| Independent review | Not recorded; optional and not required for this release |
| Repository publication | Files prepared for check-in; no remote publication, Git commit or tag is claimed |

## Release decision

PD-001 Revision 1.0 is the approved input baseline for concept development, vehicle-level hazard analysis, requirements engineering and targeted feasibility characterization. Later architecture, detailed design and verification planning use this baseline subject to its existing decision and evidence gates.

The owner's content acceptance covers the document's stated assumptions and open-issue dispositions. **Accepted assumptions remain provisional; open issues remain open.** This release does not convert reported component ratings into verified performance or authorize unvalidated riding, charging or hazardous testing.

## Change scope

Revision 1.0 is an administrative promotion of the reviewed Revision 0.7. Changes are limited to revision/status metadata, owner approval, the review/release record, three administrative labels in the technical body, the supersession/change history and the footer. No objective, numerical limit, component selection, interface definition, assumption wording, calculation, exclusion or open-issue entry in Sections 1–17 was altered. External source references and their recorded provenance were retained unchanged.

The exact reviewed source is included for traceability. The unified diff `PD-001_Rev0.7_to_Rev1.0.patch` records every textual change. The released definition remains standalone and does not require consulting the reviewed source to understand the project.

## File identities

| File | Purpose | SHA-256 |
|---|---|---|
| `PD-001_Project_Definition_Rev0.7.md` | Unchanged, owner-reviewed input | `817c956b6d0b18556af06cb85dcf0a6ef4f4abfcc8283bb0393969b7572912d4` |
| `PD-001_Project_Definition_Rev1.0.md` | Versioned approved release | `e3c2d0177df6e479e818d389e428a45d429d915b62ad830f1ae7179e0124769f` |
| `README.md` | Identical repository landing-page copy of the release | `e3c2d0177df6e479e818d389e428a45d429d915b62ad830f1ae7179e0124769f` |

Hashes identify the prepared content. They are not signatures and do not attest to tests or approvals beyond the written project-owner approval recorded above. `PD-001_Rev1.0_SHA256SUMS.txt` also identifies this release record and the change diff.

## Downstream handover

The issue register in Section 15 remains authoritative; Dominik is the default responsible person until another owner is assigned. In particular:

| Topic | Handover status |
|---|---|
| Reference-cycle and qualification assumptions | Accepted initial basis; retain their assumption status and baseline a reproducible trace before relying on the model for the relevant sizing commitments |
| Battery energy, SOC window, mass and removable packaging | Feasibility assessment and SOC/storage qualification remain required before their stated commitments |
| Donor, motor attachment and 40 km/h mechanical suitability | Inspection, assessment and validation remain required; no completion is implied |
| Motor hill capability and thermal envelope | Characterization and grade-duty evidence remain required before inverter/pack sizing commitments |
| HMI protocol reference | Prior verification accepted; concrete asset references and selected-unit correlation remain to be recorded before final integration relies on them |
| Cold use, outdoor storage and removed-pack charging | Requirements and validation remain to be completed within the approved operating context |
| Resources | Recorded access assumptions accepted; expenditure decisions and task-specific readiness remain required |

No repository path to the pre-existing HMI implementation, inspection report, measurement result, reviewer signature or Git identifier has been fabricated.

## Repository handling

Place `README.md` at the repository root for the landing page. Keep the versioned definition, reviewed input, release record, change diff and checksum manifest together in the controlled document archive. Record the actual Git commit or tag after check-in; a suitable tag name is `PD-001-v1.0`, but this preparation has not created it.

Subsequent technical changes require a new controlled revision and the applicable change assessment and approval. Do not silently overwrite the versioned released definition.
