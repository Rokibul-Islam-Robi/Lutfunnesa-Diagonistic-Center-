<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Appointments
{
    public static function getSchedules(PDO $db, int $branchId, ?int $doctorId = null): array
    {
        Security::requireBranch($db, $branchId);
        $sql = 'SELECT s.*, d.name AS doctor_name, r.name AS room_name 
            FROM doctor_schedules s 
            JOIN doctors d ON d.id=s.doctor_id 
            LEFT JOIN rooms r ON r.id=s.room_id 
            WHERE s.branch_id=? AND s.active=1';
        $params = [$branchId];

        if ($doctorId) {
            $sql .= ' AND s.doctor_id=?';
            $params[] = $doctorId;
        }

        $sql .= ' ORDER BY s.doctor_id, FIELD(s.day_of_week, "sun","mon","tue","wed","thu","fri","sat"), s.start_time';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function saveSchedule(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'appointments.manage');
        $doctorId = (int) ($data['doctor_id'] ?? 0);
        $branchId = (int) ($data['branch_id'] ?? 0);
        $dayOfWeek = (string) ($data['day_of_week'] ?? 'sun');
        $startTime = (string) ($data['start_time'] ?? '09:00:00');
        $endTime = (string) ($data['end_time'] ?? '13:00:00');
        $maxPatients = (int) ($data['max_patients'] ?? 20);
        $roomId = !empty($data['room_id']) ? (int) $data['room_id'] : null;

        if (!$doctorId || !$branchId) {
            throw new RuntimeException('Doctor and Branch are required.');
        }
        Security::requireBranch($db, $branchId);

        $stmt = $db->prepare('INSERT INTO doctor_schedules (branch_id, doctor_id, day_of_week, start_time, end_time, max_patients, room_id) 
            VALUES (?, ?, ?, ?, ?, ?, ?)');
        $stmt->execute([$branchId, $doctorId, $dayOfWeek, $startTime, $endTime, $maxPatients, $roomId]);
        $id = (int) $db->lastInsertId();

        audit($db, 'doctor_schedules', (string) $id, 'create', null, [
            'doctor_id' => $doctorId, 'day_of_week' => $dayOfWeek
        ], $branchId);

        return $id;
    }

    public static function list(PDO $db, int $branchId, ?string $date = null, ?int $doctorId = null): array
    {
        Security::requireBranch($db, $branchId);
        $sql = 'SELECT a.*, p.name AS patient_name, p.mobile AS patient_mobile, p.mrn, p.category AS patient_category,
                       d.name AS doctor_name, d.specialty, d.consultation_fee AS doc_default_fee,
                       rm.name AS room_name, ref.name AS referrer_name
            FROM appointments a 
            JOIN patients p ON p.id=a.patient_id 
            JOIN doctors d ON d.id=a.doctor_id 
            LEFT JOIN rooms rm ON rm.id=a.room_id 
            LEFT JOIN referrers ref ON ref.id=a.referrer_id
            WHERE a.branch_id=?';
        $params = [$branchId];

        if ($date) {
            $sql .= ' AND a.appointment_date=?';
            $params[] = $date;
        }
        if ($doctorId) {
            $sql .= ' AND a.doctor_id=?';
            $params[] = $doctorId;
        }

        $sql .= ' ORDER BY a.appointment_date DESC, a.time_slot ASC';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function getAppointment(PDO $db, int $id): ?array
    {
        $stmt = $db->prepare('SELECT a.*, p.name AS patient_name, p.mobile AS patient_mobile, p.mrn, p.gender, p.dob, p.blood_group,
                       p.category AS patient_category, d.name AS doctor_name, d.specialty, d.registration_no AS bmdc_no,
                       rm.name AS room_name, ref.name AS referrer_name, b.name AS branch_name
            FROM appointments a 
            JOIN patients p ON p.id=a.patient_id 
            JOIN doctors d ON d.id=a.doctor_id 
            LEFT JOIN rooms rm ON rm.id=a.room_id 
            LEFT JOIN referrers ref ON ref.id=a.referrer_id
            LEFT JOIN branches b ON b.id=a.branch_id
            WHERE a.id=?');
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    public static function book(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'appointments.manage');
        $branchId = (int) ($data['branch_id'] ?? 0);
        if (!$branchId) $branchId = Security::branchIds($db)[0] ?? 1;

        $patientId = (int) ($data['patient_id'] ?? 0);
        $patientName = trim((string) ($data['patient_name'] ?? ''));
        $patientMobile = trim((string) ($data['patient_mobile'] ?? ''));
        $category = trim((string) ($data['patient_category'] ?? 'doctor_prescribed'));
        $gender = trim((string) ($data['gender'] ?? 'male'));

        $doctorId = (int) ($data['doctor_id'] ?? 0);
        $date = (string) ($data['appointment_date'] ?? date('Y-m-d'));
        $timeSlot = (string) ($data['time_slot'] ?? '09:00 AM');
        $source = (string) ($data['booking_source'] ?? 'walkin');
        $roomId = !empty($data['room_id']) ? (int) $data['room_id'] : null;
        $notes = !empty($data['clinical_notes']) ? trim((string) $data['clinical_notes']) : null;

        // Fees & Billing fields
        $fee = max(0.00, (float) ($data['consultation_fee'] ?? 1000.00));
        $discount = max(0.00, (float) ($data['discount_amount'] ?? 0.00));
        $payable = max(0.00, $fee - $discount);
        $paid = isset($data['paid_amount']) ? max(0.00, (float)$data['paid_amount']) : $payable;
        $paymentMethod = trim((string) ($data['payment_method'] ?? 'CASH'));
        $paymentStatus = ($paid >= $payable) ? 'paid' : ($paid > 0 ? 'partial' : 'unpaid');
        $referrerId = !empty($data['referrer_id']) ? (int)$data['referrer_id'] : null;
        $voucherCode = !empty($data['voucher_code']) ? trim((string)$data['voucher_code']) : null;

        if (!$doctorId) {
            throw new RuntimeException('Consultant Doctor selection is required.');
        }
        Security::requireBranch($db, $branchId);

        $db->beginTransaction();
        try {
            // Patient registration / resolution
            if (!$patientId) {
                if ($patientName === '' || $patientMobile === '') {
                    throw new RuntimeException('Patient Name and Mobile Number are required for chamber appointment registration.');
                }
                $chk = $db->prepare('SELECT id FROM patients WHERE mobile=? LIMIT 1');
                $chk->execute([$patientMobile]);
                $exId = $chk->fetchColumn();
                if ($exId) {
                    $patientId = (int)$exId;
                    $db->prepare('UPDATE patients SET category="doctor_prescribed", updated_at=NOW() WHERE id=?')->execute([$patientId]);
                } else {
                    $mrn = Numbering::next($db, 'doctor_prescribed', $branchId);
                    $ins = $db->prepare('INSERT INTO patients (mrn, branch_id, category, name, gender, mobile, created_at, updated_at) VALUES (?, ?, "doctor_prescribed", ?, ?, ?, NOW(), NOW())');
                    $ins->execute([$mrn, $branchId, $patientName, $gender, $patientMobile]);
                    $patientId = (int)$db->lastInsertId();
                }
            } else {
                // Patient took a doctor chamber appointment, ensure category is doctor_prescribed
                $db->prepare('UPDATE patients SET category="doctor_prescribed", updated_at=NOW() WHERE id=?')->execute([$patientId]);
            }

            $appNo = Numbering::next($db, 'order', $branchId);
            $appNo = str_replace(['ORD-', 'SMP-'], 'APT-', $appNo);

            // Queue Token Generation
            $tokenRes = Queue::issueToken($db, [
                'branch_id'    => $branchId,
                'service_area' => 'doctor_chamber',
                'patient_id'   => $patientId,
                'priority'     => 'normal'
            ]);
            $tokenNo = $tokenRes['token_no'] ?? ('DOC-' . rand(101, 999));

            $stmt = $db->prepare('INSERT INTO appointments 
                (appointment_no, branch_id, patient_id, doctor_id, room_id, booking_source, appointment_date, time_slot,
                 consultation_fee, discount_amount, payable_amount, paid_amount, payment_method, payment_status,
                 referrer_id, voucher_code, token_no, clinical_notes, created_by) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
            $stmt->execute([
                $appNo, $branchId, $patientId, $doctorId, $roomId, $source, $date, $timeSlot,
                $fee, $discount, $payable, $paid, $paymentMethod, $paymentStatus,
                $referrerId, $voucherCode, $tokenNo, $notes, $userId
            ]);
            $apptId = (int) $db->lastInsertId();

            audit($db, 'appointments', (string) $apptId, 'book_chamber_consultation', null, [
                'appointment_no' => $appNo, 'token_no' => $tokenNo, 'payable' => $payable, 'paid' => $paid
            ], $branchId);

            $db->commit();
            return $apptId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function updateStatus(PDO $db, int $appointmentId, string $status, int $userId): void
    {
        Security::requirePermission($db, 'appointments.manage');
        $stmt = $db->prepare('SELECT * FROM appointments WHERE id=?');
        $stmt->execute([$appointmentId]);
        $appt = $stmt->fetch();
        if (!$appt) throw new RuntimeException('Appointment not found.');

        Security::requireBranch($db, (int) $appt['branch_id']);
        $allowed = ['scheduled', 'confirmed', 'arrived', 'rescheduled', 'cancelled', 'no_show'];
        if (!in_array($status, $allowed, true)) throw new RuntimeException('Invalid appointment status.');

        $stmt = $db->prepare('UPDATE appointments SET status=? WHERE id=?');
        $stmt->execute([$status, $appointmentId]);

        audit($db, 'appointments', (string) $appointmentId, 'status_change', $appt, ['status' => $status], (int) $appt['branch_id']);
    }
}
