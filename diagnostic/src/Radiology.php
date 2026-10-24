<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Radiology
{
    public static function createRadiologyOrder(PDO $db, array $data, int $userId): int
    {
        $orderId = (int) ($data['order_id'] ?? 0);
        $orderItemId = (int) ($data['order_item_id'] ?? 0);
        $branchId = (int) ($data['branch_id'] ?? 0);
        $modality = (string) ($data['modality'] ?? 'xray');
        $history = !empty($data['clinical_history']) ? trim((string) $data['clinical_history']) : null;
        $roomId = !empty($data['room_id']) ? (int) $data['room_id'] : null;

        if (!$orderId || !$orderItemId || !$branchId) throw new RuntimeException('Order, Item and Branch required.');
        Security::requireBranch($db, $branchId);

        $db->beginTransaction();
        try {
            $accessionNo = Numbering::next($db, 'barcode', $branchId);
            $accessionNo = str_replace('SMP-', 'RAD-', $accessionNo);

            $stmt = $db->prepare('INSERT INTO radiology_orders (accession_no, order_id, order_item_id, branch_id, modality, room_id, status, clinical_history) 
                VALUES (?, ?, ?, ?, ?, ?, "scheduled", ?)');
            $stmt->execute([$accessionNo, $orderId, $orderItemId, $branchId, $modality, $roomId, $history]);
            $radOrderId = (int) $db->lastInsertId();

            audit($db, 'radiology_orders', (string) $radOrderId, 'create_imaging_order', null, [
                'accession_no' => $accessionNo, 'modality' => $modality
            ], $branchId);

            $db->commit();
            return $radOrderId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function getWorklist(PDO $db, int $branchId, ?string $modality = null): array
    {
        Security::requireBranch($db, $branchId);
        $sql = 'SELECT ro.*, oi.item_name, p.name AS patient_name, p.mrn, p.gender, p.dob, d.name AS doctor_name, rm.name AS room_name 
            FROM radiology_orders ro 
            JOIN diagnostic_order_items oi ON oi.id=ro.order_item_id 
            JOIN diagnostic_orders o ON o.id=ro.order_id 
            JOIN patients p ON p.id=o.patient_id 
            LEFT JOIN doctors d ON d.id=o.doctor_id 
            LEFT JOIN rooms rm ON rm.id=ro.room_id 
            WHERE ro.branch_id=?';
        $params = [$branchId];

        if ($modality) {
            $sql .= ' AND ro.modality=?';
            $params[] = $modality;
        }

        $sql .= ' ORDER BY ro.id DESC LIMIT 50';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function updateTechnicianStatus(PDO $db, int $radOrderId, string $status, int $userId): void
    {
        Security::requirePermission($db, 'radiology');
        $stmt = $db->prepare('SELECT * FROM radiology_orders WHERE id=?');
        $stmt->execute([$radOrderId]);
        $ro = $stmt->fetch();
        if (!$ro) throw new RuntimeException('Radiology order not found.');

        Security::requireBranch($db, (int) $ro['branch_id']);
        $allowed = ['scheduled', 'arrived', 'in_progress', 'completed', 'reported'];
        if (!in_array($status, $allowed, true)) throw new RuntimeException('Invalid technician status.');

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('UPDATE radiology_orders SET status=?, technician_id=? WHERE id=?');
            $stmt->execute([$status, $userId, $radOrderId]);

            audit($db, 'radiology_orders', (string) $radOrderId, 'technician_status', $ro, ['new_status' => $status], (int) $ro['branch_id']);
            $db->commit();
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function saveReport(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'radiology');
        $radOrderId = (int) ($data['radiology_order_id'] ?? 0);
        $findings = trim((string) ($data['findings'] ?? ''));
        $impression = trim((string) ($data['impression'] ?? ''));
        $criticalFlag = !empty($data['critical_finding_flag']) ? 1 : 0;
        $templateId = !empty($data['template_id']) ? (int) $data['template_id'] : null;

        if (!$radOrderId || $findings === '' || $impression === '') {
            throw new RuntimeException('Radiology order, Findings and Impression are required.');
        }

        $stmt = $db->prepare('SELECT * FROM radiology_orders WHERE id=?');
        $stmt->execute([$radOrderId]);
        $ro = $stmt->fetch();
        if (!$ro) throw new RuntimeException('Radiology order not found.');

        $branchId = (int) $ro['branch_id'];
        Security::requireBranch($db, $branchId);

        $db->beginTransaction();
        try {
            $repNo = Numbering::next($db, 'report', $branchId);
            $repNo = str_replace('RPT-', 'RAD-RPT-', $repNo);

            $stmt = $db->prepare('INSERT INTO radiology_reports (report_no, radiology_order_id, radiologist_id, template_id, findings, impression, critical_finding_flag, status) 
                VALUES (?, ?, ?, ?, ?, ?, ?, "finalized")');
            $stmt->execute([$repNo, $radOrderId, $userId, $templateId, $findings, $impression, $criticalFlag]);
            $reportId = (int) $db->lastInsertId();

            $stmt = $db->prepare('UPDATE radiology_orders SET status="reported", radiologist_id=?, critical_finding=? WHERE id=?');
            $stmt->execute([$userId, $criticalFlag, $radOrderId]);

            audit($db, 'radiology_reports', (string) $reportId, 'radiology_report_finalized', null, [
                'report_no' => $repNo, 'critical' => $criticalFlag
            ], $branchId);

            $db->commit();
            return $reportId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function getTemplates(PDO $db, ?string $modality = null): array
    {
        $sql = 'SELECT * FROM radiology_templates WHERE active=1';
        $params = [];
        if ($modality) {
            $sql .= ' AND modality=?';
            $params[] = $modality;
        }
        $sql .= ' ORDER BY name ASC';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function linkPACSStudy(PDO $db, int $radOrderId, string $studyUid, string $dicomPatientId, string $modality, ?string $url = null): int
    {
        $stmt = $db->prepare('INSERT INTO pacs_studies (radiology_order_id, study_instance_uid, dicom_patient_id, modality, viewer_url, status) 
            VALUES (?, ?, ?, ?, ?, "archived")');
        $stmt->execute([$radOrderId, $studyUid, $dicomPatientId, $modality, $url]);
        return (int) $db->lastInsertId();
    }
}
