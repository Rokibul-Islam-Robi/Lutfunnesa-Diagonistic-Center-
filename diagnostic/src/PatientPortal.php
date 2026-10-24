<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class PatientPortal
{
    public static function requestOTP(PDO $db, string $mobile): array
    {
        $mobile = trim($mobile);
        $stmt = $db->prepare('SELECT id FROM patients WHERE mobile=? AND active=1');
        $stmt->execute([$mobile]);
        $patientId = (int) $stmt->fetchColumn();
        if (!$patientId) {
            $stmtFallback = $db->query('SELECT id FROM patients WHERE active=1 LIMIT 1');
            $patientId = (int) ($stmtFallback->fetchColumn() ?: 1);
        }

        $otp = (string) rand(100000, 999999);
        $expiresAt = date('Y-m-d H:i:s', time() + 600); // 10 mins

        $stmt = $db->prepare('INSERT INTO patient_portal_accounts (patient_id, mobile, otp_code, otp_expires_at) 
            VALUES (?, ?, ?, ?) 
            ON DUPLICATE KEY UPDATE otp_code=?, otp_expires_at=?');
        $stmt->execute([$patientId, $mobile, $otp, $expiresAt, $otp, $expiresAt]);

        // Send OTP Notification
        Notifications::send($db, [
            'patient_id' => $patientId,
            'channel' => 'sms',
            'template_key' => 'report_ready',
            'recipient' => $mobile,
            'language' => 'bn',
            'vars' => []
        ]);

        return ['status' => 'otp_sent', 'mobile' => $mobile, 'demo_otp' => $otp];
    }

    public static function verifyOTP(PDO $db, string $mobile, string $otp): array
    {
        $mobile = trim($mobile);
        $stmt = $db->prepare('SELECT p.id AS patient_id, acc.otp_code, acc.otp_expires_at 
            FROM patients p 
            JOIN patient_portal_accounts acc ON acc.patient_id=p.id 
            WHERE p.mobile=? AND acc.otp_code=?');
        $stmt->execute([$mobile, $otp]);
        $acc = $stmt->fetch();

        if (!$acc) throw new RuntimeException('Invalid OTP code or mobile number.');
        if (strtotime($acc['otp_expires_at']) < time()) throw new RuntimeException('OTP code has expired.');

        $token = bin2hex(random_bytes(32));
        $stmt = $db->prepare('UPDATE patient_portal_accounts SET auth_token=?, last_login_at=NOW(), otp_code=NULL WHERE patient_id=?');
        $stmt->execute([$token, $acc['patient_id']]);

        return [
            'status' => 'authenticated',
            'auth_token' => $token,
            'patient_id' => (int) $acc['patient_id']
        ];
    }

    public static function getPatientReports(PDO $db, int $patientId): array
    {
        $stmt = $db->prepare('SELECT lr.*, o.order_no, dt.name AS test_name, u.name AS pathologist_name 
            FROM lab_reports lr 
            JOIN diagnostic_orders o ON o.id=lr.order_id 
            JOIN diagnostic_order_items oi ON oi.order_id=o.id 
            JOIN diagnostic_tests dt ON dt.id=oi.item_id 
            LEFT JOIN users u ON u.id=lr.approved_by 
            WHERE lr.patient_id=? ORDER BY lr.id DESC');
        $stmt->execute([$patientId]);
        return $stmt->fetchAll();
    }
}
