<?php
declare(strict_types=1);
require dirname(__DIR__) . '/src/bootstrap.php';

use Diagnostic\Security;

if (PHP_SAPI !== 'cli') exit(1);
$action = $argv[1] ?? '';
if (!in_array($action, ['migrate','install','grant-branch'], true)) {
    fwrite(STDERR, "Usage: php bin/setup.php migrate|install|grant-branch EMAIL BRANCH_CODE\n");
    exit(1);
}
try {
    $db = db();
    if ($action === 'migrate' || $action === 'install') {
        $db->exec('CREATE TABLE IF NOT EXISTS schema_migrations (version VARCHAR(100) PRIMARY KEY, applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB');
        $migrations = ['diagnostic_erp'];
        foreach ($migrations as $version) {
            $check = $db->prepare('SELECT 1 FROM schema_migrations WHERE version=?');
            $check->execute([$version]);
            if (!$check->fetchColumn()) {
                $sql = file_get_contents(dirname(__DIR__) . '/database/' . $version . '.sql');
                if (str_contains($sql, 'DELIMITER $$')) {
                    [$statements, $triggers] = explode('DELIMITER $$', $sql, 2);
                    foreach (explode(";\n", $statements) as $statement) {
                        if (trim($statement)) $db->exec(trim($statement));
                    }
                    foreach (explode('$$', str_replace('DELIMITER ;', '', $triggers)) as $statement) {
                        if (trim($statement)) $db->exec(trim($statement));
                    }
                } else {
                    foreach (explode(";\n", $sql) as $statement) {
                        if (trim($statement)) $db->exec(trim($statement));
                    }
                }
                $db->prepare('INSERT IGNORE INTO schema_migrations(version) VALUES(?)')->execute([$version]);
                echo "Migration {$version} applied.\n";
            } else echo "Migration {$version} already applied.\n";
        }

        // Register All Permissions (Phase 0 - 4)
        $newPermissions = [
            'patients.view' => 'View patient longitudinal history and records',
            'patients.edit' => 'Create and edit patient demographics',
            'patients.merge' => 'Request patient record merge',
            'appointments.manage' => 'Manage doctor schedules and appointments',
            'orders.create' => 'Create and manage diagnostic orders',
            'orders.view' => 'View diagnostic orders and status',
            'queue.manage' => 'Manage service counter queue and display board',
            'billing.manage' => 'Process billing, invoicing, payments and receipts',
            'cashier.shift' => 'Manage cashier shift opening, float and closing variance',
            'lis.specimen' => 'Collect specimens and manage barcode chain of custody',
            'lis.results' => 'Enter lab results and verify clinical flags',
            'lis.approval' => 'Authorize final diagnostic reports as Pathologist/Consultant',
            'lis.microbiology' => 'Record culture incubation, organisms and antibiogram sensitivity',
            'lis.pathology' => 'Process histopathology accessioning, grossing and biopsy diagnosis',
            'radiology.view' => 'View radiology orders and modality worklist',
            'radiology.manage' => 'Manage radiology technician status and room scheduling',
            'radiology.report' => 'Authorize radiology reports as Radiologist/Sonologist',
            'pacs.access' => 'Access DICOM PACS imaging viewer launch',
            'reports.deliver' => 'Deliver combined reports, issue QR hashes and record delivery logs',
            'notifications.view' => 'Manage SMS and Email transactional notification logs',
            'home_collection.manage' => 'Book and dispatch home sample collections',
            'portal.manage' => 'Manage Patient Portal OTP accounts and mobile app APIs',
            'corporate.manage' => 'Manage corporate client contracts, eligibility and B2B invoices',
            'referral.manage' => 'Manage doctor/referrer profiles, visit logs and relationship performance',
            'commission.manage' => 'Manage commission rules, accrual holds, settlement batches and TDS',
            'crm.manage' => 'Manage corporate sales leads, campaigns and patient feedback',
            'inventory.manage' => 'Manage reagent and consumable stock, FEFO and stock transfers',
            'procurement.manage' => 'Manage purchase requisitions, PO issuance and GRN 3-way matching',
            'equipment.manage' => 'Manage equipment asset register and maintenance breakdown tickets',
            'accounting.manage' => 'Manage Chart of Accounts, double-entry GL vouchers, and financial statements',
            'hr.manage' => 'Manage employee profiles, clinical credential licenses and rosters',
            'payroll.manage' => 'Manage payroll processing, payslips and GL payroll voucher posting',
            'quality.manage' => 'Manage lab Quality Control (QC), TAT breach metrics, CAPA incidents and SOPs',
            'compliance.manage' => 'Manage regulatory compliance licensing, DGHS/BAERA renewals and calendars',
            'intelligence.view' => 'View executive & operational dashboards',
            'reports.export' => 'Generate and export governed report catalog',
            'integration.manage' => 'Manage external webhooks, APIs and partner integrations',
            'security.manage' => 'Manage cybersecurity controls, MFA and system backups'
        ];
        foreach ($newPermissions as $code => $desc) {
            $db->prepare('INSERT IGNORE INTO permissions(code,description) VALUES(?,?)')->execute([$code, $desc]);
            $db->prepare("INSERT IGNORE INTO role_permissions(role_id, permission_id) 
                SELECT r.id, p.id FROM roles r CROSS JOIN permissions p WHERE r.code='super_admin' AND p.code=?")->execute([$code]);
        }
    }
    if ($action === 'migrate') exit(0);
    if ($action === 'install') {
        if ((int) $db->query('SELECT COUNT(*) FROM users')->fetchColumn() > 0) throw new RuntimeException('Already installed. Use the administrator UI to manage users.');
        $ask = static function(string $label, bool $secret = false): string {
            fwrite(STDOUT, $label . ': ');
            $tty = function_exists('posix_isatty') && posix_isatty(STDIN);
            if ($secret && $tty) shell_exec('stty -echo');
            try { $answer = trim((string) fgets(STDIN)); }
            finally { if ($secret && $tty) { shell_exec('stty echo'); fwrite(STDOUT, "\n"); } }
            return $answer;
        };
        $org = $ask('Organization name');
        $short = $ask('Organization short name');
        $branchName = $ask('First branch name');
        $branchCode = strtoupper($ask('Branch code (e.g. DHA)'));
        $name = $ask('Administrator name');
        $email = mb_strtolower($ask('Administrator email'));
        $password = $ask('Administrator password (min 12 chars)', true);
        if (!$org || !$short || !$branchName || !preg_match('/^[A-Z0-9_-]{2,25}$/', $branchCode)
            || !$name || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 12) {
            throw new RuntimeException('Invalid setup details or password too short.');
        }
        $permissionCodes = [
            'dashboard.view','masters.view','masters.edit','settings.manage','users.manage',
            'audit.view','approvals.request','approvals.decide','sequences.manage','department.all',
        ];
        $roles = ['super_admin'=>'System administrator','branch_manager'=>'Branch manager',
            'front_desk'=>'Front desk','cashier'=>'Cashier','lab'=>'Laboratory','radiology'=>'Radiology',
            'finance'=>'Finance','quality'=>'Quality and compliance'];
        $db->beginTransaction();
        try {
            foreach ($permissionCodes as $code) $db->prepare('INSERT INTO permissions(code,description) VALUES(?,?)')->execute([$code, ucwords(str_replace(['.','_'], ' ', $code))]);
            foreach ($roles as $code => $label) $db->prepare('INSERT INTO roles(code,name) VALUES(?,?)')->execute([$code, $label]);
            // Ensure the first system administrator receives all permissions registered by installed modules.
            $db->exec("INSERT IGNORE INTO role_permissions(role_id,permission_id) SELECT r.id,p.id FROM roles r CROSS JOIN permissions p WHERE r.code='super_admin'");
            $grants = [
                'super_admin'=>$permissionCodes,
                'branch_manager'=>['dashboard.view','masters.view','masters.edit','audit.view','approvals.request','approvals.decide','department.all'],
                'front_desk'=>['dashboard.view','masters.view','approvals.request'],
                'cashier'=>['dashboard.view','masters.view','approvals.request'],
                'lab'=>['dashboard.view','masters.view','approvals.request'],
                'radiology'=>['dashboard.view','masters.view','approvals.request'],
                'finance'=>['dashboard.view','masters.view','audit.view','approvals.request','approvals.decide'],
                'quality'=>['dashboard.view','masters.view','audit.view','approvals.request','approvals.decide'],
            ];
            foreach ($grants as $role => $codes) foreach ($codes as $code) {
                $db->prepare('INSERT INTO role_permissions(role_id,permission_id) SELECT r.id,p.id FROM roles r CROSS JOIN permissions p WHERE r.code=? AND p.code=?')->execute([$role,$code]);
            }
            $db->prepare('INSERT INTO organizations(name,short_name) VALUES(?,?)')->execute([$org,$short]);
            $orgId = (int) $db->lastInsertId();
            $db->prepare('INSERT INTO branches(organization_id,code,name) VALUES(?,?,?)')->execute([$orgId,$branchCode,$branchName]);
            $branchId = (int) $db->lastInsertId();
            $db->prepare('INSERT INTO users(name,email,password_hash,password_changed_at) VALUES(?,?,?,NOW())')
                ->execute([$name,$email,password_hash($password,PASSWORD_DEFAULT)]);
            $userId = (int) $db->lastInsertId();
            $db->prepare("INSERT INTO user_roles(user_id,role_id) SELECT ?,id FROM roles WHERE code='super_admin'")->execute([$userId]);
            $db->prepare('INSERT INTO user_branches(user_id,branch_id) VALUES(?,?)')->execute([$userId,$branchId]);
            foreach (['patient'=>'PAT-','order'=>'ORD-','invoice'=>'INV-','receipt'=>'RCT-','barcode'=>'SMP-','report'=>'RPT-','voucher'=>'VCH-','purchase'=>'PUR-','employee'=>'EMP-'] as $type=>$prefix) {
                $db->prepare('INSERT INTO number_sequences(document_type,branch_id,prefix) VALUES(?,?,?)')->execute([$type,$branchId,$prefix]);
            }
            foreach (['discount','refund','result_correction','credit_note','purchase','journal_posting'] as $type) {
                $db->prepare('INSERT INTO approval_policies(action_type,approver_permission) VALUES(?,?)')->execute([$type,'approvals.decide']);
            }
            audit($db, 'organizations', (string) $orgId, 'install', null, ['name'=>$org], $branchId);
            $db->commit();
            echo "Installed. Serve only public/ as the document root.\n";
        } catch (Throwable $e) { $db->rollBack(); throw $e; }
        exit(0);
    }
    $email = $argv[2] ?? '';
    $code = $argv[3] ?? '';
    if (!$email || !$code) throw new RuntimeException('Email and branch code required.');
    $stmt = $db->prepare('INSERT IGNORE INTO user_branches(user_id,branch_id) SELECT u.id,b.id FROM users u CROSS JOIN branches b WHERE u.email=? AND b.code=?');
    $stmt->execute([$email,$code]);
    if ($stmt->rowCount() !== 1) throw new RuntimeException('No assignment made; check email/code or existing grant.');
    echo "Branch granted.\n";
} catch (Throwable $e) {
    fwrite(STDERR, $e->getMessage() . "\n");
    exit(1);
}
