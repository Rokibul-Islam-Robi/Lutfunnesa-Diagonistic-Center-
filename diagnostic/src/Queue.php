<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Queue
{
    public static function issueToken(PDO $db, array $data): array
    {
        $branchId = (int) ($data['branch_id'] ?? 0);
        $area = (string) ($data['service_area'] ?? 'registration');
        $priority = (string) ($data['priority'] ?? 'normal');
        $patientId = !empty($data['patient_id']) ? (int) $data['patient_id'] : null;
        $orderId = !empty($data['order_id']) ? (int) $data['order_id'] : null;
        $appointmentId = !empty($data['appointment_id']) ? (int) $data['appointment_id'] : null;

        if (!$branchId) throw new RuntimeException('Branch required for token generation.');
        Security::requireBranch($db, $branchId);

        $prefixes = [
            'registration' => 'REG',
            'billing' => 'BIL',
            'sample_collection' => 'SPL',
            'doctor_chamber' => 'DOC',
            'imaging' => 'IMG'
        ];
        $prefix = $prefixes[$area] ?? 'TKN';

        // Count today's tokens for sequence
        $stmt = $db->prepare('SELECT COUNT(*) FROM queue_tokens WHERE branch_id=? AND service_area=? AND DATE(created_at)=CURDATE()');
        $stmt->execute([$branchId, $area]);
        $seq = (int) $stmt->fetchColumn() + 1;
        $tokenNo = sprintf('%s-%03d', $prefix, $seq);

        $stmt = $db->prepare('INSERT INTO queue_tokens (token_no, branch_id, service_area, patient_id, order_id, appointment_id, priority, status) 
            VALUES (?, ?, ?, ?, ?, ?, ?, "waiting")');
        $stmt->execute([$tokenNo, $branchId, $area, $patientId, $orderId, $appointmentId, $priority]);
        $id = (int) $db->lastInsertId();

        return [
            'id' => $id,
            'token_no' => $tokenNo,
            'service_area' => $area,
            'status' => 'waiting'
        ];
    }

    public static function getQueue(PDO $db, int $branchId, ?string $serviceArea = null): array
    {
        Security::requireBranch($db, $branchId);
        $sql = 'SELECT q.*, p.name AS patient_name, p.mrn, c.name AS counter_name 
            FROM queue_tokens q 
            LEFT JOIN patients p ON p.id=q.patient_id 
            LEFT JOIN counters c ON c.id=q.counter_id 
            WHERE q.branch_id=? AND DATE(q.created_at)=CURDATE()';
        $params = [$branchId];

        if ($serviceArea) {
            $sql .= ' AND q.service_area=?';
            $params[] = $serviceArea;
        }

        $sql .= ' ORDER BY FIELD(q.status, "called", "serving", "waiting", "completed", "skipped"), FIELD(q.priority, "senior_vip", "urgent", "normal"), q.id ASC';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function callNext(PDO $db, int $counterId, string $serviceArea, int $userId): ?array
    {
        Security::requirePermission($db, 'queue.manage');
        $stmt = $db->prepare('SELECT branch_id FROM counters WHERE id=?');
        $stmt->execute([$counterId]);
        $branchId = (int) $stmt->fetchColumn();
        if (!$branchId) throw new RuntimeException('Invalid counter selected.');

        Security::requireBranch($db, $branchId);

        $db->beginTransaction();
        try {
            // Find next waiting token
            $stmt = $db->prepare('SELECT id FROM queue_tokens 
                WHERE branch_id=? AND service_area=? AND status="waiting" AND DATE(created_at)=CURDATE() 
                ORDER BY FIELD(priority, "senior_vip","urgent","normal"), id ASC LIMIT 1 FOR UPDATE');
            $stmt->execute([$branchId, $serviceArea]);
            $tokenId = (int) $stmt->fetchColumn();

            if (!$tokenId) {
                $db->commit();
                return null;
            }

            $stmt = $db->prepare('UPDATE queue_tokens SET counter_id=?, status="called", called_at=NOW() WHERE id=?');
            $stmt->execute([$counterId, $tokenId]);

            $stmt = $db->prepare('SELECT q.*, p.name AS patient_name, c.name AS counter_name FROM queue_tokens q LEFT JOIN patients p ON p.id=q.patient_id LEFT JOIN counters c ON c.id=q.counter_id WHERE q.id=?');
            $stmt->execute([$tokenId]);
            $calledToken = $stmt->fetch();

            audit($db, 'queue_tokens', (string) $tokenId, 'call_next', null, [
                'token_no' => $calledToken['token_no'], 'counter_id' => $counterId
            ], $branchId);

            $db->commit();
            return $calledToken;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function updateTokenStatus(PDO $db, int $tokenId, string $status, int $userId): void
    {
        Security::requirePermission($db, 'queue.manage');
        $stmt = $db->prepare('SELECT * FROM queue_tokens WHERE id=?');
        $stmt->execute([$tokenId]);
        $token = $stmt->fetch();
        if (!$token) throw new RuntimeException('Token not found.');

        Security::requireBranch($db, (int) $token['branch_id']);
        $allowed = ['waiting', 'called', 'serving', 'completed', 'skipped'];
        if (!in_array($status, $allowed, true)) throw new RuntimeException('Invalid queue token status.');

        $sql = 'UPDATE queue_tokens SET status=?';
        if ($status === 'serving' && empty($token['served_at'])) $sql .= ', served_at=NOW()';
        if ($status === 'completed' && empty($token['completed_at'])) $sql .= ', completed_at=NOW()';
        $sql .= ' WHERE id=?';

        $db->beginTransaction();
        try {
            $stmt = $db->prepare($sql);
            $stmt->execute([$status, $tokenId]);

            audit($db, 'queue_tokens', (string) $tokenId, 'status_change', $token, ['new_status' => $status], (int) $token['branch_id']);
            $db->commit();
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function getDisplayBoard(PDO $db, int $branchId): array
    {
        Security::requireBranch($db, $branchId);
        $stmt = $db->prepare('SELECT q.token_no, q.service_area, q.status, q.called_at, c.name AS counter_name, p.name AS patient_name 
            FROM queue_tokens q 
            LEFT JOIN counters c ON c.id=q.counter_id 
            LEFT JOIN patients p ON p.id=q.patient_id 
            WHERE q.branch_id=? AND q.status IN ("called","serving") AND DATE(q.created_at)=CURDATE() 
            ORDER BY q.called_at DESC LIMIT 15');
        $stmt->execute([$branchId]);
        $active = $stmt->fetchAll();

        $stmt = $db->prepare('SELECT service_area, COUNT(*) AS total_waiting 
            FROM queue_tokens 
            WHERE branch_id=? AND status="waiting" AND DATE(created_at)=CURDATE() 
            GROUP BY service_area');
        $stmt->execute([$branchId]);
        $waitingSummary = $stmt->fetchAll();

        return [
            'active_calling' => $active,
            'waiting_summary' => $waitingSummary
        ];
    }
}
