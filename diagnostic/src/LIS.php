<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class LIS
{
    public static function collectSample(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'lab');
        $orderId = (int) ($data['order_id'] ?? 0);
        $orderItemId = (int) ($data['order_item_id'] ?? 0);
        $branchId = (int) ($data['branch_id'] ?? 0);
        $sampleTypeId = !empty($data['sample_type_id']) ? (int) $data['sample_type_id'] : null;
        $containerId = !empty($data['container_id']) ? (int) $data['container_id'] : null;

        if (!$orderId || !$orderItemId || !$branchId) throw new RuntimeException('Order, Item and Branch required.');
        Security::requireBranch($db, $branchId);

        $db->beginTransaction();
        try {
            $barcode = Numbering::next($db, 'barcode', $branchId);

            $stmt = $db->prepare('INSERT INTO sample_collections (barcode, order_id, order_item_id, branch_id, sample_type_id, container_id, status, collected_by, collected_at) 
                VALUES (?, ?, ?, ?, ?, ?, "collected", ?, NOW())');
            $stmt->execute([$barcode, $orderId, $orderItemId, $branchId, $sampleTypeId, $containerId, $userId]);
            $collectionId = (int) $db->lastInsertId();

            $stmt = $db->prepare('UPDATE diagnostic_order_items SET status="collected" WHERE id=?');
            $stmt->execute([$orderItemId]);

            audit($db, 'sample_collections', (string) $collectionId, 'collected', null, [
                'barcode' => $barcode, 'order_id' => $orderId
            ], $branchId);

            $db->commit();
            return $collectionId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function getWorklist(PDO $db, int $branchId, ?int $departmentId = null, ?string $status = null): array
    {
        Security::requireBranch($db, $branchId);
        $sql = 'SELECT sc.*, o.order_no, oi.item_name, p.name AS patient_name, p.mrn, p.gender, p.dob, st.name AS sample_type_name, c.name AS container_name 
            FROM sample_collections sc 
            JOIN diagnostic_orders o ON o.id=sc.order_id 
            JOIN diagnostic_order_items oi ON oi.id=sc.order_item_id 
            JOIN patients p ON p.id=o.patient_id 
            LEFT JOIN sample_types st ON st.id=sc.sample_type_id 
            LEFT JOIN containers c ON c.id=sc.container_id 
            WHERE sc.branch_id=?';
        $params = [$branchId];

        if ($status) {
            $sql .= ' AND sc.status=?';
            $params[] = $status;
        }

        $sql .= ' ORDER BY sc.id DESC LIMIT 50';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function enterResult(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'lab');
        $orderId = (int) ($data['order_id'] ?? 0);
        $orderItemId = (int) ($data['order_item_id'] ?? 0);
        $testId = (int) ($data['test_id'] ?? 0);
        $val = trim((string) ($data['result_value'] ?? ''));
        $comments = !empty($data['comments']) ? trim((string) $data['comments']) : null;

        if (!$orderId || !$orderItemId || !$testId || $val === '') {
            throw new RuntimeException('Order, Test and Result Value are required.');
        }

        // Auto Flagging against reference range
        $flag = 'normal';
        $refRangeText = null;

        if (is_numeric($val)) {
            $numVal = (float) $val;
            $stmt = $db->prepare('SELECT * FROM test_reference_ranges WHERE test_id=? AND active=1 ORDER BY id DESC LIMIT 1');
            $stmt->execute([$testId]);
            $range = $stmt->fetch();

            if ($range) {
                $refRangeText = $range['display_text'] ?: ($range['low_value'] . ' - ' . $range['high_value']);
                if ($range['critical_high'] !== null && $numVal >= (float) $range['critical_high']) $flag = 'critical';
                elseif ($range['critical_low'] !== null && $numVal <= (float) $range['critical_low']) $flag = 'critical';
                elseif ($range['high_value'] !== null && $numVal > (float) $range['high_value']) $flag = 'high';
                elseif ($range['low_value'] !== null && $numVal < (float) $range['low_value']) $flag = 'low';
            }
        }

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('INSERT INTO lab_results (order_id, order_item_id, test_id, result_value, result_flag, reference_range_text, comments, entered_by, status) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, "draft")');
            $stmt->execute([$orderId, $orderItemId, $testId, $val, $flag, $refRangeText, $comments, $userId]);
            $resultId = (int) $db->lastInsertId();

            $stmt = $db->prepare('UPDATE diagnostic_order_items SET status="in_lab" WHERE id=?');
            $stmt->execute([$orderItemId]);

            audit($db, 'lab_results', (string) $resultId, 'enter_result', null, [
                'val' => $val, 'flag' => $flag
            ], null);

            $db->commit();
            return $resultId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function verifyResult(PDO $db, int $resultId, int $userId): void
    {
        Security::requirePermission($db, 'lab');
        $stmt = $db->prepare('SELECT * FROM lab_results WHERE id=?');
        $stmt->execute([$resultId]);
        $res = $stmt->fetch();
        if (!$res) throw new RuntimeException('Result not found.');

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('UPDATE lab_results SET status="verified", verified_by=?, verified_at=NOW() WHERE id=?');
            $stmt->execute([$userId, $resultId]);

            audit($db, 'lab_results', (string) $resultId, 'technologist_verify', $res, ['status' => 'verified'], null);
            $db->commit();
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function approveReport(PDO $db, int $orderId, int $userId): int
    {
        Security::requirePermission($db, 'lab');
        $order = Orders::getOrder($db, $orderId);
        if (!$order) throw new RuntimeException('Order not found.');

        $branchId = (int) $order['branch_id'];
        $patientId = (int) $order['patient_id'];

        $db->beginTransaction();
        try {
            $reportNo = Numbering::next($db, 'report', $branchId);

            $stmt = $db->prepare('INSERT INTO lab_reports (report_no, order_id, branch_id, patient_id, status, approved_by, approved_at, version, pdf_watermark) 
                VALUES (?, ?, ?, ?, "approved", ?, NOW(), 1, "final")');
            $stmt->execute([$reportNo, $orderId, $branchId, $patientId, $userId]);
            $reportId = (int) $db->lastInsertId();

            $stmt = $db->prepare('UPDATE diagnostic_orders SET status="completed" WHERE id=?');
            $stmt->execute([$orderId]);

            $stmt = $db->prepare('UPDATE lab_results SET status="approved", verified_by=?, verified_at=NOW() WHERE order_id=?');
            $stmt->execute([$userId, $orderId]);

            $stmt = $db->prepare('UPDATE diagnostic_order_items SET status="completed" WHERE order_id=?');
            $stmt->execute([$orderId]);

            audit($db, 'lab_reports', (string) $reportId, 'pathologist_approve', null, [
                'report_no' => $reportNo
            ], $branchId);

            $db->commit();
            return $reportId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }
}
