<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Billing
{
    public static function createInvoiceForOrder(PDO $db, int $orderId, int $userId): int
    {
        $order = Orders::getOrder($db, $orderId);
        if (!$order) throw new RuntimeException('Order not found.');

        // Check if invoice already exists
        $stmt = $db->prepare('SELECT id FROM invoices WHERE order_id=?');
        $stmt->execute([$orderId]);
        $existingId = $stmt->fetchColumn();
        if ($existingId) return (int) $existingId;

        $branchId = (int) $order['branch_id'];
        $patientId = (int) $order['patient_id'];
        $total = (float) $order['total_amount'];
        $discount = (float) $order['discount_amount'];
        $payable = (float) $order['payable_amount'];

        $ownTransaction = !$db->inTransaction();
        if ($ownTransaction) $db->beginTransaction();
        try {
            $invNo = Numbering::next($db, 'invoice', $branchId);

            $stmt = $db->prepare('INSERT INTO invoices 
                (invoice_no, order_id, branch_id, patient_id, total_amount, discount_amount, payable_amount, paid_amount, due_amount, status, created_by) 
                VALUES (?, ?, ?, ?, ?, ?, ?, 0.00, ?, "unpaid", ?)');
            $stmt->execute([
                $invNo, $orderId, $branchId, $patientId, $total, $discount, $payable, $payable, $userId
            ]);
            $invoiceId = (int) $db->lastInsertId();

            audit($db, 'invoices', (string) $invoiceId, 'create', null, [
                'invoice_no' => $invNo, 'payable' => $payable
            ], $branchId);

            if ($ownTransaction) $db->commit();
            return $invoiceId;
        } catch (\Throwable $e) {
            if ($ownTransaction && $db->inTransaction()) $db->rollBack();
            throw $e;
        }
    }

    public static function receivePayment(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'orders.create');
        $invoiceId = (int) ($data['invoice_id'] ?? 0);
        $methodId = (int) ($data['payment_method_id'] ?? 1);
        $amount = (float) ($data['amount'] ?? 0.00);
        $counterId = !empty($data['counter_id']) ? (int) $data['counter_id'] : null;
        $refNo = !empty($data['reference_no']) ? trim((string) $data['reference_no']) : null;
        $remarks = !empty($data['remarks']) ? trim((string) $data['remarks']) : null;

        if (!$invoiceId || $amount <= 0) {
            throw new RuntimeException('Valid invoice and payment amount are required.');
        }

        $stmt = $db->prepare('SELECT * FROM invoices WHERE id=?');
        $stmt->execute([$invoiceId]);
        $inv = $stmt->fetch();
        if (!$inv) throw new RuntimeException('Invoice not found.');

        $branchId = (int) $inv['branch_id'];
        Security::requireBranch($db, $branchId);

        $due = (float) $inv['due_amount'];
        if ($amount > $due + 0.01) {
            throw new RuntimeException('Payment amount cannot exceed the remaining due amount of BDT ' . number_format($due, 2));
        }

        // Validate payment_method_id
        $stmtPm = $db->prepare('SELECT id, code FROM payment_methods WHERE id=?');
        $stmtPm->execute([$methodId]);
        $pm = $stmtPm->fetch();
        if (!$pm) {
            $stmtFallback = $db->query('SELECT id, code FROM payment_methods WHERE active=1 LIMIT 1');
            $pm = $stmtFallback->fetch() ?: ['id' => 1, 'code' => 'CASH'];
            $methodId = (int) $pm['id'];
        }

        // Validate counter_id
        if ($counterId) {
            $stmtCnt = $db->prepare('SELECT id FROM counters WHERE id=?');
            $stmtCnt->execute([$counterId]);
            if (!$stmtCnt->fetchColumn()) {
                $stmtCntBranch = $db->prepare('SELECT id FROM counters WHERE branch_id=? AND active=1 LIMIT 1');
                $stmtCntBranch->execute([$branchId]);
                $counterId = $stmtCntBranch->fetchColumn() ?: null;
            }
        }

        // Auto-generate Gateway TxID if refNo empty
        if (!$refNo && in_array(strtoupper((string)($pm['code'] ?? '')), ['SSLCOMMERZ', 'BKASH', 'NAGAD', 'CARD', 'BANK_TRANSFER'], true)) {
            $prefix = match (strtoupper((string)$pm['code'])) {
                'SSLCOMMERZ' => 'TXN-SSL-',
                'BKASH' => 'TXN-BKASH-',
                'NAGAD' => 'TXN-NAGAD-',
                'CARD' => 'POS-CARD-',
                'BANK_TRANSFER' => 'EFT-',
                default => 'TXN-'
            };
            $refNo = $prefix . rand(100000, 999999);
        }

        $ownTransaction = !$db->inTransaction();
        if ($ownTransaction) $db->beginTransaction();
        try {
            $receiptNo = Numbering::next($db, 'receipt', $branchId);

            $stmt = $db->prepare('INSERT INTO payments (receipt_no, invoice_id, branch_id, counter_id, payment_method_id, amount, reference_no, remarks, received_by) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)');
            $stmt->execute([$receiptNo, $invoiceId, $branchId, $counterId ? (int)$counterId : null, $methodId, $amount, $refNo, $remarks, $userId]);
            $paymentId = (int) $db->lastInsertId();

            $newPaid = (float) $inv['paid_amount'] + $amount;
            $newDue = max(0.00, (float) $inv['payable_amount'] - $newPaid);
            $newStatus = $newDue <= 0.001 ? 'paid' : 'partially_paid';

            $stmt = $db->prepare('UPDATE invoices SET paid_amount=?, due_amount=?, status=? WHERE id=?');
            $stmt->execute([$newPaid, $newDue, $newStatus, $invoiceId]);

            // Update associated Order status
            if ($newStatus === 'paid') {
                Orders::updateStatus($db, (int) $inv['order_id'], 'ready_for_collection', $userId);
            }

            audit($db, 'payments', (string) $paymentId, 'received', null, [
                'receipt_no' => $receiptNo, 'amount' => $amount, 'new_status' => $newStatus
            ], $branchId);

            if ($ownTransaction) $db->commit();
            return $paymentId;
        } catch (\Throwable $e) {
            if ($ownTransaction && $db->inTransaction()) $db->rollBack();
            throw $e;
        }
    }

    public static function getInvoice(PDO $db, int $invoiceId): ?array
    {
        $stmt = $db->prepare('SELECT i.*, o.order_no, p.name AS patient_name, p.mrn, p.mobile AS patient_mobile 
            FROM invoices i 
            JOIN diagnostic_orders o ON o.id=i.order_id 
            JOIN patients p ON p.id=i.patient_id 
            WHERE i.id=?');
        $stmt->execute([$invoiceId]);
        $inv = $stmt->fetch() ?: null;
        if (!$inv) return null;

        Security::requireBranch($db, (int) $inv['branch_id']);

        $stmtPayments = $db->prepare('SELECT p.*, pm.name AS method_name, c.name AS counter_name, u.name AS receiver_name 
            FROM payments p 
            JOIN payment_methods pm ON pm.id=p.payment_method_id 
            LEFT JOIN counters c ON c.id=p.counter_id 
            JOIN users u ON u.id=p.received_by 
            WHERE p.invoice_id=? ORDER BY p.id ASC');
        $stmtPayments->execute([$invoiceId]);
        $inv['payments'] = $stmtPayments->fetchAll();

        return $inv;
    }

    public static function listInvoices(PDO $db, int $branchId, ?string $status = null): array
    {
        Security::requireBranch($db, $branchId);
        $sql = 'SELECT i.*, p.name AS patient_name, p.mrn, o.order_no 
            FROM invoices i 
            JOIN patients p ON p.id=i.patient_id 
            JOIN diagnostic_orders o ON o.id=i.order_id 
            WHERE i.branch_id=?';
        $params = [$branchId];

        if ($status) {
            $sql .= ' AND i.status=?';
            $params[] = $status;
        }

        $sql .= ' ORDER BY i.id DESC LIMIT 50';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }
}
