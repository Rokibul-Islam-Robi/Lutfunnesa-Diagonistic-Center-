<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class HR
{
    public static function createEmployee(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $code = trim((string) ($data['employee_code'] ?? ''));
        $name = trim((string) ($data['name'] ?? ''));
        $designation = trim((string) ($data['designation'] ?? 'Lab Technologist'));
        $departmentId = !empty($data['department_id']) ? (int) $data['department_id'] : null;
        $userId = !empty($data['user_id']) ? (int) $data['user_id'] : null;
        $mobile = trim((string) ($data['mobile'] ?? ''));
        $email = !empty($data['email']) ? trim((string) $data['email']) : null;
        $licenseNo = !empty($data['license_no']) ? trim((string) $data['license_no']) : null;
        $licenseExpiry = !empty($data['license_expiry']) ? trim((string) $data['license_expiry']) : null;
        $salary = (float) ($data['basic_salary'] ?? 35000.00);
        $joiningDate = trim((string) ($data['joining_date'] ?? date('Y-m-d')));

        if ($code === '' || $name === '' || $mobile === '') {
            throw new RuntimeException('Employee Code, Name and Mobile are required.');
        }

        $stmt = $db->prepare('INSERT INTO hr_employees (employee_code, name, designation, department_id, user_id, mobile, email, license_no, license_expiry, basic_salary, joining_date, status, created_at) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "active", NOW())');
        $stmt->execute([$code, $name, $designation, $departmentId, $userId, $mobile, $email, $licenseNo, $licenseExpiry, $salary, $joiningDate]);
        return (int) $db->lastInsertId();
    }

    public static function listEmployees(PDO $db): array
    {
        $stmt = $db->query('SELECT e.*, d.name AS department_name, u.name AS user_name 
            FROM hr_employees e 
            LEFT JOIN departments d ON d.id=e.department_id 
            LEFT JOIN users u ON u.id=e.user_id 
            ORDER BY e.id DESC');
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    public static function getEmployee(PDO $db, int $id): ?array
    {
        $stmt = $db->prepare('SELECT e.*, d.name AS department_name, u.name AS user_name 
            FROM hr_employees e 
            LEFT JOIN departments d ON d.id=e.department_id 
            LEFT JOIN users u ON u.id=e.user_id 
            WHERE e.id=?');
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    // ==========================================
    // 24/7 Duty Rostering
    // ==========================================
    public static function assignRoster(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $employeeId = (int) ($data['employee_id'] ?? 0);
        $branchId = (int) ($data['branch_id'] ?? Security::branchIds($db)[0]);
        $shiftDate = trim((string) ($data['shift_date'] ?? date('Y-m-d')));
        $shiftName = (string) ($data['shift_name'] ?? 'morning');

        if (!$employeeId) throw new RuntimeException('Employee is required.');

        $times = [
            'morning' => ['08:00:00', '16:00:00'],
            'evening' => ['16:00:00', '00:00:00'],
            'night'   => ['00:00:00', '08:00:00'],
        ];
        $start = $times[$shiftName][0] ?? '08:00:00';
        $end = $times[$shiftName][1] ?? '16:00:00';

        $stmt = $db->prepare('INSERT INTO employee_rosters (employee_id, branch_id, shift_date, shift_name, start_time, end_time, created_at) 
            VALUES (?, ?, ?, ?, ?, ?, NOW())');
        $stmt->execute([$employeeId, $branchId, $shiftDate, $shiftName, $start, $end]);
        return (int) $db->lastInsertId();
    }

    public static function listRosters(PDO $db, int $branchId, ?string $date = null): array
    {
        $sql = 'SELECT er.*, e.name AS employee_name, e.employee_code, e.designation, d.name AS department_name 
            FROM employee_rosters er 
            JOIN hr_employees e ON e.id=er.employee_id 
            LEFT JOIN departments d ON d.id=e.department_id 
            WHERE er.branch_id=?';
        $params = [$branchId];
        if ($date !== null && $date !== '') {
            $sql .= ' AND er.shift_date=?';
            $params[] = $date;
        }
        $sql .= ' ORDER BY er.shift_date DESC, er.id DESC LIMIT 100';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    // ==========================================
    // Daily Attendance & Biometric Logs
    // ==========================================
    public static function logAttendance(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $employeeId = (int) ($data['employee_id'] ?? 0);
        $date = trim((string) ($data['attendance_date'] ?? date('Y-m-d')));
        $clockIn = trim((string) ($data['clock_in'] ?? '08:00:00'));
        $clockOut = !empty($data['clock_out']) ? trim((string) $data['clock_out']) : null;
        $status = (string) ($data['status'] ?? 'present');
        $ot = (float) ($data['overtime_hours'] ?? 0.00);
        $notes = !empty($data['notes']) ? trim((string) $data['notes']) : null;
        $branchId = (int) ($data['branch_id'] ?? Security::branchIds($db)[0]);

        if (!$employeeId) throw new RuntimeException('Employee is required.');

        // Update if existing on same day, otherwise insert
        $existing = $db->prepare('SELECT id FROM hr_attendance WHERE employee_id=? AND attendance_date=?');
        $existing->execute([$employeeId, $date]);
        $row = $existing->fetch(PDO::FETCH_ASSOC);

        if ($row) {
            $upd = $db->prepare('UPDATE hr_attendance SET clock_in=?, clock_out=?, overtime_hours=?, status=?, notes=? WHERE id=?');
            $upd->execute([$clockIn, $clockOut, $ot, $status, $notes, $row['id']]);
            return (int) $row['id'];
        } else {
            $ins = $db->prepare('INSERT INTO hr_attendance (employee_id, branch_id, attendance_date, clock_in, clock_out, overtime_hours, status, notes, created_at) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())');
            $ins->execute([$employeeId, $branchId, $date, $clockIn, $clockOut, $ot, $status, $notes]);
            return (int) $db->lastInsertId();
        }
    }

    public static function listAttendance(PDO $db, string $date, ?int $deptId = null): array
    {
        $sql = 'SELECT a.*, e.name AS employee_name, e.employee_code, e.designation, d.name AS department_name 
            FROM hr_attendance a 
            JOIN hr_employees e ON e.id=a.employee_id 
            LEFT JOIN departments d ON d.id=e.department_id 
            WHERE a.attendance_date=?';
        $params = [$date];
        if ($deptId !== null && $deptId > 0) {
            $sql .= ' AND e.department_id=?';
            $params[] = $deptId;
        }
        $sql .= ' ORDER BY a.clock_in ASC, e.name ASC';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    public static function getAttendanceStats(PDO $db, string $date): array
    {
        $totalActive = (int) $db->query('SELECT COUNT(1) FROM hr_employees WHERE status="active"')->fetchColumn();
        $stmt = $db->prepare('SELECT status, COUNT(1) AS cnt, SUM(overtime_hours) AS total_ot FROM hr_attendance WHERE attendance_date=? GROUP BY status');
        $stmt->execute([$date]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];

        $present = 0; $late = 0; $halfDay = 0; $onLeave = 0; $otHours = 0.0;
        foreach ($rows as $r) {
            if ($r['status'] === 'present') $present += (int) $r['cnt'];
            if ($r['status'] === 'late') $late += (int) $r['cnt'];
            if ($r['status'] === 'half_day') $halfDay += (int) $r['cnt'];
            if ($r['status'] === 'on_leave') $onLeave += (int) $r['cnt'];
            $otHours += (float) ($r['total_ot'] ?? 0);
        }
        $totalAttended = $present + $late + $halfDay;
        $absent = max(0, $totalActive - ($totalAttended + $onLeave));

        return [
            'total_active' => $totalActive,
            'present' => $present,
            'late' => $late,
            'half_day' => $halfDay,
            'on_leave' => $onLeave,
            'absent' => $absent,
            'total_attended' => $totalAttended,
            'overtime_hours' => $otHours,
        ];
    }

    // ==========================================
    // Leave Management & Approvals
    // ==========================================
    public static function applyLeave(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $empId = (int) ($data['employee_id'] ?? 0);
        $type = (string) ($data['leave_type'] ?? 'casual');
        $start = trim((string) ($data['start_date'] ?? date('Y-m-d')));
        $end = trim((string) ($data['end_date'] ?? date('Y-m-d')));
        $days = max(1, (int) round((strtotime($end) - strtotime($start)) / 86400) + 1);
        $reason = trim((string) ($data['reason'] ?? 'Medical / Personal Leave'));

        if (!$empId) throw new RuntimeException('Employee is required.');

        $stmt = $db->prepare('INSERT INTO leave_requests (employee_id, leave_type, start_date, end_date, total_days, reason, status, created_at) 
            VALUES (?, ?, ?, ?, ?, ?, "pending", NOW())');
        $stmt->execute([$empId, $type, $start, $end, $days, $reason]);
        return (int) $db->lastInsertId();
    }

    public static function listLeaves(PDO $db, ?string $status = null): array
    {
        $sql = 'SELECT lr.*, e.name AS employee_name, e.employee_code, e.designation, d.name AS department_name 
            FROM leave_requests lr 
            JOIN hr_employees e ON e.id=lr.employee_id 
            LEFT JOIN departments d ON d.id=e.department_id';
        $params = [];
        if ($status !== null && $status !== '' && $status !== 'all') {
            $sql .= ' WHERE lr.status=?';
            $params[] = $status;
        }
        $sql .= ' ORDER BY lr.id DESC LIMIT 100';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    public static function updateLeaveStatus(PDO $db, int $leaveId, string $status, int $userId): void
    {
        Security::requirePermission($db, 'dashboard.view');
        if (!in_array($status, ['approved', 'rejected', 'pending'], true)) {
            throw new RuntimeException('Invalid leave status.');
        }
        $stmt = $db->prepare('UPDATE leave_requests SET status=? WHERE id=?');
        $stmt->execute([$status, $leaveId]);
        audit($db, 'leave_requests', (string) $leaveId, 'update_leave_status', null, ['status' => $status], $userId);
    }

    // ==========================================
    // Payroll & Payslips
    // ==========================================
    public static function runPayroll(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $period = trim((string) ($data['payroll_period'] ?? date('F Y')));
        $employeeId = (int) ($data['employee_id'] ?? 0);
        $basic = (float) ($data['basic_salary'] ?? 35000.00);
        $house = round($basic * 0.40, 2);
        $med = 3000.00;
        $allowances = !empty($data['allowances']) ? (float) $data['allowances'] : ($house + $med);
        $pf = round($basic * 0.08, 2);
        $tax = ($basic > 50000) ? 2500.00 : (($basic > 35000) ? 1000.00 : 0.00);
        $deductions = !empty($data['deductions']) ? (float) $data['deductions'] : ($pf + $tax);
        $method = trim((string) ($data['payment_method'] ?? 'Bank Transfer'));
        $txRef = 'SLP-' . date('Ym') . '-' . str_pad((string) mt_rand(100, 9999), 4, '0', STR_PAD_LEFT);

        if (!$employeeId) throw new RuntimeException('Employee is required.');
        $net = round($basic + $allowances - $deductions, 2);

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('INSERT INTO payrolls (payroll_period, employee_id, basic_salary, house_rent, medical_allowance, allowances, provident_fund, tax_deduction, deductions, net_salary, payment_method, transaction_ref, status, paid_at, created_at) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "paid", NOW(), NOW())');
            $stmt->execute([$period, $employeeId, $basic, $house, $med, $allowances, $pf, $tax, $deductions, $net, $method, $txRef]);
            $payrollId = (int) $db->lastInsertId();

            audit($db, 'payrolls', (string) $payrollId, 'run_payroll', null, [
                'period' => $period, 'net_salary' => $net
            ], $userId);

            $db->commit();
            return $payrollId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function runPayrollBatch(PDO $db, string $period, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $employees = $db->query('SELECT id, basic_salary FROM hr_employees WHERE status="active"')->fetchAll(PDO::FETCH_ASSOC);
        $count = 0;

        $db->beginTransaction();
        try {
            $stmt = $db->prepare('INSERT INTO payrolls (payroll_period, employee_id, basic_salary, house_rent, medical_allowance, allowances, provident_fund, tax_deduction, deductions, net_salary, payment_method, transaction_ref, status, paid_at, created_at) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "Bank Transfer", ?, "paid", NOW(), NOW())');

            foreach ($employees as $e) {
                // Check if already run for this period
                $chk = $db->prepare('SELECT id FROM payrolls WHERE employee_id=? AND payroll_period=?');
                $chk->execute([$e['id'], $period]);
                if ($chk->fetch()) continue;

                $basic = (float) $e['basic_salary'];
                $house = round($basic * 0.40, 2);
                $med = 3000.00;
                $allowances = $house + $med + 1500.00;
                $pf = round($basic * 0.08, 2);
                $tax = ($basic > 50000) ? 2500.00 : (($basic > 35000) ? 1000.00 : 0.00);
                $deductions = $pf + $tax;
                $net = round($basic + $allowances - $deductions, 2);
                $txRef = 'SLP-' . date('Ym') . '-' . str_pad((string)($e['id'] + 100), 4, '0', STR_PAD_LEFT);

                $stmt->execute([$period, $e['id'], $basic, $house, $med, $allowances, $pf, $tax, $deductions, $net, $txRef]);
                $count++;
            }
            $db->commit();
            return $count;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function listPayrolls(PDO $db, ?string $period = null): array
    {
        $sql = 'SELECT p.*, e.name AS employee_name, e.employee_code, e.designation, d.name AS department_name 
            FROM payrolls p 
            JOIN hr_employees e ON e.id=p.employee_id 
            LEFT JOIN departments d ON d.id=e.department_id';
        $params = [];
        if ($period !== null && $period !== '' && $period !== 'all') {
            $sql .= ' WHERE p.payroll_period=?';
            $params[] = $period;
        }
        $sql .= ' ORDER BY p.id DESC LIMIT 100';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    public static function getPayroll(PDO $db, int $id): ?array
    {
        $stmt = $db->prepare('SELECT p.*, e.name AS employee_name, e.employee_code, e.designation, e.mobile AS employee_mobile, e.email AS employee_email, e.license_no, e.joining_date, d.name AS department_name 
            FROM payrolls p 
            JOIN hr_employees e ON e.id=p.employee_id 
            LEFT JOIN departments d ON d.id=e.department_id 
            WHERE p.id=?');
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    // ==========================================
    // Staff Competency Matrix
    // ==========================================
    public static function listCompetencies(PDO $db): array
    {
        $stmt = $db->query('SELECT ec.*, e.name AS employee_name, e.employee_code, e.designation, d.name AS department_name 
            FROM employee_competencies ec 
            JOIN hr_employees e ON e.id=ec.employee_id 
            LEFT JOIN departments d ON d.id=e.department_id 
            ORDER BY ec.id DESC');
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    public static function addCompetency(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $empId = (int) ($data['employee_id'] ?? 0);
        $title = trim((string) ($data['competency_title'] ?? ''));
        $cat = (string) ($data['category'] ?? 'lab');
        $score = (float) ($data['assessment_score'] ?? 100.00);
        $expiry = trim((string) ($data['expiry_date'] ?? date('Y-12-31', strtotime('+1 year'))));

        if (!$empId || $title === '') throw new RuntimeException('Employee and Competency Title are required.');

        $stmt = $db->prepare('INSERT INTO employee_competencies (employee_id, competency_title, category, assessment_score, expiry_date, created_at) 
            VALUES (?, ?, ?, ?, ?, NOW())');
        $stmt->execute([$empId, $title, $cat, $score, $expiry]);
        return (int) $db->lastInsertId();
    }

    // ==========================================
    // Recruitment & Candidate Pipeline
    // ==========================================
    public static function listRecruitments(PDO $db): array
    {
        $stmt = $db->query('SELECT r.*, d.name AS department_name, 
            (SELECT COUNT(1) FROM hr_candidates c WHERE c.recruitment_id=r.id) AS total_candidates,
            (SELECT COUNT(1) FROM hr_candidates c WHERE c.recruitment_id=r.id AND c.status="shortlisted") AS shortlisted_count,
            (SELECT COUNT(1) FROM hr_candidates c WHERE c.recruitment_id=r.id AND c.status="hired") AS hired_count
            FROM hr_recruitment r 
            LEFT JOIN departments d ON d.id=r.department_id 
            ORDER BY r.id DESC');
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    public static function createRecruitment(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $title = trim((string) ($data['job_title'] ?? ''));
        $deptId = !empty($data['department_id']) ? (int) $data['department_id'] : null;
        $vacancies = max(1, (int) ($data['vacancy_count'] ?? 1));
        $exp = trim((string) ($data['experience_required'] ?? '2+ Years'));
        $type = (string) ($data['job_type'] ?? 'full_time');
        $range = trim((string) ($data['salary_range'] ?? 'Negotiable'));
        $deadline = !empty($data['deadline']) ? trim((string) $data['deadline']) : date('Y-m-d', strtotime('+30 days'));

        if ($title === '') throw new RuntimeException('Job Title is required.');

        $stmt = $db->prepare('INSERT INTO hr_recruitment (job_title, department_id, vacancy_count, experience_required, job_type, status, salary_range, deadline, created_at) 
            VALUES (?, ?, ?, ?, ?, "open", ?, ?, NOW())');
        $stmt->execute([$title, $deptId, $vacancies, $exp, $type, $range, $deadline]);
        return (int) $db->lastInsertId();
    }

    public static function listCandidates(PDO $db, ?int $recruitmentId = null): array
    {
        $sql = 'SELECT c.*, r.job_title, d.name AS department_name 
            FROM hr_candidates c 
            JOIN hr_recruitment r ON r.id=c.recruitment_id 
            LEFT JOIN departments d ON d.id=r.department_id';
        $params = [];
        if ($recruitmentId !== null && $recruitmentId > 0) {
            $sql .= ' WHERE c.recruitment_id=?';
            $params[] = $recruitmentId;
        }
        $sql .= ' ORDER BY c.id DESC LIMIT 100';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    public static function addCandidate(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $recId = (int) ($data['recruitment_id'] ?? 0);
        $name = trim((string) ($data['name'] ?? ''));
        $mobile = trim((string) ($data['mobile'] ?? ''));
        $email = !empty($data['email']) ? trim((string) $data['email']) : null;
        $exp = (int) ($data['experience_years'] ?? 2);
        $salary = !empty($data['expected_salary']) ? (float) $data['expected_salary'] : null;
        $interview = !empty($data['interview_date']) ? trim((string) $data['interview_date']) : null;
        $notes = !empty($data['notes']) ? trim((string) $data['notes']) : null;

        if (!$recId || $name === '' || $mobile === '') {
            throw new RuntimeException('Position, Candidate Name and Mobile are required.');
        }

        $stmt = $db->prepare('INSERT INTO hr_candidates (recruitment_id, name, mobile, email, experience_years, expected_salary, interview_date, status, notes, created_at) 
            VALUES (?, ?, ?, ?, ?, ?, ?, "applied", ?, NOW())');
        $stmt->execute([$recId, $name, $mobile, $email, $exp, $salary, $interview, $notes]);
        return (int) $db->lastInsertId();
    }

    public static function updateCandidateStatus(PDO $db, int $candidateId, string $status): void
    {
        Security::requirePermission($db, 'dashboard.view');
        if (!in_array($status, ['applied', 'shortlisted', 'interviewed', 'offered', 'rejected', 'hired'], true)) {
            throw new RuntimeException('Invalid candidate status.');
        }
        $stmt = $db->prepare('UPDATE hr_candidates SET status=? WHERE id=?');
        $stmt->execute([$status, $candidateId]);
    }
}
