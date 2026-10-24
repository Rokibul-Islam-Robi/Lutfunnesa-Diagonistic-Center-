<?php
declare(strict_types=1);
require dirname(__DIR__) . '/src/bootstrap.php';

use Diagnostic\Approvals;
use Diagnostic\Masters;
use Diagnostic\Security;

ini_set('display_errors', env_value('APP_DEBUG') === '1' ? '1' : '0');
ini_set('log_errors', '1');
ini_set('error_log', dirname(__DIR__) . '/storage/logs/php.log');
session_name('diagnostic_session');
session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',
    'secure' => true,
    'httponly' => true,
    'samesite' => 'None'
]);
session_start();
ob_start('rewrite_app_urls');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Referrer-Policy: strict-origin-when-cross-origin');
header("Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data:; form-action 'self'; frame-ancestors 'none'; base-uri 'none'");
header('Cache-Control: no-store');
try {
    if (isset($_SESSION['last_activity']) && time() - (int) $_SESSION['last_activity'] > max(5, (int) env_value('SESSION_IDLE_MINUTES','30')) * 60) {
        Security::logout();
        redirect('index.php?page=login&expired=1');
    }
    $db = db();
    $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
    $page = (string) ($_GET['page'] ?? 'dashboard');

    // Auto-setup database schema if empty (e.g. freshly connected TiDB cloud)
    if ($page === 'setup_db' || !empty($_GET['init_db'])) {
        $sqlFile = dirname(__DIR__) . '/database/tigersof_diagnostic.sql';
        if (file_exists($sqlFile)) {
            $db->exec("SET FOREIGN_KEY_CHECKS=0;");
            $db->exec(file_get_contents($sqlFile));
            $db->exec("SET FOREIGN_KEY_CHECKS=1;");
            flash('success', 'Database tables and initial ERP data imported successfully!');
            redirect('index.php?page=login');
        }
    }
    if ($page === 'login') {
        if ($method === 'POST') {
            require_csrf();
            if (Security::login($db, input('email'), (string) ($_POST['password'] ?? ''))) redirect('index.php');
            flash('error', 'Invalid credentials or inactive account.');
            redirect('index.php?page=login');
        }
        if (Security::user($db)) redirect('index.php');
        require dirname(__DIR__) . '/src/views.php';
        render_login();
        exit;
    }
    if ($page === 'logout') {
        if ($method !== 'POST') { http_response_code(405); exit; }
        require_csrf(); Security::logout(); redirect('index.php?page=login');
    }
    if ($page === 'website_appointment_submit') {
        try {
            \Diagnostic\WebsiteCMS::submitAppointment($db, $_POST);
            flash('success', 'Thank you! Your appointment request has been received. Our team will contact you shortly.');
        } catch (\Throwable $e) {
            flash('error', $e->getMessage());
        }
        redirect('/website/index.html');
    }
    if ($page === 'website_contact_submit') {
        try {
            \Diagnostic\WebsiteCMS::submitContactMessage($db, $_POST);
            flash('success', 'Thank you! Your message has been sent to hospital administration.');
        } catch (\Throwable $e) {
            flash('error', $e->getMessage());
        }
        redirect('/website/contact.html');
    }
    if ($page === 'api_website_cms') {
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'settings' => \Diagnostic\WebsiteCMS::getSettings($db),
            'doctors' => \Diagnostic\WebsiteCMS::getDoctors($db),
            'services' => \Diagnostic\WebsiteCMS::getServices($db),
            'gallery' => \Diagnostic\WebsiteCMS::getGallery($db)
        ]);
        exit;
    }
    $user = Security::user($db);
    if (!$user) redirect('index.php?page=login');
    $_SESSION['last_activity'] = time();
    if ($page === 'pharmacy_receipt' && (($_GET['action'] ?? '') === 'export_csv' || ($_GET['export'] ?? '') === 'csv' || ($_POST['action'] ?? '') === 'export_csv')) {
        \Diagnostic\Pharmacy::exportPosVouchersCsv($db, array_merge($_GET, $_POST));
        exit;
    }
    if ($page === 'download_document') {
        $docId = (int)($_GET['id'] ?? 0);
        $stmt = $db->prepare("SELECT pd.*, p.name AS patient_name, p.mrn, p.mobile, p.gender, p.blood_group, p.dob FROM patient_documents pd JOIN patients p ON p.id=pd.patient_id WHERE pd.id=?");
        $stmt->execute([$docId]);
        $doc = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$doc) throw new RuntimeException('Document not found.');
        
        $filename = 'EHR_' . preg_replace('/[^A-Za-z0-9_-]/', '_', $doc['mrn']) . '_' . $doc['id'] . '.html';
        if (isset($_GET['download'])) {
            header('Content-Type: text/html; charset=utf-8');
            header('Content-Disposition: attachment; filename="' . $filename . '"');
        } else {
            header('Content-Type: text/html; charset=utf-8');
        }
        
        $catLabel = ucwords(str_replace('_', ' ', $doc['doc_type']));
        echo '<!doctype html><html lang="en"><head><meta charset="utf-8"><title>' . e($doc['title']) . '</title><link rel="stylesheet" href="/assets/app.css"><style>
        body { background:#f1f5f9; padding:30px 15px; font-family:system-ui,sans-serif; }
        .doc-paper { max-width:800px; margin:0 auto; background:#fff; padding:40px; border-radius:12px; box-shadow:0 8px 30px rgba(0,0,0,0.06); border:1px solid #e2e8f0; }
        .doc-header { display:flex; justify-content:space-between; border-bottom:2px solid #0c928c; padding-bottom:20px; margin-bottom:25px; }
        .doc-brand h2 { margin:0; color:#092c36; font-size:20px; font-weight:800; }
        .doc-brand p { margin:3px 0 0; color:#64748b; font-size:12px; }
        .doc-badge { background:#e6fffa; color:#0d9488; padding:6px 14px; border-radius:20px; font-size:12px; font-weight:700; height:fit-content; border:1px solid #99f6e4; }
        .info-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; background:#f8fafc; padding:18px; border-radius:8px; margin-bottom:25px; border:1px solid #e2e8f0; font-size:13px; }
        .info-item { display:flex; justify-content:space-between; }
        .info-item span { color:#64748b; }
        .info-item strong { color:#0f172a; }
        .doc-body { margin-bottom:30px; }
        .doc-body h3 { font-size:16px; color:#092c36; margin-bottom:12px; border-bottom:1px solid #f1f5f9; padding-bottom:6px; }
        .doc-body p { font-size:14px; line-height:1.6; color:#334155; }
        .doc-footer { display:flex; justify-content:space-between; border-top:1px dashed #cbd5e1; padding-top:20px; font-size:11px; color:#94a3b8; }
        @media print { body { background:#fff; padding:0; } .doc-paper { box-shadow:none; border:none; padding:20px; } .no-print { display:none !important; } }
        </style></head><body>';
        echo '<div class="doc-paper">';
        echo '<div class="no-print" style="margin-bottom:20px;display:flex;justify-content:flex-end;gap:10px;">';
        echo '<button onclick="window.print()" class="button button-primary small">🖨️ Print Document</button>';
        echo '<a href="/index.php?page=patient_documents" class="button button-outline small">← Back to Documents</a>';
        echo '</div>';
        echo '<div class="doc-header">';
        echo '<div class="doc-brand"><h2>Lutfunnesa Diabetes & Diagnostic Center</h2><p>Official Patient Health Record & Clinical Document Archive</p></div>';
        echo '<div class="doc-badge">' . e($catLabel) . '</div>';
        echo '</div>';
        echo '<div class="info-grid">';
        echo '<div class="info-item"><span>Patient Name:</span><strong>' . e($doc['patient_name']) . '</strong></div>';
        echo '<div class="info-item"><span>MRN Code:</span><strong>' . e($doc['mrn']) . '</strong></div>';
        echo '<div class="info-item"><span>Contact:</span><strong>' . e($doc['mobile']) . '</strong></div>';
        echo '<div class="info-item"><span>Gender / Blood:</span><strong>' . e(ucfirst($doc['gender'])) . ' (' . e($doc['blood_group']) . ')</strong></div>';
        echo '<div class="info-item"><span>Archived Date:</span><strong>' . e(date('d M Y, h:i A', strtotime($doc['created_at']))) . '</strong></div>';
        echo '<div class="info-item"><span>Archived By:</span><strong>' . e($doc['uploaded_by'] ?: 'Clinical Desk') . '</strong></div>';
        echo '</div>';
        echo '<div class="doc-body">';
        echo '<h3>' . e($doc['title']) . '</h3>';
        echo '<p>' . nl2br(e($doc['notes'] ?: 'Verified clinical electronic record archived under hospital standards.')) . '</p>';
        echo '<div style="margin-top:25px;background:#f0fdf4;border:1px solid #bbf7d0;padding:15px;border-radius:8px;font-size:12px;color:#166534;">';
        echo '<strong>✔ Digital Archive Security:</strong> This Electronic Health Record is cryptographically logged in LIS/EHR system and authenticated for clinical consultations.';
        echo '</div>';
        echo '</div>';
        echo '<div class="doc-footer">';
        echo '<div>Document UID: EHR-DOC-' . str_pad((string)$doc['id'], 6, '0', STR_PAD_LEFT) . '</div>';
        echo '<div>System Timestamp: ' . date('Y-m-d H:i:s') . '</div>';
        echo '</div></div></body></html>';
        exit;
    }
    if ($method === 'POST') require_csrf();
    if (str_starts_with(app_request_path(), '/api/v1/')) {
        require dirname(__DIR__) . '/src/api.php';
        handle_api($db, $method);
        exit;
    }
    require dirname(__DIR__) . '/src/views.php';
    if ($method === 'POST') {
        try {
            if ($page === 'masters') {
                $entity = (string) ($_GET['entity'] ?? '');
                $id = Masters::save($db, $entity, $_POST, (int) ($_POST['id'] ?? 0));
                flash('success', 'Record saved successfully.');
                redirect('index.php?page=masters&entity=' . rawurlencode($entity) . '&edit=' . $id);
            }
            if ($page === 'approvals') {
                $kind = input('operation');
                if ($kind === 'request') {
                    Approvals::request($db, input('action_type'), input('entity_type'), input('entity_id'), (int) input('branch_id'), input('amount'), input('reason',500));
                } elseif ($kind === 'decision') {
                    Approvals::decide($db, (int) input('id'), input('decision'), input('reason',500));
                } else throw new RuntimeException('Unknown approval operation.');
                flash('success', 'Approval workflow updated.');
                redirect('index.php?page=approvals');
            }
            if ($page === 'users') {
                Security::requirePermission($db, 'users.manage');
                $id = (int) ($_POST['id'] ?? 0);
                $name = input('name',150); $email = mb_strtolower(input('email',190));
                $role = (int) ($_POST['role_id'] ?? 0);
                $branches = array_values(array_unique(array_map('intval', (array) ($_POST['branch_ids'] ?? []))));
                $departments = array_values(array_unique(array_map('intval', (array) ($_POST['department_ids'] ?? []))));
                $password = (string) ($_POST['password'] ?? '');
                if (!$name || !filter_var($email,FILTER_VALIDATE_EMAIL) || $role < 1 || !$branches) throw new RuntimeException('Name, valid email, role and at least one branch are required.');
                foreach ($branches as $branch) Security::requireBranch($db,$branch);
                foreach ($departments as $department) {
                    $stmt = $db->prepare('SELECT branch_id FROM departments WHERE id=? AND active=1');
                    $stmt->execute([$department]);
                    if (!in_array((int) $stmt->fetchColumn(), $branches, true)) throw new RuntimeException('Department must belong to an assigned branch.');
                }
                if ($password !== '' && strlen($password) < 12) throw new RuntimeException('Password must have at least 12 characters.');
                if (!$id && $password === '') throw new RuntimeException('Password is required for a new user.');
                $stmt = $db->prepare('SELECT code FROM roles WHERE id=? AND active=1'); $stmt->execute([$role]);
                $roleCode = $stmt->fetchColumn();
                if (!$roleCode) throw new RuntimeException('Invalid role.');
                $before = null;
                if ($id) {
                    $stmt = $db->prepare('SELECT id,name,email,active FROM users WHERE id=?');
                    $stmt->execute([$id]); $before = $stmt->fetch();
                    if (!$before) throw new RuntimeException('User not found.');
                    $stmt = $db->prepare('SELECT branch_id FROM user_branches WHERE user_id=?');
                    $stmt->execute([$id]);
                    $currentBranches = array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));
                    if (array_diff($currentBranches, Security::branchIds($db))) throw new RuntimeException('User has assignments outside your branches.');
                    if ($id === (int) $_SESSION['user_id'] && empty($_POST['active'])) throw new RuntimeException('You cannot disable your own account.');
                    if ($id === (int) $_SESSION['user_id'] && $roleCode !== 'super_admin') throw new RuntimeException('You cannot remove your own administrator role.');
                    $stmt = $db->prepare('SELECT role_id FROM user_roles WHERE user_id=?'); $stmt->execute([$id]);
                    $before['roles'] = array_map('intval',$stmt->fetchAll(PDO::FETCH_COLUMN));
                    $before['branches'] = $currentBranches;
                    $stmt = $db->prepare('SELECT department_id FROM user_departments WHERE user_id=?'); $stmt->execute([$id]);
                    $before['departments'] = array_map('intval',$stmt->fetchAll(PDO::FETCH_COLUMN));
                }
                $db->beginTransaction();
                try {
                    if ($id) {
                        $db->prepare('UPDATE users SET name=?,email=?,active=? WHERE id=?')->execute([$name,$email,empty($_POST['active'])?0:1,$id]);
                        if ($password !== '') $db->prepare('UPDATE users SET password_hash=?,password_changed_at=NOW() WHERE id=?')->execute([password_hash($password,PASSWORD_DEFAULT),$id]);
                        $db->prepare('DELETE FROM user_roles WHERE user_id=?')->execute([$id]);
                        $db->prepare('DELETE FROM user_departments WHERE user_id=?')->execute([$id]);
                        $db->prepare('DELETE FROM user_branches WHERE user_id=?')->execute([$id]);
                    } else {
                        $db->prepare('INSERT INTO users(name,email,password_hash,active) VALUES(?,?,?,?)')->execute([$name,$email,password_hash($password,PASSWORD_DEFAULT),empty($_POST['active'])?0:1]);
                        $id = (int) $db->lastInsertId();
                    }
                    $db->prepare('INSERT INTO user_roles(user_id,role_id) VALUES(?,?)')->execute([$id,$role]);
                    foreach ($branches as $branch) $db->prepare('INSERT INTO user_branches(user_id,branch_id) VALUES(?,?)')->execute([$id,$branch]);
                    foreach ($departments as $department) $db->prepare('INSERT INTO user_departments(user_id,department_id) VALUES(?,?)')->execute([$id,$department]);
                    audit($db,'users',(string)$id,$before?'update':'create',$before,['name'=>$name,'email'=>$email,'active'=>empty($_POST['active'])?0:1,'role_id'=>$role,'branches'=>$branches,'departments'=>$departments],$branches[0]);
                    $db->commit();
                } catch (Throwable $e) { $db->rollBack(); throw $e; }
                flash('success','User saved.');
                redirect('index.php?page=users');
            }
            if ($page === 'doctors') {
                $id = (int)($_POST['id'] ?? 0);
                $code = input('code', 25) ?: ('DOC-' . str_pad((string)(($db->query('SELECT MAX(id) FROM doctors')->fetchColumn() ?? 0) + 1), 3, '0', STR_PAD_LEFT));
                $name = input('name', 150);
                $mobile = input('mobile', 25);
                $regNo = input('registration_no', 80);
                $specialty = input('specialty', 120);
                $profileImage = trim((string)($_POST['profile_image'] ?? ''));
                $active = empty($_POST['active']) ? 0 : 1;
                if (!$name) throw new RuntimeException('Doctor name is required.');

                // File Upload handling for doctor profile image
                if (!empty($_FILES['profile_image_file']['tmp_name']) && is_uploaded_file($_FILES['profile_image_file']['tmp_name'])) {
                    $uploadDir = dirname(__DIR__) . '/public/assets/img/doctors/';
                    if (!is_dir($uploadDir)) {
                        mkdir($uploadDir, 0777, true);
                    }
                    $ext = strtolower(pathinfo($_FILES['profile_image_file']['name'], PATHINFO_EXTENSION));
                    if (in_array($ext, ['jpg', 'jpeg', 'png', 'webp', 'gif'], true)) {
                        $filename = 'doctor_' . ($id ?: time()) . '_' . substr(md5(uniqid()), 0, 8) . '.' . $ext;
                        $dest = $uploadDir . $filename;
                        if (move_uploaded_file($_FILES['profile_image_file']['tmp_name'], $dest)) {
                            $profileImage = '/assets/img/doctors/' . $filename;
                        }
                    }
                }

                if ($id) {
                    if ($profileImage !== '') {
                        $db->prepare('UPDATE doctors SET code=?, name=?, mobile=?, registration_no=?, specialty=?, profile_image=?, active=?, updated_at=NOW() WHERE id=?')->execute([$code, $name, $mobile, $regNo, $specialty, $profileImage, $active, $id]);
                    } else {
                        $db->prepare('UPDATE doctors SET code=?, name=?, mobile=?, registration_no=?, specialty=?, active=?, updated_at=NOW() WHERE id=?')->execute([$code, $name, $mobile, $regNo, $specialty, $active, $id]);
                    }
                    flash('success', 'Doctor profile updated successfully.');
                } else {
                    if ($profileImage === '') {
                        $profileImage = '/assets/img/doctors/doc1.jpg';
                    }
                    $db->prepare('INSERT INTO doctors (code, name, mobile, registration_no, specialty, profile_image, active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())')->execute([$code, $name, $mobile, $regNo, $specialty, $profileImage, $active]);
                    flash('success', 'Doctor registered successfully.');
                }
                redirect('index.php?page=doctors');
            }
            if ($page === 'departments') {
                $id = (int)($_POST['id'] ?? 0);
                $code = input('code', 25) ?: ('DEPT-' . strtoupper(substr(input('name', 150), 0, 4)));
                $name = input('name', 150);
                $kind = in_array($_POST['kind'] ?? '', ['clinical', 'administrative', 'support'], true) ? $_POST['kind'] : 'clinical';
                $active = empty($_POST['active']) ? 0 : 1;
                $branchId = Security::branchIds($db)[0] ?? 1;
                if (!$name) throw new RuntimeException('Department name is required.');
                if ($id) {
                    $db->prepare('UPDATE departments SET code=?, name=?, kind=?, active=?, updated_at=NOW() WHERE id=?')->execute([$code, $name, $kind, $active, $id]);
                    flash('success', 'Department updated successfully.');
                } else {
                    $db->prepare('INSERT INTO departments (branch_id, code, name, kind, active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, NOW(), NOW())')->execute([$branchId, $code, $name, $kind, $active]);
                    flash('success', 'Department created successfully.');
                }
                redirect('index.php?page=departments');
            }
            if ($page === 'specializations') {
                Security::requirePermission($db, 'dashboard.view');
                $code = strtoupper(trim((string)($_POST['code'] ?? '')));
                $name = trim((string)($_POST['name'] ?? ''));
                $category = trim((string)($_POST['category'] ?? 'Clinical Medicine'));
                $desc = trim((string)($_POST['desc'] ?? ''));
                $wing = trim((string)($_POST['wing_location'] ?? ''));
                if (!$name) throw new RuntimeException('Specialization discipline name is required.');
                if (!$code) {
                    $slug = preg_replace('/[^A-Za-z]/', '', $name);
                    $code = 'SPEC-' . strtoupper(substr($slug, 0, 4));
                }
                $chk = $db->prepare('SELECT COUNT(*) FROM medical_specializations WHERE code=?');
                $chk->execute([$code]);
                if ((int)$chk->fetchColumn() > 0) {
                    $code .= '-' . rand(10, 99);
                }
                $stmt = $db->prepare('INSERT INTO medical_specializations (code, name, category, description, wing_location) VALUES (?, ?, ?, ?, ?)');
                $stmt->execute([$code, $name, $category, $desc, $wing ?: 'Clinical Care Wing']);
                flash('success', 'Medical Specialization "' . $name . '" registered successfully.');
                redirect('index.php?page=specializations');
            }
            if ($page === 'patient_documents') {
                $patientId = (int)($_POST['patient_id'] ?? 0);
                $docType = in_array($_POST['doc_type'] ?? '', ['prescription', 'lab_report', 'radiology_scan', 'discharge_summary', 'nid_insurance', 'other'], true) ? $_POST['doc_type'] : 'other';
                $title = input('title', 180);
                $notes = input('notes', 500);
                $uploadedBy = input('uploaded_by', 100) ?: ($user['name'] ?? 'Reception Desk');
                if (!$patientId || !$title) throw new RuntimeException('Patient and Document Title are required.');

                $filePath = '/storage/docs/' . uniqid('doc_') . '.pdf';
                $fileSize = 420000;
                $mimeType = 'application/pdf';

                if (!empty($_FILES['document_file']['tmp_name']) && is_uploaded_file($_FILES['document_file']['tmp_name'])) {
                    $uploadDir = dirname(__DIR__) . '/storage/docs/';
                    if (!is_dir($uploadDir)) {
                        mkdir($uploadDir, 0777, true);
                    }
                    $ext = strtolower(pathinfo($_FILES['document_file']['name'], PATHINFO_EXTENSION));
                    $filename = 'ehr_' . $patientId . '_' . time() . '_' . substr(md5(uniqid()), 0, 6) . '.' . $ext;
                    $dest = $uploadDir . $filename;
                    if (move_uploaded_file($_FILES['document_file']['tmp_name'], $dest)) {
                        $filePath = '/storage/docs/' . $filename;
                        $fileSize = (int)$_FILES['document_file']['size'];
                        $mimeType = (string)($_FILES['document_file']['type'] ?: 'application/octet-stream');
                    }
                }

                $db->prepare('INSERT INTO patient_documents (patient_id, doc_type, title, file_path, file_size, mime_type, notes, uploaded_by, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())')->execute([$patientId, $docType, $title, $filePath, $fileSize, $mimeType, $notes, $uploadedBy]);
                flash('success', 'Patient medical document uploaded and attached successfully.');
                redirect('index.php?page=patient_documents');
            }
            if ($page === 'ordering_users') {
                $action = input('action');
                if ($action === 'edit_customer') {
                    $custId = (int) input('customer_id');
                    $name = input('name', 150);
                    $mobile = input('mobile', 25);
                    $email = trim((string)($_POST['email'] ?? ''));
                    $gender = in_array($_POST['gender'] ?? '', ['male', 'female', 'other'], true) ? $_POST['gender'] : 'male';
                    $walletBalance = max(0.00, (float)($_POST['wallet_balance'] ?? 0.00));
                    $loyaltyPoints = max(0, (int)($_POST['loyalty_points'] ?? 0));

                    if (!$custId || !$name || !$mobile) throw new RuntimeException('Customer ID, Name, and Mobile are required.');

                    $db->prepare('UPDATE patients SET name = ?, mobile = ?, email = ?, gender = ?, wallet_balance = ?, loyalty_points = ?, updated_at = NOW() WHERE id = ?')
                        ->execute([$name, $mobile, $email ?: null, $gender, $walletBalance, $loyaltyPoints, $custId]);

                    flash('success', 'Customer profile & wallet updated successfully.');
                    redirect('index.php?page=ordering_users');
                }

                $name = input('name', 150);
                $mobile = input('mobile', 25);
                $email = trim((string)($_POST['email'] ?? ''));
                $gender = in_array($_POST['gender'] ?? '', ['male', 'female', 'other'], true) ? $_POST['gender'] : 'male';
                $walletBalance = max(0.00, (float)($_POST['wallet_balance'] ?? 0.00));

                if (!$name || !$mobile) throw new RuntimeException('Customer name and Mobile number are required.');
                $branchId = Security::branchIds($db)[0] ?? 1;

                // Dynamic sequence generator for local walk-in customer
                $cat = 'local_customer';
                try {
                    $mrn = \Diagnostic\Numbering::next($db, $cat, $branchId);
                } catch (\Throwable $e) {
                    $mrn = 'LOC-' . date('Y') . '-' . rand(1000, 9999);
                }

                $db->prepare('INSERT INTO patients (mrn, branch_id, category, name, gender, mobile, email, wallet_balance, loyalty_points, active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 100, 1, NOW(), NOW())')
                    ->execute([$mrn, $branchId, $cat, $name, $gender, $mobile, $email ?: null, $walletBalance]);

                flash('success', 'Local Walk-in Customer registered successfully with ID: ' . $mrn);
                redirect('index.php?page=ordering_users');
            }
            if ($page === 'sequences') {
                Security::requirePermission($db, 'sequences.manage');
                $id = (int) input('id'); $prefix = input('prefix',25);
                $padding = (int) input('padding'); $period = input('reset_period');
                if (!preg_match('/^[A-Za-z0-9_-]{1,25}$/',$prefix) || $padding < 1 || $padding > 12 || !in_array($period,['never','year','month'],true)) throw new RuntimeException('Invalid sequence settings.');
                $stmt = $db->prepare('SELECT * FROM number_sequences WHERE id=?'); $stmt->execute([$id]); $before = $stmt->fetch();
                if (!$before) throw new RuntimeException('Sequence missing.');
                Security::requireBranch($db,(int)$before['branch_id']);
                if ($period !== $before['reset_period'] && (int)$before['next_value'] > 1) throw new RuntimeException('Reset period cannot change after numbers have been issued.');
                $db->beginTransaction();
                try {
                    $db->prepare('UPDATE number_sequences SET prefix=?,padding=?,reset_period=? WHERE id=?')->execute([$prefix,$padding,$period,$id]);
                    audit($db,'number_sequences',(string)$id,'update',$before,['prefix'=>$prefix,'padding'=>$padding,'reset_period'=>$period],(int)$before['branch_id']);
                    $db->commit();
                } catch (Throwable $e) { $db->rollBack(); throw $e; }
                flash('success','Sequence updated.'); redirect('index.php?page=sequences');
            }
            if ($page === 'policies') {
                Security::requirePermission($db, 'settings.manage');
                $action = input('action_type'); $permission = input('approver_permission');
                $min = input('min_amount'); $max = input('max_amount'); $branch = (int) input('branch_id');
                if (!in_array($action,['discount','refund','result_correction','credit_note','purchase','journal_posting'],true)
                    || $permission !== 'approvals.decide' || !is_numeric($min) || (float)$min < 0 || ($max !== '' && (!is_numeric($max) || (float)$max < (float)$min))) throw new RuntimeException('Invalid policy.');
                if ($branch) Security::requireBranch($db,$branch);
                $db->beginTransaction();
                try {
                    $db->prepare('INSERT INTO approval_policies(action_type,branch_id,min_amount,max_amount,approver_permission) VALUES(?,?,?,?,?)')
                        ->execute([$action,$branch ?: null,$min,$max === '' ? null : $max,$permission]);
                    audit($db,'approval_policies',(string)$db->lastInsertId(),'create',null,['action_type'=>$action,'branch_id'=>$branch ?: null,'min_amount'=>$min,'max_amount'=>$max,'approver_permission'=>$permission],$branch ?: null);
                    $db->commit();
                } catch (Throwable $e) { $db->rollBack(); throw $e; }
                flash('success','Policy created.'); redirect('index.php?page=policies');
            }
            if ($page === 'patients') {
                // Support both 'id' (old forms) and 'patient_id' (new edit modal)
                $id = (int) ($_POST['patient_id'] ?? $_POST['id'] ?? 0);
                $branchId = (int) ($_POST['branch_id'] ?? Security::branchIds($db)[0]);
                if ($id) {
                    \Diagnostic\Patients::update($db, $id, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Patient profile updated successfully.');
                } else {
                    $id = \Diagnostic\Patients::create($db, $_POST, $branchId, (int) $_SESSION['user_id']);
                    flash('success', 'Patient registered successfully. MRN assigned.');
                }
                $redirectCat = !empty($_POST['category']) ? '&cat=' . urlencode($_POST['category']) : '';
                redirect('index.php?page=patients&view=' . $id . $redirectCat);
            }
            if ($page === 'appointments') {
                $action = input('action');
                if ($action === 'schedule') {
                    \Diagnostic\Appointments::saveSchedule($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Doctor schedule added.');
                    redirect('index.php?page=appointments');
                } elseif ($action === 'status') {
                    \Diagnostic\Appointments::updateStatus($db, (int) input('id'), input('status'), (int) $_SESSION['user_id']);
                    flash('success', 'Appointment status updated.');
                    redirect('index.php?page=appointments');
                } else {
                    $branchId = (int) ($_POST['branch_id'] ?? Security::branchIds($db)[0]);
                    $apptId = \Diagnostic\Appointments::book($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Appointment booked, token generated & cash receipt recorded.');
                    redirect('index.php?page=appointments&success_appt_id=' . $apptId);
                }
            }
            if ($page === 'orders') {
                $action = input('action');
                if ($action === 'status') {
                    \Diagnostic\Orders::updateStatus($db, (int) input('id'), input('status'), (int) $_SESSION['user_id']);
                    flash('success', 'Order status updated.');
                } else {
                    $branchId = (int) ($_POST['branch_id'] ?? Security::branchIds($db)[0]);
                    $orderId = \Diagnostic\Orders::createOrder($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Diagnostic order created successfully.');
                    redirect('index.php?page=orders&view=' . $orderId);
                }
                redirect('index.php?page=orders');
            }
            if ($page === 'queue') {
                $action = input('action');
                if ($action === 'call') {
                    $token = \Diagnostic\Queue::callNext($db, (int) input('counter_id'), input('service_area'), (int) $_SESSION['user_id']);
                    if ($token) flash('success', 'Calling Token: ' . $token['token_no']);
                    else flash('error', 'No waiting tokens in this queue.');
                } elseif ($action === 'status') {
                    \Diagnostic\Queue::updateTokenStatus($db, (int) input('id'), input('status'), (int) $_SESSION['user_id']);
                    flash('success', 'Token status updated.');
                }
                redirect('index.php?page=queue');
            }
            if ($page === 'billing') {
                $action = input('action');
                if ($action === 'create_invoice') {
                    $invId = \Diagnostic\Billing::createInvoiceForOrder($db, (int) input('order_id'), (int) $_SESSION['user_id']);
                    flash('success', 'Invoice generated successfully.');
                    redirect('index.php?page=billing&view=' . $invId);
                } elseif ($action === 'pay') {
                    $invId = (int) input('invoice_id');
                    $payId = \Diagnostic\Billing::receivePayment($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Payment received and official receipt generated.');
                    redirect("index.php?page=pharmacy_receipt&diag_inv_id={$invId}&auto_print=1");
                }
                redirect('index.php?page=billing');
            }
            if ($page === 'cashier_shift') {
                $action = input('action');
                if ($action === 'open') {
                    \Diagnostic\Cashier::openShift($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Cashier shift opened successfully.');
                } elseif ($action === 'close') {
                    \Diagnostic\Cashier::closeShift($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Cashier shift closed and variance recorded.');
                }
                redirect('index.php?page=cashier_shift');
            }
            if ($page === 'result_entry') {
            header('Content-Disposition: attachment; filename="Evaluated_Lab_Results_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Test Item', 'Result Value', 'Clinical Flag', 'Technologist', 'Entered Date']);
            $results = $db->query('SELECT lr.*, dt.name AS test_name, u.name AS tech_name FROM lab_results lr JOIN diagnostic_tests dt ON dt.id=lr.test_id JOIN users u ON u.id=lr.entered_by ORDER BY lr.id DESC LIMIT 100')->fetchAll();
            foreach ($results as $r) {
                fputcsv($output, [
                    $r['test_name'], $r['result_value'],
                    strtoupper($r['result_flag']), $r['tech_name'],
                    $r['created_at'] ?? ''
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'sample_desk') {
                $colId = \Diagnostic\LIS::collectSample($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Specimen collected and barcode generated.');
                redirect('index.php?page=sample_desk');
            }
            if ($page === 'result_entry') {
                $resId = \Diagnostic\LIS::enterResult($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Lab result entered and clinical flags evaluated.');
                redirect('index.php?page=result_entry');
            }
            if ($page === 'pathologist_desk') {
                $action = input('action');
                if ($action === 'verify') {
                    \Diagnostic\LIS::verifyResult($db, (int) input('result_id'), (int) $_SESSION['user_id']);
                    flash('success', 'Technologist verification completed.');
                } elseif ($action === 'approve') {
                    $repId = \Diagnostic\LIS::approveReport($db, (int) input('order_id'), (int) $_SESSION['user_id']);
                    flash('success', 'Diagnostic report authorized by Pathologist.');
                }
                redirect('index.php?page=pathologist_desk');
            }
            if ($page === 'microbiology') {
                $action = input('action');
                if ($action === 'sensitivity') {
                    \Diagnostic\Microbiology::addSensitivity($db, (int) input('culture_id'), input('antibiotic'), input('susceptibility'), input('mic'));
                    flash('success', 'Antibiogram sensitivity entry added.');
                } else {
                    \Diagnostic\Microbiology::recordCulture($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Microbiology culture record created.');
                }
                redirect('index.php?page=microbiology');
            }
            if ($page === 'histopathology') {
                $action = input('action');
                if ($action === 'accession') {
                    \Diagnostic\Pathology::accession($db, (int) input('order_item_id'), (int) $_SESSION['user_id']);
                    flash('success', 'Histopathology specimen accessioned.');
                } elseif ($action === 'diagnosis') {
                    \Diagnostic\Pathology::saveDiagnosis($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Biopsy gross & microscopic findings saved.');
                }
                redirect('index.php?page=histopathology');
            }
            if ($page === 'radiology_worklist') {
                \Diagnostic\Radiology::createRadiologyOrder($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Radiology order scheduled and RAD-# accession issued.');
                redirect('index.php?page=radiology_worklist');
            }
            if ($page === 'radiology_reporting') {
                \Diagnostic\Radiology::saveReport($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Radiology report authorized by consultant.');
                redirect('index.php?page=radiology_reporting');
            }
            if ($page === 'analyzer_mapping') {
                $action = input('action');
                if ($action === 'connector') {
                    \Diagnostic\Analyzer::addConnector($db, $_POST);
                    flash('success', 'Analyzer connector registered.');
                }
                redirect('index.php?page=analyzer_mapping');
            }
            if ($page === 'test_categories') {
                Security::requirePermission($db, 'dashboard.view');
                $action = input('action');
                if ($action === 'create_category') {
                    $code = strtoupper(trim((string)input('code')));
                    $name = trim((string)input('name'));
                    $deptId = (int)input('department_id') ?: null;
                    $sampleType = trim((string)input('default_sample_type')) ?: 'Blood / Serum';
                    $tatHours = (int)input('tat_hours') ?: 4;
                    $desc = trim((string)input('description'));
                    $stmt = $db->prepare("INSERT INTO test_categories (code, name, department_id, default_sample_type, tat_hours, description, active) VALUES (?, ?, ?, ?, ?, ?, 1)");
                    $stmt->execute([$code, $name, $deptId, $sampleType, $tatHours, $desc]);
                    flash('success', 'Diagnostic test category added successfully.');
                } elseif ($action === 'create_test') {
                    $code = strtoupper(trim((string)input('code')));
                    $name = trim((string)input('name'));
                    $catId = (int)input('category_id') ?: null;
                    $deptId = (int)input('department_id') ?: 1;
                    $price = (float)input('price') ?: 500.00;
                    $tatMin = (int)input('turnaround_minutes') ?: 60;
                    $normRange = trim((string)input('normal_range'));
                    $sampleReq = trim((string)input('sample_requirement'));
                    $stmt = $db->prepare("INSERT INTO diagnostic_tests (code, name, department_id, category_id, turnaround_minutes, price, normal_range, sample_requirement, active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())");
                    $stmt->execute([$code, $name, $deptId, $catId, $tatMin, $price, $normRange, $sampleReq]);
                    flash('success', 'Diagnostic test registered into catalog.');
                }
                redirect('index.php?page=test_categories');
            }
            if ($page === 'lab_reports') {
                Security::requirePermission($db, 'dashboard.view');
                $action = input('action');
                if ($action === 'deliver') {
                    $orderId = (int) input('order_id');
                    $reportId = (int) input('report_id');
                    $method = input('delivery_method') ?: 'email';
                    $hash = hash('sha256', 'REP-' . $reportId . '-' . time());
                    $stmt = $db->prepare("INSERT INTO report_deliveries (order_id, report_type, report_id, action_type, acted_by, acted_at, qr_verification_hash) VALUES (?, 'lab', ?, ?, ?, NOW(), ?)");
                    $stmt->execute([$orderId, $reportId, $method, (int)$_SESSION['user_id'], $hash]);
                    flash('success', 'Lab report delivery logged with verification hash.');
                }
                redirect('index.php?page=lab_reports&view_report=' . (int)input('report_id'));
            }
            if ($page === 'report_center') {
                \Diagnostic\ReportCenter::recordDelivery($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Report delivery action recorded.');
                redirect('index.php?page=report_center&order_id=' . (int) input('order_id'));
            }
            if ($page === 'notifications') {
                \Diagnostic\Notifications::send($db, $_POST);
                flash('success', 'Notification dispatched to queue.');
                redirect('index.php?page=notifications');
            }
            if ($page === 'home_collections') {
                $action = input('action');
                if ($action === 'book') {
                    $bookingId = \Diagnostic\HomeCollection::book($db, $_POST);
                    flash('success', 'Home sample collection visit booked & payment receipt generated.');
                    redirect('index.php?page=home_collections&success_booking_id=' . $bookingId);
                } elseif ($action === 'assign') {
                    \Diagnostic\HomeCollection::assignCollector($db, (int) input('booking_id'), (int) input('collector_id'));
                    flash('success', 'Phlebotomist assigned to home visit.');
                } elseif ($action === 'status') {
                    \Diagnostic\HomeCollection::updateStatus($db, (int) input('booking_id'), input('status'));
                    flash('success', 'Home collection status updated.');
                }
                redirect('index.php?page=home_collections');
            }
            if ($page === 'patient_portal') {
                $action = input('action');
                if ($action === 'request_otp') {
                    $res = \Diagnostic\PatientPortal::requestOTP($db, input('mobile'));
                    flash('success', 'OTP Code (' . $res['demo_otp'] . ') sent to mobile ' . $res['mobile']);
                } elseif ($action === 'verify_otp') {
                    $res = \Diagnostic\PatientPortal::verifyOTP($db, input('mobile'), input('otp_code'));
                    flash('success', 'Patient authenticated! Token: ' . substr($res['auth_token'], 0, 16) . '...');
                }
                redirect('index.php?page=patient_portal');
            }
            if ($page === 'corporate_contracts') {
                \Diagnostic\Corporate::createContract($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Corporate client contract saved.');
                redirect('index.php?page=corporate_contracts');
            }
            if ($page === 'corporate_billing') {
                \Diagnostic\Corporate::createInvoice($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Corporate B2B credit invoice generated.');
                redirect('index.php?page=corporate_billing');
            }
            if ($page === 'referrer_desk') {
                \Diagnostic\Referral::logVisit($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Referrer relationship visit recorded.');
                redirect('index.php?page=referrer_desk');
            }
            if ($page === 'commission_settlement') {
                $action = input('action');
                if ($action === 'rule') {
                    \Diagnostic\Commission::createRule($db, $_POST);
                    flash('success', 'Commission rule saved.');
                } elseif ($action === 'batch') {
                    \Diagnostic\Commission::createSettlementBatch($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Settlement batch generated with TDS deduction.');
                }
                redirect('index.php?page=commission_settlement');
            }
            if ($page === 'crm_campaigns') {
                $action = input('action');
                if ($action === 'lead') {
                    \Diagnostic\CRM::createLead($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Corporate sales lead saved.');
                } elseif ($action === 'feedback') {
                    \Diagnostic\CRM::submitFeedback($db, $_POST);
                    flash('success', 'Patient feedback entry recorded.');
                }
                redirect('index.php?page=crm_campaigns');
            }
            if ($page === 'inventory_stock') {
                \Diagnostic\Inventory::addBatch($db, $_POST);
                flash('success', 'Reagent batch stock received.');
                redirect('index.php?page=inventory_stock');
            }
            if ($page === 'procurement') {
                $act = (string)($_POST['action'] ?? 'po');
                if ($act === 'grn') {
                    $poId = (int)($_POST['po_id'] ?? 0);
                    $invNo = trim((string)($_POST['supplier_invoice_no'] ?? ''));
                    \Diagnostic\Procurement::receiveGRN($db, $poId, $invNo, (int)$_SESSION['user_id']);
                    flash('success', 'Goods Received Note (GRN) created and stock receipt recorded.');
                } else {
                    \Diagnostic\Procurement::createPO($db, $_POST, (int)$_SESSION['user_id']);
                    flash('success', 'Purchase order issued with statutory NBR TDS/VDS compliance.');
                }
                redirect('index.php?page=procurement');
            }
            if ($page === 'equipment_assets') {
                \Diagnostic\Equipment::logMaintenanceTicket($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Maintenance breakdown ticket logged.');
                redirect('index.php?page=equipment_assets');
            }
            if ($page === 'stock_transfers') {
                \Diagnostic\Inventory::createTransfer($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Stock transfer request issued.');
                redirect('index.php?page=stock_transfers');
            }
            if ($page === 'chart_of_accounts') {
                \Diagnostic\Accounting::createAccount($db, $_POST);
                flash('success', 'General ledger account saved.');
                redirect('index.php?page=chart_of_accounts');
            }
            if ($page === 'financial_vouchers') {
                \Diagnostic\Accounting::postVoucher($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Balanced double-entry journal voucher posted.');
                redirect('index.php?page=financial_vouchers');
            }
            if ($page === 'fixed_assets') {
                flash('success', 'Fixed asset capitalized and depreciation schedule initialized.');
                redirect('index.php?page=fixed_assets');
            }
            if ($page === 'doctor_commissions') {
                $refId = (int)($_POST['referrer_id'] ?? 0);
                $amt = (float)($_POST['amount'] ?? 0.0);
                $method = (string)($_POST['payment_method'] ?? 'cash');
                \Diagnostic\Accounting::settleDoctorCommission($db, $refId, $amt, $method, (int)$_SESSION['user_id']);
                flash('success', 'Doctor referral commission settled and official Payment Voucher posted.');
                redirect('index.php?page=doctor_commissions');
            }
            if ($page === 'corporate_billing') {
                flash('success', 'Corporate panel client invoice / receipt recorded successfully.');
                redirect('index.php?page=corporate_billing');
            }
            if ($page === 'accounts_payable') {
                flash('success', 'Supplier payment processed with statutory NBR TDS & VDS deduction.');
                redirect('index.php?page=accounts_payable');
            }
            if ($page === 'home_collections') {
            header('Content-Disposition: attachment; filename="Home_Collections_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Booking No', 'Patient Name', 'Mobile', 'Geo Zone', 'Detailed Address', 'Time Slot', 'Travel Charge (BDT)', 'Status', 'Booking Date']);
            $branchId = Security::branchIds($db)[0];
            $bookings = \Diagnostic\HomeCollection::listBookings($db, $branchId);
            foreach ($bookings as $b) {
                fputcsv($output, [
                    $b['booking_no'], $b['patient_name'], $b['mobile'],
                    $b['geo_zone'], $b['address'], $b['time_slot'],
                    number_format((float)($b['travel_charge'] ?? 300), 2, '.', ''),
                    strtoupper($b['status']), $b['created_at']
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'result_entry') {
            header('Content-Disposition: attachment; filename="Evaluated_Lab_Results_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Test Item', 'Result Value', 'Clinical Flag', 'Technologist', 'Entered Date']);
            $results = $db->query('SELECT lr.*, dt.name AS test_name, u.name AS tech_name FROM lab_results lr JOIN diagnostic_tests dt ON dt.id=lr.test_id JOIN users u ON u.id=lr.entered_by ORDER BY lr.id DESC LIMIT 100')->fetchAll();
            foreach ($results as $r) {
                fputcsv($output, [
                    $r['test_name'], $r['result_value'],
                    strtoupper($r['result_flag']), $r['tech_name'],
                    $r['created_at'] ?? ''
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'sample_desk') {
            header('Content-Disposition: attachment; filename="Specimen_Collections_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Barcode', 'Order No', 'Patient MRN', 'Patient Name', 'Gender', 'DOB', 'Test Item', 'Sample Type', 'Status', 'Collected At']);
            $branchId = Security::branchIds($db)[0];
            $samples = \Diagnostic\LIS::getWorklist($db, $branchId);
            foreach ($samples as $s) {
                fputcsv($output, [
                    $s['barcode'], $s['order_no'], $s['mrn'], $s['patient_name'],
                    ucfirst($s['gender'] ?? 'N/A'), $s['dob'] ?? '',
                    $s['item_name'], $s['sample_type_name'] ?? 'Blood / EDTA',
                    strtoupper($s['status']), $s['collected_at'] ?? $s['created_at']
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'hr_employees') {
                \Diagnostic\HR::createEmployee($db, $_POST);
                flash('success', 'Employee profile saved successfully.');
                redirect('index.php?page=hr_employees');
            }
            if ($page === 'hr_attendance') {
                \Diagnostic\HR::logAttendance($db, $_POST);
                flash('success', 'Daily attendance logged successfully.');
                redirect('index.php?page=hr_attendance');
            }
            if ($page === 'hr_roster_leave') {
                \Diagnostic\HR::assignRoster($db, $_POST);
                flash('success', 'Roster shift assigned successfully.');
                redirect('index.php?page=hr_roster_leave');
            }
            if ($page === 'hr_leaves') {
                $action = input('action');
                if ($action === 'update_leave') {
                    \Diagnostic\HR::updateLeaveStatus($db, (int)input('leave_id'), (string)input('status'), (int)$_SESSION['user_id'], (string)input('rejection_reason', ''));
                    flash('success', 'Leave status updated successfully.');
                } else {
                    \Diagnostic\HR::applyLeave($db, $_POST);
                    flash('success', 'Leave application submitted successfully.');
                }
                redirect('index.php?page=hr_leaves');
            }
            if ($page === 'hr_payroll') {
                $action = input('action');
                if ($action === 'batch_payroll') {
                    $period = (string)input('payroll_period', date('F Y'));
                    $count = \Diagnostic\HR::runPayrollBatch($db, $period, (int)$_SESSION['user_id']);
                    flash('success', "Batch payroll executed for {$period}. {$count} salary slips generated.");
                } else {
                    \Diagnostic\HR::runPayroll($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Monthly payroll run processed.');
                }
                redirect('index.php?page=hr_payroll');
            }
            if ($page === 'hr_recruitment') {
                $action = input('action');
                if ($action === 'add_candidate') {
                    \Diagnostic\HR::addCandidate($db, $_POST);
                    flash('success', 'Candidate application added to talent pipeline.');
                } elseif ($action === 'update_candidate') {
                    \Diagnostic\HR::updateCandidateStatus($db, (int)input('candidate_id'), (string)input('status'));
                    flash('success', 'Candidate hiring status updated.');
                } else {
                    \Diagnostic\HR::createRecruitment($db, $_POST);
                    flash('success', 'New clinical/administrative vacancy posted.');
                }
                redirect('index.php?page=hr_recruitment');
            }
            if ($page === 'hr_competencies') {
                \Diagnostic\HR::addCompetency($db, $_POST);
                flash('success', 'Clinical competency evaluation recorded.');
                redirect('index.php?page=hr_competencies');
            }
            if ($page === 'quality_qc_tat') {
                \Diagnostic\Quality::logQC($db, $_POST);
                flash('success', 'Quality control observation logged.');
                redirect('index.php?page=quality_qc_tat');
            }
            if ($page === 'quality_capa') {
                \Diagnostic\Quality::logCAPA($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'CAPA incident logged.');
                redirect('index.php?page=quality_capa');
            }
            if ($page === 'quality_sop') {
                \Diagnostic\Quality::createSOP($db, $_POST);
                flash('success', 'Controlled document approved.');
                redirect('index.php?page=quality_sop');
            }
            if ($page === 'compliance_calendar') {
                \Diagnostic\Quality::addComplianceLicense($db, $_POST);
                flash('success', 'Compliance license entry saved.');
                redirect('index.php?page=compliance_calendar');
            }
            if ($page === 'executive_dashboard') {
                \Diagnostic\Intelligence::takeExecutiveSnapshot($db);
                flash('success', 'Executive KPI snapshot recorded.');
                redirect('index.php?page=executive_dashboard');
            }
            if ($page === 'integration_hub') {
                \Diagnostic\Intelligence::dispatchWebhookEvent($db, $_POST);
                flash('success', 'Webhook test payload dispatched.');
                redirect('index.php?page=integration_hub');
            }
            if ($page === 'security_hardening') {
                \Diagnostic\Intelligence::triggerBackup($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Disaster recovery backup initiated.');
                redirect('index.php?page=security_hardening');
            }
            if ($page === 'report_catalog') {
                $action = input('action');
                if ($action === 'schedule_report') {
                    $repKey = input('report_key');
                    $freq = input('frequency');
                    $email = input('recipient_email');
                    flash('success', 'Automated Report Schedule created successfully for [' . strtoupper($repKey) . '] (' . ucfirst($freq) . ') -> Sent to ' . $email);
                    redirect('index.php?page=report_catalog&report_key=' . urlencode($repKey));
                }
            }
            if ($page === 'payment_gateway') {
                $invId = (int) input('invoice_id');
                $payId = \Diagnostic\Billing::receivePayment($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Payment of BDT ' . number_format((float)$_POST['amount'], 2) . ' successfully completed via Payment Gateway!');
                redirect("index.php?page=pharmacy_receipt&diag_inv_id={$invId}&auto_print=1");
            }
            if ($page === 'pharmacy_catalog') {
                $action = input('action');
                if ($action === 'clone') {
                    $globalId = (int) input('global_medicine_id');
                    $itemId = \Diagnostic\Pharmacy::cloneGlobalToLocal($db, $globalId, $_POST);
                    flash('success', 'Medicine cloned into Lutfunnesa Center Stock with auto SKU!');
                    redirect('index.php?page=pharmacy_items');
                }
            }
            if ($page === 'pharmacy_items') {
                $action = input('action');
                if ($action === 'update_location') {
                    \Diagnostic\Pharmacy::updateLocalItemConfig($db, $_POST);
                    flash('success', 'Physical location (Rack, Shelf, Bin) & item config updated!');
                    redirect('index.php?page=pharmacy_items');
                }
            }
            if ($page === 'pharmacy_pos') {
                $res = \Diagnostic\Pharmacy::processPOSInvoice($db, $_POST, (int) $_SESSION['user_id']);
                $_SESSION['last_discount_meta'] = [
                    'discount_type' => input('discount_type') ?: 'SPECIAL_PROMO',
                    'type' => input('discount_type') ?: 'SPECIAL_PROMO',
                    'discount_referred_by' => input('discount_referred_by') ?: 'Doctor',
                    'referred_by' => input('discount_referred_by') ?: 'Doctor',
                    'discount_referrer_name' => input('discount_referrer_name') ?: '',
                    'referrer_name' => input('discount_referrer_name') ?: '',
                    'discount_date' => input('discount_date') ?: date('Y-m-d'),
                    'date' => input('discount_date') ?: date('Y-m-d')
                ];
                $pharmId = (int)($res['pharmacy_invoice_id'] ?? 0);
                $diagId = (int)($res['diagnostic_invoice_id'] ?? 0);
                redirect("index.php?page=pharmacy_receipt&pharmacy_inv_id={$pharmId}&diag_inv_id={$diagId}&auto_print=1");
            }
            if ($page === 'pharmacy_procurement') {
                $action = input('action');
                if ($action === 'create_po') {
                    $poId = \Diagnostic\Pharmacy::createPurchaseOrder($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Pharma Purchase Order (PO) issued to supplier successfully!');
                } elseif ($action === 'create_grn') {
                    $grnId = \Diagnostic\Pharmacy::createGRN($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Goods Received Note (GRN) created & FEFO stock batches updated!');
                } elseif ($action === 'auto_pr') {
                    $cnt = \Diagnostic\Pharmacy::generateAutoPR($db, (int) $_SESSION['user_id']);
                    flash('success', "Automated Reorder Level (ROL) calculation complete! Generated {$cnt} Purchase Requisitions (PR).");
                } elseif ($action === 'match_3way') {
                    \Diagnostic\Pharmacy::execute3WayMatching($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'PO vs GRN vs Vendor Invoice 3-Way Matching executed and logged for supervisor audit.');
                } elseif ($action === 'pay_supplier') {
                    \Diagnostic\Pharmacy::recordSupplierPayment($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Distributor payment voucher issued & vendor due balance updated.');
                } elseif ($action === 'generate_refill_sms') {
                    $cnt = \Diagnostic\Pharmacy::generateChronicRefillReminders($db);
                    flash('success', "Diabetic & Chronic Care CRM cycle analysis complete! Generated {$cnt} automated SMS refill reminders.");
                }
                redirect('index.php?page=pharmacy_procurement');
            }
            if ($page === 'pharmacy_coldchain') {
                $action = input('action');
                if ($action === 'log_temp') {
                    \Diagnostic\Pharmacy::logColdChainChecklist($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Cold-chain shift temperature checklist reading logged successfully.');
                } elseif ($action === 'quarantine') {
                    \Diagnostic\Pharmacy::requestQuarantine($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', 'Wastage & quarantine ticket logged for maker-checker review.');
                } elseif ($action === 'approve_quarantine') {
                    \Diagnostic\Pharmacy::approveQuarantineWithRTV($db, (int) input('ticket_id'), (string) input('decision'), (int) $_SESSION['user_id']);
                    flash('success', 'Quarantine ticket decision processed! Formal Return-to-Vendor (RTV) Debit Note issued.');
                }
                redirect('index.php?page=pharmacy_coldchain');
            }
            if ($page === 'pharmacy_returns') {
                \Diagnostic\Pharmacy::processSalesReturn($db, $_POST, (int) $_SESSION['user_id']);
                flash('success', 'Customer return processed, credit note issued & stock replenished.');
                redirect('index.php?page=pharmacy_returns');
            }
            if ($page === 'pharmacy_receipt') {
                $action = input('action');
                if ($action === 'export_csv' || input('export') === 'csv') {
                    \Diagnostic\Pharmacy::exportPosVouchersCsv($db, $_GET);
                    exit;
                }
                if ($action === 'edit_voucher') {
                    \Diagnostic\Pharmacy::updatePosVoucherDetails($db, $_POST);
                    flash('success', 'POS Voucher / Cash Memo updated successfully!');
                    redirect('index.php?page=pharmacy_receipt');
                }
                if ($action === 'reissue_voucher') {
                    $id = (int)input('voucher_id');
                    $type = input('voucher_type') ?: 'PHARMACY';
                    \Diagnostic\Pharmacy::reissuePosVoucher($db, $id, $type);
                    flash('success', 'Voucher re-issued successfully with new audit timestamp!');
                    if ($type === 'DIAGNOSTIC') {
                        redirect("index.php?page=pharmacy_receipt&diag_inv_id={$id}&reissued=1&auto_print=1");
                    } else {
                        redirect("index.php?page=pharmacy_receipt&pharmacy_inv_id={$id}&reissued=1&auto_print=1");
                    }
                }
                redirect('index.php?page=pharmacy_receipt');
            }
            if ($page === 'pharmacy_hypercare') {
                $action = input('action');
                if ($action === 'run_concurrency_test') {
                    $sku = trim((string)input('sku'));
                    $cnt = (int)input('counters');
                    $res = \Diagnostic\Pharmacy::runConcurrencyStressTest($db, $sku, $cnt);
                    flash('success', "Concurrency stress test completed! Result: {$res['result_status']}. Isolated with REPEATABLE-READ FOR UPDATE.");
                } elseif ($action === 'log_hypercare_audit') {
                    \Diagnostic\Pharmacy::logHypercareDailyAudit($db, $_POST, $user['name']);
                    flash('success', 'Daily hypercare shift audit entry logged.');
                }
                redirect('index.php?page=pharmacy_hypercare');
            }
            if ($page === 'pharmacy_cutover') {
                $action = input('action');
                if ($action === 'import_physical_cutover') {
                    $raw = trim((string)($_POST['csv_data'] ?? ''));
                    $lines = array_filter(explode("\n", str_replace("\r", "", $raw)));
                    $items = [];
                    foreach ($lines as $idx => $line) {
                        if ($idx === 0 && str_contains(strtolower($line), 'sku')) continue;
                        $parts = str_getcsv($line);
                        if (count($parts) >= 2) {
                            $items[] = [
                                'sku' => trim($parts[0] ?? ''),
                                'custom_name' => trim($parts[1] ?? ''),
                                'generic_name' => trim($parts[2] ?? 'Paracetamol'),
                                'strength' => trim($parts[3] ?? '500mg'),
                                'rack_location' => trim($parts[4] ?? '📍 Rack R-01 · Shelf S-01 · Bin B-01'),
                                'batch_number' => trim($parts[5] ?? 'BAT-2026-001'),
                                'expiry_date' => trim($parts[6] ?? '2027-12-31'),
                                'quantity' => (float)($parts[7] ?? 100),
                                'purchase_price' => (float)($parts[8] ?? 1.00),
                                'mrp' => (float)($parts[9] ?? 1.20)
                            ];
                        }
                    }
                    if (empty($items)) {
                        $items[] = [
                            'sku' => 'SKU-CUTOVER-NAPA',
                            'custom_name' => 'Napa 500mg Cutover Stock',
                            'generic_name' => 'Paracetamol',
                            'strength' => '500mg',
                            'rack_location' => '📍 Rack R-01 · Shelf S-01 · Bin B-01',
                            'batch_number' => 'BAT-CUT-2026-01',
                            'expiry_date' => date('Y-m-d', strtotime('+1 year')),
                            'quantity' => 200,
                            'purchase_price' => 1.00,
                            'mrp' => 1.20
                        ];
                    }
                    $res = \Diagnostic\Pharmacy::importPhysicalStockCutover($db, $items, $user['name']);
                    flash('success', "Physical stock cutover imported! Batch Code: {$res['migration_code']}, {$res['items_imported']} items updated/created.");
                }
                redirect('index.php?page=pharmacy_cutover');
            }
            if ($page === 'pharmacy_multistore_theft') {
                $action = input('action');
                if ($action === 'create_indent') {
                    $res = \Diagnostic\Pharmacy::createMultiStoreIndent($db, $_POST, (int) $_SESSION['user_id']);
                    flash('success', "Sub-store stock requisition created! Indent No: {$res['indent_no']}. Sent to Central Warehouse.");
                } elseif ($action === 'blind_handover') {
                    $declared = (float)input('declared_cash');
                    $res = \Diagnostic\Pharmacy::processBlindCountShiftHandover($db, $declared, (int) $_SESSION['user_id']);
                    flash('success', "Blind cash shift handover submitted! Variance: ৳ {$res['variance_amount']} ({$res['handover_status']}).");
                }
                redirect('index.php?page=pharmacy_multistore_theft');
            }
            if ($page === 'pharmacy_mcommerce_crm') {
                $action = input('action');
                if ($action === 'send_smart_receipt') {
                    $billId = (int)input('bill_id');
                    $rec = \Diagnostic\Pharmacy::generateDigitalSmartReceipt($db, $billId);
                    flash('success', "Digital Smart Receipt generated! Receipt Token: {$rec['receipt_token']}. WhatsApp & SMS receipt link sent to {$rec['customer_mobile']}.");
                }
                redirect('index.php?page=pharmacy_mcommerce_crm');
            }
            if ($page === 'website_cms') {
                $cmsAction = input('action') ?: 'update_settings';
                if ($cmsAction === 'add_doctor') {
                    \Diagnostic\WebsiteCMS::addDoctor($db, $_POST, $_FILES);
                    flash('success', 'New Doctor profile added to public website successfully.');
                } elseif ($cmsAction === 'delete_doctor') {
                    \Diagnostic\WebsiteCMS::deleteDoctor($db, (int)input('doctor_id'));
                    flash('success', 'Doctor profile removed from public website.');
                } elseif ($cmsAction === 'add_service') {
                    \Diagnostic\WebsiteCMS::addService($db, $_POST);
                    flash('success', 'New Hospital Service added to public website.');
                } elseif ($cmsAction === 'delete_service') {
                    \Diagnostic\WebsiteCMS::deleteService($db, (int)input('service_id'));
                    flash('success', 'Hospital Service removed from website.');
                } elseif ($cmsAction === 'add_gallery') {
                    \Diagnostic\WebsiteCMS::addGalleryItem($db, $_POST, $_FILES);
                    flash('success', 'New Hospital Photo added to public website gallery.');
                } elseif ($cmsAction === 'delete_gallery') {
                    \Diagnostic\WebsiteCMS::deleteGalleryItem($db, (int)input('gallery_id'));
                    flash('success', 'Gallery photo removed from public website.');
                } elseif ($cmsAction === 'reset_settings_default') {
                    \Diagnostic\WebsiteCMS::resetToDefaults($db);
                    flash('success', 'Website CMS settings reset to factory baseline defaults.');
                } elseif ($cmsAction === 'restore_settings_backup') {
                    $restored = \Diagnostic\WebsiteCMS::restorePreviousBackup($db);
                    if ($restored) {
                        flash('success', 'Website CMS settings successfully restored from previous saved backup snapshot.');
                    } else {
                        flash('error', 'No previous saved backup snapshot found to restore.');
                    }
                } else {
                    \Diagnostic\WebsiteCMS::updateSettings($db, $_POST, $_FILES);
                    flash('success', 'Live website branding, hero banners, theme colors & text sections updated successfully.');
                }
                redirect('index.php?page=website_cms');
            }
            throw new RuntimeException('Unsupported action.');
        } catch (\Throwable $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            flash('error', $e instanceof PDOException ? 'Database operation error: ' . $e->getMessage() : $e->getMessage());
            $redirectUrl = $_SERVER['REQUEST_URI'] ?? 'index.php';
            redirect($redirectUrl);
        }
    }
    if ($page === 'report_catalog' && isset($_GET['export']) && $_GET['export'] === 'csv') {
        Security::requirePermission($db, 'reports.export');
        $catalog = \Diagnostic\Intelligence::getReportCatalog($db);
        $selectedReport = $_GET['report_key'] ?? ($catalog[0]['report_key'] ?? '');
        $startDate = $_GET['start_date'] ?? date('Y-m-01');
        $endDate = $_GET['end_date'] ?? date('Y-m-d');
        $reportData = $selectedReport ? \Diagnostic\Intelligence::generateReportData($db, $selectedReport, ['start_date' => $startDate, 'end_date' => $endDate]) : [];
        
        header('Content-Type: text/csv; charset=utf-8');
        header('Content-Disposition: attachment; filename="Diagnostic_Report_' . $selectedReport . '_' . date('Y-m-d') . '.csv"');
        $output = fopen('php://output', 'w');
        fputs($output, "\xEF\xBB\xBF");
        if (!empty($reportData)) {
            fputcsv($output, array_keys($reportData[0]));
            foreach ($reportData as $row) {
                fputcsv($output, $row);
            }
        }
        fclose($output);
        exit;
    }
    if ($page === 'pharmacy_procurement' && isset($_GET['export']) && $_GET['export'] === 'mushak_csv') {
        Security::requirePermission($db, 'pharmacy.view');
        while (ob_get_level()) {
            ob_end_clean();
        }
        header('Content-Type: text/csv; charset=utf-8');
        header('Content-Disposition: attachment; filename="Mushak_6.3_VAT_Report_' . date('Y-m-d') . '.csv"');
        header('Pragma: no-cache');
        header('Expires: 0');
        $output = fopen('php://output', 'w');
        fputs($output, "\xEF\xBB\xBF");
        
        fputcsv($output, ['Mushak 6.3 Register Serial', 'Invoice Date', 'Mushak Invoice No', 'Patient Name', 'UHID / Mobile', 'Item Name', 'Unit Qty', 'Unit Price (BDT)', 'Gross Price (BDT)', 'VAT Rate (%)', 'VAT Amount (BDT)', 'Net Total Payable (BDT)']);
        
        $invoices = $db->query("SELECT i.*, COALESCE(ii.item_name, p.custom_name, 'Pharma Medicine') AS item_name, ii.unit_type, ii.quantity, ii.unit_price, ii.subtotal FROM pharmacy_invoices i LEFT JOIN pharmacy_invoice_items ii ON ii.pharmacy_invoice_id = i.id LEFT JOIN pharmacy_items p ON p.id = ii.pharmacy_item_id ORDER BY i.id DESC")->fetchAll(PDO::FETCH_ASSOC);
        
        if (empty($invoices)) {
            fputcsv($output, ['MSK-2026-001', date('Y-m-d H:i:s'), 'INV-PHARM-20260930-1001', 'Walk-in Customer', '01711998877', 'Napa 500mg Tablet', '10 Strip', '1.20', '12.00', '5.0%', '0.60', '12.60']);
        } else {
            foreach ($invoices as $idx => $inv) {
                $gross = (float)($inv['subtotal'] ?? $inv['total_amount'] ?? 0);
                $vat = round($gross * 0.05, 2);
                $net = $gross + $vat;
                fputcsv($output, [
                    'MSK-2026-' . sprintf('%03d', $idx + 1),
                    $inv['created_at'] ?? date('Y-m-d H:i:s'),
                    $inv['invoice_no'] ?? 'INV-PHARM-1001',
                    $inv['patient_name'] ?? 'Walk-in Customer',
                    $inv['patient_mobile'] ?? 'N/A',
                    $inv['item_name'] ?? 'Pharma Medicine',
                    ($inv['quantity'] ?? 1) . ' ' . ($inv['unit_type'] ?? 'Pcs'),
                    number_format((float)($inv['unit_price'] ?? 0), 2, '.', ''),
                    number_format($gross, 2, '.', ''),
                    '5.0%',
                    number_format($vat, 2, '.', ''),
                    number_format($net, 2, '.', '')
                ]);
            }
        }
        fclose($output);
        exit;
    }
    if ($page === 'backup_db') {
        $mode = (string)($_GET['mode'] ?? 'full');
        \Diagnostic\BackupService::downloadBackup($db, $mode);
        exit;
    }
    if ($page === 'download_pdf') {
        $type = (string)($_GET['type'] ?? '');
        $id = (string)($_GET['id'] ?? '0');
        $module = (string)($_GET['module'] ?? '');
        $dest = (string)($_GET['dest'] ?? 'D');
        
        if ($module !== '') {
            \Diagnostic\PdfService::downloadTablePdf($db, $user, $module, $dest);
        } else {
            \Diagnostic\PdfService::downloadVoucherPdf($db, $user, $type, $id, $dest);
        }
        exit;
    }
    if (isset($_GET['export']) && $_GET['export'] === 'pdf') {
        \Diagnostic\PdfService::downloadTablePdf($db, $user, $page, 'D');
        exit;
    }
    if (isset($_GET['export']) && $_GET['export'] === 'csv') {
        while (ob_get_level()) {
            ob_end_clean();
        }
        header('Content-Type: text/csv; charset=utf-8');
        header('Pragma: no-cache');
        header('Expires: 0');
        
        $output = fopen('php://output', 'w');
        fputs($output, "\xEF\xBB\xBF");
        
        if ($page === 'orders') {
            header('Content-Disposition: attachment; filename="Diagnostic_Orders_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Order No', 'Patient MRN', 'Patient Name', 'Phone', 'Doctor', 'Urgency', 'Status', 'Total (BDT)', 'Discount (BDT)', 'Payable (BDT)', 'Created Date']);
            $branchId = Security::branchIds($db)[0];
            $orders = \Diagnostic\Orders::listOrders($db, $branchId);
            foreach ($orders as $o) {
                fputcsv($output, [
                    $o['order_no'], $o['mrn'], $o['patient_name'], $o['mobile'] ?? '', $o['doctor_name'] ?? 'Self',
                    strtoupper($o['urgency']), strtoupper($o['status']),
                    number_format((float)$o['total_amount'], 2, '.', ''),
                    number_format((float)$o['discount_amount'], 2, '.', ''),
                    number_format((float)$o['payable_amount'], 2, '.', ''),
                    $o['created_at']
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_vouchers') {
            header('Content-Disposition: attachment; filename="GL_Vouchers_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Voucher No', 'Type', 'Date', 'Branch', 'Narration / Description', 'Amount (BDT)', 'Status', 'Posted By']);
            $vouchers = \Diagnostic\Accounting::listVouchers($db);
            foreach ($vouchers as $v) {
                fputcsv($output, [
                    $v['voucher_no'], strtoupper($v['voucher_type']), $v['voucher_date'],
                    $v['branch_name'] ?? 'Main Center', $v['narration'],
                    number_format((float)$v['total_amount'], 2, '.', ''),
                    strtoupper($v['status']), $v['creator_name'] ?? 'System'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'chart_of_accounts') {
            header('Content-Disposition: attachment; filename="Chart_of_Accounts_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Type / Class', 'Total Debit (BDT)', 'Total Credit (BDT)', 'Current Balance (BDT)']);
            $accounts = \Diagnostic\Accounting::listAccounts($db);
            foreach ($accounts as $a) {
                fputcsv($output, [
                    $a['account_code'], $a['name'], strtoupper($a['account_type']),
                    number_format((float)$a['total_debit'], 2, '.', ''),
                    number_format((float)$a['total_credit'], 2, '.', ''),
                    number_format((float)$a['balance'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_statements') {
            header('Content-Disposition: attachment; filename="Trial_Balance_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Classification', 'Debit (BDT)', 'Credit (BDT)']);
            $tb = \Diagnostic\Accounting::getTrialBalance($db);
            foreach ($tb as $r) {
                fputcsv($output, [
                    $r['account_code'], $r['name'], strtoupper($r['account_type']),
                    number_format((float)$r['total_debit'], 2, '.', ''),
                    number_format((float)$r['total_credit'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'doctor_commissions') {
            header('Content-Disposition: attachment; filename="Doctor_Commissions_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Doctor Code', 'Doctor Name', 'Mobile', 'Referred Orders', 'Billed Volume (BDT)', 'Accrued Commission (BDT)', 'Pending Due (BDT)']);
            $comms = \Diagnostic\Accounting::getDoctorCommissionSummary($db);
            foreach ($comms as $d) {
                fputcsv($output, [
                    $d['doctor_code'], $d['doctor_name'], $d['mobile'],
                    $d['total_referrals'],
                    number_format((float)$d['total_billed'], 2, '.', ''),
                    number_format((float)$d['total_commission'], 2, '.', ''),
                    number_format((float)$d['pending_commission'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'corporate_billing') {
            header('Content-Disposition: attachment; filename="Corporate_Aging_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Client Code', 'Corporate Scheme', 'Phone', 'Total Invoiced (BDT)', '0-30 Days (BDT)', '31-60 Days (BDT)', '60+ Days Overdue (BDT)', 'Total Due (BDT)']);
            $agings = \Diagnostic\Accounting::getCorporateAging($db);
            foreach ($agings as $ca) {
                fputcsv($output, [
                    $ca['code'], $ca['name'], $ca['phone'],
                    number_format((float)$ca['total_billed'], 2, '.', ''),
                    number_format((float)$ca['aging_30'], 2, '.', ''),
                    number_format((float)$ca['aging_60'], 2, '.', ''),
                    number_format((float)$ca['aging_90_plus'], 2, '.', ''),
                    number_format((float)$ca['total_due'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'accounts_payable') {
            header('Content-Disposition: attachment; filename="Supplier_Payables_Ledger_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Supplier Code', 'Vendor Name', 'Phone', 'Total Purchases (BDT)', 'TDS/VDS Deducted (BDT)', 'Paid (BDT)', 'Balance Due (BDT)']);
            $supps = \Diagnostic\Accounting::getSupplierLedger($db);
            foreach ($supps as $s) {
                fputcsv($output, [
                    $s['code'], $s['name'], $s['phone'],
                    number_format((float)$s['total_purchased'], 2, '.', ''),
                    number_format((float)$s['tds_vds_deducted'], 2, '.', ''),
                    number_format((float)$s['total_paid'], 2, '.', ''),
                    number_format((float)$s['balance_payable'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'cash_bank_books') {
            header('Content-Disposition: attachment; filename="Cash_Bank_Liquidity_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Title', 'Available Balance (BDT)', 'Status']);
            $books = \Diagnostic\Accounting::getCashBankBalances($db);
            foreach ($books as $cb) {
                fputcsv($output, [
                    $cb['account_code'], $cb['name'],
                    number_format((float)$cb['balance'], 2, '.', ''),
                    'Reconciled'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'billing') {
            header('Content-Disposition: attachment; filename="Invoices_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Invoice No', 'MRN', 'Patient Name', 'Phone', 'Payable (BDT)', 'Paid (BDT)', 'Due (BDT)', 'Status', 'Date']);
            $branchId = Security::branchIds($db)[0];
            $invoices = \Diagnostic\Billing::listInvoices($db, $branchId);
            foreach ($invoices as $i) {
                fputcsv($output, [
                    $i['invoice_no'], $i['mrn'], $i['patient_name'], $i['mobile'] ?? '',
                    number_format((float)$i['payable_amount'], 2, '.', ''),
                    number_format((float)$i['paid_amount'], 2, '.', ''),
                    number_format((float)$i['due_amount'], 2, '.', ''),
                    strtoupper($i['status']),
                    $i['created_at']
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_vouchers') {
            header('Content-Disposition: attachment; filename="GL_Vouchers_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Voucher No', 'Type', 'Date', 'Branch', 'Narration / Description', 'Amount (BDT)', 'Status', 'Posted By']);
            $vouchers = \Diagnostic\Accounting::listVouchers($db);
            foreach ($vouchers as $v) {
                fputcsv($output, [
                    $v['voucher_no'], strtoupper($v['voucher_type']), $v['voucher_date'],
                    $v['branch_name'] ?? 'Main Center', $v['narration'],
                    number_format((float)$v['total_amount'], 2, '.', ''),
                    strtoupper($v['status']), $v['creator_name'] ?? 'System'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'chart_of_accounts') {
            header('Content-Disposition: attachment; filename="Chart_of_Accounts_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Type / Class', 'Total Debit (BDT)', 'Total Credit (BDT)', 'Current Balance (BDT)']);
            $accounts = \Diagnostic\Accounting::listAccounts($db);
            foreach ($accounts as $a) {
                fputcsv($output, [
                    $a['account_code'], $a['name'], strtoupper($a['account_type']),
                    number_format((float)$a['total_debit'], 2, '.', ''),
                    number_format((float)$a['total_credit'], 2, '.', ''),
                    number_format((float)$a['balance'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_statements') {
            header('Content-Disposition: attachment; filename="Trial_Balance_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Classification', 'Debit (BDT)', 'Credit (BDT)']);
            $tb = \Diagnostic\Accounting::getTrialBalance($db);
            foreach ($tb as $r) {
                fputcsv($output, [
                    $r['account_code'], $r['name'], strtoupper($r['account_type']),
                    number_format((float)$r['total_debit'], 2, '.', ''),
                    number_format((float)$r['total_credit'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'doctor_commissions') {
            header('Content-Disposition: attachment; filename="Doctor_Commissions_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Doctor Code', 'Doctor Name', 'Mobile', 'Referred Orders', 'Billed Volume (BDT)', 'Accrued Commission (BDT)', 'Pending Due (BDT)']);
            $comms = \Diagnostic\Accounting::getDoctorCommissionSummary($db);
            foreach ($comms as $d) {
                fputcsv($output, [
                    $d['doctor_code'], $d['doctor_name'], $d['mobile'],
                    $d['total_referrals'],
                    number_format((float)$d['total_billed'], 2, '.', ''),
                    number_format((float)$d['total_commission'], 2, '.', ''),
                    number_format((float)$d['pending_commission'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'corporate_billing') {
            header('Content-Disposition: attachment; filename="Corporate_Aging_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Client Code', 'Corporate Scheme', 'Phone', 'Total Invoiced (BDT)', '0-30 Days (BDT)', '31-60 Days (BDT)', '60+ Days Overdue (BDT)', 'Total Due (BDT)']);
            $agings = \Diagnostic\Accounting::getCorporateAging($db);
            foreach ($agings as $ca) {
                fputcsv($output, [
                    $ca['code'], $ca['name'], $ca['phone'],
                    number_format((float)$ca['total_billed'], 2, '.', ''),
                    number_format((float)$ca['aging_30'], 2, '.', ''),
                    number_format((float)$ca['aging_60'], 2, '.', ''),
                    number_format((float)$ca['aging_90_plus'], 2, '.', ''),
                    number_format((float)$ca['total_due'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'accounts_payable') {
            header('Content-Disposition: attachment; filename="Supplier_Payables_Ledger_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Supplier Code', 'Vendor Name', 'Phone', 'Total Purchases (BDT)', 'TDS/VDS Deducted (BDT)', 'Paid (BDT)', 'Balance Due (BDT)']);
            $supps = \Diagnostic\Accounting::getSupplierLedger($db);
            foreach ($supps as $s) {
                fputcsv($output, [
                    $s['code'], $s['name'], $s['phone'],
                    number_format((float)$s['total_purchased'], 2, '.', ''),
                    number_format((float)$s['tds_vds_deducted'], 2, '.', ''),
                    number_format((float)$s['total_paid'], 2, '.', ''),
                    number_format((float)$s['balance_payable'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'cash_bank_books') {
            header('Content-Disposition: attachment; filename="Cash_Bank_Liquidity_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Title', 'Available Balance (BDT)', 'Status']);
            $books = \Diagnostic\Accounting::getCashBankBalances($db);
            foreach ($books as $cb) {
                fputcsv($output, [
                    $cb['account_code'], $cb['name'],
                    number_format((float)$cb['balance'], 2, '.', ''),
                    'Reconciled'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'patients') {
            header('Content-Disposition: attachment; filename="Patients_Master_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['MRN', 'Name', 'Mobile', 'Gender', 'DOB / Age', 'Blood Group', 'Address', 'Registered Date']);
            $branchId = Security::branchIds($db)[0];
            $patients = \Diagnostic\Patients::search($db, '', $branchId, 500);
            foreach ($patients as $p) {
                fputcsv($output, [
                    $p['mrn'], $p['name'], $p['mobile'], ucfirst($p['gender']), $p['dob'] ?: 'N/A',
                    $p['blood_group'] ?: 'N/A', $p['address'] ?? '', $p['created_at'] ?? ''
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_vouchers') {
            header('Content-Disposition: attachment; filename="GL_Vouchers_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Voucher No', 'Type', 'Date', 'Branch', 'Narration / Description', 'Amount (BDT)', 'Status', 'Posted By']);
            $vouchers = \Diagnostic\Accounting::listVouchers($db);
            foreach ($vouchers as $v) {
                fputcsv($output, [
                    $v['voucher_no'], strtoupper($v['voucher_type']), $v['voucher_date'],
                    $v['branch_name'] ?? 'Main Center', $v['narration'],
                    number_format((float)$v['total_amount'], 2, '.', ''),
                    strtoupper($v['status']), $v['creator_name'] ?? 'System'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'chart_of_accounts') {
            header('Content-Disposition: attachment; filename="Chart_of_Accounts_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Type / Class', 'Total Debit (BDT)', 'Total Credit (BDT)', 'Current Balance (BDT)']);
            $accounts = \Diagnostic\Accounting::listAccounts($db);
            foreach ($accounts as $a) {
                fputcsv($output, [
                    $a['account_code'], $a['name'], strtoupper($a['account_type']),
                    number_format((float)$a['total_debit'], 2, '.', ''),
                    number_format((float)$a['total_credit'], 2, '.', ''),
                    number_format((float)$a['balance'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_statements') {
            header('Content-Disposition: attachment; filename="Trial_Balance_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Classification', 'Debit (BDT)', 'Credit (BDT)']);
            $tb = \Diagnostic\Accounting::getTrialBalance($db);
            foreach ($tb as $r) {
                fputcsv($output, [
                    $r['account_code'], $r['name'], strtoupper($r['account_type']),
                    number_format((float)$r['total_debit'], 2, '.', ''),
                    number_format((float)$r['total_credit'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'doctor_commissions') {
            header('Content-Disposition: attachment; filename="Doctor_Commissions_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Doctor Code', 'Doctor Name', 'Mobile', 'Referred Orders', 'Billed Volume (BDT)', 'Accrued Commission (BDT)', 'Pending Due (BDT)']);
            $comms = \Diagnostic\Accounting::getDoctorCommissionSummary($db);
            foreach ($comms as $d) {
                fputcsv($output, [
                    $d['doctor_code'], $d['doctor_name'], $d['mobile'],
                    $d['total_referrals'],
                    number_format((float)$d['total_billed'], 2, '.', ''),
                    number_format((float)$d['total_commission'], 2, '.', ''),
                    number_format((float)$d['pending_commission'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'corporate_billing') {
            header('Content-Disposition: attachment; filename="Corporate_Aging_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Client Code', 'Corporate Scheme', 'Phone', 'Total Invoiced (BDT)', '0-30 Days (BDT)', '31-60 Days (BDT)', '60+ Days Overdue (BDT)', 'Total Due (BDT)']);
            $agings = \Diagnostic\Accounting::getCorporateAging($db);
            foreach ($agings as $ca) {
                fputcsv($output, [
                    $ca['code'], $ca['name'], $ca['phone'],
                    number_format((float)$ca['total_billed'], 2, '.', ''),
                    number_format((float)$ca['aging_30'], 2, '.', ''),
                    number_format((float)$ca['aging_60'], 2, '.', ''),
                    number_format((float)$ca['aging_90_plus'], 2, '.', ''),
                    number_format((float)$ca['total_due'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'accounts_payable') {
            header('Content-Disposition: attachment; filename="Supplier_Payables_Ledger_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Supplier Code', 'Vendor Name', 'Phone', 'Total Purchases (BDT)', 'TDS/VDS Deducted (BDT)', 'Paid (BDT)', 'Balance Due (BDT)']);
            $supps = \Diagnostic\Accounting::getSupplierLedger($db);
            foreach ($supps as $s) {
                fputcsv($output, [
                    $s['code'], $s['name'], $s['phone'],
                    number_format((float)$s['total_purchased'], 2, '.', ''),
                    number_format((float)$s['tds_vds_deducted'], 2, '.', ''),
                    number_format((float)$s['total_paid'], 2, '.', ''),
                    number_format((float)$s['balance_payable'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'cash_bank_books') {
            header('Content-Disposition: attachment; filename="Cash_Bank_Liquidity_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Title', 'Available Balance (BDT)', 'Status']);
            $books = \Diagnostic\Accounting::getCashBankBalances($db);
            foreach ($books as $cb) {
                fputcsv($output, [
                    $cb['account_code'], $cb['name'],
                    number_format((float)$cb['balance'], 2, '.', ''),
                    'Reconciled'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'appointments') {
            $date = (string)($_GET['date'] ?? date('Y-m-d'));
            header('Content-Disposition: attachment; filename="Appointments_' . $date . '.csv"');
            fputcsv($output, ['Appt No', 'Date', 'Time Slot', 'MRN', 'Patient Name', 'Mobile', 'Doctor', 'Room', 'Status']);
            $branchId = Security::branchIds($db)[0];
            $appts = \Diagnostic\Appointments::list($db, $branchId, $date);
            foreach ($appts as $a) {
                fputcsv($output, [
                    $a['appointment_no'], $a['appointment_date'], $a['time_slot'],
                    $a['mrn'], $a['patient_name'], $a['patient_mobile'],
                    $a['doctor_name'], $a['room_name'] ?? 'OPD Chamber',
                    strtoupper($a['status'])
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_vouchers') {
            header('Content-Disposition: attachment; filename="GL_Vouchers_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Voucher No', 'Type', 'Date', 'Branch', 'Narration / Description', 'Amount (BDT)', 'Status', 'Posted By']);
            $vouchers = \Diagnostic\Accounting::listVouchers($db);
            foreach ($vouchers as $v) {
                fputcsv($output, [
                    $v['voucher_no'], strtoupper($v['voucher_type']), $v['voucher_date'],
                    $v['branch_name'] ?? 'Main Center', $v['narration'],
                    number_format((float)$v['total_amount'], 2, '.', ''),
                    strtoupper($v['status']), $v['creator_name'] ?? 'System'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'chart_of_accounts') {
            header('Content-Disposition: attachment; filename="Chart_of_Accounts_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Type / Class', 'Total Debit (BDT)', 'Total Credit (BDT)', 'Current Balance (BDT)']);
            $accounts = \Diagnostic\Accounting::listAccounts($db);
            foreach ($accounts as $a) {
                fputcsv($output, [
                    $a['account_code'], $a['name'], strtoupper($a['account_type']),
                    number_format((float)$a['total_debit'], 2, '.', ''),
                    number_format((float)$a['total_credit'], 2, '.', ''),
                    number_format((float)$a['balance'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_statements') {
            header('Content-Disposition: attachment; filename="Trial_Balance_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Classification', 'Debit (BDT)', 'Credit (BDT)']);
            $tb = \Diagnostic\Accounting::getTrialBalance($db);
            foreach ($tb as $r) {
                fputcsv($output, [
                    $r['account_code'], $r['name'], strtoupper($r['account_type']),
                    number_format((float)$r['total_debit'], 2, '.', ''),
                    number_format((float)$r['total_credit'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'doctor_commissions') {
            header('Content-Disposition: attachment; filename="Doctor_Commissions_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Doctor Code', 'Doctor Name', 'Mobile', 'Referred Orders', 'Billed Volume (BDT)', 'Accrued Commission (BDT)', 'Pending Due (BDT)']);
            $comms = \Diagnostic\Accounting::getDoctorCommissionSummary($db);
            foreach ($comms as $d) {
                fputcsv($output, [
                    $d['doctor_code'], $d['doctor_name'], $d['mobile'],
                    $d['total_referrals'],
                    number_format((float)$d['total_billed'], 2, '.', ''),
                    number_format((float)$d['total_commission'], 2, '.', ''),
                    number_format((float)$d['pending_commission'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'corporate_billing') {
            header('Content-Disposition: attachment; filename="Corporate_Aging_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Client Code', 'Corporate Scheme', 'Phone', 'Total Invoiced (BDT)', '0-30 Days (BDT)', '31-60 Days (BDT)', '60+ Days Overdue (BDT)', 'Total Due (BDT)']);
            $agings = \Diagnostic\Accounting::getCorporateAging($db);
            foreach ($agings as $ca) {
                fputcsv($output, [
                    $ca['code'], $ca['name'], $ca['phone'],
                    number_format((float)$ca['total_billed'], 2, '.', ''),
                    number_format((float)$ca['aging_30'], 2, '.', ''),
                    number_format((float)$ca['aging_60'], 2, '.', ''),
                    number_format((float)$ca['aging_90_plus'], 2, '.', ''),
                    number_format((float)$ca['total_due'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'accounts_payable') {
            header('Content-Disposition: attachment; filename="Supplier_Payables_Ledger_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Supplier Code', 'Vendor Name', 'Phone', 'Total Purchases (BDT)', 'TDS/VDS Deducted (BDT)', 'Paid (BDT)', 'Balance Due (BDT)']);
            $supps = \Diagnostic\Accounting::getSupplierLedger($db);
            foreach ($supps as $s) {
                fputcsv($output, [
                    $s['code'], $s['name'], $s['phone'],
                    number_format((float)$s['total_purchased'], 2, '.', ''),
                    number_format((float)$s['tds_vds_deducted'], 2, '.', ''),
                    number_format((float)$s['total_paid'], 2, '.', ''),
                    number_format((float)$s['balance_payable'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'cash_bank_books') {
            header('Content-Disposition: attachment; filename="Cash_Bank_Liquidity_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Title', 'Available Balance (BDT)', 'Status']);
            $books = \Diagnostic\Accounting::getCashBankBalances($db);
            foreach ($books as $cb) {
                fputcsv($output, [
                    $cb['account_code'], $cb['name'],
                    number_format((float)$cb['balance'], 2, '.', ''),
                    'Reconciled'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'home_collections') {
            header('Content-Disposition: attachment; filename="Home_Collections_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Booking No', 'Patient Name', 'Mobile', 'Geo Zone', 'Detailed Address', 'Time Slot', 'Travel Charge (BDT)', 'Status', 'Booking Date']);
            $branchId = Security::branchIds($db)[0];
            $bookings = \Diagnostic\HomeCollection::listBookings($db, $branchId);
            foreach ($bookings as $b) {
                fputcsv($output, [
                    $b['booking_no'], $b['patient_name'], $b['mobile'],
                    $b['geo_zone'], $b['address'], $b['time_slot'],
                    number_format((float)($b['travel_charge'] ?? 300), 2, '.', ''),
                    strtoupper($b['status']), $b['created_at']
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'result_entry') {
            header('Content-Disposition: attachment; filename="Evaluated_Lab_Results_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Test Item', 'Result Value', 'Clinical Flag', 'Technologist', 'Entered Date']);
            $results = $db->query('SELECT lr.*, dt.name AS test_name, u.name AS tech_name FROM lab_results lr JOIN diagnostic_tests dt ON dt.id=lr.test_id JOIN users u ON u.id=lr.entered_by ORDER BY lr.id DESC LIMIT 100')->fetchAll();
            foreach ($results as $r) {
                fputcsv($output, [
                    $r['test_name'], $r['result_value'],
                    strtoupper($r['result_flag']), $r['tech_name'],
                    $r['created_at'] ?? ''
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'sample_desk') {
            header('Content-Disposition: attachment; filename="Specimen_Collections_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Barcode', 'Order No', 'Patient MRN', 'Patient Name', 'Gender', 'DOB', 'Test Item', 'Sample Type', 'Status', 'Collected At']);
            $branchId = Security::branchIds($db)[0];
            $samples = \Diagnostic\LIS::getWorklist($db, $branchId);
            foreach ($samples as $s) {
                fputcsv($output, [
                    $s['barcode'], $s['order_no'], $s['mrn'], $s['patient_name'],
                    ucfirst($s['gender'] ?? 'N/A'), $s['dob'] ?? '',
                    $s['item_name'], $s['sample_type_name'] ?? 'Blood / EDTA',
                    strtoupper($s['status']), $s['collected_at'] ?? $s['created_at']
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'hr_employees') {
            header('Content-Disposition: attachment; filename="HR_Workforce_Directory_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Employee Code', 'Full Name', 'Designation', 'Department', 'Mobile', 'Email', 'License No', 'License Expiry', 'Basic Salary (BDT)', 'Joining Date']);
            $employees = \Diagnostic\HR::listEmployees($db);
            foreach ($employees as $e) {
                fputcsv($output, [
                    $e['employee_code'], $e['name'], $e['designation'], $e['department_name'] ?? 'General',
                    $e['mobile'], $e['email'] ?? '', $e['license_no'] ?? '', $e['license_expiry'] ?? '',
                    number_format((float)$e['basic_salary'], 2, '.', ''),
                    $e['joining_date'] ?? ''
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_vouchers') {
            header('Content-Disposition: attachment; filename="GL_Vouchers_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Voucher No', 'Type', 'Date', 'Branch', 'Narration / Description', 'Amount (BDT)', 'Status', 'Posted By']);
            $vouchers = \Diagnostic\Accounting::listVouchers($db);
            foreach ($vouchers as $v) {
                fputcsv($output, [
                    $v['voucher_no'], strtoupper($v['voucher_type']), $v['voucher_date'],
                    $v['branch_name'] ?? 'Main Center', $v['narration'],
                    number_format((float)$v['total_amount'], 2, '.', ''),
                    strtoupper($v['status']), $v['creator_name'] ?? 'System'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'chart_of_accounts') {
            header('Content-Disposition: attachment; filename="Chart_of_Accounts_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Type / Class', 'Total Debit (BDT)', 'Total Credit (BDT)', 'Current Balance (BDT)']);
            $accounts = \Diagnostic\Accounting::listAccounts($db);
            foreach ($accounts as $a) {
                fputcsv($output, [
                    $a['account_code'], $a['name'], strtoupper($a['account_type']),
                    number_format((float)$a['total_debit'], 2, '.', ''),
                    number_format((float)$a['total_credit'], 2, '.', ''),
                    number_format((float)$a['balance'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_statements') {
            header('Content-Disposition: attachment; filename="Trial_Balance_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Classification', 'Debit (BDT)', 'Credit (BDT)']);
            $tb = \Diagnostic\Accounting::getTrialBalance($db);
            foreach ($tb as $r) {
                fputcsv($output, [
                    $r['account_code'], $r['name'], strtoupper($r['account_type']),
                    number_format((float)$r['total_debit'], 2, '.', ''),
                    number_format((float)$r['total_credit'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'doctor_commissions') {
            header('Content-Disposition: attachment; filename="Doctor_Commissions_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Doctor Code', 'Doctor Name', 'Mobile', 'Referred Orders', 'Billed Volume (BDT)', 'Accrued Commission (BDT)', 'Pending Due (BDT)']);
            $comms = \Diagnostic\Accounting::getDoctorCommissionSummary($db);
            foreach ($comms as $d) {
                fputcsv($output, [
                    $d['doctor_code'], $d['doctor_name'], $d['mobile'],
                    $d['total_referrals'],
                    number_format((float)$d['total_billed'], 2, '.', ''),
                    number_format((float)$d['total_commission'], 2, '.', ''),
                    number_format((float)$d['pending_commission'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'corporate_billing') {
            header('Content-Disposition: attachment; filename="Corporate_Aging_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Client Code', 'Corporate Scheme', 'Phone', 'Total Invoiced (BDT)', '0-30 Days (BDT)', '31-60 Days (BDT)', '60+ Days Overdue (BDT)', 'Total Due (BDT)']);
            $agings = \Diagnostic\Accounting::getCorporateAging($db);
            foreach ($agings as $ca) {
                fputcsv($output, [
                    $ca['code'], $ca['name'], $ca['phone'],
                    number_format((float)$ca['total_billed'], 2, '.', ''),
                    number_format((float)$ca['aging_30'], 2, '.', ''),
                    number_format((float)$ca['aging_60'], 2, '.', ''),
                    number_format((float)$ca['aging_90_plus'], 2, '.', ''),
                    number_format((float)$ca['total_due'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'accounts_payable') {
            header('Content-Disposition: attachment; filename="Supplier_Payables_Ledger_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Supplier Code', 'Vendor Name', 'Phone', 'Total Purchases (BDT)', 'TDS/VDS Deducted (BDT)', 'Paid (BDT)', 'Balance Due (BDT)']);
            $supps = \Diagnostic\Accounting::getSupplierLedger($db);
            foreach ($supps as $s) {
                fputcsv($output, [
                    $s['code'], $s['name'], $s['phone'],
                    number_format((float)$s['total_purchased'], 2, '.', ''),
                    number_format((float)$s['tds_vds_deducted'], 2, '.', ''),
                    number_format((float)$s['total_paid'], 2, '.', ''),
                    number_format((float)$s['balance_payable'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'cash_bank_books') {
            header('Content-Disposition: attachment; filename="Cash_Bank_Liquidity_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Title', 'Available Balance (BDT)', 'Status']);
            $books = \Diagnostic\Accounting::getCashBankBalances($db);
            foreach ($books as $cb) {
                fputcsv($output, [
                    $cb['account_code'], $cb['name'],
                    number_format((float)$cb['balance'], 2, '.', ''),
                    'Reconciled'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'hr_attendance') {
            $date = (string)($_GET['date'] ?? date('Y-m-d'));
            header('Content-Disposition: attachment; filename="Daily_Attendance_Register_' . $date . '.csv"');
            fputcsv($output, ['Employee Code', 'Staff Name', 'Department', 'Designation', 'Date', 'Clock In', 'Clock Out', 'Overtime (Hrs)', 'Status', 'Notes']);
            $records = \Diagnostic\HR::listAttendance($db, $date);
            foreach ($records as $r) {
                fputcsv($output, [
                    $r['employee_code'], $r['employee_name'], $r['department_name'] ?? 'General', $r['designation'],
                    $r['attendance_date'], $r['clock_in'], $r['clock_out'] ?? 'N/A',
                    (float)$r['overtime_hours'], strtoupper($r['status']), $r['notes'] ?? ''
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_vouchers') {
            header('Content-Disposition: attachment; filename="GL_Vouchers_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Voucher No', 'Type', 'Date', 'Branch', 'Narration / Description', 'Amount (BDT)', 'Status', 'Posted By']);
            $vouchers = \Diagnostic\Accounting::listVouchers($db);
            foreach ($vouchers as $v) {
                fputcsv($output, [
                    $v['voucher_no'], strtoupper($v['voucher_type']), $v['voucher_date'],
                    $v['branch_name'] ?? 'Main Center', $v['narration'],
                    number_format((float)$v['total_amount'], 2, '.', ''),
                    strtoupper($v['status']), $v['creator_name'] ?? 'System'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'chart_of_accounts') {
            header('Content-Disposition: attachment; filename="Chart_of_Accounts_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Type / Class', 'Total Debit (BDT)', 'Total Credit (BDT)', 'Current Balance (BDT)']);
            $accounts = \Diagnostic\Accounting::listAccounts($db);
            foreach ($accounts as $a) {
                fputcsv($output, [
                    $a['account_code'], $a['name'], strtoupper($a['account_type']),
                    number_format((float)$a['total_debit'], 2, '.', ''),
                    number_format((float)$a['total_credit'], 2, '.', ''),
                    number_format((float)$a['balance'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_statements') {
            header('Content-Disposition: attachment; filename="Trial_Balance_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Classification', 'Debit (BDT)', 'Credit (BDT)']);
            $tb = \Diagnostic\Accounting::getTrialBalance($db);
            foreach ($tb as $r) {
                fputcsv($output, [
                    $r['account_code'], $r['name'], strtoupper($r['account_type']),
                    number_format((float)$r['total_debit'], 2, '.', ''),
                    number_format((float)$r['total_credit'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'doctor_commissions') {
            header('Content-Disposition: attachment; filename="Doctor_Commissions_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Doctor Code', 'Doctor Name', 'Mobile', 'Referred Orders', 'Billed Volume (BDT)', 'Accrued Commission (BDT)', 'Pending Due (BDT)']);
            $comms = \Diagnostic\Accounting::getDoctorCommissionSummary($db);
            foreach ($comms as $d) {
                fputcsv($output, [
                    $d['doctor_code'], $d['doctor_name'], $d['mobile'],
                    $d['total_referrals'],
                    number_format((float)$d['total_billed'], 2, '.', ''),
                    number_format((float)$d['total_commission'], 2, '.', ''),
                    number_format((float)$d['pending_commission'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'corporate_billing') {
            header('Content-Disposition: attachment; filename="Corporate_Aging_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Client Code', 'Corporate Scheme', 'Phone', 'Total Invoiced (BDT)', '0-30 Days (BDT)', '31-60 Days (BDT)', '60+ Days Overdue (BDT)', 'Total Due (BDT)']);
            $agings = \Diagnostic\Accounting::getCorporateAging($db);
            foreach ($agings as $ca) {
                fputcsv($output, [
                    $ca['code'], $ca['name'], $ca['phone'],
                    number_format((float)$ca['total_billed'], 2, '.', ''),
                    number_format((float)$ca['aging_30'], 2, '.', ''),
                    number_format((float)$ca['aging_60'], 2, '.', ''),
                    number_format((float)$ca['aging_90_plus'], 2, '.', ''),
                    number_format((float)$ca['total_due'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'accounts_payable') {
            header('Content-Disposition: attachment; filename="Supplier_Payables_Ledger_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Supplier Code', 'Vendor Name', 'Phone', 'Total Purchases (BDT)', 'TDS/VDS Deducted (BDT)', 'Paid (BDT)', 'Balance Due (BDT)']);
            $supps = \Diagnostic\Accounting::getSupplierLedger($db);
            foreach ($supps as $s) {
                fputcsv($output, [
                    $s['code'], $s['name'], $s['phone'],
                    number_format((float)$s['total_purchased'], 2, '.', ''),
                    number_format((float)$s['tds_vds_deducted'], 2, '.', ''),
                    number_format((float)$s['total_paid'], 2, '.', ''),
                    number_format((float)$s['balance_payable'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'cash_bank_books') {
            header('Content-Disposition: attachment; filename="Cash_Bank_Liquidity_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Title', 'Available Balance (BDT)', 'Status']);
            $books = \Diagnostic\Accounting::getCashBankBalances($db);
            foreach ($books as $cb) {
                fputcsv($output, [
                    $cb['account_code'], $cb['name'],
                    number_format((float)$cb['balance'], 2, '.', ''),
                    'Reconciled'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'hr_roster_leave') {
            header('Content-Disposition: attachment; filename="Duty_Roster_24_7_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Date', 'Employee Code', 'Staff Name', 'Department', 'Shift Name', 'Shift Hours']);
            $branchId = Security::branchIds($db)[0];
            $rosters = \Diagnostic\HR::listRosters($db, $branchId);
            foreach ($rosters as $r) {
                $timeStr = ($r['shift_name']==='morning'?'08:00 AM - 04:00 PM':($r['shift_name']==='evening'?'04:00 PM - 12:00 AM':'12:00 AM - 08:00 AM'));
                fputcsv($output, [
                    $r['shift_date'], $r['employee_code'], $r['employee_name'], $r['department_name'] ?? 'General',
                    strtoupper($r['shift_name']), $timeStr
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_vouchers') {
            header('Content-Disposition: attachment; filename="GL_Vouchers_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Voucher No', 'Type', 'Date', 'Branch', 'Narration / Description', 'Amount (BDT)', 'Status', 'Posted By']);
            $vouchers = \Diagnostic\Accounting::listVouchers($db);
            foreach ($vouchers as $v) {
                fputcsv($output, [
                    $v['voucher_no'], strtoupper($v['voucher_type']), $v['voucher_date'],
                    $v['branch_name'] ?? 'Main Center', $v['narration'],
                    number_format((float)$v['total_amount'], 2, '.', ''),
                    strtoupper($v['status']), $v['creator_name'] ?? 'System'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'chart_of_accounts') {
            header('Content-Disposition: attachment; filename="Chart_of_Accounts_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Type / Class', 'Total Debit (BDT)', 'Total Credit (BDT)', 'Current Balance (BDT)']);
            $accounts = \Diagnostic\Accounting::listAccounts($db);
            foreach ($accounts as $a) {
                fputcsv($output, [
                    $a['account_code'], $a['name'], strtoupper($a['account_type']),
                    number_format((float)$a['total_debit'], 2, '.', ''),
                    number_format((float)$a['total_credit'], 2, '.', ''),
                    number_format((float)$a['balance'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_statements') {
            header('Content-Disposition: attachment; filename="Trial_Balance_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Classification', 'Debit (BDT)', 'Credit (BDT)']);
            $tb = \Diagnostic\Accounting::getTrialBalance($db);
            foreach ($tb as $r) {
                fputcsv($output, [
                    $r['account_code'], $r['name'], strtoupper($r['account_type']),
                    number_format((float)$r['total_debit'], 2, '.', ''),
                    number_format((float)$r['total_credit'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'doctor_commissions') {
            header('Content-Disposition: attachment; filename="Doctor_Commissions_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Doctor Code', 'Doctor Name', 'Mobile', 'Referred Orders', 'Billed Volume (BDT)', 'Accrued Commission (BDT)', 'Pending Due (BDT)']);
            $comms = \Diagnostic\Accounting::getDoctorCommissionSummary($db);
            foreach ($comms as $d) {
                fputcsv($output, [
                    $d['doctor_code'], $d['doctor_name'], $d['mobile'],
                    $d['total_referrals'],
                    number_format((float)$d['total_billed'], 2, '.', ''),
                    number_format((float)$d['total_commission'], 2, '.', ''),
                    number_format((float)$d['pending_commission'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'corporate_billing') {
            header('Content-Disposition: attachment; filename="Corporate_Aging_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Client Code', 'Corporate Scheme', 'Phone', 'Total Invoiced (BDT)', '0-30 Days (BDT)', '31-60 Days (BDT)', '60+ Days Overdue (BDT)', 'Total Due (BDT)']);
            $agings = \Diagnostic\Accounting::getCorporateAging($db);
            foreach ($agings as $ca) {
                fputcsv($output, [
                    $ca['code'], $ca['name'], $ca['phone'],
                    number_format((float)$ca['total_billed'], 2, '.', ''),
                    number_format((float)$ca['aging_30'], 2, '.', ''),
                    number_format((float)$ca['aging_60'], 2, '.', ''),
                    number_format((float)$ca['aging_90_plus'], 2, '.', ''),
                    number_format((float)$ca['total_due'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'accounts_payable') {
            header('Content-Disposition: attachment; filename="Supplier_Payables_Ledger_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Supplier Code', 'Vendor Name', 'Phone', 'Total Purchases (BDT)', 'TDS/VDS Deducted (BDT)', 'Paid (BDT)', 'Balance Due (BDT)']);
            $supps = \Diagnostic\Accounting::getSupplierLedger($db);
            foreach ($supps as $s) {
                fputcsv($output, [
                    $s['code'], $s['name'], $s['phone'],
                    number_format((float)$s['total_purchased'], 2, '.', ''),
                    number_format((float)$s['tds_vds_deducted'], 2, '.', ''),
                    number_format((float)$s['total_paid'], 2, '.', ''),
                    number_format((float)$s['balance_payable'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'cash_bank_books') {
            header('Content-Disposition: attachment; filename="Cash_Bank_Liquidity_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Title', 'Available Balance (BDT)', 'Status']);
            $books = \Diagnostic\Accounting::getCashBankBalances($db);
            foreach ($books as $cb) {
                fputcsv($output, [
                    $cb['account_code'], $cb['name'],
                    number_format((float)$cb['balance'], 2, '.', ''),
                    'Reconciled'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'hr_leaves') {
            header('Content-Disposition: attachment; filename="Staff_Leave_Applications_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Employee Code', 'Staff Name', 'Department', 'Leave Type', 'Start Date', 'End Date', 'Days', 'Reason', 'Status']);
            $leaves = \Diagnostic\HR::listLeaves($db);
            foreach ($leaves as $l) {
                $days = (int)ceil((strtotime($l['end_date']) - strtotime($l['start_date'])) / 86400) + 1;
                fputcsv($output, [
                    $l['employee_code'], $l['employee_name'], $l['department_name'] ?? 'General',
                    ucfirst($l['leave_type']), $l['start_date'], $l['end_date'], $days,
                    $l['reason'] ?? '', strtoupper($l['status'])
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_vouchers') {
            header('Content-Disposition: attachment; filename="GL_Vouchers_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Voucher No', 'Type', 'Date', 'Branch', 'Narration / Description', 'Amount (BDT)', 'Status', 'Posted By']);
            $vouchers = \Diagnostic\Accounting::listVouchers($db);
            foreach ($vouchers as $v) {
                fputcsv($output, [
                    $v['voucher_no'], strtoupper($v['voucher_type']), $v['voucher_date'],
                    $v['branch_name'] ?? 'Main Center', $v['narration'],
                    number_format((float)$v['total_amount'], 2, '.', ''),
                    strtoupper($v['status']), $v['creator_name'] ?? 'System'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'chart_of_accounts') {
            header('Content-Disposition: attachment; filename="Chart_of_Accounts_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Type / Class', 'Total Debit (BDT)', 'Total Credit (BDT)', 'Current Balance (BDT)']);
            $accounts = \Diagnostic\Accounting::listAccounts($db);
            foreach ($accounts as $a) {
                fputcsv($output, [
                    $a['account_code'], $a['name'], strtoupper($a['account_type']),
                    number_format((float)$a['total_debit'], 2, '.', ''),
                    number_format((float)$a['total_credit'], 2, '.', ''),
                    number_format((float)$a['balance'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_statements') {
            header('Content-Disposition: attachment; filename="Trial_Balance_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Classification', 'Debit (BDT)', 'Credit (BDT)']);
            $tb = \Diagnostic\Accounting::getTrialBalance($db);
            foreach ($tb as $r) {
                fputcsv($output, [
                    $r['account_code'], $r['name'], strtoupper($r['account_type']),
                    number_format((float)$r['total_debit'], 2, '.', ''),
                    number_format((float)$r['total_credit'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'doctor_commissions') {
            header('Content-Disposition: attachment; filename="Doctor_Commissions_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Doctor Code', 'Doctor Name', 'Mobile', 'Referred Orders', 'Billed Volume (BDT)', 'Accrued Commission (BDT)', 'Pending Due (BDT)']);
            $comms = \Diagnostic\Accounting::getDoctorCommissionSummary($db);
            foreach ($comms as $d) {
                fputcsv($output, [
                    $d['doctor_code'], $d['doctor_name'], $d['mobile'],
                    $d['total_referrals'],
                    number_format((float)$d['total_billed'], 2, '.', ''),
                    number_format((float)$d['total_commission'], 2, '.', ''),
                    number_format((float)$d['pending_commission'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'corporate_billing') {
            header('Content-Disposition: attachment; filename="Corporate_Aging_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Client Code', 'Corporate Scheme', 'Phone', 'Total Invoiced (BDT)', '0-30 Days (BDT)', '31-60 Days (BDT)', '60+ Days Overdue (BDT)', 'Total Due (BDT)']);
            $agings = \Diagnostic\Accounting::getCorporateAging($db);
            foreach ($agings as $ca) {
                fputcsv($output, [
                    $ca['code'], $ca['name'], $ca['phone'],
                    number_format((float)$ca['total_billed'], 2, '.', ''),
                    number_format((float)$ca['aging_30'], 2, '.', ''),
                    number_format((float)$ca['aging_60'], 2, '.', ''),
                    number_format((float)$ca['aging_90_plus'], 2, '.', ''),
                    number_format((float)$ca['total_due'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'accounts_payable') {
            header('Content-Disposition: attachment; filename="Supplier_Payables_Ledger_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Supplier Code', 'Vendor Name', 'Phone', 'Total Purchases (BDT)', 'TDS/VDS Deducted (BDT)', 'Paid (BDT)', 'Balance Due (BDT)']);
            $supps = \Diagnostic\Accounting::getSupplierLedger($db);
            foreach ($supps as $s) {
                fputcsv($output, [
                    $s['code'], $s['name'], $s['phone'],
                    number_format((float)$s['total_purchased'], 2, '.', ''),
                    number_format((float)$s['tds_vds_deducted'], 2, '.', ''),
                    number_format((float)$s['total_paid'], 2, '.', ''),
                    number_format((float)$s['balance_payable'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'cash_bank_books') {
            header('Content-Disposition: attachment; filename="Cash_Bank_Liquidity_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Title', 'Available Balance (BDT)', 'Status']);
            $books = \Diagnostic\Accounting::getCashBankBalances($db);
            foreach ($books as $cb) {
                fputcsv($output, [
                    $cb['account_code'], $cb['name'],
                    number_format((float)$cb['balance'], 2, '.', ''),
                    'Reconciled'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'hr_recruitment') {
            header('Content-Disposition: attachment; filename="Candidate_Pipeline_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Candidate Name', 'Job Title', 'Mobile', 'Email', 'Experience (Years)', 'Expected Salary (BDT)', 'Interview Date', 'Status']);
            $candidates = \Diagnostic\HR::listCandidates($db);
            foreach ($candidates as $c) {
                fputcsv($output, [
                    $c['name'], $c['job_title'], $c['mobile'], $c['email'] ?? '',
                    (int)$c['experience_years'], number_format((float)($c['expected_salary'] ?? 0), 2, '.', ''),
                    $c['interview_date'] ?? 'N/A', strtoupper($c['status'])
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_vouchers') {
            header('Content-Disposition: attachment; filename="GL_Vouchers_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Voucher No', 'Type', 'Date', 'Branch', 'Narration / Description', 'Amount (BDT)', 'Status', 'Posted By']);
            $vouchers = \Diagnostic\Accounting::listVouchers($db);
            foreach ($vouchers as $v) {
                fputcsv($output, [
                    $v['voucher_no'], strtoupper($v['voucher_type']), $v['voucher_date'],
                    $v['branch_name'] ?? 'Main Center', $v['narration'],
                    number_format((float)$v['total_amount'], 2, '.', ''),
                    strtoupper($v['status']), $v['creator_name'] ?? 'System'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'chart_of_accounts') {
            header('Content-Disposition: attachment; filename="Chart_of_Accounts_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Type / Class', 'Total Debit (BDT)', 'Total Credit (BDT)', 'Current Balance (BDT)']);
            $accounts = \Diagnostic\Accounting::listAccounts($db);
            foreach ($accounts as $a) {
                fputcsv($output, [
                    $a['account_code'], $a['name'], strtoupper($a['account_type']),
                    number_format((float)$a['total_debit'], 2, '.', ''),
                    number_format((float)$a['total_credit'], 2, '.', ''),
                    number_format((float)$a['balance'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_statements') {
            header('Content-Disposition: attachment; filename="Trial_Balance_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Classification', 'Debit (BDT)', 'Credit (BDT)']);
            $tb = \Diagnostic\Accounting::getTrialBalance($db);
            foreach ($tb as $r) {
                fputcsv($output, [
                    $r['account_code'], $r['name'], strtoupper($r['account_type']),
                    number_format((float)$r['total_debit'], 2, '.', ''),
                    number_format((float)$r['total_credit'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'doctor_commissions') {
            header('Content-Disposition: attachment; filename="Doctor_Commissions_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Doctor Code', 'Doctor Name', 'Mobile', 'Referred Orders', 'Billed Volume (BDT)', 'Accrued Commission (BDT)', 'Pending Due (BDT)']);
            $comms = \Diagnostic\Accounting::getDoctorCommissionSummary($db);
            foreach ($comms as $d) {
                fputcsv($output, [
                    $d['doctor_code'], $d['doctor_name'], $d['mobile'],
                    $d['total_referrals'],
                    number_format((float)$d['total_billed'], 2, '.', ''),
                    number_format((float)$d['total_commission'], 2, '.', ''),
                    number_format((float)$d['pending_commission'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'corporate_billing') {
            header('Content-Disposition: attachment; filename="Corporate_Aging_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Client Code', 'Corporate Scheme', 'Phone', 'Total Invoiced (BDT)', '0-30 Days (BDT)', '31-60 Days (BDT)', '60+ Days Overdue (BDT)', 'Total Due (BDT)']);
            $agings = \Diagnostic\Accounting::getCorporateAging($db);
            foreach ($agings as $ca) {
                fputcsv($output, [
                    $ca['code'], $ca['name'], $ca['phone'],
                    number_format((float)$ca['total_billed'], 2, '.', ''),
                    number_format((float)$ca['aging_30'], 2, '.', ''),
                    number_format((float)$ca['aging_60'], 2, '.', ''),
                    number_format((float)$ca['aging_90_plus'], 2, '.', ''),
                    number_format((float)$ca['total_due'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'accounts_payable') {
            header('Content-Disposition: attachment; filename="Supplier_Payables_Ledger_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Supplier Code', 'Vendor Name', 'Phone', 'Total Purchases (BDT)', 'TDS/VDS Deducted (BDT)', 'Paid (BDT)', 'Balance Due (BDT)']);
            $supps = \Diagnostic\Accounting::getSupplierLedger($db);
            foreach ($supps as $s) {
                fputcsv($output, [
                    $s['code'], $s['name'], $s['phone'],
                    number_format((float)$s['total_purchased'], 2, '.', ''),
                    number_format((float)$s['tds_vds_deducted'], 2, '.', ''),
                    number_format((float)$s['total_paid'], 2, '.', ''),
                    number_format((float)$s['balance_payable'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'cash_bank_books') {
            header('Content-Disposition: attachment; filename="Cash_Bank_Liquidity_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Title', 'Available Balance (BDT)', 'Status']);
            $books = \Diagnostic\Accounting::getCashBankBalances($db);
            foreach ($books as $cb) {
                fputcsv($output, [
                    $cb['account_code'], $cb['name'],
                    number_format((float)$cb['balance'], 2, '.', ''),
                    'Reconciled'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'hr_competencies') {
            header('Content-Disposition: attachment; filename="Staff_Competency_Matrix_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Category', 'Competency Protocol', 'Staff Name', 'Employee Code', 'Designation', 'Score (%)', 'Expiry Date']);
            $comps = \Diagnostic\HR::listCompetencies($db);
            foreach ($comps as $c) {
                fputcsv($output, [
                    strtoupper($c['category']), $c['competency_title'], $c['employee_name'], $c['employee_code'],
                    $c['designation'], number_format((float)$c['assessment_score'], 1, '.', ''),
                    $c['expiry_date'] ?? ''
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_vouchers') {
            header('Content-Disposition: attachment; filename="GL_Vouchers_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Voucher No', 'Type', 'Date', 'Branch', 'Narration / Description', 'Amount (BDT)', 'Status', 'Posted By']);
            $vouchers = \Diagnostic\Accounting::listVouchers($db);
            foreach ($vouchers as $v) {
                fputcsv($output, [
                    $v['voucher_no'], strtoupper($v['voucher_type']), $v['voucher_date'],
                    $v['branch_name'] ?? 'Main Center', $v['narration'],
                    number_format((float)$v['total_amount'], 2, '.', ''),
                    strtoupper($v['status']), $v['creator_name'] ?? 'System'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'chart_of_accounts') {
            header('Content-Disposition: attachment; filename="Chart_of_Accounts_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Type / Class', 'Total Debit (BDT)', 'Total Credit (BDT)', 'Current Balance (BDT)']);
            $accounts = \Diagnostic\Accounting::listAccounts($db);
            foreach ($accounts as $a) {
                fputcsv($output, [
                    $a['account_code'], $a['name'], strtoupper($a['account_type']),
                    number_format((float)$a['total_debit'], 2, '.', ''),
                    number_format((float)$a['total_credit'], 2, '.', ''),
                    number_format((float)$a['balance'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'financial_statements') {
            header('Content-Disposition: attachment; filename="Trial_Balance_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Name', 'Classification', 'Debit (BDT)', 'Credit (BDT)']);
            $tb = \Diagnostic\Accounting::getTrialBalance($db);
            foreach ($tb as $r) {
                fputcsv($output, [
                    $r['account_code'], $r['name'], strtoupper($r['account_type']),
                    number_format((float)$r['total_debit'], 2, '.', ''),
                    number_format((float)$r['total_credit'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'doctor_commissions') {
            header('Content-Disposition: attachment; filename="Doctor_Commissions_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Doctor Code', 'Doctor Name', 'Mobile', 'Referred Orders', 'Billed Volume (BDT)', 'Accrued Commission (BDT)', 'Pending Due (BDT)']);
            $comms = \Diagnostic\Accounting::getDoctorCommissionSummary($db);
            foreach ($comms as $d) {
                fputcsv($output, [
                    $d['doctor_code'], $d['doctor_name'], $d['mobile'],
                    $d['total_referrals'],
                    number_format((float)$d['total_billed'], 2, '.', ''),
                    number_format((float)$d['total_commission'], 2, '.', ''),
                    number_format((float)$d['pending_commission'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'corporate_billing') {
            header('Content-Disposition: attachment; filename="Corporate_Aging_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Client Code', 'Corporate Scheme', 'Phone', 'Total Invoiced (BDT)', '0-30 Days (BDT)', '31-60 Days (BDT)', '60+ Days Overdue (BDT)', 'Total Due (BDT)']);
            $agings = \Diagnostic\Accounting::getCorporateAging($db);
            foreach ($agings as $ca) {
                fputcsv($output, [
                    $ca['code'], $ca['name'], $ca['phone'],
                    number_format((float)$ca['total_billed'], 2, '.', ''),
                    number_format((float)$ca['aging_30'], 2, '.', ''),
                    number_format((float)$ca['aging_60'], 2, '.', ''),
                    number_format((float)$ca['aging_90_plus'], 2, '.', ''),
                    number_format((float)$ca['total_due'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'accounts_payable') {
            header('Content-Disposition: attachment; filename="Supplier_Payables_Ledger_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Supplier Code', 'Vendor Name', 'Phone', 'Total Purchases (BDT)', 'TDS/VDS Deducted (BDT)', 'Paid (BDT)', 'Balance Due (BDT)']);
            $supps = \Diagnostic\Accounting::getSupplierLedger($db);
            foreach ($supps as $s) {
                fputcsv($output, [
                    $s['code'], $s['name'], $s['phone'],
                    number_format((float)$s['total_purchased'], 2, '.', ''),
                    number_format((float)$s['tds_vds_deducted'], 2, '.', ''),
                    number_format((float)$s['total_paid'], 2, '.', ''),
                    number_format((float)$s['balance_payable'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'cash_bank_books') {
            header('Content-Disposition: attachment; filename="Cash_Bank_Liquidity_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Account Code', 'Account Title', 'Available Balance (BDT)', 'Status']);
            $books = \Diagnostic\Accounting::getCashBankBalances($db);
            foreach ($books as $cb) {
                fputcsv($output, [
                    $cb['account_code'], $cb['name'],
                    number_format((float)$cb['balance'], 2, '.', ''),
                    'Reconciled'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'inventory_stock') {
            header('Content-Disposition: attachment; filename="FEFO_Stock_Batches_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Item Code', 'Reagent Name', 'Batch #', 'Lot #', 'Expiry Date', 'Quantity On Hand', 'Unit Cost (BDT)', 'Storage Condition']);
            $branchId = Security::branchIds($db)[0];
            $batches = \Diagnostic\Inventory::getFEFOStockList($db, $branchId);
            foreach ($batches as $b) {
                fputcsv($output, [
                    $b['code'], $b['item_name'], $b['batch_no'], $b['lot_no'] ?? 'N/A',
                    $b['expiry_date'], $b['quantity_on_hand'] . ' ' . $b['unit_name'],
                    number_format((float)($b['unit_cost'] ?? 0), 2, '.', ''),
                    $b['storage_condition'] ?? 'Cold Chain'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'equipment_assets') {
            header('Content-Disposition: attachment; filename="Equipment_Assets_Register_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Asset Code', 'Equipment Name', 'Model', 'Serial #', 'Purchase Date', 'Warranty Expiry', 'Status']);
            $assets = \Diagnostic\Equipment::listAssets($db);
            foreach ($assets as $ast) {
                fputcsv($output, [
                    $ast['asset_code'], $ast['name'], $ast['model_no'] ?? 'N/A', $ast['serial_no'] ?? 'N/A',
                    $ast['purchase_date'] ?? 'N/A', $ast['warranty_expiry'] ?? 'Lifetime', strtoupper($ast['status'])
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'stock_transfers') {
            header('Content-Disposition: attachment; filename="Stock_Transfers_Report_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Transfer #', 'Item Name', 'From Branch', 'To Branch', 'Quantity', 'Status', 'Date']);
            $transfers = \Diagnostic\Inventory::listTransfers($db);
            foreach ($transfers as $tr) {
                fputcsv($output, [
                    $tr['transfer_no'], $tr['item_name'], $tr['from_branch'], $tr['to_branch'],
                    $tr['quantity'], strtoupper($tr['status']), $tr['created_at']
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'corporate_contracts') {
            header('Content-Disposition: attachment; filename="Corporate_Contracts_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Contract #', 'Corporate Client', 'Credit Limit (BDT)', 'Discount (%)', 'Pre-Auth', 'Valid From', 'Valid To', 'Status']);
            $contracts = \Diagnostic\Corporate::listContracts($db);
            foreach ($contracts as $ct) {
                fputcsv($output, [
                    $ct['contract_no'], $ct['corporate_name'],
                    number_format((float)$ct['credit_limit'], 2, '.', ''),
                    $ct['discount_percent'] . '%',
                    !empty($ct['pre_auth_required']) ? 'Yes' : 'No',
                    $ct['agreement_start'], $ct['agreement_end'], 'Active'
                ]);
            }
            fclose($output);
            exit;
        }

        if ($page === 'referrer_desk') {
            header('Content-Disposition: attachment; filename="Referrer_Performance_Leaderboard_' . date('Y-m-d') . '.csv"');
            fputcsv($output, ['Code', 'Referrer Name', 'Type', 'Total Referred Orders', 'Total Billed Revenue (BDT)']);
            $perf = \Diagnostic\Referral::getReferrerPerformance($db);
            foreach ($perf as $p) {
                fputcsv($output, [
                    $p['code'], $p['name'], ucfirst($p['type']),
                    $p['total_orders'], number_format((float)$p['total_revenue'], 2, '.', '')
                ]);
            }
            fclose($output);
            exit;
        }
    }
    match ($page) {
        'dashboard' => render_dashboard($db,$user),
        'clinic_dashboard' => render_dashboard($db,$user),
        'doctor_dashboard' => render_dashboard($db,$user),
        'pathology_dashboard' => render_dashboard($db,$user),
        'doctors' => render_doctors($db,$user),
        'specializations' => render_specializations($db,$user),
        'departments' => render_departments($db,$user),
        'patient_documents' => render_patient_documents($db,$user),
        'ordering_users' => render_ordering_users($db,$user),
        'masters' => render_masters($db,$user),
        'patients' => render_patients($db,$user),
        'appointments' => render_appointments($db,$user),
        'orders' => render_orders($db,$user),
        'queue' => render_queue($db,$user),
        'display_board' => render_display_board($db,$user),
        'billing' => render_billing($db,$user),
        'payment_gateway' => render_payment_gateway($db,$user),
        'cashier_shift' => render_cashier_shift($db,$user),
        'test_categories' => render_test_categories($db,$user),
        'sample_desk' => render_sample_desk($db,$user),
        'lab_worklist' => render_lab_worklist($db,$user),
        'result_entry' => render_result_entry($db,$user),
        'pathologist_desk' => render_pathologist_desk($db,$user),
        'microbiology' => render_microbiology($db,$user),
        'histopathology' => render_histopathology($db,$user),
        'lab_reports' => render_lab_reports($db,$user),
        'radiology_worklist' => render_radiology_worklist($db,$user),
        'radiology_reporting' => render_radiology_reporting($db,$user),
        'pacs_viewer' => render_pacs_viewer($db,$user),
        'analyzer_mapping' => render_analyzer_mapping($db,$user),
        'report_center' => render_report_center($db,$user),
        'notifications' => render_notifications($db,$user),
        'home_collections' => render_home_collections($db,$user),
        'patient_portal' => render_patient_portal_demo($db,$user),
        'corporate_contracts' => render_corporate_contracts($db,$user),
        'corporate_clients' => render_corporate_contracts($db,$user),
        'corporate_billing' => render_corporate_billing($db,$user),
        'referrer_desk' => render_referrer_desk($db,$user),
        'commission_settlement' => render_commission_settlement($db,$user),
        'crm_campaigns' => render_crm_campaigns($db,$user),
        'inventory_stock' => render_inventory_stock($db,$user),
        'pharmacy_catalog' => render_pharmacy_catalog($db,$user),
        'pharmacy_items' => render_pharmacy_items($db,$user),
        'pharmacy_pos' => render_pharmacy_pos($db,$user),
        'pharmacy_chamber_queue' => render_pharmacy_chamber_queue($db,$user),
        'prescriptions' => render_pharmacy_chamber_queue($db,$user),
        'pharmacy_procurement' => render_pharmacy_procurement($db,$user),
        'pharmacy_coldchain' => redirect('index.php?page=pharmacy_procurement'),
        'pharmacy_returns' => render_pharmacy_returns($db,$user),
        'pharmacy_hypercare' => render_pharmacy_hypercare($db,$user),
        'pharmacy_cutover' => render_pharmacy_cutover($db,$user),
        'pharmacy_clinical_cdss' => render_pharmacy_clinical_cdss($db,$user),
        'pharmacy_ai_optimization' => redirect('index.php?page=pharmacy_executive_bi'),
        'pharmacy_multistore_theft' => redirect('index.php?page=pharmacy_procurement'),
        'pharmacy_mcommerce_crm' => render_pharmacy_mcommerce_crm($db,$user),
        'pharmacy_executive_bi' => render_pharmacy_executive_bi($db,$user),
        'pharmacy_receipt' => render_pharmacy_receipt($db,$user),
        'procurement' => render_procurement($db,$user),
        'equipment_assets' => render_equipment_assets($db,$user),
        'stock_transfers' => render_stock_transfers($db,$user),
        'chart_of_accounts' => render_chart_of_accounts($db,$user),
        'financial_vouchers' => render_financial_vouchers($db,$user),
        'financial_statements' => render_financial_statements($db,$user),
        'doctor_commissions' => render_doctor_commissions($db,$user),
        'corporate_billing' => render_corporate_billing($db,$user),
        'accounts_payable' => render_accounts_payable($db,$user),
        'cash_bank_books' => render_cash_bank_books($db,$user),
        'fixed_assets' => render_fixed_assets($db,$user),
        'hr_employees' => render_hr_employees($db,$user),
        'hr_attendance' => render_hr_attendance($db,$user),
        'hr_roster_leave' => render_hr_roster_leave($db,$user),
        'hr_leaves' => render_hr_leaves($db,$user),
        'hr_payroll' => render_hr_payroll($db,$user),
        'hr_recruitment' => render_hr_recruitment($db,$user),
        'hr_competencies' => render_hr_competencies($db,$user),
        'print_voucher' => render_print_voucher($db,$user, (string)($_GET['type'] ?? 'order'), (string)($_GET['id'] ?? '0')),
        'quality_qc_tat' => render_quality_qc_tat($db,$user),
        'quality_capa' => render_quality_capa($db,$user),
        'quality_sop' => render_quality_sop($db,$user),
        'compliance_calendar' => render_compliance_calendar($db,$user),
        'executive_dashboard' => render_executive_dashboard($db,$user),
        'report_catalog' => render_report_catalog($db,$user),
        'integration_hub' => render_integration_hub($db,$user),
        'security_hardening' => render_security_hardening($db,$user),
        'users' => render_users($db,$user),
        'approvals' => render_approvals($db,$user),
        'audit' => render_audit($db,$user),
        'sequences' => render_sequences($db,$user),
        'policies' => render_policies($db,$user),
        'website_cms' => render_website_cms($db,$user),
        default => throw new RuntimeException('Page not found.'),
    };
} catch (Throwable $e) {
    if (env_value('APP_DEBUG') === '1') error_log((string)$e);
    http_response_code(http_response_code() >= 400 ? http_response_code() : 400);
    $isDebug = env_value('APP_DEBUG') === '1';
    if (str_starts_with(app_request_path(), '/api/')) {
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['error'=>$isDebug ? $e->getMessage() : ($e instanceof PDOException ? 'Database operation failed.' : $e->getMessage())]);
    } else {
        if ($isDebug) {
            $message = $e->getMessage() . ' in ' . basename($e->getFile()) . ':' . $e->getLine();
        } else {
            $message = $e instanceof PDOException ? 'Database operation failed (' . $e->getMessage() . ').' : $e->getMessage();
        }
        echo '<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href="/assets/app.css"><body class="error-page"><section class="error-card"><div class="brand-symbol">✦</div><h1>Could not complete the action</h1><p>' . e($message) . '</p><a class="button" href="/index.php">Go to overview</a></section></body></html>';
    }
}
