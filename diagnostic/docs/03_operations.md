# Deployment and operations

Use separate development, UAT and production databases, storage, credentials and hostnames. Version source and migrations together. Take a verified backup before migration and promote a reviewed release through UAT.

Serve only public/ over HTTPS. Deny dotfiles and directory listings. Rotate secrets; use least privilege. Keep logs and backups outside the web root and review clinical/financial access with actual job role accounts.

Schedule full backups and use binary logs if point in time restore is required. Test restoring into a separate environment and measure recovery time. Agree RPO/RTO with management. Back up future report and document storage with the database; Phase 0 stores no clinical files.

Cutover checklist: signed workflows; current migration applied; roles/branches reviewed; numbering and thresholds approved; representative data and scope tests passed; backup restore drill; monitoring and incident owner; rollback plan and release signoff.

Phase 1 adds patients and appointments. Phase 2 adds pricing, invoices, receipts and refund controls. Phases 3–4 add LIS/RIS. Phase 6 adds doctor/referrer commission using approved contracts and settlement evidence. All sensitive downstream transactions should call the branch, approval, numbering and audit services introduced here.
