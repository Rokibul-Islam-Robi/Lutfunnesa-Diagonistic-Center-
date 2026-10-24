<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Inventory
{
    public static function createItem(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $code = trim((string) ($data['code'] ?? ''));
        $name = trim((string) ($data['name'] ?? ''));
        $category = (string) ($data['category'] ?? 'reagent');
        $unitName = trim((string) ($data['unit_name'] ?? 'pcs'));
        $manufacturer = !empty($data['manufacturer']) ? trim((string) $data['manufacturer']) : null;
        $reorder = (float) ($data['min_reorder_level'] ?? 10.00);

        if ($code === '' || $name === '') throw new RuntimeException('Item Code and Name are required.');

        $stmt = $db->prepare('INSERT INTO inventory_items (code, name, category, unit_name, manufacturer, min_reorder_level) 
            VALUES (?, ?, ?, ?, ?, ?)');
        $stmt->execute([$code, $name, $category, $unitName, $manufacturer, $reorder]);
        return (int) $db->lastInsertId();
    }

    public static function listItems(PDO $db): array
    {
        $stmt = $db->query('SELECT * FROM inventory_items ORDER BY id DESC');
        return $stmt->fetchAll();
    }

    public static function addBatch(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $itemId = (int) ($data['item_id'] ?? 0);
        $branchId = (int) ($data['branch_id'] ?? Security::branchIds($db)[0]);
        $batchNo = trim((string) ($data['batch_no'] ?? ''));
        $expiryDate = trim((string) ($data['expiry_date'] ?? date('Y-12-31')));
        $qty = (float) ($data['quantity_on_hand'] ?? 100.00);
        $cost = (float) ($data['unit_cost'] ?? 50.00);

        if (!$itemId || $batchNo === '') throw new RuntimeException('Inventory Item and Batch Number are required.');

        $stmt = $db->prepare('INSERT INTO inventory_batches (item_id, branch_id, batch_no, expiry_date, quantity_on_hand, unit_cost) 
            VALUES (?, ?, ?, ?, ?, ?)');
        $stmt->execute([$itemId, $branchId, $batchNo, $expiryDate, $qty, $cost]);
        return (int) $db->lastInsertId();
    }

    public static function getFEFOStockList(PDO $db, int $branchId): array
    {
        $stmt = $db->prepare('SELECT ib.*, ii.code, ii.name AS item_name, ii.unit_name, ii.min_reorder_level 
            FROM inventory_batches ib 
            JOIN inventory_items ii ON ii.id=ib.item_id 
            WHERE ib.branch_id=? AND ib.quantity_on_hand > 0 
            ORDER BY ib.expiry_date ASC');
        $stmt->execute([$branchId]);
        return $stmt->fetchAll();
    }

    public static function createTransfer(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $fromBranch = (int) ($data['from_branch_id'] ?? Security::branchIds($db)[0]);
        $toBranch = (int) ($data['to_branch_id'] ?? 1);
        $itemId = (int) ($data['item_id'] ?? 0);
        $qty = (float) ($data['quantity'] ?? 1.00);

        if (!$itemId) {
            $stmtItem = $db->query('SELECT id FROM inventory_items ORDER BY id ASC LIMIT 1');
            $itemId = (int) ($stmtItem->fetchColumn() ?: 1);
        }
        if ($fromBranch === $toBranch) {
            $stmtOther = $db->prepare('SELECT id FROM branches WHERE id != ? AND active=1 LIMIT 1');
            $stmtOther->execute([$fromBranch]);
            $toBranch = (int) ($stmtOther->fetchColumn() ?: ($fromBranch === 1 ? 2 : 1));
        }

        $db->beginTransaction();
        try {
            $transferNo = Numbering::next($db, 'voucher', $fromBranch);
            $transferNo = str_replace('VOU-', 'TRF-', $transferNo);

            $stmt = $db->prepare('INSERT INTO inventory_transfers (transfer_no, from_branch_id, to_branch_id, item_id, quantity, status, requested_by) 
                VALUES (?, ?, ?, ?, ?, "in_transit", ?)');
            $stmt->execute([$transferNo, $fromBranch, $toBranch, $itemId, $qty, $userId]);
            $id = (int) $db->lastInsertId();

            audit($db, 'inventory_transfers', (string) $id, 'create_transfer', null, [
                'transfer_no' => $transferNo, 'qty' => $qty
            ], $fromBranch);

            $db->commit();
            return $id;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function listTransfers(PDO $db): array
    {
        $stmt = $db->query('SELECT it.*, ii.name AS item_name, b1.name AS from_branch, b2.name AS to_branch 
            FROM inventory_transfers it 
            JOIN inventory_items ii ON ii.id=it.item_id 
            JOIN branches b1 ON b1.id=it.from_branch_id 
            JOIN branches b2 ON b2.id=it.to_branch_id 
            ORDER BY it.id DESC');
        return $stmt->fetchAll();
    }
}
