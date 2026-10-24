<?php
declare(strict_types=1);

use Diagnostic\Masters;
use Diagnostic\Security;

function handle_api(PDO $db, string $method): void
{
    header('Content-Type: application/json; charset=utf-8');
    $path = app_request_path();
    if ($path === '/api/v1/health') {
        Security::requirePermission($db,'dashboard.view');
        echo json_encode(['status'=>'ok','time'=>date(DATE_ATOM)]);
        return;
    }
    if (preg_match('~^/api/v1/masters/([a-z_]+)$~',$path,$m) && $method === 'GET') {
        $search = mb_substr(trim((string)($_GET['q'] ?? '')),0,80);
        $rows = Masters::scoped($db,$m[1],100,$search);
        echo json_encode(['data'=>$rows],JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/patients/search' && $method === 'GET') {
        $branchId = (int) ($_GET['branch_id'] ?? Security::branchIds($db)[0]);
        $q = (string) ($_GET['q'] ?? '');
        $patients = \Diagnostic\Patients::search($db, $q, $branchId, 20);
        echo json_encode(['data' => $patients], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/queue/display' && $method === 'GET') {
        $branchId = (int) ($_GET['branch_id'] ?? Security::branchIds($db)[0]);
        $display = \Diagnostic\Queue::getDisplayBoard($db, $branchId);
        echo json_encode(['data' => $display], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/patient/login-otp' && $method === 'POST') {
        $mobile = (string) ($_POST['mobile'] ?? $_GET['mobile'] ?? '');
        $res = \Diagnostic\PatientPortal::requestOTP($db, $mobile);
        echo json_encode(['data' => $res], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/patient/verify-otp' && $method === 'POST') {
        $mobile = (string) ($_POST['mobile'] ?? $_GET['mobile'] ?? '');
        $otp = (string) ($_POST['otp'] ?? $_GET['otp'] ?? '');
        $res = \Diagnostic\PatientPortal::verifyOTP($db, $mobile, $otp);
        echo json_encode(['data' => $res], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/patient/reports' && $method === 'GET') {
        $patientId = (int) ($_GET['patient_id'] ?? 0);
        $reports = \Diagnostic\PatientPortal::getPatientReports($db, $patientId);
        echo json_encode(['data' => $reports], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/report/verify-qr' && $method === 'GET') {
        $hash = (string) ($_GET['hash'] ?? '');
        $res = \Diagnostic\ReportCenter::verifyQRHash($db, $hash);
        echo json_encode(['verified' => $res !== null, 'data' => $res], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/corporate/eligibility' && $method === 'GET') {
        $corporateId = (int) ($_GET['corporate_client_id'] ?? 0);
        $contracts = \Diagnostic\Corporate::listContracts($db);
        echo json_encode(['data' => array_values(array_filter($contracts, fn($c) => (int)$c['corporate_client_id'] === $corporateId))], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/referrers/summary' && $method === 'GET') {
        $perf = \Diagnostic\Referral::getReferrerPerformance($db);
        echo json_encode(['data' => $perf], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/inventory/stock' && $method === 'GET') {
        $branchId = (int) ($_GET['branch_id'] ?? Security::branchIds($db)[0]);
        $stock = \Diagnostic\Inventory::getFEFOStockList($db, $branchId);
        echo json_encode(['data' => $stock], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/finance/trial-balance' && $method === 'GET') {
        $tb = \Diagnostic\Accounting::getTrialBalance($db);
        echo json_encode(['data' => $tb], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/compliance/expiries' && $method === 'GET') {
        $licenses = \Diagnostic\Quality::listLicenses($db);
        echo json_encode(['data' => $licenses], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/quality/summary' && $method === 'GET') {
        $qc = \Diagnostic\Quality::listQCLogs($db);
        $capa = \Diagnostic\Quality::listCAPA($db);
        echo json_encode(['data' => ['qc' => $qc, 'capa' => $capa]], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/intelligence/kpis' && $method === 'GET') {
        $cockpit = \Diagnostic\Intelligence::getRealtimeCockpitData($db);
        echo json_encode(['data' => $cockpit], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/integration/webhooks' && $method === 'GET') {
        $webhooks = \Diagnostic\Intelligence::listWebhooks($db);
        echo json_encode(['data' => $webhooks], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/pharmacy/search' && $method === 'GET') {
        $q = (string) ($_GET['q'] ?? '');
        $limit = isset($_GET['limit']) ? (int) $_GET['limit'] : 50;
        $results = \Diagnostic\Pharmacy::searchGlobalMedicines($db, $q, $limit);
        echo json_encode(['data' => $results], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/pharmacy/clone' && $method === 'POST') {
        $globalId = (int) ($_POST['global_medicine_id'] ?? $_GET['global_medicine_id'] ?? 0);
        if (!$globalId) {
            http_response_code(400);
            echo json_encode(['error' => 'global_medicine_id is required']);
            return;
        }
        $itemId = \Diagnostic\Pharmacy::cloneGlobalToLocal($db, $globalId, $_POST);
        echo json_encode(['status' => 'success', 'pharmacy_item_id' => $itemId, 'message' => 'Successfully cloned to Lutfunnesa Center stock']);
        return;
    }
    if ($path === '/api/v1/notifications' && $method === 'GET') {
        $user = Security::user($db);
        if (!$user) {
            http_response_code(401);
            echo json_encode(['error' => 'Unauthorized']);
            return;
        }
        $data = \Diagnostic\Notifications::getSystemNotifications($db, $user);
        echo json_encode(['status' => 'success', 'data' => $data], JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE);
        return;
    }
    if ($path === '/api/v1/notifications/read' && $method === 'POST') {
        $user = Security::user($db);
        if (!$user) {
            http_response_code(401);
            echo json_encode(['error' => 'Unauthorized']);
            return;
        }
        $key = isset($_POST['id']) ? (string)$_POST['id'] : null;
        \Diagnostic\Notifications::markAsRead($db, (int)$user['id'], $key);
        echo json_encode(['status' => 'success', 'message' => 'Marked as read']);
        return;
    }
    http_response_code(404);
    echo json_encode(['error'=>'Endpoint not found.']);
}
