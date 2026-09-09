# PD-001 — Release Record, Revision 1.1

| Field | Record |
|---|---|
| Release record | **RR-PD-001-R1.1** |
| Document / release | **PD-001 / PD-001-R1.1** |
| Release date | **2026-09-09** |
| Reviewer and approver | **Dominik — project owner** |
| Reviewed input | Current PD Rev1.1 root README, preserved exactly as [PD-001_Project_Definition_Rev1.1_Reviewed.md](PD-001_Project_Definition_Rev1.1_Reviewed.md) |
| Approval basis | Owner instruction: “I have reviewed the current PD. Release it.” |
| Status | **Approved and released for downstream development with controlled open issues** |
| Supersedes | PD-001-R1.0 for current downstream use; prior frozen definition and release record remain unchanged |
| Independent review | Not recorded; no independent approval claimed |
| Repository context | Branch main, pre-release HEAD 9df58f11f2c054376dd1abb6d1e99007f95d4134; reviewed/released files include uncommitted working-tree content |
| Repository publication | File-based document release; no Git commit, tag or remote publication created by this release |

## Release scope

The owner reviewed and approved the complete current PD Rev1.1, including its owner amendments, condensed text, assumptions and open-issue dispositions. This release is the upstream baseline for concept development, vehicle-level hazard analysis, requirements, targeted feasibility characterization and later architecture/design/verification planning subject to the recorded evidence gates.

Release preparation changes administrative status, approval, source-authority and release metadata only. **Sections 1–17 are text-identical to the reviewed input.** The [PD-001_Rev1.1_Reviewed_to_Released.patch](PD-001_Rev1.1_Reviewed_to_Released.patch) records every PD text change from the reviewed input to the released copy. Technical changes accumulated since Rev1.0 were already present in the reviewed Rev1.1; this is not a claim that Rev1.1 is technically identical to Rev1.0.

## File identities

| File | Purpose | SHA-256 |
|---|---|---|
| [PD-001_Project_Definition_Rev1.1_Reviewed.md](PD-001_Project_Definition_Rev1.1_Reviewed.md) | Exact owner-reviewed input, before administrative release updates | 0a1d9d01150d23568c8f5efad392934ec416ad2fe8744421ccb43128088f7462 |
| [PD-001_Project_Definition_Rev1.1.md](PD-001_Project_Definition_Rev1.1.md) | Frozen approved release | d6f5a724da1713e0eb6bb7b66d647be7be1f0166aaafe7a1619e64268fc6d776 |
| [README.md](README.md) | Identical released landing-page copy | d6f5a724da1713e0eb6bb7b66d647be7be1f0166aaafe7a1619e64268fc6d776 |

The [PD-001_Rev1.1_SHA256SUMS.txt](PD-001_Rev1.1_SHA256SUMS.txt) records the release artifacts, this record and the referenced working-document/interface versions captured during release preparation. It excludes itself. Hashes identify content; they are not signatures or verification results.

Linked DEC/ID/REQ documents remain separate working records. Their hashes identify the release context, not approval of their candidates or immutable future contents. Subsequent changes affecting PD scope, obligations or assumptions require the PD change-control process.

## Downstream handover

- PD Rev1.1 replaces the former Rev1.0 policy as current upstream authority. WS-OI-004 is closed by this release.
- The item definition and candidate requirements remain unapproved working documents; this release does not complete their review or the Item Definition stage.
- Accepted assumptions remain provisional. All technical open issues, required evidence and closure gates remain effective; Dominik remains the default responsible person.
- No architecture allocation, safety-analysis completion, component suitability, executed vehicle validation or authorization for unvalidated riding/charging/testing follows from document approval.
- Current source-authority references in the workstream index, item definition, decision record, requirements and VD18MT implementation evidence were updated administratively. Historical implementation evidence and the independent interface definition were not changed technically.
- The missing Rev0.7 source/promotion/checksum artifacts remain a documented historical limitation under WS-OI-014. This package does not reconstruct or alter the Rev1.0 release record.

## Configuration control

Keep the reviewed input, frozen definition, release record, administrative patch and checksum manifest together at the repository root. Preserve the versioned released bytes; future technical changes require a new controlled revision and applicable owner review/approval. Record an actual release commit/tag only if later created and authorized.
