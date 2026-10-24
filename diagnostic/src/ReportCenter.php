<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class ReportCenter
{
    public static function getCombinedReports(PDO $db, int $orderId): array
    {
        $order = Orders::getOrder($db, $orderId);
        if (!$order) throw new RuntimeException('Order not found.');

        // Lab Reports
        $stmt = $db->prepare('SELECT lr.*, u.name AS approver_name 
            FROM lab_reports lr 
            LEFT JOIN users u ON u.id=lr.approved_by 
            WHERE lr.order_id=?');
        $stmt->execute([$orderId]);
        $labReports = $stmt->fetchAll();

        // Radiology Reports
        $stmt = $db->prepare('SELECT rr.*, ro.modality, ro.accession_no, u.name AS radiologist_name 
            FROM radiology_reports rr 
            JOIN radiology_orders ro ON ro.id=rr.radiology_order_id 
            JOIN users u ON u.id=rr.radiologist_id 
            WHERE ro.order_id=?');
        $stmt->execute([$orderId]);
        $radReports = $stmt->fetchAll();

        return [
            'order' => $order,
            'lab_reports' => $labReports,
            'radiology_reports' => $radReports
        ];
    }

    public static function recordDelivery(PDO $db, array $data, int $userId): array
    {
        Security::requirePermission($db, 'dashboard.view');
        $orderId = (int) ($data['order_id'] ?? 0);
        $reportType = (string) ($data['report_type'] ?? 'lab');
        $reportId = (int) ($data['report_id'] ?? 0);
        $action = (string) ($data['action_type'] ?? 'print');
        $recipientEmail = !empty($data['recipient_email']) ? trim((string) $data['recipient_email']) : null;

        if (!$orderId || !$reportId) throw new RuntimeException('Order ID and Report ID are required.');

        $qrHash = hash('sha256', "ORD-{$orderId}-{$reportType}-{$reportId}-" . time());

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('INSERT INTO report_deliveries (order_id, report_type, report_id, action_type, acted_by, recipient_email, qr_verification_hash) 
                VALUES (?, ?, ?, ?, ?, ?, ?)');
            $stmt->execute([$orderId, $reportType, $reportId, $action, $userId, $recipientEmail, $qrHash]);
            $id = (int) $db->lastInsertId();

            audit($db, 'report_deliveries', (string) $id, 'deliver_report', null, [
                'action' => $action, 'qr_hash' => $qrHash
            ], null);

            $db->commit();
            return ['id' => $id, 'qr_hash' => $qrHash];
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function getDeliveryLog(PDO $db, int $orderId): array
    {
        $stmt = $db->prepare('SELECT rd.*, u.name AS actor_name 
            FROM report_deliveries rd 
            JOIN users u ON u.id=rd.acted_by 
            WHERE rd.order_id=? ORDER BY rd.id DESC');
        $stmt->execute([$orderId]);
        return $stmt->fetchAll();
    }

    public static function verifyQRHash(PDO $db, string $hash): ?array
    {
        $stmt = $db->prepare('SELECT rd.*, o.order_no, p.name AS patient_name, p.mrn 
            FROM report_deliveries rd 
            JOIN diagnostic_orders o ON o.id=rd.order_id 
            JOIN patients p ON p.id=o.patient_id 
            WHERE rd.qr_verification_hash=?');
        $stmt->execute([$hash]);
        return $stmt->fetch() ?: null;
    }
}
