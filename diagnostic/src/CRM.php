<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class CRM
{
    public static function createLead(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $company = trim((string) ($data['company_name'] ?? ''));
        $person = trim((string) ($data['contact_person'] ?? ''));
        $phone = trim((string) ($data['phone'] ?? ''));
        $email = !empty($data['email']) ? trim((string) $data['email']) : null;
        $notes = !empty($data['notes']) ? trim((string) $data['notes']) : null;

        if ($company === '' || $person === '' || $phone === '') throw new RuntimeException('Company, Contact Person and Phone are required.');

        $stmt = $db->prepare('INSERT INTO crm_leads (company_name, contact_person, phone, email, assigned_to, notes) 
            VALUES (?, ?, ?, ?, ?, ?)');
        $stmt->execute([$company, $person, $phone, $email, $userId, $notes]);
        return (int) $db->lastInsertId();
    }

    public static function listLeads(PDO $db): array
    {
        $stmt = $db->query('SELECT l.*, u.name AS owner_name 
            FROM crm_leads l 
            LEFT JOIN users u ON u.id=l.assigned_to 
            ORDER BY l.id DESC');
        return $stmt->fetchAll();
    }

    public static function submitFeedback(PDO $db, array $data): int
    {
        $patientId = (int) ($data['patient_id'] ?? 0);
        $orderId = !empty($data['order_id']) ? (int) $data['order_id'] : null;
        $category = (string) ($data['category'] ?? 'staff');
        $rating = max(1, min(5, (int) ($data['rating'] ?? 5)));
        $comments = trim((string) ($data['comments'] ?? ''));

        if (!$patientId) throw new RuntimeException('Patient ID is required.');

        $stmt = $db->prepare('INSERT INTO patient_feedback (patient_id, order_id, category, rating, comments) 
            VALUES (?, ?, ?, ?, ?)');
        $stmt->execute([$patientId, $orderId, $category, $rating, $comments]);
        return (int) $db->lastInsertId();
    }

    public static function listFeedback(PDO $db): array
    {
        $stmt = $db->query('SELECT pf.*, p.name AS patient_name, p.mobile, o.order_no 
            FROM patient_feedback pf 
            JOIN patients p ON p.id=pf.patient_id 
            LEFT JOIN diagnostic_orders o ON o.id=pf.order_id 
            ORDER BY pf.id DESC LIMIT 50');
        return $stmt->fetchAll();
    }
}
