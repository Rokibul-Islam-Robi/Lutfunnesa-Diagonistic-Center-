<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Orders
{
    public static function createOrder(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'orders.create');
        $branchId = (int) ($data['branch_id'] ?? 0);
        $patientId = (int) ($data['patient_id'] ?? 0);
        $doctorId = !empty($data['doctor_id']) ? (int) $data['doctor_id'] : null;
        $referrerId = !empty($data['referrer_id']) ? (int) $data['referrer_id'] : null;
        $corporateId = !empty($data['corporate_client_id']) ? (int) $data['corporate_client_id'] : null;
        $urgency = (string) ($data['urgency'] ?? 'routine');
        $location = !empty($data['collection_location']) ? trim((string) $data['collection_location']) : 'Main Counter';
        $notes = !empty($data['clinical_notes']) ? trim((string) $data['clinical_notes']) : null;
        $items = (array) ($data['items'] ?? []);

        if (!$branchId || !$patientId || empty($items)) {
            throw new RuntimeException('Branch, Patient and at least one test item are required.');
        }
        Security::requireBranch($db, $branchId);

        $db->beginTransaction();
        try {
            $orderNo = Numbering::next($db, 'order', $branchId);

            $totalAmount = 0.00;
            $orderItems = [];

            foreach ($items as $item) {
                $itemId = (int) ($item['item_id'] ?? 0);
                $type = (string) ($item['item_type'] ?? 'test');

                if ($type === 'test') {
                    $stmt = $db->prepare('SELECT id, name FROM diagnostic_tests WHERE id=? AND active=1');
                    $stmt->execute([$itemId]);
                    $testRow = $stmt->fetch();
                    if (!$testRow) continue;
                    $itemName = $testRow['name'];
                } else {
                    $stmt = $db->prepare('SELECT id, name FROM test_panels WHERE id=? AND active=1');
                    $stmt->execute([$itemId]);
                    $panelRow = $stmt->fetch();
                    if (!$panelRow) continue;
                    $itemName = $panelRow['name'];
                }

                $price = (float) ($item['price'] ?? 1000.00);
                $fasting = !empty($item['fasting_required']) ? 1 : 0;
                $prepNotes = !empty($item['preparation_notes']) ? trim((string) $item['preparation_notes']) : null;

                $totalAmount += $price;
                $orderItems[] = [
                    'item_type' => $type,
                    'item_id' => $itemId,
                    'item_name' => $itemName,
                    'price' => $price,
                    'fasting_required' => $fasting,
                    'preparation_notes' => $prepNotes
                ];
            }

            if (empty($orderItems)) {
                throw new RuntimeException('No valid diagnostic tests or panels were selected.');
            }

            $discountAmount = (float) ($data['discount_amount'] ?? 0.00);
            $payableAmount = max(0.00, $totalAmount - $discountAmount);

            $stmt = $db->prepare('INSERT INTO diagnostic_orders 
                (order_no, branch_id, patient_id, doctor_id, referrer_id, corporate_client_id, urgency, collection_location, clinical_notes, status, total_amount, discount_amount, payable_amount, created_by) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, "pending_payment", ?, ?, ?, ?)');
            $stmt->execute([
                $orderNo, $branchId, $patientId, $doctorId, $referrerId, $corporateId,
                $urgency, $location, $notes, $totalAmount, $discountAmount, $payableAmount, $userId
            ]);
            $orderId = (int) $db->lastInsertId();

            $stmtItem = $db->prepare('INSERT INTO diagnostic_order_items (order_id, item_type, item_id, item_name, price, fasting_required, preparation_notes) 
                VALUES (?, ?, ?, ?, ?, ?, ?)');
            foreach ($orderItems as $item) {
                $stmtItem->execute([
                    $orderId, $item['item_type'], $item['item_id'], $item['item_name'],
                    $item['price'], $item['fasting_required'], $item['preparation_notes']
                ]);
            }

            // Issue Queue token for registration / billing
            Queue::issueToken($db, [
                'branch_id' => $branchId,
                'service_area' => 'billing',
                'patient_id' => $patientId,
                'order_id' => $orderId,
                'priority' => $urgency === 'stat' ? 'urgent' : 'normal'
            ]);

            audit($db, 'diagnostic_orders', (string) $orderId, 'create', null, [
                'order_no' => $orderNo, 'total' => $totalAmount, 'payable' => $payableAmount
            ], $branchId);

            $db->commit();
            return $orderId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function getOrder(PDO $db, int $orderId): ?array
    {
        $stmt = $db->prepare('SELECT o.*, p.name AS patient_name, p.mrn, p.mobile AS patient_mobile, d.name AS doctor_name, r.name AS referrer_name, c.name AS corporate_name 
            FROM diagnostic_orders o 
            JOIN patients p ON p.id=o.patient_id 
            LEFT JOIN doctors d ON d.id=o.doctor_id 
            LEFT JOIN referrers r ON r.id=o.referrer_id 
            LEFT JOIN corporate_clients c ON c.id=o.corporate_client_id 
            WHERE o.id=?');
        $stmt->execute([$orderId]);
        $order = $stmt->fetch() ?: null;
        if (!$order) return null;

        Security::requireBranch($db, (int) $order['branch_id']);

        $stmtItems = $db->prepare('SELECT * FROM diagnostic_order_items WHERE order_id=?');
        $stmtItems->execute([$orderId]);
        $order['items'] = $stmtItems->fetchAll();

        return $order;
    }

    public static function listOrders(PDO $db, int $branchId, ?string $status = null, int $limit = 50): array
    {
        Security::requireBranch($db, $branchId);
        $sql = 'SELECT o.*, p.name AS patient_name, p.mrn, p.mobile AS patient_mobile, d.name AS doctor_name 
            FROM diagnostic_orders o 
            JOIN patients p ON p.id=o.patient_id 
            LEFT JOIN doctors d ON d.id=o.doctor_id 
            WHERE o.branch_id=?';
        $params = [$branchId];

        if ($status) {
            $sql .= ' AND o.status=?';
            $params[] = $status;
        }

        $sql .= ' ORDER BY o.id DESC LIMIT ?';
        $params[] = $limit;

        $stmt = $db->prepare($sql);
        foreach ($params as $idx => $val) {
            $stmt->bindValue($idx + 1, $val, is_int($val) ? PDO::PARAM_INT : PDO::PARAM_STR);
        }
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public static function updateStatus(PDO $db, int $orderId, string $status, int $userId): void
    {
        Security::requirePermission($db, 'orders.create');
        $order = self::getOrder($db, $orderId);
        if (!$order) throw new RuntimeException('Order not found.');

        $allowed = ['pending_payment', 'ready_for_collection', 'sample_collected', 'processing', 'completed', 'delivered'];
        if (!in_array($status, $allowed, true)) {
            throw new RuntimeException('Invalid order status transition.');
        }

        $ownTransaction = !$db->inTransaction();
        if ($ownTransaction) $db->beginTransaction();
        try {
            $stmt = $db->prepare('UPDATE diagnostic_orders SET status=? WHERE id=?');
            $stmt->execute([$status, $orderId]);

            // Automatically issue Sample Collection token when paid
            if ($status === 'ready_for_collection') {
                Queue::issueToken($db, [
                    'branch_id' => (int) $order['branch_id'],
                    'service_area' => 'sample_collection',
                    'patient_id' => (int) $order['patient_id'],
                    'order_id' => $orderId,
                    'priority' => $order['urgency'] === 'stat' ? 'urgent' : 'normal'
                ]);
            }

            audit($db, 'diagnostic_orders', (string) $orderId, 'status_change', $order, [
                'new_status' => $status
            ], (int) $order['branch_id']);

            if ($ownTransaction) $db->commit();
        } catch (\Throwable $e) {
            if ($ownTransaction && $db->inTransaction()) $db->rollBack();
            throw $e;
        }
    }

    public static function getDashboardMetrics(PDO $db, int $branchId): array
    {
        Security::requireBranch($db, $branchId);
        $statuses = ['pending_payment', 'ready_for_collection', 'sample_collected', 'processing', 'completed', 'delivered'];
        $metrics = [];
        foreach ($statuses as $st) {
            $stmt = $db->prepare('SELECT COUNT(*) FROM diagnostic_orders WHERE branch_id=? AND status=?');
            $stmt->execute([$branchId, $st]);
            $metrics[$st] = (int) $stmt->fetchColumn();
        }
        return $metrics;
    }
}
