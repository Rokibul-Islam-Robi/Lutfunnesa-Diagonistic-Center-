<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Referral
{
    public static function logVisit(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $referrerId = (int) ($data['referrer_id'] ?? 0);
        $visitDate = trim((string) ($data['visit_date'] ?? date('Y-m-d')));
        $notes = trim((string) ($data['discussion_notes'] ?? ''));
        $followUp = !empty($data['follow_up_action']) ? trim((string) $data['follow_up_action']) : null;

        if (!$referrerId || $notes === '') throw new RuntimeException('Referrer Doctor and Discussion Notes are required.');

        $stmt = $db->prepare('INSERT INTO referrer_visits (referrer_id, visited_by, visit_date, discussion_notes, follow_up_action) 
            VALUES (?, ?, ?, ?, ?)');
        $stmt->execute([$referrerId, $userId, $visitDate, $notes, $followUp]);
        return (int) $db->lastInsertId();
    }

    public static function listVisits(PDO $db, int $referrerId = 0): array
    {
        if ($referrerId > 0) {
            $stmt = $db->prepare('SELECT rv.*, r.name AS referrer_name, u.name AS visitor_name 
                FROM referrer_visits rv 
                JOIN referrers r ON r.id=rv.referrer_id 
                JOIN users u ON u.id=rv.visited_by 
                WHERE rv.referrer_id=? ORDER BY rv.id DESC');
            $stmt->execute([$referrerId]);
        } else {
            $stmt = $db->query('SELECT rv.*, r.name AS referrer_name, u.name AS visitor_name 
                FROM referrer_visits rv 
                JOIN referrers r ON r.id=rv.referrer_id 
                JOIN users u ON u.id=rv.visited_by 
                ORDER BY rv.id DESC LIMIT 50');
        }
        return $stmt->fetchAll();
    }

    public static function getReferrerPerformance(PDO $db): array
    {
        $stmt = $db->query('SELECT r.id, r.name, r.code, r.type, 
            COUNT(o.id) AS total_orders, 
            COALESCE(SUM(o.payable_amount), 0) AS total_revenue 
            FROM referrers r 
            LEFT JOIN diagnostic_orders o ON o.referrer_id=r.id 
            GROUP BY r.id, r.name, r.code, r.type 
            ORDER BY total_revenue DESC');
        return $stmt->fetchAll();
    }
}
