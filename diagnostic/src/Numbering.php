<?php
declare(strict_types=1);
namespace Diagnostic;

use DateTimeImmutable;
use PDO;
use RuntimeException;

final class Numbering
{
    public static function next(PDO $db, string $type, int $branchId, ?DateTimeImmutable $now = null): string
    {
        Security::requireBranch($db, $branchId);
        $now ??= new DateTimeImmutable();
        $ownTransaction = !$db->inTransaction();
        if ($ownTransaction) $db->beginTransaction();
        try {
            $stmt = $db->prepare('SELECT * FROM number_sequences WHERE document_type=? AND branch_id=? AND active=1 FOR UPDATE');
            $stmt->execute([$type, $branchId]);
            $sequence = $stmt->fetch();
            if (!$sequence) {
                $prefix = match($type) {
                    'doctor_prescribed' => 'DOC-',
                    'clinical_patient' => 'CLN-',
                    'local_customer' => 'LOC-',
                    'online_customer' => 'ONL-',
                    'patient' => 'PAT-',
                    'transfer', 'stock_transfer' => 'STR-',
                    'ticket', 'maintenance' => 'MNT-',
                    'pos', 'pos_invoice' => 'POS-',
                    'return' => 'RET-',
                    'credit_note' => 'CN-',
                    'po' => 'PO-',
                    'grn' => 'GRN-',
                    'quarantine' => 'QAR-',
                    default => strtoupper(substr($type, 0, 3)) . '-'
                };
                $db->prepare('INSERT INTO number_sequences (document_type, branch_id, prefix, padding, reset_period, period_key, next_value, active) VALUES (?, ?, ?, 5, "year", "", 1001, 1)')
                   ->execute([$type, $branchId, $prefix]);
                $stmt->execute([$type, $branchId]);
                $sequence = $stmt->fetch();
            }
            $period = match ($sequence['reset_period']) {
                'year' => $now->format('Y'), 'month' => $now->format('Y-m'), default => '',
            };
            $value = $period === $sequence['period_key'] ? (int) $sequence['next_value'] : 1;
            $db->prepare('UPDATE number_sequences SET period_key=?,next_value=? WHERE id=?')->execute([$period, $value+1, $sequence['id']]);
            $result = $sequence['prefix'] . ($period === '' ? '' : str_replace('-', '', $period) . '-') . str_pad((string) $value, (int) $sequence['padding'], '0', STR_PAD_LEFT);
            if ($ownTransaction) $db->commit();
            return $result;
        } catch (\Throwable $e) {
            if ($ownTransaction && $db->inTransaction()) $db->rollBack();
            throw $e;
        }
    }
}
