# Phase 0 traceability and acceptance

| ID | Plan requirement | Implementation | Verification |
| --- | --- | --- | --- |
| P0-01 | Organization and branch masters | Tables and Core masters | Create first and second branch; numbering exists |
| P0-02 | Units, departments, rooms, counters, booths, cost centers | Tables and forms | Branch user sees own records |
| P0-03 | Test, panel, sample, method, unit, range, template | Tables and most catalog forms | Clinical catalog approved; range/panel editors still open |
| P0-04 | Doctor, referrer, corporate, supplier, payment | Tables and forms | Review duplicates and valid relationships |
| P0-05 | Configurable IDs | Sequence service and screen | Concurrent MySQL backed uniqueness test |
| P0-06 | Roles, branches, departments, permissions | User assignments and defaults | Test each job role |
| P0-07 | Maker/checker | Policies and decision queue | Self approval blocked |
| P0-08 | Audit | Before/after JSON, database triggers | Changes logged; edit/delete log rejected |
| P0-09 | Session and login | Idle timeout and attempts log | Disabled/expired user denied |
| P0-10 | Environments and backup | Config, migration, API and guide | UAT deployment/restore drill outstanding |

Manual acceptance: create a branch, department, booth, sample and test; test branch and department scope via UI and API; request an approval as user A and decide as user B; issue concurrent numbers; verify audit changes and immutable triggers; disable an active account; inspect layouts at 360px, 768px and desktop widths.

Phase exit requires signed workflows, role tests, migration/restore evidence, security review and UAT signoff. This starter has not met those external signoffs.
