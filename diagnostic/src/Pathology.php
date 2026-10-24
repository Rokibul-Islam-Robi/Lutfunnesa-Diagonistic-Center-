<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Pathology
{
    public static function accession(PDO $db, int $orderItemId, int $userId): int
    {
        Security::requirePermission($db, 'lab');

        $stmt = $db->prepare('SELECT o.branch_id FROM diagnostic_order_items oi JOIN diagnostic_orders o ON o.id=oi.order_id WHERE oi.id=?');
        $stmt->execute([$orderItemId]);
        $branchId = (int) $stmt->fetchColumn();
        if (!$branchId) throw new RuntimeException('Order item not found.');

        Security::requireBranch($db, $branchId);

        $db->beginTransaction();
        try {
            $accessionNo = Numbering::next($db, 'barcode', $branchId);
            $accessionNo = str_replace('SMP-', 'BIO-', $accessionNo);

            $stmt = $db->prepare('INSERT INTO pathology_accessions (accession_no, order_item_id, status) VALUES (?, ?, "accessioned")');
            $stmt->execute([$accessionNo, $orderItemId]);
            $id = (int) $db->lastInsertId();

            audit($db, 'pathology_accessions', (string) $id, 'accession', null, ['accession_no' => $accessionNo], $branchId);
            $db->commit();
            return $id;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function saveDiagnosis(PDO $db, array $data, int $userId): void
    {
        Security::requirePermission($db, 'lab');
        $id = (int) ($data['id'] ?? 0);
        $gross = !empty($data['gross_description']) ? trim((string) $data['gross_description']) : null;
        $micro = !empty($data['microscopic_description']) ? trim((string) $data['microscopic_description']) : null;
        $diag = !empty($data['diagnosis']) ? trim((string) $data['diagnosis']) : null;
        $comments = !empty($data['comments']) ? trim((string) $data['comments']) : null;

        $stmt = $db->prepare('SELECT * FROM pathology_accessions WHERE id=?');
        $stmt->execute([$id]);
        $acc = $stmt->fetch();
        if (!$acc) throw new RuntimeException('Accession record not found.');

        $status = $diag ? 'microscopy' : ($gross ? 'grossed' : 'accessioned');

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('UPDATE pathology_accessions SET gross_description=?, microscopic_description=?, diagnosis=?, comments=?, pathologist_id=?, status=? WHERE id=?');
            $stmt->execute([$gross, $micro, $diag, $comments, $userId, $status, $id]);

            audit($db, 'pathology_accessions', (string) $id, 'update_diagnosis', $acc, ['status' => $status], null);
            $db->commit();
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function listAccessions(PDO $db, int $branchId): array
    {
        Security::requireBranch($db, $branchId);
        $stmt = $db->prepare('SELECT pa.*, oi.item_name, p.name AS patient_name, p.mrn, path.name AS pathologist_name 
            FROM pathology_accessions pa 
            JOIN diagnostic_order_items oi ON oi.id=pa.order_item_id 
            JOIN diagnostic_orders o ON o.id=oi.order_id 
            JOIN patients p ON p.id=o.patient_id 
            LEFT JOIN users path ON path.id=pa.pathologist_id 
            WHERE o.branch_id=? ORDER BY pa.id DESC LIMIT 30');
        $stmt->execute([$branchId]);
        return $stmt->fetchAll();
    }
}
