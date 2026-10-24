<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Equipment
{
    public static function createAsset(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $code = trim((string) ($data['asset_code'] ?? ''));
        $name = trim((string) ($data['name'] ?? ''));
        $model = !empty($data['model_no']) ? trim((string) $data['model_no']) : null;
        $serial = !empty($data['serial_no']) ? trim((string) $data['serial_no']) : null;
        $departmentId = !empty($data['department_id']) ? (int) $data['department_id'] : null;
        $warranty = !empty($data['warranty_expiry']) ? trim((string) $data['warranty_expiry']) : null;

        if ($code === '' || $name === '') throw new RuntimeException('Asset Code and Name are required.');

        $stmt = $db->prepare('INSERT INTO equipment_assets (asset_code, name, model_no, serial_no, department_id, warranty_expiry, status) 
            VALUES (?, ?, ?, ?, ?, ?, "operational")');
        $stmt->execute([$code, $name, $model, $serial, $departmentId, $warranty]);
        return (int) $db->lastInsertId();
    }

    public static function listAssets(PDO $db): array
    {
        $stmt = $db->query('SELECT ea.*, d.name AS department_name 
            FROM equipment_assets ea 
            LEFT JOIN departments d ON d.id=ea.department_id 
            ORDER BY ea.id DESC');
        return $stmt->fetchAll();
    }

    public static function logMaintenanceTicket(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $assetId = (int) ($data['asset_id'] ?? 0);
        $kind = (string) ($data['maintenance_kind'] ?? 'breakdown');
        $priority = (string) ($data['priority'] ?? 'medium');
        $desc = trim((string) ($data['issue_description'] ?? ''));
        $cost = (float) ($data['cost'] ?? 0.00);

        if (!$assetId || $desc === '') throw new RuntimeException('Equipment Asset and Issue Description are required.');

        $db->beginTransaction();
        try {
            $ticketNo = Numbering::next($db, 'voucher', 1);
            $ticketNo = str_replace('VOU-', 'MNT-', $ticketNo);

            $stmt = $db->prepare('INSERT INTO equipment_maintenance_tickets (ticket_no, asset_id, maintenance_kind, priority, issue_description, cost, status, reported_by) 
                VALUES (?, ?, ?, ?, ?, ?, "open", ?)');
            $stmt->execute([$ticketNo, $assetId, $kind, $priority, $desc, $cost, $userId]);
            $id = (int) $db->lastInsertId();

            if ($kind === 'breakdown') {
                $db->prepare('UPDATE equipment_assets SET status="under_maintenance" WHERE id=?')->execute([$assetId]);
            }

            audit($db, 'equipment_maintenance_tickets', (string) $id, 'log_maintenance_ticket', null, [
                'ticket_no' => $ticketNo, 'cost' => $cost
            ], 1);

            $db->commit();
            return $id;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function listTickets(PDO $db): array
    {
        $stmt = $db->query('SELECT emt.*, ea.name AS asset_name, ea.asset_code, u.name AS reporter_name 
            FROM equipment_maintenance_tickets emt 
            JOIN equipment_assets ea ON ea.id=emt.asset_id 
            JOIN users u ON u.id=emt.reported_by 
            ORDER BY emt.id DESC');
        return $stmt->fetchAll();
    }
}
