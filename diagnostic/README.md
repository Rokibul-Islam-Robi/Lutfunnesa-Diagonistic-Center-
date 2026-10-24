# Diagnostic Center ERP — Phase 0 foundation

A standalone PHP/MySQL starter for Phase 0 of the attached Dhaka diagnostic center ERP plan. It provides shared masters, branch and department scoped access, role permissions, maker/checker approvals, configurable identifiers, login history, an append only audit log, a responsive admin workspace, and an authenticated read API.

This is foundation infrastructure. It does not yet register patients, create invoices, calculate doctor/referrer commission, or produce diagnostic reports.

## Requirements and installation

- PHP 8.2+ with pdo_mysql, mbstring, openssl and sessions.
- MySQL 8.0+ or MariaDB 10.6+ with InnoDB and JSON support.
- Copy .env.example to .env; set database values. Never commit .env.
- Create the database and an application user with schema creation rights for installation.
- Run: php bin/setup.php install
- The installer prompts for organization, first branch and administrator. Password must be at least 12 characters.
- Local preview: php -S 127.0.0.1:8000 -t public public/router.php
- Open http://127.0.0.1:8000/index.php
- Later migrations: php bin/setup.php migrate

Install only into a fresh database. The migration is recorded in schema_migrations. Do not import it into another ERP schema without reviewing table names and data ownership.

## Production

Point the virtual host document root at the public/ directory. Deny direct access to src/, bin/, database/, storage/ and .env. Force HTTPS, disable APP_DEBUG and use separate credentials for development, UAT and production. The migration account needs CREATE and TRIGGER; runtime permissions can be narrower. Set up encrypted offsite backup, restore drills, monitoring and log rotation before use with patient data.

## Functionality

- Overview: setup counts and recent activity.
- Core masters: branch operations, clinical catalog, relationships and commercial setup.
- People & access: one role and multiple branches/departments per account. Default roles: administrator, branch manager, front desk, cashier, lab, radiology, finance and quality.
- Approval desk: a maker cannot decide their own request. Later modules must recheck their underlying transaction before executing the approved action.
- Numbering: branch specific patient, order, invoice, receipt, barcode, report, voucher, purchase and employee sequences. Diagnostic\Numbering::next() locks the sequence row; call it inside the business transaction.
- Audit: before/after records and login actions. SQL triggers block ordinary update/delete on audit_logs.
- API: authenticated GET /api/v1/health and GET /api/v1/masters/{entity}?q=... using the same web session and scope. Third-party integrations require separate credentials, scopes, rate limits and logs.

## Project files

- database/001_foundation.sql: foundation schema and audit triggers.
- bin/setup.php: migration, first organization/branch and administrator.
- src/Masters.php, Security.php, Approvals.php, Numbering.php: shared services.
- public/: web root, responsive interface and API.
- docs/: discovery register, acceptance and operating notes.

## Current limits

| Plan item | Implementation | Remaining |
| --- | --- | --- |
| 0.1 Discovery | Draft decision register and acceptance matrix | Workshops, actual forms, signed scope and workflow maps |
| 0.2 Masters | Core schema and forms | Dedicated reference range, panel composition and report body editors; clinical validation |
| 0.3 Controls | Login, RBAC, scopes, approval requests, audit and history | Full role/policy editor, privileged review, security test |
| 0.4 Architecture | Modular PHP layout, migration, environments guide, read API | CI, hosting, backup automation, monitoring and rollback drills |

Do not go live with clinical or financial data on this starter alone. Review clinical rules, tax/VAT and commission policy with responsible owners.
