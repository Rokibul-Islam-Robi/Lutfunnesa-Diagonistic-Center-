<?php
declare(strict_types=1);
namespace Diagnostic;

use PDO;
use RuntimeException;

final class Approvals
{
    public static function request(PDO $db, string $action, string $entity, string $entityId, int $branch, string $amount, string $reason): int
    {
        Security::requirePermission($db, 'approvals.request');
        Security::requireBranch($db, $branch);
        if (!is_numeric($amount) || (float) $amount < 0 || trim($reason) === '') throw new RuntimeException('Amount and reason are required.');
        $stmt = $db->prepare('SELECT * FROM approval_policies WHERE action_type=? AND (branch_id=? OR branch_id IS NULL) AND active=1 AND min_amount<=? AND (max_amount IS NULL OR max_amount>=?) ORDER BY (branch_id IS NOT NULL) DESC,min_amount DESC LIMIT 1');
        $stmt->execute([$action, $branch, $amount, $amount]);
        $policy = $stmt->fetch();
        if (!$policy) throw new RuntimeException('Approval policy has not been configured for this request.');
        $db->beginTransaction();
        try {
            $db->prepare('INSERT INTO approval_requests(policy_id,action_type,entity_type,entity_id,branch_id,amount,maker_id,request_reason) VALUES(?,?,?,?,?,?,?,?)')
                ->execute([$policy['id'], $action, $entity, $entityId, $branch, $amount, $_SESSION['user_id'], trim($reason)]);
            $id = (int) $db->lastInsertId();
            \audit($db, 'approval_requests', (string) $id, 'request', null, ['action' => $action, 'entity' => $entity, 'entity_id' => $entityId, 'amount' => $amount], $branch, $reason);
            $db->commit();
            return $id;
        } catch (\Throwable $e) { $db->rollBack(); throw $e; }
    }

    public static function decide(PDO $db, int $id, string $decision, string $reason): void
    {
        if (!in_array($decision, ['approved','rejected'], true) || trim($reason) === '') throw new RuntimeException('Decision and reason are required.');
        $db->beginTransaction();
        try {
            $stmt = $db->prepare('SELECT ar.*,ap.approver_permission FROM approval_requests ar JOIN approval_policies ap ON ap.id=ar.policy_id WHERE ar.id=? FOR UPDATE');
            $stmt->execute([$id]);
            $request = $stmt->fetch();
            if (!$request || $request['status'] !== 'pending') throw new RuntimeException('Request is no longer pending.');
            Security::requireBranch($db, (int) $request['branch_id']);
            Security::requirePermission($db, $request['approver_permission']);
            if ((int) $request['maker_id'] === (int) $_SESSION['user_id']) throw new RuntimeException('Maker cannot approve their own request.');
            $db->prepare('UPDATE approval_requests SET status=?,checker_id=?,decision_reason=?,decided_at=NOW() WHERE id=?')
                ->execute([$decision, $_SESSION['user_id'], trim($reason), $id]);
            \audit($db, 'approval_requests', (string) $id, 'decision', ['status' => 'pending'], ['status' => $decision], (int) $request['branch_id'], $reason);
            $db->commit();
        } catch (\Throwable $e) { $db->rollBack(); throw $e; }
    }
}
