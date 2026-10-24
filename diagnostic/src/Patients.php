<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Patients
{
    public static function search(PDO $db, string $query, int $branchId, int $limit = 50): array
    {
        Security::requireBranch($db, $branchId);
        $term = trim($query);
        if ($term === '') {
            $stmt = $db->prepare('SELECT p.*, c.name AS corporate_name FROM patients p LEFT JOIN corporate_clients c ON c.id=p.corporate_client_id WHERE p.branch_id=? AND p.active=1 ORDER BY p.id DESC LIMIT ?');
            $stmt->bindValue(1, $branchId, PDO::PARAM_INT);
            $stmt->bindValue(2, $limit, PDO::PARAM_INT);
            $stmt->execute();
            return $stmt->fetchAll();
        }

        $like = '%' . $term . '%';
        $stmt = $db->prepare('SELECT p.*, c.name AS corporate_name FROM patients p 
            LEFT JOIN corporate_clients c ON c.id=p.corporate_client_id 
            WHERE p.branch_id=? AND p.active=1 AND (
                p.mrn LIKE ? OR p.mobile LIKE ? OR p.name LIKE ? OR p.nid_passport LIKE ? OR p.alternate_mobile LIKE ?
            ) ORDER BY p.id DESC LIMIT ?');
        $stmt->bindValue(1, $branchId, PDO::PARAM_INT);
        $stmt->bindValue(2, $like);
        $stmt->bindValue(3, $like);
        $stmt->bindValue(4, $like);
        $stmt->bindValue(5, $like);
        $stmt->bindValue(6, $like);
        $stmt->bindValue(7, $limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public static function get(PDO $db, int $id): ?array
    {
        $stmt = $db->prepare('SELECT p.*, c.name AS corporate_name, b.name AS branch_name 
            FROM patients p 
            JOIN branches b ON b.id=p.branch_id 
            LEFT JOIN corporate_clients c ON c.id=p.corporate_client_id 
            WHERE p.id=?');
        $stmt->execute([$id]);
        $patient = $stmt->fetch() ?: null;
        if ($patient) {
            Security::requireBranch($db, (int) $patient['branch_id']);
        }
        return $patient;
    }

    public static function create(PDO $db, array $data, int $branchId, int $userId): int
    {
        Security::requireBranch($db, $branchId);
        Security::requirePermission($db, 'patients.edit');

        $name = trim((string) ($data['name'] ?? ''));
        $mobile = trim((string) ($data['mobile'] ?? ''));
        $gender = (string) ($data['gender'] ?? 'male');
        if ($name === '' || $mobile === '') {
            throw new RuntimeException('Patient name and mobile number are required.');
        }

        $dob = !empty($data['dob']) ? (string) $data['dob'] : null;
        $bloodGroup = (string) ($data['blood_group'] ?? 'unknown');
        $altMobile = !empty($data['alternate_mobile']) ? trim((string) $data['alternate_mobile']) : null;
        $email = !empty($data['email']) ? mb_strtolower(trim((string) $data['email'])) : null;
        $address = !empty($data['address']) ? trim((string) $data['address']) : null;
        $emergName = !empty($data['emergency_contact_name']) ? trim((string) $data['emergency_contact_name']) : null;
        $emergPhone = !empty($data['emergency_contact_phone']) ? trim((string) $data['emergency_contact_phone']) : null;
        $occupation = !empty($data['occupation']) ? trim((string) $data['occupation']) : null;
        $nidPassport = !empty($data['nid_passport']) ? trim((string) $data['nid_passport']) : null;
        $corporateId = !empty($data['corporate_client_id']) ? (int) $data['corporate_client_id'] : null;

        $allowedCats = ['doctor_prescribed', 'clinical_patient', 'local_customer', 'online_customer'];
        $category = in_array((string)($data['category'] ?? ''), $allowedCats, true)
            ? (string)$data['category']
            : 'doctor_prescribed';

        $db->beginTransaction();
        try {
            $mrn = !empty($data['mrn']) ? trim((string)$data['mrn']) : Numbering::next($db, $category, $branchId);
            $stmt = $db->prepare('INSERT INTO patients (mrn, branch_id, category, name, gender, dob, blood_group, mobile, alternate_mobile, email, address, emergency_contact_name, emergency_contact_phone, occupation, nid_passport, corporate_client_id) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
            $stmt->execute([
                $mrn, $branchId, $category, $name, $gender, $dob, $bloodGroup, $mobile, $altMobile,
                $email, $address, $emergName, $emergPhone, $occupation, $nidPassport, $corporateId
            ]);
            $patientId = (int) $db->lastInsertId();

            audit($db, 'patients', (string) $patientId, 'create', null, [
                'mrn' => $mrn,
                'category' => $category,
                'name' => $name,
                'mobile' => $mobile,
                'branch_id' => $branchId
            ], $branchId);

            $db->commit();
            return $patientId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function update(PDO $db, int $id, array $data, int $userId): void
    {
        $existing = self::get($db, $id);
        if (!$existing) {
            throw new RuntimeException('Patient record not found.');
        }
        Security::requirePermission($db, 'patients.edit');
        Security::requireBranch($db, (int) $existing['branch_id']);

        $name = trim((string) ($data['name'] ?? $existing['name']));
        $mobile = trim((string) ($data['mobile'] ?? $existing['mobile']));
        if ($name === '' || $mobile === '') {
            throw new RuntimeException('Patient name and mobile number are required.');
        }

        $gender = (string) ($data['gender'] ?? $existing['gender']);
        $dob = !empty($data['dob']) ? (string) $data['dob'] : null;
        $bloodGroup = (string) ($data['blood_group'] ?? $existing['blood_group']);
        $altMobile = !empty($data['alternate_mobile']) ? trim((string) $data['alternate_mobile']) : null;
        $email = !empty($data['email']) ? mb_strtolower(trim((string) $data['email'])) : null;
        $address = !empty($data['address']) ? trim((string) $data['address']) : null;
        $emergName = !empty($data['emergency_contact_name']) ? trim((string) $data['emergency_contact_name']) : null;
        $emergPhone = !empty($data['emergency_contact_phone']) ? trim((string) $data['emergency_contact_phone']) : null;
        $occupation = !empty($data['occupation']) ? trim((string) $data['occupation']) : null;
        $nidPassport = !empty($data['nid_passport']) ? trim((string) $data['nid_passport']) : null;
        $corporateId = !empty($data['corporate_client_id']) ? (int) $data['corporate_client_id'] : null;

        // Category field (doctor_prescribed | clinical_patient | local_customer | online_customer)
        $allowedCats = ['doctor_prescribed', 'clinical_patient', 'local_customer', 'online_customer'];
        $category = in_array((string)($data['category'] ?? ''), $allowedCats, true)
            ? (string)$data['category']
            : (string)($existing['category'] ?? 'doctor_prescribed');

        $mrn = !empty($data['mrn']) ? trim((string)$data['mrn']) : (string)$existing['mrn'];

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('UPDATE patients SET name=?, gender=?, dob=?, blood_group=?, mobile=?, alternate_mobile=?, email=?, address=?, emergency_contact_name=?, emergency_contact_phone=?, occupation=?, nid_passport=?, corporate_client_id=?, category=?, mrn=? WHERE id=?');
            $stmt->execute([
                $name, $gender, $dob, $bloodGroup, $mobile, $altMobile, $email, $address,
                $emergName, $emergPhone, $occupation, $nidPassport, $corporateId, $category, $mrn, $id
            ]);

            audit($db, 'patients', (string) $id, 'update', $existing, [
                'name' => $name, 'mobile' => $mobile, 'gender' => $gender
            ], (int) $existing['branch_id']);

            $db->commit();
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function getHistory(PDO $db, int $patientId): array
    {
        $patient = self::get($db, $patientId);
        if (!$patient) {
            throw new RuntimeException('Patient not found.');
        }

        // Orders
        $stmt = $db->prepare('SELECT o.*, d.name AS doctor_name, r.name AS referrer_name 
            FROM diagnostic_orders o 
            LEFT JOIN doctors d ON d.id=o.doctor_id 
            LEFT JOIN referrers r ON r.id=o.referrer_id 
            WHERE o.patient_id=? ORDER BY o.id DESC');
        $stmt->execute([$patientId]);
        $orders = $stmt->fetchAll();

        // Appointments
        $stmt = $db->prepare('SELECT a.*, d.name AS doctor_name, rm.name AS room_name 
            FROM appointments a 
            LEFT JOIN doctors d ON d.id=a.doctor_id 
            LEFT JOIN rooms rm ON rm.id=a.room_id 
            WHERE a.patient_id=? ORDER BY a.id DESC');
        $stmt->execute([$patientId]);
        $appointments = $stmt->fetchAll();

        // Tokens
        $stmt = $db->prepare('SELECT q.*, c.name AS counter_name 
            FROM queue_tokens q 
            LEFT JOIN counters c ON c.id=q.counter_id 
            WHERE q.patient_id=? ORDER BY q.id DESC LIMIT 20');
        $stmt->execute([$patientId]);
        $tokens = $stmt->fetchAll();

        return [
            'patient' => $patient,
            'orders' => $orders,
            'appointments' => $appointments,
            'tokens' => $tokens
        ];
    }
}
