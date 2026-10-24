<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Commission
{
    public static function createRule(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $referrerId = !empty($data['referrer_id']) ? (int) $data['referrer_id'] : null;
        $departmentId = !empty($data['department_id']) ? (int) $data['department_id'] : null;
        $testId = !empty($data['test_id']) ? (int) $data['test_id'] : null;
        $rateType = (string) ($data['rate_type'] ?? 'percent_gross');
        $rateValue = (float) ($data['rate_value'] ?? 0.00);
        $startDate = trim((string) ($data['effective_from'] ?? date('Y-m-d')));

        $stmt = $db->prepare('INSERT INTO commission_rules (referrer_id, department_id, test_id, rate_type, rate_value, effective_from) 
            VALUES (?, ?, ?, ?, ?, ?)');
        $stmt->execute([$referrerId, $departmentId, $testId, $rateType, $rateValue, $startDate]);
        return (int) $db->lastInsertId();
    }

    public static function listRules(PDO $db): array
    {
        $stmt = $db->query('SELECT cr.*, r.name AS referrer_name, d.name AS department_name, dt.name AS test_name 
            FROM commission_rules cr 
            LEFT JOIN referrers r ON r.id=cr.referrer_id 
            LEFT JOIN departments d ON d.id=cr.department_id 
            LEFT JOIN diagnostic_tests dt ON dt.id=cr.test_id 
            ORDER BY cr.id DESC');
        return $stmt->fetchAll();
    }

    public static function calculateForOrder(PDO $db, int $orderId): array
    {
        $order = Orders::getOrder($db, $orderId);
        if (!$order || empty($order['referrer_id'])) return [];

        $referrerId = (int) $order['referrer_id'];
        $items = $order['items'] ?? [];
        $accruals = [];

        foreach ($items as $item) {
            $billed = (float) $item['price'];
            $rate = 15.00; // Standard default 15% rate rule
            $commission = round($billed * ($rate / 100.0), 2);

            $stmt = $db->prepare('INSERT INTO commission_accruals (order_id, order_item_id, referrer_id, billed_amount, realized_amount, rate_used, calculated_commission, status) 
                VALUES (?, ?, ?, ?, ?, ?, ?, "accrued")');
            $stmt->execute([$orderId, $item['id'], $referrerId, $billed, $billed, $rate, $commission]);
            $accruals[] = (int) $db->lastInsertId();
        }

        return $accruals;
    }

    public static function listAccruals(PDO $db): array
    {
        $stmt = $db->query('SELECT ca.*, r.name AS referrer_name, o.order_no, doi.item_name 
            FROM commission_accruals ca 
            JOIN referrers r ON r.id=ca.referrer_id 
            JOIN diagnostic_orders o ON o.id=ca.order_id 
            JOIN diagnostic_order_items doi ON doi.id=ca.order_item_id 
            ORDER BY ca.id DESC LIMIT 50');
        return $stmt->fetchAll();
    }

    public static function createSettlementBatch(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $referrerId = (int) ($data['referrer_id'] ?? 0);
        $branchId = (int) ($data['branch_id'] ?? Security::branchIds($db)[0]);
        $startDate = trim((string) ($data['period_start'] ?? date('Y-m-01')));
        $endDate = trim((string) ($data['period_end'] ?? date('Y-m-t')));
        $gross = (float) ($data['gross_commission'] ?? 0.00);
        $tdsRate = (float) ($data['tds_percent'] ?? 10.00);

        if (!$referrerId || $gross <= 0) throw new RuntimeException('Referrer Doctor and Gross Commission are required.');

        $tds = round($gross * ($tdsRate / 100.0), 2);
        $net = round($gross - $tds, 2);

        $db->beginTransaction();
        try {
            $batchNo = Numbering::next($db, 'voucher', $branchId);
            $batchNo = str_replace('VOU-', 'SETTLE-', $batchNo);

            $stmt = $db->prepare('INSERT INTO commission_settlement_batches (batch_no, referrer_id, branch_id, period_start, period_end, gross_commission, tds_deduction, net_payable, status, created_by) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, "approved", ?)');
            $stmt->execute([$batchNo, $referrerId, $branchId, $startDate, $endDate, $gross, $tds, $net, $userId]);
            $id = (int) $db->lastInsertId();

            audit($db, 'commission_settlement_batches', (string) $id, 'create_settlement_batch', null, [
                'batch_no' => $batchNo, 'gross' => $gross, 'tds' => $tds, 'net' => $net
            ], $branchId);

            $db->commit();
            return $id;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function listBatches(PDO $db): array
    {
        $stmt = $db->query('SELECT csb.*, r.name AS referrer_name, b.name AS branch_name, u.name AS creator_name 
            FROM commission_settlement_batches csb 
            JOIN referrers r ON r.id=csb.referrer_id 
            JOIN branches b ON b.id=csb.branch_id 
            JOIN users u ON u.id=csb.created_by 
            ORDER BY csb.id DESC');
        return $stmt->fetchAll();
    }
}
