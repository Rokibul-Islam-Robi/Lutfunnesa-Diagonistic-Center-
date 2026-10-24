<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Quality
{
    public static function logQC(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $section = trim((string) ($data['section_name'] ?? 'Biochemistry'));
        $testId = !empty($data['test_id']) ? (int) $data['test_id'] : null;
        $level = (string) ($data['qc_level'] ?? 'level_1');
        $target = (float) ($data['target_value'] ?? 100.0000);
        $observed = (float) ($data['observed_value'] ?? 101.2000);

        $status = (abs($observed - $target) > ($target * 0.10)) ? 'out_of_control' : 'passed';

        $stmt = $db->prepare('INSERT INTO quality_controls (section_name, test_id, qc_level, target_value, observed_value, status) 
            VALUES (?, ?, ?, ?, ?, ?)');
        $stmt->execute([$section, $testId, $level, $target, $observed, $status]);
        return (int) $db->lastInsertId();
    }

    public static function listQCLogs(PDO $db): array
    {
        $stmt = $db->query('SELECT qc.*, dt.name AS test_name 
            FROM quality_controls qc 
            LEFT JOIN diagnostic_tests dt ON dt.id=qc.test_id 
            ORDER BY qc.id DESC LIMIT 50');
        return $stmt->fetchAll();
    }

    public static function logCAPA(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $departmentId = !empty($data['department_id']) ? (int) $data['department_id'] : null;
        $severity = (string) ($data['severity'] ?? 'minor');
        $desc = trim((string) ($data['issue_description'] ?? ''));
        $cause = !empty($data['root_cause']) ? trim((string) $data['root_cause']) : null;
        $action = !empty($data['corrective_action']) ? trim((string) $data['corrective_action']) : null;

        if ($desc === '') throw new RuntimeException('Incident Issue Description is required.');

        $db->beginTransaction();
        try {
            $incidentNo = Numbering::next($db, 'voucher', 1);
            $incidentNo = str_replace('VOU-', 'CAPA-', $incidentNo);

            $stmt = $db->prepare('INSERT INTO capa_incidents (incident_no, department_id, severity, issue_description, root_cause, corrective_action, status, reported_by) 
                VALUES (?, ?, ?, ?, ?, ?, "open", ?)');
            $stmt->execute([$incidentNo, $departmentId, $severity, $desc, $cause, $action, $userId]);
            $id = (int) $db->lastInsertId();

            audit($db, 'capa_incidents', (string) $id, 'log_capa_incident', null, ['incident_no' => $incidentNo], 1);

            $db->commit();
            return $id;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function listCAPA(PDO $db): array
    {
        $stmt = $db->query('SELECT ci.*, d.name AS department_name, u.name AS reporter_name 
            FROM capa_incidents ci 
            LEFT JOIN departments d ON d.id=ci.department_id 
            JOIN users u ON u.id=ci.reported_by 
            ORDER BY ci.id DESC');
        return $stmt->fetchAll();
    }

    public static function createSOP(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $title = trim((string) ($data['title'] ?? ''));
        $category = (string) ($data['category'] ?? 'sop');
        $version = trim((string) ($data['version'] ?? '1.0'));
        $effDate = trim((string) ($data['effective_date'] ?? date('Y-m-d')));

        if ($title === '') throw new RuntimeException('Document Title is required.');

        $docNo = 'SOP-' . sprintf('%04d', rand(100, 9999));

        $stmt = $db->prepare('INSERT INTO controlled_documents (doc_no, title, category, version, effective_date, status) 
            VALUES (?, ?, ?, ?, ?, "approved")');
        $stmt->execute([$docNo, $title, $category, $version, $effDate]);
        return (int) $db->lastInsertId();
    }

    public static function listSOPs(PDO $db): array
    {
        $stmt = $db->query('SELECT * FROM controlled_documents ORDER BY id DESC');
        return $stmt->fetchAll();
    }

    public static function addComplianceLicense(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $no = trim((string) ($data['license_no'] ?? ''));
        $title = trim((string) ($data['title'] ?? ''));
        $category = (string) ($data['category'] ?? 'facility');
        $auth = trim((string) ($data['issuing_authority'] ?? 'DGHS'));
        $effDate = trim((string) ($data['effective_date'] ?? date('Y-m-d')));
        $expDate = trim((string) ($data['expiry_date'] ?? date('Y-12-31')));

        if ($no === '' || $title === '') throw new RuntimeException('License No and Title are required.');

        $stmt = $db->prepare('INSERT INTO compliance_licenses (license_no, title, category, issuing_authority, effective_date, expiry_date, status) 
            VALUES (?, ?, ?, ?, ?, ?, "active")');
        $stmt->execute([$no, $title, $category, $auth, $effDate, $expDate]);
        return (int) $db->lastInsertId();
    }

    public static function listLicenses(PDO $db): array
    {
        $stmt = $db->query('SELECT * FROM compliance_licenses ORDER BY expiry_date ASC');
        return $stmt->fetchAll();
    }
}
