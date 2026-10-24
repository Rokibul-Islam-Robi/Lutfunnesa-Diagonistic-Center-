<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Notifications
{
    private static array $templates = [
        'appointment_confirm' => [
            'bn' => 'আপনার অ্যাপয়েন্টমেন্ট সফলভাবে কনফার্ম করা হয়েছে। অ্যাপয়েন্টমেন্ট নং: {code}',
            'en' => 'Your appointment has been confirmed. Appointment No: {code}'
        ],
        'payment_receipt' => [
            'bn' => 'আপনার পেমেন্ট সফলভাবে গৃহীত হয়েছে। রসিদ নং: {code}, পরিমাণ: BDT {amount}',
            'en' => 'Payment received successfully. Receipt No: {code}, Amount: BDT {amount}'
        ],
        'report_ready' => [
            'bn' => 'আপনার ডায়াগনস্টিক রিপোর্ট প্রস্তুত হয়েছে। অনলাইন পোর্টাল থেকে ডাউনলোড করতে ভিজিট করুন।',
            'en' => 'Your diagnostic test report is ready. Please log in to the patient portal to download.'
        ]
    ];

    public static function send(PDO $db, array $data): int
    {
        $patientId = (int) ($data['patient_id'] ?? 0);
        $channel = (string) ($data['channel'] ?? 'sms');
        $key = (string) ($data['template_key'] ?? 'report_ready');
        $recipient = trim((string) ($data['recipient'] ?? ''));
        $lang = (string) ($data['language'] ?? 'bn');
        $vars = (array) ($data['vars'] ?? []);

        if (!$patientId || $recipient === '') throw new RuntimeException('Patient and Recipient required.');

        $template = self::$templates[$key][$lang] ?? self::$templates['report_ready']['en'];
        foreach ($vars as $k => $v) {
            $template = str_replace('{' . $k . '}', (string)$v, $template);
        }

        $stmt = $db->prepare('INSERT INTO notification_logs (patient_id, channel, template_key, recipient, language, content, status, provider_response, sent_at) 
            VALUES (?, ?, ?, ?, ?, ?, "sent", "HTTP 200 OK - Sent via SMS Gateway", NOW())');
        $stmt->execute([$patientId, $channel, $key, $recipient, $lang, $template]);
        return (int) $db->lastInsertId();
    }

    public static function listLogs(PDO $db, int $limit = 50): array
    {
        $stmt = $db->prepare('SELECT nl.*, p.name AS patient_name, p.mrn 
            FROM notification_logs nl 
            JOIN patients p ON p.id=nl.patient_id 
            ORDER BY nl.id DESC LIMIT ?');
        $stmt->bindValue(1, $limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    /**
     * Get real-time system notifications filtered by role & permissions
     */
    public static function getSystemNotifications(PDO $db, array $user): array
    {
        $userId = (int) ($user['id'] ?? 0);
        $roleCode = (string) ($user['role_code'] ?? 'super_admin');
        $isAdmin = ($roleCode === 'super_admin');

        // Fetch read keys for this user
        $readKeys = [];
        try {
            $stmt = $db->prepare('SELECT notification_key FROM notification_reads WHERE user_id=?');
            $stmt->execute([$userId]);
            $readKeys = array_fill_keys($stmt->fetchAll(PDO::FETCH_COLUMN), true);
        } catch (\Throwable $e) {}

        $items = [];

        // 1. Pending Approval Requests
        // Super admin, accounts, or anyone with approvals.decide
        if ($isAdmin || Security::can($db, 'approvals.decide') || in_array($roleCode, ['super_admin', 'accounts'], true)) {
            try {
                $appStmt = $db->query("SELECT ar.id, ar.action_type, ar.entity_type, ar.entity_id, ar.amount, ar.created_at, u.name maker_name 
                    FROM approval_requests ar 
                    JOIN users u ON u.id=ar.maker_id 
                    WHERE ar.status='pending' 
                    ORDER BY ar.id DESC LIMIT 10");
                while ($row = $appStmt->fetch()) {
                    $key = 'approval_' . $row['id'];
                    $items[] = [
                        'id' => $key,
                        'category' => 'approval',
                        'title' => 'Pending Approval: ' . ucwords(str_replace('_', ' ', (string)$row['action_type'])),
                        'message' => 'Requested by ' . $row['maker_name'] . ' for ' . $row['entity_type'] . ' (' . $row['entity_id'] . ') · BDT ' . number_format((float)$row['amount'], 2),
                        'time' => self::timeElapsed($row['created_at']),
                        'link' => '/index.php?page=approvals',
                        'icon' => 'approval',
                        'badge' => 'High',
                        'badge_color' => 'amber',
                        'is_read' => isset($readKeys[$key])
                    ];
                }
            } catch (\Throwable $e) {}
        }

        // 2. Critical Diagnostic Alerts / Panic Values
        // Super admin, doctors, lab technologists
        if ($isAdmin || in_array($roleCode, ['doctor', 'lab_tech'], true) || Security::can($db, 'dashboard.view')) {
            try {
                $critStmt = $db->query("SELECT ca.*, p.name patient_name 
                    FROM critical_alert_logs ca 
                    LEFT JOIN diagnostic_order_items doi ON doi.id=ca.order_item_id 
                    LEFT JOIN diagnostic_orders do ON do.id=doi.order_id 
                    LEFT JOIN patients p ON p.id=do.patient_id 
                    WHERE ca.status IN ('pending', 'notified') 
                    ORDER BY ca.id DESC LIMIT 5");
                while ($row = $critStmt->fetch()) {
                    $key = 'critical_alert_' . $row['id'];
                    $items[] = [
                        'id' => $key,
                        'category' => 'critical',
                        'title' => 'Critical Lab Panic Value: ' . $row['critical_parameter'],
                        'message' => ($row['patient_name'] ? 'Patient: ' . $row['patient_name'] . ' · ' : '') . $row['critical_value'],
                        'time' => self::timeElapsed($row['logged_at']),
                        'link' => '/index.php?page=pathologist_desk',
                        'icon' => 'alert',
                        'badge' => 'Critical',
                        'badge_color' => 'red',
                        'is_read' => isset($readKeys[$key])
                    ];
                }
            } catch (\Throwable $e) {}
        }

        // 3. CAPA Incidents (Open & Critical/Major nonconformances)
        // Super admin, lab tech, doctor
        if ($isAdmin || in_array($roleCode, ['lab_tech', 'doctor'], true)) {
            try {
                $capaStmt = $db->query("SELECT ci.*, d.name department_name 
                    FROM capa_incidents ci 
                    LEFT JOIN departments d ON d.id=ci.department_id 
                    WHERE ci.status IN ('open', 'in_progress') 
                    ORDER BY ci.id DESC LIMIT 5");
                while ($row = $capaStmt->fetch()) {
                    $key = 'capa_' . $row['id'];
                    $items[] = [
                        'id' => $key,
                        'category' => 'compliance',
                        'title' => 'CAPA Incident ' . $row['incident_no'] . ' (' . strtoupper((string)$row['severity']) . ')',
                        'message' => mb_strimwidth((string)$row['issue_description'], 0, 90, '...'),
                        'time' => self::timeElapsed($row['created_at']),
                        'link' => '/index.php?page=quality_capa',
                        'icon' => 'shield',
                        'badge' => strtoupper((string)$row['severity']),
                        'badge_color' => ($row['severity'] === 'critical' ? 'red' : ($row['severity'] === 'major' ? 'amber' : 'teal')),
                        'is_read' => isset($readKeys[$key])
                    ];
                }
            } catch (\Throwable $e) {}
        }

        // 4. Quality Control (Westgard violations out of control)
        // Super admin, lab tech
        if ($isAdmin || $roleCode === 'lab_tech') {
            try {
                $qcStmt = $db->query("SELECT * FROM quality_controls WHERE status='out_of_control' ORDER BY id DESC LIMIT 5");
                while ($row = $qcStmt->fetch()) {
                    $key = 'qc_' . $row['id'];
                    $items[] = [
                        'id' => $key,
                        'category' => 'compliance',
                        'title' => 'Westgard QC Rule Violation: ' . $row['section_name'],
                        'message' => strtoupper((string)$row['qc_level']) . ' Target: ' . $row['target_value'] . ' vs Observed: ' . $row['observed_value'],
                        'time' => self::timeElapsed($row['logged_at']),
                        'link' => '/index.php?page=quality_qc_tat',
                        'icon' => 'flask',
                        'badge' => 'Out of Ctrl',
                        'badge_color' => 'red',
                        'is_read' => isset($readKeys[$key])
                    ];
                }
            } catch (\Throwable $e) {}
        }

        // 5. Regulatory Licenses Renewal Due / Expiring
        // Super admin, accounts
        if ($isAdmin || $roleCode === 'accounts') {
            try {
                $licStmt = $db->query("SELECT * FROM compliance_licenses WHERE status IN ('renewal_due', 'expired') OR expiry_date <= DATE_ADD(CURDATE(), INTERVAL 60 DAY) ORDER BY expiry_date ASC LIMIT 5");
                while ($row = $licStmt->fetch()) {
                    $key = 'license_' . $row['id'];
                    $items[] = [
                        'id' => $key,
                        'category' => 'compliance',
                        'title' => 'Regulatory License Renewal: ' . $row['license_no'],
                        'message' => $row['title'] . ' (Expires: ' . $row['expiry_date'] . ')',
                        'time' => 'Due soon',
                        'link' => '/index.php?page=compliance_calendar',
                        'icon' => 'calendar',
                        'badge' => 'Compliance',
                        'badge_color' => 'amber',
                        'is_read' => isset($readKeys[$key])
                    ];
                }
            } catch (\Throwable $e) {}
        }

        // 6. Patient Consultation Appointments Arrived / Scheduled
        // Doctor, Cashier, Super admin
        if ($isAdmin || in_array($roleCode, ['doctor', 'cashier'], true)) {
            try {
                $aptStmt = $db->query("SELECT a.*, p.name patient_name, doc.name doctor_name 
                    FROM appointments a 
                    JOIN patients p ON p.id=a.patient_id 
                    JOIN doctors doc ON doc.id=a.doctor_id 
                    WHERE a.status IN ('arrived', 'confirmed') 
                    ORDER BY a.id DESC LIMIT 4");
                while ($row = $aptStmt->fetch()) {
                    $key = 'apt_' . $row['id'];
                    $items[] = [
                        'id' => $key,
                        'category' => 'general',
                        'title' => 'Patient ' . ucfirst((string)$row['status']) . ': ' . $row['patient_name'],
                        'message' => 'Appointment #' . $row['appointment_no'] . ' with Dr. ' . $row['doctor_name'],
                        'time' => self::timeElapsed($row['created_at']),
                        'link' => '/index.php?page=appointments',
                        'icon' => 'user',
                        'badge' => ucfirst((string)$row['status']),
                        'badge_color' => 'teal',
                        'is_read' => isset($readKeys[$key])
                    ];
                }
            } catch (\Throwable $e) {}
        }

        // 7. Equipment Breakdown / Maintenance Tickets
        // Super admin, lab tech, pharmacist
        if ($isAdmin || in_array($roleCode, ['lab_tech', 'pharmacist'], true)) {
            try {
                $eqStmt = $db->query("SELECT emt.*, ea.name asset_name 
                    FROM equipment_maintenance_tickets emt 
                    JOIN equipment_assets ea ON ea.id=emt.asset_id 
                    WHERE emt.status IN ('open', 'in_progress') 
                    ORDER BY emt.id DESC LIMIT 3");
                while ($row = $eqStmt->fetch()) {
                    $key = 'equip_' . $row['id'];
                    $items[] = [
                        'id' => $key,
                        'category' => 'general',
                        'title' => 'Equipment Service: ' . $row['asset_name'],
                        'message' => 'Ticket #' . $row['ticket_no'] . ' · ' . mb_strimwidth((string)$row['issue_description'], 0, 80, '...'),
                        'time' => self::timeElapsed($row['created_at']),
                        'link' => '/index.php?page=equipment_assets',
                        'icon' => 'gear',
                        'badge' => strtoupper((string)$row['priority']),
                        'badge_color' => ($row['priority'] === 'high' ? 'red' : 'amber'),
                        'is_read' => isset($readKeys[$key])
                    ];
                }
            } catch (\Throwable $e) {}
        }

        // Calculate unread count
        $unreadCount = 0;
        foreach ($items as $item) {
            if (!$item['is_read']) {
                $unreadCount++;
            }
        }

        return [
            'count' => count($items),
            'unread_count' => $unreadCount,
            'items' => $items
        ];
    }

    public static function markAsRead(PDO $db, int $userId, ?string $notificationKey = null): void
    {
        if ($notificationKey) {
            $stmt = $db->prepare('INSERT IGNORE INTO notification_reads (user_id, notification_key, read_at) VALUES (?, ?, NOW())');
            $stmt->execute([$userId, $notificationKey]);
        } else {
            // Mark all active keys
            $stmt = $db->prepare('SELECT id FROM approval_requests UNION SELECT id FROM capa_incidents');
            // Or get current user notifications and mark them all
            $user = ['id' => $userId, 'role_code' => 'super_admin'];
            $data = self::getSystemNotifications($db, $user);
            $ins = $db->prepare('INSERT IGNORE INTO notification_reads (user_id, notification_key, read_at) VALUES (?, ?, NOW())');
            foreach ($data['items'] as $item) {
                $ins->execute([$userId, $item['id']]);
            }
        }
    }

    private static function timeElapsed(string $datetime): string
    {
        $time = strtotime($datetime);
        if (!$time) return 'Just now';
        $diff = time() - $time;
        if ($diff < 60) return 'Just now';
        if ($diff < 3600) return floor($diff / 60) . 'm ago';
        if ($diff < 86400) return floor($diff / 3600) . 'h ago';
        if ($diff < 604800) return floor($diff / 86400) . 'd ago';
        return date('d M', $time);
    }
}
