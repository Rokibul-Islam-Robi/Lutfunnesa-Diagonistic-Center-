<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Microbiology
{
    public static function recordCulture(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'lab');
        $orderItemId = (int) ($data['order_item_id'] ?? 0);
        $collectionId = (int) ($data['sample_collection_id'] ?? 0);
        $quality = !empty($data['specimen_quality']) ? trim((string) $data['specimen_quality']) : 'Satisfactory';
        $gramStain = !empty($data['gram_stain_findings']) ? trim((string) $data['gram_stain_findings']) : null;
        $growthStatus = (string) ($data['growth_status'] ?? 'incubation');
        $organism = !empty($data['isolated_organism']) ? trim((string) $data['isolated_organism']) : null;
        $colonyCount = !empty($data['colony_count']) ? trim((string) $data['colony_count']) : null;

        if (!$orderItemId) {
            $stmt = $db->query('SELECT id FROM diagnostic_order_items ORDER BY id DESC LIMIT 1');
            $orderItemId = (int) ($stmt->fetchColumn() ?: 1);
        }
        if (!$collectionId) {
            $stmt = $db->query('SELECT id FROM sample_collections ORDER BY id DESC LIMIT 1');
            $collectionId = (int) ($stmt->fetchColumn() ?: 1);
        }

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('INSERT INTO microbiology_cultures (order_item_id, sample_collection_id, specimen_quality, gram_stain_findings, growth_status, isolated_organism, colony_count, reported_by) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
            $stmt->execute([$orderItemId, $collectionId, $quality, $gramStain, $growthStatus, $organism, $colonyCount, $userId]);
            $cultureId = (int) $db->lastInsertId();

            audit($db, 'microbiology_cultures', (string) $cultureId, 'record_culture', null, [
                'growth_status' => $growthStatus, 'organism' => $organism
            ], null);

            $db->commit();
            return $cultureId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function addSensitivity(PDO $db, int $cultureId, string $antibiotic, string $susceptibility, ?string $mic = null): void
    {
        Security::requirePermission($db, 'lab');
        if (!in_array($susceptibility, ['S', 'I', 'R'], true)) throw new RuntimeException('Invalid susceptibility rating (S/I/R).');

        $stmt = $db->prepare('INSERT INTO culture_sensitivities (culture_id, antibiotic_name, susceptibility, mic_value) VALUES (?, ?, ?, ?)');
        $stmt->execute([$cultureId, $antibiotic, $susceptibility, $mic]);
    }

    public static function listCultures(PDO $db, int $branchId): array
    {
        Security::requireBranch($db, $branchId);
        $stmt = $db->prepare('SELECT mc.*, oi.item_name, p.name AS patient_name, p.mrn 
            FROM microbiology_cultures mc 
            JOIN diagnostic_order_items oi ON oi.id=mc.order_item_id 
            JOIN diagnostic_orders o ON o.id=oi.order_id 
            JOIN patients p ON p.id=o.patient_id 
            WHERE o.branch_id=? ORDER BY mc.id DESC LIMIT 30');
        $stmt->execute([$branchId]);
        return $stmt->fetchAll();
    }
}
