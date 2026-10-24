<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class HomeCollection
{
    public static function book(PDO $db, array $data): int
    {
        $branchId = (int) ($data['branch_id'] ?? 0);
        if (!$branchId) {
            $branchId = Security::branchIds($db)[0] ?? 1;
        }

        $patientId = (int) ($data['patient_id'] ?? 0);
        $patientName = trim((string) ($data['patient_name'] ?? ''));
        $patientMobile = trim((string) ($data['patient_mobile'] ?? ''));
        $category = trim((string) ($data['patient_category'] ?? 'doctor_prescribed'));
        $gender = trim((string) ($data['gender'] ?? 'male'));
        $address = trim((string) ($data['address'] ?? ''));
        $zone = !empty($data['geo_zone']) ? trim((string) $data['geo_zone']) : 'Gulshan / Banani Zone';
        $slot = trim((string) ($data['time_slot'] ?? '08:00 AM - 10:00 AM'));
        $travelCharge = max(0.00, (float) ($data['travel_charge'] ?? 300.00));

        // Test items & calculations
        $testIds = (array) ($data['test_ids'] ?? []);
        $selectedTests = [];
        $testsAmount = 0.00;

        if (!empty($testIds)) {
            $inQ = implode(',', array_fill(0, count($testIds), '?'));
            $testStmt = $db->prepare("SELECT id, name, code, price FROM diagnostic_tests WHERE id IN ($inQ)");
            $testStmt->execute(array_map('intval', $testIds));
            $foundTests = $testStmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($foundTests as $ft) {
                $p = (float)($ft['price'] ?? 500.00);
                $testsAmount += $p;
                $selectedTests[] = [
                    'id'    => (int)$ft['id'],
                    'code'  => $ft['code'],
                    'name'  => $ft['name'],
                    'price' => $p
                ];
            }
        }

        $discount = max(0.00, (float) ($data['discount_amount'] ?? 0.00));
        $discountApprovedBy = trim((string) ($data['discount_approved_by'] ?? ''));
        $totalPayable = max(0.00, ($testsAmount + $travelCharge) - $discount);
        $paidAmount = isset($data['paid_amount']) ? (float)$data['paid_amount'] : $totalPayable;
        $paymentMethod = trim((string) ($data['payment_method'] ?? 'CASH'));
        $paymentStatus = ($paidAmount >= $totalPayable) ? 'paid' : ($paidAmount > 0 ? 'partial' : 'unpaid');

        if ($address === '') {
            throw new RuntimeException('Collection address is required.');
        }

        $db->beginTransaction();
        try {
            // If patientId is not provided or 0, or new patient details provided:
            if (!$patientId) {
                if ($patientName === '' || $patientMobile === '') {
                    throw new RuntimeException('Patient Name and Phone Number are required to register and book home collection.');
                }

                // Check existing patient with same mobile
                $chk = $db->prepare('SELECT id FROM patients WHERE mobile=? LIMIT 1');
                $chk->execute([$patientMobile]);
                $existingId = $chk->fetchColumn();

                if ($existingId) {
                    $patientId = (int)$existingId;
                    // Update category and address if needed
                    $db->prepare('UPDATE patients SET category=?, address=?, updated_at=NOW() WHERE id=?')
                       ->execute([$category, $address, $patientId]);
                } else {
                    $mrn = Numbering::next($db, $category, $branchId);
                    $ins = $db->prepare('INSERT INTO patients (mrn, branch_id, category, name, gender, mobile, address, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())');
                    $ins->execute([$mrn, $branchId, $category, $patientName, $gender, $patientMobile, $address]);
                    $patientId = (int)$db->lastInsertId();
                }
            } else {
                // Update patient address / category
                $db->prepare('UPDATE patients SET category=?, address=COALESCE(NULLIF(?, ""), address), updated_at=NOW() WHERE id=?')
                   ->execute([$category, $address, $patientId]);
            }

            $bookingNo = Numbering::next($db, 'barcode', $branchId);
            $bookingNo = str_replace(['SMP-', 'ORD-'], 'HC-', $bookingNo);

            $stmt = $db->prepare('INSERT INTO home_collections 
                (booking_no, patient_id, branch_id, patient_category, geo_zone, address, time_slot, travel_charge, tests_json, tests_amount, discount_amount, discount_approved_by, total_payable, paid_amount, payment_method, payment_status, status) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "pending")');
            $stmt->execute([
                $bookingNo, $patientId, $branchId, $category, $zone, $address, $slot, $travelCharge,
                json_encode($selectedTests, JSON_UNESCAPED_UNICODE),
                $testsAmount, $discount, $discountApprovedBy ?: null, $totalPayable, $paidAmount, $paymentMethod, $paymentStatus
            ]);
            $bookingId = (int) $db->lastInsertId();

            audit($db, 'home_collections', (string) $bookingId, 'book_home_collection', null, [
                'booking_no' => $bookingNo, 'patient_id' => $patientId, 'total_payable' => $totalPayable
            ], $branchId);

            $db->commit();
            return $bookingId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function getBooking(PDO $db, int $id): ?array
    {
        $stmt = $db->prepare('SELECT hc.*, p.name AS patient_name, p.mobile, p.mrn, p.gender, u.name AS collector_name, b.name AS branch_name
            FROM home_collections hc 
            JOIN patients p ON p.id=hc.patient_id 
            LEFT JOIN users u ON u.id=hc.collector_id 
            LEFT JOIN branches b ON b.id=hc.branch_id
            WHERE hc.id=?');
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row && !empty($row['tests_json'])) {
            $row['tests_array'] = json_decode($row['tests_json'], true) ?: [];
        } else {
            $row['tests_array'] = [];
        }
        return $row ?: null;
    }

    public static function assignCollector(PDO $db, int $bookingId, int $collectorId): void
    {
        $stmt = $db->prepare('UPDATE home_collections SET collector_id=?, status="assigned" WHERE id=?');
        $stmt->execute([$collectorId, $bookingId]);
    }

    public static function updateStatus(PDO $db, int $bookingId, string $status): void
    {
        $allowed = ['pending', 'assigned', 'collected', 'handed_over'];
        if (!in_array($status, $allowed, true)) throw new RuntimeException('Invalid status.');

        $stmt = $db->prepare('UPDATE home_collections SET status=? WHERE id=?');
        $stmt->execute([$status, $bookingId]);
    }

    public static function listBookings(PDO $db, int $branchId): array
    {
        Security::requireBranch($db, $branchId);
        $stmt = $db->prepare('SELECT hc.*, p.name AS patient_name, p.mobile, p.mrn, u.name AS collector_name 
            FROM home_collections hc 
            JOIN patients p ON p.id=hc.patient_id 
            LEFT JOIN users u ON u.id=hc.collector_id 
            WHERE hc.branch_id=? ORDER BY hc.id DESC LIMIT 100');
        $stmt->execute([$branchId]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($rows as &$r) {
            $r['tests_array'] = !empty($r['tests_json']) ? (json_decode($r['tests_json'], true) ?: []) : [];
        }
        return $rows;
    }
}
