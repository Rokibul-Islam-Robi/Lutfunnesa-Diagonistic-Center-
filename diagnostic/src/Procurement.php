<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Procurement
{
    public static function createRequisition(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $branchId = (int) ($data['branch_id'] ?? Security::branchIds($db)[0]);
        $notes = trim((string) ($data['notes'] ?? ''));

        $db->beginTransaction();
        try {
            $reqNo = Numbering::next($db, 'purchase', $branchId);
            $reqNo = str_replace('PO-', 'REQ-', $reqNo);

            $stmt = $db->prepare('INSERT INTO purchase_requisitions (req_no, branch_id, requested_by, status, notes) 
                VALUES (?, ?, ?, "approved", ?)');
            $stmt->execute([$reqNo, $branchId, $userId, $notes]);
            $id = (int) $db->lastInsertId();

            audit($db, 'purchase_requisitions', (string) $id, 'create_requisition', null, ['req_no' => $reqNo], $branchId);

            $db->commit();
            return $id;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function listRequisitions(PDO $db): array
    {
        $stmt = $db->query('SELECT pr.*, b.name AS branch_name, u.name AS requester_name 
            FROM purchase_requisitions pr 
            JOIN branches b ON b.id=pr.branch_id 
            JOIN users u ON u.id=pr.requested_by 
            ORDER BY pr.id DESC');
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function createPO(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $supplierId = (int) ($data['supplier_id'] ?? 0);
        $branchId = (int) ($data['branch_id'] ?? Security::branchIds($db)[0]);
        $amount = (float) ($data['total_amount'] ?? 0.00);
        $notes = trim((string) ($data['notes'] ?? ''));

        if (!$supplierId || $amount <= 0) throw new RuntimeException('Supplier and Total Amount are required.');

        // 5% TDS and 7.5% VDS by statutory NBR healthcare standard
        $tds = round($amount * 0.05, 2);
        $vds = round($amount * 0.075, 2);

        $db->beginTransaction();
        try {
            $poNo = Numbering::next($db, 'purchase', $branchId);

            $stmt = $db->prepare('INSERT INTO purchase_orders (po_no, supplier_id, branch_id, total_amount, status, created_by, po_date, delivery_date, payment_status, tds_amount, vds_amount, notes) 
                VALUES (?, ?, ?, ?, "issued", ?, CURDATE(), CURDATE() + INTERVAL 7 DAY, "unpaid", ?, ?, ?)');
            $stmt->execute([$poNo, $supplierId, $branchId, $amount, $userId, $tds, $vds, $notes]);
            $id = (int) $db->lastInsertId();

            audit($db, 'purchase_orders', (string) $id, 'create_po', null, [
                'po_no' => $poNo, 'total_amount' => $amount
            ], $branchId);

            $db->commit();
            return $id;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function receiveGRN(PDO $db, int $poId, string $invoiceNo, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $po = $db->prepare('SELECT * FROM purchase_orders WHERE id=?');
        $po->execute([$poId]);
        $poData = $po->fetch(PDO::FETCH_ASSOC);
        if (!$poData) throw new RuntimeException('Purchase Order not found.');

        $branchId = (int) $poData['branch_id'];
        $grnNo = 'GRN-' . date('Ymd') . '-' . str_pad((string)$poId, 3, '0', STR_PAD_LEFT);

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('INSERT INTO goods_received_notes (grn_no, po_id, branch_id, supplier_invoice_no, received_by) 
                VALUES (?, ?, ?, ?, ?)');
            $stmt->execute([$grnNo, $poId, $branchId, $invoiceNo ?: 'INV-' . strtoupper(substr(md5((string)$poId), 0, 8)), $userId]);
            $grnId = (int) $db->lastInsertId();

            $upd = $db->prepare('UPDATE purchase_orders SET status="received" WHERE id=?');
            $upd->execute([$poId]);

            audit($db, 'goods_received_notes', (string) $grnId, 'create_grn', null, ['grn_no' => $grnNo, 'po_id' => $poId], $branchId);

            $db->commit();
            return $grnId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function listPOs(PDO $db): array
    {
        $stmt = $db->query('SELECT po.*, s.name AS supplier_name, s.code AS supplier_code, s.category AS supplier_category,
            b.name AS branch_name, u.name AS creator_name,
            grn.grn_no, grn.supplier_invoice_no, grn.created_at AS grn_date
            FROM purchase_orders po 
            JOIN suppliers s ON s.id=po.supplier_id 
            JOIN branches b ON b.id=po.branch_id 
            JOIN users u ON u.id=po.created_by 
            LEFT JOIN goods_received_notes grn ON grn.po_id=po.id
            ORDER BY po.id DESC');
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function getProcurementStats(PDO $db): array
    {
        $sql = 'SELECT 
            COUNT(po.id) AS total_orders,
            COALESCE(SUM(po.total_amount), 0.00) AS total_spend,
            COALESCE(SUM(CASE WHEN po.status="issued" THEN 1 ELSE 0 END), 0) AS pending_deliveries,
            COALESCE(SUM(CASE WHEN po.status="received" THEN 1 ELSE 0 END), 0) AS grn_completed,
            COALESCE(SUM(po.tds_amount + po.vds_amount), 0.00) AS total_tax_withheld
            FROM purchase_orders po';
        return $db->query($sql)->fetch(PDO::FETCH_ASSOC) ?: [
            'total_orders' => 0, 'total_spend' => 0.0, 'pending_deliveries' => 0, 'grn_completed' => 0, 'total_tax_withheld' => 0.0
        ];
    }
}
