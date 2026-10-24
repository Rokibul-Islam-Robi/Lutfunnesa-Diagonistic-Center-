<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Cashier
{
    public static function openShift(PDO $db, array $data, int $userId): int
    {
        $branchId = (int) ($data['branch_id'] ?? 0);
        $counterId = (int) ($data['counter_id'] ?? 0);
        $openingFloat = (float) ($data['opening_float'] ?? 0.00);

        if (!$branchId || !$counterId) throw new RuntimeException('Branch and Counter selection are required.');
        Security::requireBranch($db, $branchId);

        // Check if cashier already has open shift
        $stmt = $db->prepare('SELECT id FROM cashier_shifts WHERE counter_id=? AND cashier_id=? AND status="open"');
        $stmt->execute([$counterId, $userId]);
        if ($stmt->fetchColumn()) throw new RuntimeException('You already have an open shift for this counter.');

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('INSERT INTO cashier_shifts (branch_id, counter_id, cashier_id, opening_float, system_expected_cash, declared_cash, variance, status, opened_at) 
                VALUES (?, ?, ?, ?, ?, 0.00, 0.00, "open", NOW())');
            $stmt->execute([$branchId, $counterId, $userId, $openingFloat, $openingFloat]);
            $shiftId = (int) $db->lastInsertId();

            audit($db, 'cashier_shifts', (string) $shiftId, 'open_shift', null, [
                'counter_id' => $counterId, 'float' => $openingFloat
            ], $branchId);

            $db->commit();
            return $shiftId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function getActiveShift(PDO $db, int $cashierId, int $counterId): ?array
    {
        $stmt = $db->prepare('SELECT s.*, c.name AS counter_name, b.name AS branch_name 
            FROM cashier_shifts s 
            JOIN counters c ON c.id=s.counter_id 
            JOIN branches b ON b.id=s.branch_id 
            WHERE s.cashier_id=? AND s.counter_id=? AND s.status="open"');
        $stmt->execute([$cashierId, $counterId]);
        return $stmt->fetch() ?: null;
    }

    public static function closeShift(PDO $db, array $data, int $userId): void
    {
        $shiftId = (int) ($data['shift_id'] ?? 0);
        $declaredCash = (float) ($data['declared_cash'] ?? 0.00);
        $notes = !empty($data['notes']) ? trim((string) $data['notes']) : null;
        $supervisorId = !empty($data['supervisor_id']) ? (int) $data['supervisor_id'] : null;

        $stmt = $db->prepare('SELECT * FROM cashier_shifts WHERE id=? AND status="open"');
        $stmt->execute([$shiftId]);
        $shift = $stmt->fetch();
        if (!$shift) throw new RuntimeException('Open shift record not found.');

        $branchId = (int) $shift['branch_id'];
        Security::requireBranch($db, $branchId);

        // Calculate expected cash from collections during shift
        $stmt = $db->prepare('SELECT COALESCE(SUM(amount), 0.00) FROM payments WHERE counter_id=? AND received_by=? AND created_at >= ?');
        $stmt->execute([$shift['counter_id'], $shift['cashier_id'], $shift['opened_at']]);
        $totalCollected = (float) $stmt->fetchColumn();

        $expectedCash = (float) $shift['opening_float'] + $totalCollected;
        $variance = $declaredCash - $expectedCash;

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('UPDATE cashier_shifts SET system_expected_cash=?, declared_cash=?, variance=?, status="closed", closed_at=NOW(), supervisor_id=?, notes=? WHERE id=?');
            $stmt->execute([$expectedCash, $declaredCash, $variance, $supervisorId, $notes, $shiftId]);

            audit($db, 'cashier_shifts', (string) $shiftId, 'close_shift', $shift, [
                'expected' => $expectedCash, 'declared' => $declaredCash, 'variance' => $variance
            ], $branchId);

            $db->commit();
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function listShifts(PDO $db, int $branchId): array
    {
        Security::requireBranch($db, $branchId);
        $stmt = $db->prepare('SELECT s.*, c.name AS counter_name, u.name AS cashier_name, sup.name AS supervisor_name 
            FROM cashier_shifts s 
            JOIN counters c ON c.id=s.counter_id 
            JOIN users u ON u.id=s.cashier_id 
            LEFT JOIN users sup ON sup.id=s.supervisor_id 
            WHERE s.branch_id=? ORDER BY s.id DESC LIMIT 30');
        $stmt->execute([$branchId]);
        return $stmt->fetchAll();
    }
}
