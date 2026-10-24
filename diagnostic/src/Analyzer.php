<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Analyzer
{
    public static function addConnector(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'settings.manage');
        $code = strtoupper(trim((string) ($data['code'] ?? '')));
        $name = trim((string) ($data['name'] ?? ''));
        $protocol = (string) ($data['protocol'] ?? 'astm');

        if ($code === '' || $name === '') throw new RuntimeException('Connector code and name are required.');

        $stmt = $db->prepare('INSERT INTO analyzer_connectors (code, name, protocol) VALUES (?, ?, ?)');
        $stmt->execute([$code, $name, $protocol]);
        return (int) $db->lastInsertId();
    }

    public static function addMapping(PDO $db, int $connectorId, string $analyzerTestCode, int $erpTestId, float $multiplier = 1.0): int
    {
        Security::requirePermission($db, 'settings.manage');
        $stmt = $db->prepare('INSERT INTO analyzer_mappings (connector_id, analyzer_test_code, erp_test_id, multiplier) VALUES (?, ?, ?, ?)');
        $stmt->execute([$connectorId, $analyzerTestCode, $erpTestId, $multiplier]);
        return (int) $db->lastInsertId();
    }

    public static function logMessage(PDO $db, int $connectorId, string $payload): int
    {
        $stmt = $db->prepare('INSERT INTO analyzer_messages (connector_id, raw_payload, processed) VALUES (?, ?, 0)');
        $stmt->execute([$connectorId, $payload]);
        return (int) $db->lastInsertId();
    }

    public static function listConnectors(PDO $db): array
    {
        $stmt = $db->query('SELECT * FROM analyzer_connectors WHERE active=1 ORDER BY name ASC');
        return $stmt->fetchAll();
    }

    public static function getMappings(PDO $db, int $connectorId): array
    {
        $stmt = $db->prepare('SELECT am.*, dt.name AS erp_test_name, dt.code AS erp_test_code 
            FROM analyzer_mappings am 
            JOIN diagnostic_tests dt ON dt.id=am.erp_test_id 
            WHERE am.connector_id=?');
        $stmt->execute([$connectorId]);
        return $stmt->fetchAll();
    }
}
