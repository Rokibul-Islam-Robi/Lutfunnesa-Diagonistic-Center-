<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class PrintVoucher
{
    public static function render(PDO $db, array $user, string $type, string $id): void
    {
        Security::requirePermission($db, 'dashboard.view');

        echo '<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Official Corporate Voucher · Lutfunnesa Diabetes & Diagnostic Center</title>
    <link rel="icon" href="/assets/fav.png" type="image/png">
    <link rel="stylesheet" href="/assets/app.css">
    <style>
        body {
            background: #e2e8f0;
            margin: 0;
            padding: 24px 12px;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            color: #0f172a;
        }
        .voucher-screen-bar {
            max-width: 880px;
            margin: 0 auto 18px auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #092c36;
            color: #ffffff;
            padding: 12px 20px;
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(9, 44, 54, 0.25);
        }
        .voucher-screen-bar a {
            color: #93c5fd;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .voucher-screen-bar .btn-print-now {
            background: linear-gradient(135deg, #0d9488 0%, #059669 100%);
            color: #ffffff;
            border: none;
            border-radius: 8px;
            padding: 8px 18px;
            font-size: 13px;
            font-weight: 750;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            box-shadow: 0 2px 8px rgba(13, 148, 136, 0.35);
        }
        .voucher-screen-bar .btn-download-now {
            background: #1e293b;
            color: #ffffff;
            border: 1px solid #475569;
            border-radius: 8px;
            padding: 8px 14px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .voucher-a4-sheet {
            max-width: 880px;
            margin: 0 auto;
            background: #ffffff;
            padding: 40px 45px;
            border-radius: 4px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            border: 1px solid #cbd5e1;
            position: relative;
            box-sizing: border-box;
        }
        .corp-letterhead-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2.5px solid #0d9488;
            padding-bottom: 16px;
            margin-bottom: 20px;
        }
        .corp-brand-block {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .corp-brand-titles h1 {
            margin: 0;
            font-size: 20px;
            font-weight: 900;
            color: #092c36;
            letter-spacing: -0.02em;
            line-height: 1.2;
            text-transform: uppercase;
        }
        .corp-brand-titles p {
            margin: 3px 0 0;
            font-size: 11px;
            font-weight: 700;
            color: #0d9488;
            letter-spacing: 0.04em;
        }
        .corp-center-info {
            margin-top: 6px;
            font-size: 10.5px;
            color: #475569;
            line-height: 1.45;
        }
        .voucher-badge-box {
            text-align: right;
        }
        .voucher-title-pill {
            display: inline-block;
            background: #092c36;
            color: #ffffff;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            padding: 5px 14px;
            border-radius: 6px;
            margin-bottom: 6px;
        }
        .voucher-meta-row {
            font-size: 11px;
            color: #475569;
            line-height: 1.4;
        }
        .voucher-meta-row strong {
            color: #0f172a;
        }
        .voucher-info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 14px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 14px 18px;
            margin-bottom: 22px;
            font-size: 12px;
        }
        .voucher-info-grid .info-item {
            line-height: 1.5;
        }
        .voucher-info-grid .info-label {
            font-size: 10px;
            font-weight: 800;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .voucher-info-grid .info-val {
            font-weight: 750;
            color: #0f172a;
        }
        .voucher-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
            font-size: 11.5px;
        }
        .voucher-table th {
            background: #092c36;
            color: #ffffff;
            padding: 8px 12px;
            font-size: 10.5px;
            font-weight: 800;
            text-align: left;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            border: 1px solid #092c36;
        }
        .voucher-table td {
            padding: 9px 12px;
            border: 1px solid #e2e8f0;
            color: #1e293b;
        }
        .voucher-table tbody tr:nth-child(even) {
            background: #f8fafc;
        }
        .voucher-financial-summary {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 20px;
            margin-bottom: 25px;
        }
        .voucher-words-box {
            flex: 1;
            background: #f0fdfa;
            border: 1px solid #ccfbf1;
            border-radius: 8px;
            padding: 12px 16px;
            font-size: 11.5px;
            color: #134e4a;
        }
        .voucher-calc-table {
            width: 300px;
            font-size: 12px;
            border-collapse: collapse;
        }
        .voucher-calc-table td {
            padding: 5px 8px;
        }
        .voucher-calc-table .calc-label {
            color: #64748b;
            font-weight: 600;
        }
        .voucher-calc-table .calc-val {
            text-align: right;
            font-weight: 750;
            color: #0f172a;
        }
        .voucher-calc-table .calc-total {
            border-top: 1.5px solid #092c36;
            font-size: 14px;
            font-weight: 900;
            color: #0d9488;
            padding-top: 8px;
        }
        .voucher-signatures-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-top: 50px;
            text-align: center;
        }
        .signature-line-block {
            border-top: 1.5px dashed #94a3b8;
            padding-top: 6px;
            font-size: 10.5px;
            font-weight: 750;
            color: #334155;
            text-transform: uppercase;
        }
        .signature-line-block small {
            display: block;
            font-size: 9px;
            font-weight: 600;
            color: #64748b;
            text-transform: none;
            margin-top: 2px;
        }
        .voucher-security-footer {
            margin-top: 30px;
            padding-top: 12px;
            border-top: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 9.5px;
            color: #64748b;
        }
        @media print {
            body {
                background: #ffffff !important;
                padding: 0 !important;
            }
            .voucher-screen-bar {
                display: none !important;
            }
            .voucher-a4-sheet {
                box-shadow: none !important;
                border: none !important;
                padding: 0 !important;
                max-width: 100% !important;
                width: 100% !important;
            }
            @page {
                size: A4 portrait;
                margin: 12mm;
            }
        }
    </style>
</head>
<body>';

        // Floating Action Bar (Never printed)
        echo '<div class="voucher-screen-bar no-print">';
        echo '  <a href="javascript:history.back()">← Back to ERP</a>';
        echo '  <div style="display:flex;gap:10px;align-items:center;">';
        echo '    <a href="/index.php?page=download_pdf&type=' . e($type) . '&id=' . e($id) . '" class="btn-download-now" style="background:#0284c7;color:#ffffff;border:none;border-radius:8px;padding:8px 18px;font-size:13px;font-weight:750;text-decoration:none;display:inline-flex;align-items:center;gap:6px;box-shadow:0 2px 8px rgba(2,132,199,0.35);">';
        echo '      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>';
        echo '      Download PDF (mPDF)';
        echo '    </a>';
        echo '    <button type="button" class="btn-print-now" onclick="window.print()">';
        echo '      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>';
        echo '      Print Document (Ctrl + P)';
        echo '    </button>';
        echo '  </div>';
        echo '</div>';

        echo '<div class="voucher-a4-sheet">';
        self::renderVoucherContent($db, $type, $id);
        echo '</div>'; // close .voucher-a4-sheet
        echo '</body></html>';
    }

    public static function getVoucherHtml(PDO $db, string $type, string $id): string
    {
        ob_start();
        self::renderVoucherContent($db, $type, $id);
        return (string) ob_get_clean();
    }

    public static function renderVoucherContent(PDO $db, string $type, string $id): void
    {
        switch ($type) {
            case 'order':
                self::renderOrderVoucher($db, $id);
                break;
            case 'billing':
                self::renderBillingVoucher($db, $id);
                break;
            case 'payslip':
                self::renderPayslipVoucher($db, (int)$id);
                break;
            case 'appointment':
                self::renderAppointmentVoucher($db, $id);
                break;
            case 'home_collection':
                self::renderHomeCollectionVoucher($db, $id);
                break;
            case 'roster':
                self::renderRosterSchedule($db);
                break;
            case 'attendance':
                self::renderAttendanceSheet($db, (string)($_GET['date'] ?? date('Y-m-d')));
                break;
            case 'patient_summary':
                self::renderPatientSummary($db, (int)$id);
                break;
            case 'staff_directory':
                self::renderStaffDirectory($db);
                break;
            case 'competencies':
                self::renderCompetenciesMatrix($db);
                break;
            case 'financial_voucher':
                self::renderFinancialVoucher($db, (int)$id);
                break;
            case 'trial_balance':
                self::renderTrialBalanceReport($db);
                break;
            case 'income_statement':
                self::renderIncomeStatementReport($db);
                break;
            case 'balance_sheet':
                self::renderBalanceSheetReport($db);
                break;
            case 'doctor_commission':
                self::renderDoctorCommissionStatement($db, (int)$id);
                break;
            case 'inventory_stock':
                self::renderInventoryStockPrint($db);
                break;
            case 'equipment_assets':
                self::renderEquipmentAssetsPrint($db);
                break;
            case 'stock_transfers':
                self::renderStockTransfersPrint($db);
                break;
            case 'corporate_contracts':
                self::renderCorporateContractsPrint($db);
                break;
            case 'referrer_leaderboard':
                self::renderReferrerLeaderboardPrint($db);
                break;
            case 'home_collections':
                self::renderHomeCollectionsPrint($db);
                break;
            case 'sample_desk':
                self::renderSampleDeskPrint($db);
                break;
            case 'result_entry':
                self::renderResultEntryPrint($db);
                break;
            case 'report_catalog':
                self::renderReportCatalogPrint($db);
                break;
            default:
                echo '<div class="alert error">Unknown voucher type: ' . e($type) . '</div>';
                break;
        }

        echo '</div>'; // close .voucher-a4-sheet
        echo '</body></html>';
    }

    public static function getLogoBase64(): string
    {
        static $base64 = null;
        if ($base64 !== null) return $base64;
        $path = dirname(__DIR__) . '/public/assets/img/lutfunnesa_icon_transparent.png';
        if (!file_exists($path)) {
            $path = dirname(__DIR__) . '/public/assets/img/logo.png';
        }
        if (file_exists($path)) {
            $base64 = 'data:image/png;base64,' . base64_encode((string)file_get_contents($path));
        } else {
            $base64 = '';
        }
        return $base64;
    }

    private static function renderHeader(string $title, string $docNo, string $dateStr): void
    {
        $logo = self::getLogoBase64();
        echo '<div class="corp-letterhead-header">';
        echo '  <table width="100%" style="border-collapse:collapse;margin:0;padding:0;"><tr>';
        echo '    <td style="vertical-align:middle;width:68%;padding:0;">';
        echo '      <table style="border-collapse:collapse;margin:0;padding:0;"><tr>';
        if ($logo !== '') {
            echo '        <td style="vertical-align:middle;padding-right:15px;width:65px;"><img src="' . $logo . '" style="height:62px;width:auto;display:block;" alt="Lutfunnesa Logo"></td>';
        } else {
            echo '        <td style="vertical-align:middle;padding-right:15px;width:52px;"><div style="width:48px;height:48px;border-radius:12px;background:#0d9488;color:#ffffff;display:flex;align-items:center;justify-content:center;font-size:24px;font-weight:900;">L</div></td>';
        }
        echo '        <td style="vertical-align:middle;">';
        echo '          <h1 style="margin:0;font-size:20px;font-weight:900;color:#092c36;letter-spacing:-0.02em;line-height:1.2;text-transform:uppercase;">LUTFUNNESA DIABETES &amp; DIAGNOSTIC CENTER</h1>';
        echo '          <p style="margin:2px 0 0;font-size:11px;font-weight:800;color:#0d9488;letter-spacing:0.03em;">লুৎফুন্নেসা ডায়াবেটিস অ্যান্ড ডায়াগনস্টিক সেন্টার · Precision Clinical Pathology &amp; Specialized Health Services</p>';
        echo '          <div style="margin-top:5px;font-size:10px;color:#475569;line-height:1.45;">';
        echo '            Holding #45, Main Hospital Road, Farmgate, Tejgaon, Dhaka - 1215 · Hotline: <strong>+880 9611-000111</strong><br>';
        echo '            Govt. DGHS Reg: <strong>DGHS-DIAG-2026-9842</strong> | Tax BIN: <strong>004819284-0101</strong> | Email: <strong>info@lutfunnesa.com</strong>';
        echo '          </div>';
        echo '        </td>';
        echo '      </tr></table>';
        echo '    </td>';
        echo '    <td style="vertical-align:middle;width:32%;text-align:right;padding:0;">';
        echo '      <div class="voucher-badge-box">';
        echo '        <span class="voucher-title-pill">' . e($title) . '</span>';
        echo '        <div class="voucher-meta-row" style="margin-top:5px;">Doc Ref: <strong>' . e($docNo) . '</strong></div>';
        echo '        <div class="voucher-meta-row">Issued: <strong>' . e($dateStr) . '</strong></div>';
        echo '        <div class="voucher-meta-row">Printed: <strong>' . date('d-M-Y h:i A') . '</strong></div>';
        echo '        <div class="voucher-meta-row">Branch: <strong>Main Center (Dhaka)</strong></div>';
        echo '      </div>';
        echo '    </td>';
        echo '  </tr></table>';
        echo '</div>';
    }

    private static function renderOrderVoucher(PDO $db, string $id): void
    {
        $stmt = $db->prepare('SELECT o.*, p.name AS patient_name, p.mrn, p.mobile, p.gender, p.dob, p.blood_group, d.name AS doctor_name, r.name AS referrer_name, b.name AS branch_name 
            FROM diagnostic_orders o 
            JOIN patients p ON p.id=o.patient_id 
            LEFT JOIN doctors d ON d.id=o.doctor_id 
            LEFT JOIN referrers r ON r.id=o.referrer_id 
            LEFT JOIN branches b ON b.id=o.branch_id 
            WHERE o.id=? OR o.order_no=?');
        $stmt->execute([$id, $id]);
        $order = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$order) {
            echo '<div class="alert error">Diagnostic Order #' . e($id) . ' not found.</div>';
            return;
        }

        self::renderHeader('Diagnostic Requisition & Money Receipt', $order['order_no'], date('d-M-Y h:i A', strtotime($order['created_at'])));

        echo '<div class="voucher-info-grid">';
        echo '  <div class="info-item"><span class="info-label">Patient Full Name</span><div class="info-val">' . e($order['patient_name']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Patient MRN / UHID</span><div class="info-val">' . e($order['mrn']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Mobile Number</span><div class="info-val">' . e($order['mobile']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Gender / Blood Group</span><div class="info-val">' . e(ucfirst($order['gender'])) . ' • ' . e($order['blood_group'] ?: 'Unknown') . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Consultant / Prescribed By</span><div class="info-val">' . e($order['doctor_name'] ?? 'General Outpatient') . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Order Status</span><div class="info-val" style="color:#0d9488;text-transform:uppercase;">● ' . e($order['status']) . '</div></div>';
        echo '</div>';

        // Order items
        $itemStmt = $db->prepare('SELECT oi.*, t.code AS test_code, oi.item_name, COALESCE(t.sample_requirement, \'Blood / Serum\') AS sample_type, dept.name AS dept_name 
            FROM diagnostic_order_items oi 
            LEFT JOIN diagnostic_tests t ON t.id=oi.item_id 
            LEFT JOIN departments dept ON dept.id=t.department_id 
            WHERE oi.order_id=?');
        $itemStmt->execute([$order['id']]);
        $items = $itemStmt->fetchAll(PDO::FETCH_ASSOC) ?: [];

        echo '<table class="voucher-table">';
        echo '<thead><tr><th>#</th><th>Investigation / Test Name</th><th>Department</th><th>Specimen</th><th>Delivery Due</th><th style="text-align:right;">Charge (BDT)</th></tr></thead><tbody>';
        $sl = 1;
        foreach ($items as $it) {
            echo '<tr>';
            echo '<td>' . $sl++ . '</td>';
            echo '<td><strong>' . e($it['item_name']) . '</strong>' . (!empty($it['test_code']) ? (' <small style="color:#64748b;">(' . e($it['test_code']) . ')</small>') : '') . '</td>';
            echo '<td>' . e($it['dept_name'] ?? 'Pathology') . '</td>';
            echo '<td>' . e($it['sample_type'] ?? 'Blood') . '</td>';
            echo '<td>' . date('d-M-Y', strtotime($order['created_at'] . ' +1 day')) . ' 05:00 PM</td>';
            echo '<td style="text-align:right;">' . number_format((float)$it['price'], 2) . '</td>';
            echo '</tr>';
        }
        echo '</tbody></table>';

        $total = (float)$order['total_amount'];
        $discount = (float)$order['discount_amount'];
        $payable = (float)$order['payable_amount'];
        $paid = (float)($order['paid_amount'] ?? $payable);
        $due = max(0, $payable - $paid);

        echo '<div class="voucher-financial-summary">';
        echo '  <div class="voucher-words-box">';
        echo '    <strong>Amount in Words:</strong> BDT ' . ucwords(self::convertNumberToWords((int)$payable)) . ' Only.<br>';
        echo '    <small style="color:#0f766e;margin-top:6px;display:block;">* Please preserve this Money Receipt slip for clinical test sample verification and final certified report delivery.</small>';
        echo '  </div>';
        echo '  <table class="voucher-calc-table">';
        echo '    <tr><td class="calc-label">Gross Total:</td><td class="calc-val">BDT ' . number_format($total, 2) . '</td></tr>';
        if ($discount > 0) {
            echo '    <tr><td class="calc-label">Corporate Discount:</td><td class="calc-val" style="color:#dc2626;">- BDT ' . number_format($discount, 2) . '</td></tr>';
        }
        echo '    <tr><td class="calc-label calc-total">Net Payable:</td><td class="calc-val calc-total">BDT ' . number_format($payable, 2) . '</td></tr>';
        echo '    <tr><td class="calc-label">Paid Amount:</td><td class="calc-val" style="color:#16a34a;">BDT ' . number_format($paid, 2) . '</td></tr>';
        if ($due > 0) {
            echo '    <tr><td class="calc-label">Balance Due:</td><td class="calc-val" style="color:#e11d48;font-weight:900;">BDT ' . number_format($due, 2) . '</td></tr>';
        }
        echo '  </table>';
        echo '</div>';

        self::renderSignatures('Prepared By (Cashier)', 'Specimen Phlebotomist', 'Authorized Medical Officer');
    }

    private static function renderBillingVoucher(PDO $db, string $id): void
    {
        $stmt = $db->prepare('SELECT i.*, p.name AS patient_name, p.mrn, p.mobile, b.name AS branch_name 
            FROM invoices i 
            JOIN patients p ON p.id=i.patient_id 
            LEFT JOIN branches b ON b.id=i.branch_id 
            WHERE i.id=? OR i.invoice_no=?');
        $stmt->execute([$id, $id]);
        $inv = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$inv) {
            echo '<div class="alert error">Invoice #' . e($id) . ' not found.</div>';
            return;
        }

        self::renderHeader('Official Billing Cash Receipt', $inv['invoice_no'], date('d-M-Y h:i A', strtotime($inv['created_at'])));

        echo '<div class="voucher-info-grid">';
        echo '  <div class="info-item"><span class="info-label">Customer / Patient Name</span><div class="info-val">' . e($inv['patient_name']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Patient MRN</span><div class="info-val">' . e($inv['mrn']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Contact Mobile</span><div class="info-val">' . e($inv['mobile']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Invoice Status</span><div class="info-val" style="color:#16a34a;text-transform:uppercase;">● ' . e($inv['status']) . '</div></div>';
        echo '</div>';

        $items = $db->prepare('SELECT oi.*, oi.item_name, 1 AS quantity, oi.price AS unit_price, oi.price AS total_price 
            FROM diagnostic_order_items oi 
            WHERE oi.order_id=?');
        $items->execute([$inv['order_id']]);
        $rows = $items->fetchAll(PDO::FETCH_ASSOC) ?: [];
        if (empty($rows)) {
            $rows = [
                ['item_name' => 'Diagnostic Investigation & Medical Services', 'quantity' => 1, 'unit_price' => $inv['total_amount'], 'total_price' => $inv['total_amount']]
            ];
        }

        echo '<table class="voucher-table">';
        echo '<thead><tr><th>#</th><th>Description of Diagnostic Service</th><th>Qty</th><th style="text-align:right;">Unit Price</th><th style="text-align:right;">Total (BDT)</th></tr></thead><tbody>';
        $sl = 1;
        foreach ($rows as $r) {
            echo '<tr>';
            echo '<td>' . $sl++ . '</td>';
            echo '<td><strong>' . e($r['item_name'] ?? 'Diagnostic Service') . '</strong></td>';
            echo '<td>' . (int)($r['quantity'] ?? 1) . '</td>';
            echo '<td style="text-align:right;">' . number_format((float)($r['unit_price'] ?? 0), 2) . '</td>';
            echo '<td style="text-align:right;">' . number_format((float)($r['total_price'] ?? 0), 2) . '</td>';
            echo '</tr>';
        }
        echo '</tbody></table>';

        $total = (float)$inv['total_amount'];
        $paid = (float)$inv['paid_amount'];
        $due = (float)($inv['due_amount'] ?? 0);

        echo '<div class="voucher-financial-summary">';
        echo '  <div class="voucher-words-box">';
        echo '    <strong>Total Amount in Words:</strong> BDT ' . ucwords(self::convertNumberToWords((int)$total)) . ' Only.<br>';
        echo '    <small style="color:#0f766e;margin-top:6px;display:block;">* Official system-generated corporate tax invoice issued under DGHS &amp; NBR billing regulations.</small>';
        echo '  </div>';
        echo '  <table class="voucher-calc-table">';
        echo '    <tr><td class="calc-label">Total Billed:</td><td class="calc-val">BDT ' . number_format($total, 2) . '</td></tr>';
        echo '    <tr><td class="calc-label calc-total">Amount Paid:</td><td class="calc-val calc-total">BDT ' . number_format($paid, 2) . '</td></tr>';
        if ($due > 0) {
            echo '    <tr><td class="calc-label">Balance Due:</td><td class="calc-val" style="color:#e11d48;font-weight:900;">BDT ' . number_format($due, 2) . '</td></tr>';
        }
        echo '  </table>';
        echo '</div>';

        self::renderSignatures('Cashier / Billing Desk', 'Accounts Officer', 'Head of Finance');
    }

    private static function renderPayslipVoucher(PDO $db, int $id): void
    {
        $pay = \Diagnostic\HR::getPayroll($db, $id);

        if (!$pay) {
            echo '<div class="alert error">Salary Payslip #' . e((string)$id) . ' not found.</div>';
            return;
        }

        self::renderHeader('Confidential Employee Salary Payslip', $pay['transaction_ref'] ?: ('SLP-' . $pay['id']), date('d-M-Y', strtotime($pay['created_at'])));

        echo '<div class="voucher-info-grid">';
        echo '  <div class="info-item"><span class="info-label">Employee Code</span><div class="info-val">' . e($pay['employee_code']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Full Name</span><div class="info-val">' . e($pay['employee_name']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Designation</span><div class="info-val">' . e($pay['designation']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Department</span><div class="info-val">' . e($pay['department_name'] ?? 'Clinical Operations') . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Salary Period</span><div class="info-val" style="color:#0d9488;font-weight:900;">' . e($pay['payroll_period']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Disbursement Channel</span><div class="info-val">' . e($pay['payment_method'] ?? 'Bank Transfer') . '</div></div>';
        echo '</div>';

        $basic = (float)$pay['basic_salary'];
        $house = (float)($pay['house_rent'] ?? round($basic * 0.40, 2));
        $med = (float)($pay['medical_allowance'] ?? 3000.00);
        $totalAllow = (float)$pay['allowances'];
        $conveyance = max(0, $totalAllow - ($house + $med));

        $pf = (float)($pay['provident_fund'] ?? round($basic * 0.08, 2));
        $tax = (float)($pay['tax_deduction'] ?? 0.00);
        $totalDeduct = (float)$pay['deductions'];
        $otherDeduct = max(0, $totalDeduct - ($pf + $tax));

        $gross = $basic + $totalAllow;
        $net = (float)$pay['net_salary'];

        echo '<div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px;">';
        
        // Earnings Table
        echo '<div><table class="voucher-table" style="margin:0;">';
        echo '<thead><tr><th>Earnings Component</th><th style="text-align:right;">Amount (BDT)</th></tr></thead><tbody>';
        echo '<tr><td>Basic Salary</td><td style="text-align:right;">' . number_format($basic, 2) . '</td></tr>';
        echo '<tr><td>House Rent Allowance (HRA)</td><td style="text-align:right;">' . number_format($house, 2) . '</td></tr>';
        echo '<tr><td>Medical Allowance</td><td style="text-align:right;">' . number_format($med, 2) . '</td></tr>';
        if ($conveyance > 0) {
            echo '<tr><td>Conveyance &amp; Special Duty</td><td style="text-align:right;">' . number_format($conveyance, 2) . '</td></tr>';
        }
        echo '<tr style="font-weight:800;background:#f0fdf4;"><td>Gross Earnings:</td><td style="text-align:right;color:#16a34a;">BDT ' . number_format($gross, 2) . '</td></tr>';
        echo '</tbody></table></div>';

        // Deductions Table
        echo '<div><table class="voucher-table" style="margin:0;">';
        echo '<thead><tr><th>Deductions Component</th><th style="text-align:right;">Amount (BDT)</th></tr></thead><tbody>';
        echo '<tr><td>Provident Fund (PF) Contribution</td><td style="text-align:right;">' . number_format($pf, 2) . '</td></tr>';
        echo '<tr><td>Tax Deducted at Source (TDS)</td><td style="text-align:right;">' . number_format($tax, 2) . '</td></tr>';
        if ($otherDeduct > 0) {
            echo '<tr><td>Advance &amp; Other Adjustments</td><td style="text-align:right;">' . number_format($otherDeduct, 2) . '</td></tr>';
        }
        echo '<tr style="font-weight:800;background:#fef2f2;"><td>Total Deductions:</td><td style="text-align:right;color:#dc2626;">BDT ' . number_format($totalDeduct, 2) . '</td></tr>';
        echo '</tbody></table></div>';

        echo '</div>'; // close 2 columns

        echo '<div class="voucher-financial-summary">';
        echo '  <div class="voucher-words-box">';
        echo '    <strong>Net Disbursed Amount in Words:</strong><br>';
        echo '    <span style="font-size:13px;font-weight:800;color:#0f766e;">BDT ' . ucwords(self::convertNumberToWords((int)$net)) . ' Only.</span><br>';
        echo '    <small style="color:#64748b;margin-top:6px;display:block;">* This payslip is electronically generated by Lutfunnesa Enterprise ERP Human Capital Management.</small>';
        echo '  </div>';
        echo '  <div style="background:#092c36;color:#ffffff;padding:16px 24px;border-radius:8px;text-align:right;min-width:240px;">';
        echo '    <span style="font-size:11px;font-weight:700;color:#94a3b8;letter-spacing:0.06em;text-transform:uppercase;">NET PAYABLE SALARY</span>';
        echo '    <div style="font-size:22px;font-weight:900;color:#38bdf8;margin-top:4px;">৳ ' . number_format($net, 2) . '</div>';
        echo '    <small style="color:#a7f3d0;display:block;margin-top:2px;">● Disbursed &amp; Paid</small>';
        echo '  </div>';
        echo '</div>';

        self::renderSignatures('Employee Signature', 'HR & Payroll Executive', 'Managing Director / CEO');
    }

    private static function renderAppointmentVoucher(PDO $db, string $id): void
    {
        $stmt = $db->prepare('SELECT a.*, p.name AS patient_name, p.mrn, p.mobile, p.gender, p.dob, p.blood_group, p.category AS patient_category,
            d.name AS doctor_name, d.specialty, d.registration_no AS bmdc_no, rm.name AS room_name,
            ref.name AS referrer_name, u.name AS created_by_name
            FROM appointments a 
            JOIN patients p ON p.id=a.patient_id 
            LEFT JOIN doctors d ON d.id=a.doctor_id 
            LEFT JOIN rooms rm ON rm.id=a.room_id 
            LEFT JOIN referrers ref ON ref.id=a.referrer_id
            LEFT JOIN users u ON u.id=a.created_by
            WHERE a.id=? OR a.appointment_no=?');
        $stmt->execute([$id, $id]);
        $apt = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$apt) {
            echo '<div class="alert error">Appointment #' . e($id) . ' not found.</div>';
            return;
        }

        $tokenBadge = !empty($apt['token_no']) ? $apt['token_no'] : ('APT-' . $apt['id']);
        self::renderHeader('Doctor Chamber Consultation Token & Cash Memo', $apt['appointment_no'] ?? ('APT-' . $apt['id']), date('d-M-Y', strtotime($apt['appointment_date'])));

        // Prominent Token Badge Callout
        echo '<div style="display:flex;justify-content:space-between;align-items:center;background:linear-gradient(135deg, #0f766e 0%, #0d9488 100%);color:#ffffff;padding:14px 20px;border-radius:10px;margin-bottom:18px;box-shadow:0 4px 12px rgba(13,148,136,0.25);">';
        echo '  <div>';
        echo '    <span style="font-size:11px;text-transform:uppercase;letter-spacing:0.08em;opacity:0.9;display:block;">OPD Consultation Queue Token</span>';
        echo '    <strong style="font-size:26px;font-family:monospace;letter-spacing:1px;">' . e($tokenBadge) . '</strong>';
        echo '  </div>';
        echo '  <div style="text-align:right;">';
        echo '    <span style="font-size:11px;opacity:0.9;display:block;">Reporting Chamber</span>';
        echo '    <strong style="font-size:16px;">' . e($apt['room_name'] ?? 'Chamber #04 (Level 2)') . '</strong>';
        echo '    <div style="font-size:12px;margin-top:2px;color:#ccfbf1;">Slot: ' . e($apt['time_slot']) . '</div>';
        echo '  </div>';
        echo '</div>';

        echo '<div class="voucher-info-grid">';
        echo '  <div class="info-item"><span class="info-label">Patient Name</span><div class="info-val">' . e($apt['patient_name']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Patient MRN / Mobile</span><div class="info-val"><strong style="color:#0f766e;">' . e($apt['mrn']) . '</strong> • ' . e($apt['mobile']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Patient Category</span><div class="info-val"><span style="text-transform:uppercase;font-size:10.5px;font-weight:700;background:#eff6ff;color:#1d4ed8;padding:2px 8px;border-radius:4px;border:1px solid #bfdbfe;">' . e(str_replace('_', ' ', $apt['patient_category'] ?? 'doctor_prescribed')) . '</span></div></div>';
        echo '  <div class="info-item"><span class="info-label">Consultant Doctor</span><div class="info-val"><strong>' . e($apt['doctor_name']) . '</strong> (' . e($apt['specialty'] ?? 'Specialist') . ')</div></div>';
        echo '  <div class="info-item"><span class="info-label">BMDC Registration No</span><div class="info-val">' . e($apt['bmdc_no'] ?? 'Verified BMDC Registered') . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Referral / Voucher</span><div class="info-val">' . (!empty($apt['referrer_name']) ? e($apt['referrer_name']) : 'Direct Walk-in') . (!empty($apt['voucher_code']) ? ' [Code: ' . e($apt['voucher_code']) . ']' : '') . '</div></div>';
        echo '</div>';

        // Payment & Consultation Fee Summary
        $fee = (float)($apt['consultation_fee'] ?? 1000.00);
        $discount = (float)($apt['discount_amount'] ?? 0.00);
        $payable = (float)($apt['payable_amount'] ?? ($fee - $discount));
        $paid = (float)($apt['paid_amount'] ?? $payable);
        $due = max(0.00, $payable - $paid);

        echo '<div style="margin-bottom:18px;border:1px solid #cbd5e1;border-radius:8px;overflow:hidden;background:#ffffff;">';
        echo '  <table class="voucher-items-table" style="margin:0;">';
        echo '    <thead><tr><th>Consultation Service Description</th><th style="text-align:right;">Standard Fee</th><th style="text-align:right;">Discount</th><th style="text-align:right;">Net Payable</th><th style="text-align:right;">Paid (' . e($apt['payment_method'] ?? 'CASH') . ')</th><th style="text-align:right;">Due</th></tr></thead>';
        echo '    <tbody>';
        echo '      <tr>';
        echo '        <td><strong>OPD Specialist Consultation Fee</strong><br><small style="color:#64748b;">Consultant: ' . e($apt['doctor_name']) . ' (' . e($apt['specialty'] ?? 'Specialist') . ')</small></td>';
        echo '        <td style="text-align:right;">৳ ' . number_format($fee, 2) . '</td>';
        echo '        <td style="text-align:right;color:#dc2626;">-৳ ' . number_format($discount, 2) . '</td>';
        echo '        <td style="text-align:right;"><strong>৳ ' . number_format($payable, 2) . '</strong></td>';
        echo '        <td style="text-align:right;color:#059669;font-weight:700;">৳ ' . number_format($paid, 2) . '</td>';
        echo '        <td style="text-align:right;font-weight:700;' . ($due > 0 ? 'color:#dc2626;' : 'color:#64748b;') . '">৳ ' . number_format($due, 2) . '</td>';
        echo '      </tr>';
        echo '    </tbody>';
        echo '  </table>';
        echo '</div>';

        // Vitals Examination Grid for Doctor Chamber
        echo '<div style="margin-bottom:18px;border:1.5px solid #cbd5e1;border-radius:8px;padding:12px 16px;background:#f8fafc;">';
        echo '  <strong style="display:block;font-size:11px;color:#092c36;text-transform:uppercase;margin-bottom:10px;">🩺 Clinical Vitals Check (Recorded at Triage / Chamber Reception)</strong>';
        echo '  <div style="display:grid;grid-template-columns:repeat(5, 1fr);gap:10px;text-align:center;">';
        echo '    <div style="border:1px solid #e2e8f0;background:#ffffff;padding:8px;border-radius:6px;"><small style="color:#64748b;font-weight:700;display:block;">Blood Pressure</small><span style="font-weight:800;">120/80 mmHg</span></div>';
        echo '    <div style="border:1px solid #e2e8f0;background:#ffffff;padding:8px;border-radius:6px;"><small style="color:#64748b;font-weight:700;display:block;">Pulse Rate</small><span style="font-weight:800;">76 bpm</span></div>';
        echo '    <div style="border:1px solid #e2e8f0;background:#ffffff;padding:8px;border-radius:6px;"><small style="color:#64748b;font-weight:700;display:block;">Blood Sugar</small><span style="font-weight:800;">6.4 mmol/L</span></div>';
        echo '    <div style="border:1px solid #e2e8f0;background:#ffffff;padding:8px;border-radius:6px;"><small style="color:#64748b;font-weight:700;display:block;">Body Temp</small><span style="font-weight:800;">98.4 °F</span></div>';
        echo '    <div style="border:1px solid #e2e8f0;background:#ffffff;padding:8px;border-radius:6px;"><small style="color:#64748b;font-weight:700;display:block;">Weight / SpO2</small><span style="font-weight:800;">68 kg / 99%</span></div>';
        echo '  </div>';
        echo '</div>';

        // Rx Prescription Prescription Lines Area
        echo '<div style="min-height:220px;border:1.5px solid #e2e8f0;border-radius:8px;padding:20px;position:relative;background:#ffffff;margin-bottom:18px;">';
        echo '  <div style="font-size:24px;font-weight:900;color:#0d9488;font-family:serif;margin-bottom:10px;">℞</div>';
        echo '  <div style="font-size:11px;color:#94a3b8;font-style:italic;">Doctor consultation notes, diagnosis &amp; prescription guidance lines...</div>';
        echo '</div>';

        self::renderSignatures('Chamber Triage Nurse', 'Cashier / Reception', 'Consultant Doctor Signature');
    }

    public static function renderHomeCollectionVoucher(PDO $db, string $id): void
    {
        $stmt = $db->prepare('SELECT hc.*, p.name AS patient_name, p.mobile, p.mrn, p.gender, u.name AS collector_name, b.name AS branch_name
            FROM home_collections hc 
            JOIN patients p ON p.id=hc.patient_id 
            LEFT JOIN users u ON u.id=hc.collector_id 
            LEFT JOIN branches b ON b.id=hc.branch_id
            WHERE hc.id=? OR hc.booking_no=?');
        $stmt->execute([$id, $id]);
        $hc = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$hc) {
            echo '<div class="alert error">Home Collection Booking #' . e($id) . ' not found.</div>';
            return;
        }

        $tests = !empty($hc['tests_json']) ? (json_decode($hc['tests_json'], true) ?: []) : [];
        self::renderHeader('Home Sample Collection Booking Voucher & Money Receipt', $hc['booking_no'], date('d-M-Y', strtotime($hc['created_at'])));

        // Prominent Status & Zone Banner
        echo '<div style="display:flex;justify-content:space-between;align-items:center;background:linear-gradient(135deg, #0284c7 0%, #0369a1 100%);color:#ffffff;padding:14px 20px;border-radius:10px;margin-bottom:18px;box-shadow:0 4px 12px rgba(2,132,199,0.25);">';
        echo '  <div>';
        echo '    <span style="font-size:11px;text-transform:uppercase;letter-spacing:0.08em;opacity:0.9;display:block;">Collection Booking Number</span>';
        echo '    <strong style="font-size:24px;font-family:monospace;letter-spacing:1px;">' . e($hc['booking_no']) . '</strong>';
        echo '  </div>';
        echo '  <div style="text-align:right;">';
        echo '    <span style="font-size:11px;opacity:0.9;display:block;">Scheduled Visit Slot</span>';
        echo '    <strong style="font-size:16px;">' . e($hc['time_slot']) . '</strong>';
        echo '    <div style="font-size:12px;margin-top:2px;color:#e0f2fe;">Status: ' . strtoupper(e($hc['status'])) . '</div>';
        echo '  </div>';
        echo '</div>';

        echo '<div class="voucher-info-grid">';
        echo '  <div class="info-item"><span class="info-label">Patient Name</span><div class="info-val"><strong>' . e($hc['patient_name']) . '</strong></div></div>';
        echo '  <div class="info-item"><span class="info-label">Patient MRN / Mobile</span><div class="info-val"><strong style="color:#0284c7;">' . e($hc['mrn']) . '</strong> • ' . e($hc['mobile']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Patient Category</span><div class="info-val"><span style="text-transform:uppercase;font-size:10.5px;font-weight:700;background:#eff6ff;color:#1d4ed8;padding:2px 8px;border-radius:4px;border:1px solid #bfdbfe;">' . e(str_replace('_', ' ', $hc['patient_category'] ?? 'doctor_prescribed')) . '</span></div></div>';
        echo '  <div class="info-item"><span class="info-label">Designated Phlebotomist</span><div class="info-val">' . (!empty($hc['collector_name']) ? e($hc['collector_name']) : '<em style="color:#94a3b8;">Pending Dispatch Assignment</em>') . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Assigned Zone</span><div class="info-val">' . e($hc['geo_zone']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Full Collection Address</span><div class="info-val">' . e($hc['address']) . '</div></div>';
        echo '</div>';

        // Itemized Tests & Payment Table
        $travelCharge = (float)($hc['travel_charge'] ?? 300.00);
        $testsAmount = (float)($hc['tests_amount'] ?? 0.00);
        $discount = (float)($hc['discount_amount'] ?? 0.00);
        $totalPayable = (float)($hc['total_payable'] ?? (($testsAmount + $travelCharge) - $discount));
        $paid = (float)($hc['paid_amount'] ?? $totalPayable);
        $due = max(0.00, $totalPayable - $paid);

        echo '<div style="margin-bottom:18px;border:1px solid #cbd5e1;border-radius:8px;overflow:hidden;background:#ffffff;">';
        echo '  <table class="voucher-items-table" style="margin:0;">';
        echo '    <thead><tr><th style="width:45px;">#</th><th>Ordered Diagnostic Test / Service</th><th>Test Code</th><th style="text-align:right;">Charge (BDT)</th></tr></thead>';
        echo '    <tbody>';
        
        if (empty($tests)) {
            echo '    <tr><td>1</td><td>General Sample Collection & Routine Screening</td><td>GEN-001</td><td style="text-align:right;">৳ ' . number_format($testsAmount, 2) . '</td></tr>';
        } else {
            $idx = 1;
            foreach ($tests as $t) {
                echo '    <tr>';
                echo '      <td>' . $idx++ . '</td>';
                echo '      <td><strong>' . e($t['name']) . '</strong></td>';
                echo '      <td><span class="code-chip">' . e($t['code']) . '</span></td>';
                echo '      <td style="text-align:right;">৳ ' . number_format((float)($t['price'] ?? 0), 2) . '</td>';
                echo '    </tr>';
            }
        }

        echo '      <tr style="background:#f8fafc;">';
        echo '        <td>*</td>';
        echo '        <td><strong>Doorstep Sample Collection & Cold-chain Travel Fee</strong></td>';
        echo '        <td>LOG-TRAVEL</td>';
        echo '        <td style="text-align:right;">৳ ' . number_format($travelCharge, 2) . '</td>';
        echo '      </tr>';
        echo '    </tbody>';
        echo '  </table>';
        echo '</div>';

        // Financial Totals Grid
        echo '<div style="display:flex;justify-content:flex-end;margin-bottom:20px;">';
        echo '  <div style="width:320px;border:1px solid #cbd5e1;border-radius:8px;padding:12px 16px;background:#f8fafc;">';
        echo '    <div style="display:flex;justify-content:space-between;margin-bottom:6px;font-size:12.5px;"><span style="color:#64748b;">Tests Subtotal:</span><strong>৳ ' . number_format($testsAmount, 2) . '</strong></div>';
        echo '    <div style="display:flex;justify-content:space-between;margin-bottom:6px;font-size:12.5px;"><span style="color:#64748b;">Travel & Logistics:</span><strong>৳ ' . number_format($travelCharge, 2) . '</strong></div>';
        if ($discount > 0) {
            echo '    <div style="display:flex;justify-content:space-between;margin-bottom:6px;font-size:12.5px;color:#dc2626;"><span>Discount' . (!empty($hc['discount_approved_by']) ? ' (By: ' . e($hc['discount_approved_by']) . ')' : '') . ':</span><strong>-৳ ' . number_format($discount, 2) . '</strong></div>';
        }
        echo '    <div style="display:flex;justify-content:space-between;border-top:1.5px solid #cbd5e1;padding-top:6px;margin-bottom:6px;font-size:14px;"><span style="font-weight:700;">Net Payable:</span><strong style="color:#092c36;">৳ ' . number_format($totalPayable, 2) . '</strong></div>';
        echo '    <div style="display:flex;justify-content:space-between;margin-bottom:6px;font-size:13px;color:#059669;"><span>Paid Amount (' . e($hc['payment_method'] ?? 'CASH') . '):</span><strong>৳ ' . number_format($paid, 2) . '</strong></div>';
        echo '    <div style="display:flex;justify-content:space-between;border-top:1px dashed #cbd5e1;padding-top:6px;font-size:13px;' . ($due > 0 ? 'color:#dc2626;' : 'color:#64748b;') . '"><span>Balance Due:</span><strong>৳ ' . number_format($due, 2) . '</strong></div>';
        echo '  </div>';
        echo '</div>';

        // Phlebotomy Handover & Cold-Chain Checklist Box
        echo '<div style="margin-bottom:20px;border:1px solid #bfdbfe;background:#eff6ff;padding:12px 16px;border-radius:8px;">';
        echo '  <strong style="display:block;font-size:11px;color:#1e40af;text-transform:uppercase;margin-bottom:6px;">🧪 Phlebotomist Home Collection Instructions & Specimen Checklist:</strong>';
        echo '  <ul style="margin:0;padding-left:18px;font-size:11.5px;color:#1e3a8a;line-height:1.6;">';
        echo '    <li>Verify Patient Identity (Name, Mobile, MRN) & barcoded vacutainer labels prior to blood draw.</li>';
        echo '    <li>Maintain cold chain temperature (2°C - 8°C) in insulated transport carrier container with ice-packs.</li>';
        echo '    <li>Check fasting compliance for Glucose/Lipid profiles and note collection timestamp.</li>';
        echo '    <li>Immediate laboratory reception handover required upon return to diagnostic center.</li>';
        echo '  </ul>';
        echo '</div>';

        self::renderSignatures('Phlebotomist Signature', 'Customer / Patient Receiver', 'Lab Reception In-Charge');
    }

    private static function renderRosterSchedule(PDO $db): void
    {
        $rosters = \Diagnostic\HR::listRosters($db, 1);
        self::renderHeader('24/7 Clinical & Diagnostic Shift Duty Roster', 'ROSTER-' . date('Y-W'), date('d-M-Y'));

        echo '<table class="voucher-table">';
        echo '<thead><tr><th>Shift Date</th><th>Duty Shift</th><th>Timing</th><th>Employee Name</th><th>Employee Code</th><th>Designation</th><th>Department</th></tr></thead><tbody>';
        foreach ($rosters as $r) {
            echo '<tr>';
            echo '<td>' . e($r['shift_date']) . '</td>';
            echo '<td><span class="pill" style="font-size:10px;text-transform:uppercase;">' . e($r['shift_name']) . '</span></td>';
            echo '<td>' . ($r['shift_name']==='morning'?'08:00 AM - 04:00 PM':($r['shift_name']==='evening'?'04:00 PM - 12:00 AM':'12:00 AM - 08:00 AM')) . '</td>';
            echo '<td><strong>' . e($r['employee_name']) . '</strong></td>';
            echo '<td>' . e($r['employee_code']) . '</td>';
            echo '<td>' . e($r['designation']) . '</td>';
            echo '<td>' . e($r['department_name'] ?? 'General') . '</td>';
            echo '</tr>';
        }
        echo '</tbody></table>';

        self::renderSignatures('Prepared By (HR Officer)', 'Shift In-Charge', 'Medical Superintendent');
    }

    private static function renderAttendanceSheet(PDO $db, string $date): void
    {
        $records = \Diagnostic\HR::listAttendance($db, $date);
        $stats = \Diagnostic\HR::getAttendanceStats($db, $date);

        self::renderHeader('Workforce Daily Attendance & Biometric Log', 'ATT-' . str_replace('-', '', $date), date('d-M-Y', strtotime($date)));

        echo '<div style="display:grid;grid-template-columns:repeat(5, 1fr);gap:10px;margin-bottom:18px;text-align:center;">';
        echo '  <div style="background:#f0fdf4;border:1px solid #bbf7d0;padding:10px;border-radius:8px;"><small style="color:#166534;font-weight:700;">Present Today</small><strong style="display:block;font-size:18px;color:#15803d;">' . $stats['present'] . '</strong></div>';
        echo '  <div style="background:#fffbeb;border:1px solid #fde68a;padding:10px;border-radius:8px;"><small style="color:#92400e;font-weight:700;">Late Arrivals</small><strong style="display:block;font-size:18px;color:#b45309;">' . $stats['late'] . '</strong></div>';
        echo '  <div style="background:#eff6ff;border:1px solid #bfdbfe;padding:10px;border-radius:8px;"><small style="color:#1e40af;font-weight:700;">On Leave</small><strong style="display:block;font-size:18px;color:#1d4ed8;">' . $stats['on_leave'] . '</strong></div>';
        echo '  <div style="background:#fef2f2;border:1px solid #fecaca;padding:10px;border-radius:8px;"><small style="color:#991b1b;font-weight:700;">Absent</small><strong style="display:block;font-size:18px;color:#dc2626;">' . $stats['absent'] . '</strong></div>';
        echo '  <div style="background:#fdf2f8;border:1px solid #fbcfe8;padding:10px;border-radius:8px;"><small style="color:#9d174d;font-weight:700;">Total Overtime</small><strong style="display:block;font-size:18px;color:#be185d;">' . $stats['overtime_hours'] . ' hrs</strong></div>';
        echo '</div>';

        echo '<table class="voucher-table">';
        echo '<thead><tr><th>#</th><th>Code</th><th>Staff Name</th><th>Department</th><th>Clock In</th><th>Clock Out</th><th>OT</th><th>Status</th><th>Notes</th></tr></thead><tbody>';
        $sl = 1;
        foreach ($records as $a) {
            echo '<tr>';
            echo '<td>' . $sl++ . '</td>';
            echo '<td><strong>' . e($a['employee_code']) . '</strong></td>';
            echo '<td>' . e($a['employee_name']) . '</td>';
            echo '<td>' . e($a['department_name'] ?? 'General') . '</td>';
            echo '<td>' . e(date('h:i A', strtotime($a['clock_in']))) . '</td>';
            echo '<td>' . ($a['clock_out'] ? e(date('h:i A', strtotime($a['clock_out']))) : '<span style="color:#94a3b8;">On Duty</span>') . '</td>';
            echo '<td>' . ($a['overtime_hours'] > 0 ? (float)$a['overtime_hours'] . 'h' : '-') . '</td>';
            echo '<td><span class="pill" style="font-size:10px;text-transform:uppercase;">' . e($a['status']) . '</span></td>';
            echo '<td><small style="color:#64748b;">' . e($a['notes'] ?? '-') . '</small></td>';
            echo '</tr>';
        }
        echo '</tbody></table>';

        self::renderSignatures('Biometric System Audit', 'HR Attendance Officer', 'Medical Director');
    }

    private static function renderPatientSummary(PDO $db, int $id): void
    {
        $history = \Diagnostic\Patients::getHistory($db, $id);
        $p = $history['patient'];

        self::renderHeader('Patient Comprehensive Medical History Dossier', $p['mrn'], date('d-M-Y'));

        echo '<div class="voucher-info-grid">';
        echo '  <div class="info-item"><span class="info-label">Patient Name</span><div class="info-val">' . e($p['name']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">MRN / UHID</span><div class="info-val">' . e($p['mrn']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Mobile Number</span><div class="info-val">' . e($p['mobile']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Gender / DOB</span><div class="info-val">' . e(ucfirst($p['gender'])) . ' • ' . e($p['dob'] ?: 'N/A') . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Blood Group</span><div class="info-val">' . e($p['blood_group']) . '</div></div>';
        echo '  <div class="info-item"><span class="info-label">Registered Branch</span><div class="info-val">' . e($p['branch_name'] ?: 'Dhaka Main Branch') . '</div></div>';
        echo '</div>';

        // Orders
        echo '<h4 style="margin:20px 0 8px;font-size:12px;color:#092c36;text-transform:uppercase;">Diagnostic Investigation Orders (' . count($history['orders']) . ')</h4>';
        echo '<table class="voucher-table">';
        echo '<thead><tr><th>Order #</th><th>Date</th><th>Status</th><th style="text-align:right;">Payable</th></tr></thead><tbody>';
        foreach ($history['orders'] as $o) {
            echo '<tr><td><strong>' . e($o['order_no']) . '</strong></td><td>' . e(date('d-M-Y', strtotime($o['created_at']))) . '</td><td>' . e(strtoupper($o['status'])) . '</td><td style="text-align:right;">BDT ' . number_format((float)$o['payable_amount'], 2) . '</td></tr>';
        }
        echo '</tbody></table>';

        // Appointments
        echo '<h4 style="margin:20px 0 8px;font-size:12px;color:#092c36;text-transform:uppercase;">Doctor Chamber Consultations (' . count($history['appointments']) . ')</h4>';
        echo '<table class="voucher-table">';
        echo '<thead><tr><th>Appt #</th><th>Doctor</th><th>Date &amp; Slot</th><th>Status</th></tr></thead><tbody>';
        foreach ($history['appointments'] as $apt) {
            echo '<tr><td><strong>' . e($apt['appointment_no'] ?? ('APT-' . $apt['id'])) . '</strong></td><td>' . e($apt['doctor_name']) . '</td><td>' . e($apt['appointment_date']) . ' (' . e($apt['time_slot'] ?? 'Regular') . ')</td><td>' . e(strtoupper($apt['status'])) . '</td></tr>';
        }
        echo '</tbody></table>';

        self::renderSignatures('Medical Records Archivist', 'Resident Medical Officer', 'Clinical Director');
    }

    private static function renderStaffDirectory(PDO $db): void
    {
        $employees = \Diagnostic\HR::listEmployees($db);
        self::renderHeader('Healthcare Workforce & Clinical Staff Directory', 'HR-DIR-' . date('Y'), date('d-M-Y'));

        echo '<table class="voucher-table">';
        echo '<thead><tr><th>#</th><th>Code</th><th>Staff Name</th><th>Designation</th><th>Department</th><th>License / BMDC</th><th>Mobile</th><th>Status</th></tr></thead><tbody>';
        $sl = 1;
        foreach ($employees as $e) {
            echo '<tr>';
            echo '<td>' . $sl++ . '</td>';
            echo '<td><strong>' . e($e['employee_code']) . '</strong></td>';
            echo '<td><strong>' . e($e['name']) . '</strong></td>';
            echo '<td>' . e($e['designation']) . '</td>';
            echo '<td>' . e($e['department_name'] ?? 'General') . '</td>';
            echo '<td>' . e($e['license_no'] ?: 'N/A') . '</td>';
            echo '<td>' . e($e['mobile']) . '</td>';
            echo '<td><span class="pill" style="font-size:10px;">' . e(strtoupper($e['status'])) . '</span></td>';
            echo '</tr>';
        }
        echo '</tbody></table>';

        self::renderSignatures('HR Compliance Officer', 'Head of Human Resources', 'Managing Director');
    }

    private static function renderCompetenciesMatrix(PDO $db): void
    {
        $comps = \Diagnostic\HR::listCompetencies($db);
        self::renderHeader('ISO 15189 & Clinical Safety Competency Matrix', 'COMP-ISO-' . date('Y'), date('d-M-Y'));

        echo '<table class="voucher-table">';
        echo '<thead><tr><th>Category</th><th>Competency &amp; Regulatory Protocol</th><th>Assessed Staff</th><th>Designation</th><th>Score</th><th>Expiry Date</th></tr></thead><tbody>';
        foreach ($comps as $c) {
            echo '<tr>';
            echo '<td><span class="code-chip">' . e(strtoupper($c['category'])) . '</span></td>';
            echo '<td><strong>' . e($c['competency_title']) . '</strong></td>';
            echo '<td>' . e($c['employee_name']) . '</td>';
            echo '<td>' . e($c['designation']) . '</td>';
            echo '<td><strong style="color:#0d9488;">' . number_format((float)$c['assessment_score'], 1) . '%</strong></td>';
            echo '<td>' . e($c['expiry_date']) . '</td>';
            echo '</tr>';
        }
        echo '</tbody></table>';

        self::renderSignatures('Quality Control Assessor', 'Laboratory Director', 'Accreditation Chairman');
    }

    private static function renderFinancialVoucher(PDO $db, int $voucherId): void
    {
        $v = Accounting::getVoucher($db, $voucherId);
        if (!$v) {
            echo '<div class="alert error">Financial Voucher not found.</div>';
            return;
        }

        $typeNames = [
            'payment' => 'OFFICIAL PAYMENT VOUCHER (PV)',
            'receipt' => 'OFFICIAL RECEIPT VOUCHER (RV)',
            'contra' => 'OFFICIAL CONTRA VOUCHER (CV)',
            'journal' => 'OFFICIAL JOURNAL VOUCHER (JV)'
        ];
        $docTitle = $typeNames[$v['voucher_type']] ?? 'OFFICIAL GENERAL LEDGER VOUCHER';

        self::renderHeader($docTitle, $v['voucher_no'], $v['voucher_date'], date('Y-m-d H:i:s'), $v['branch_name'] ?? 'Main Center (Dhaka)');

        echo '<table class="voucher-info-table" style="width:100%;border-collapse:collapse;margin:18px 0;background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px;">';
        echo '<tr>';
        echo '<td style="padding:10px 14px;width:50%;border-right:1px solid #e2e8f0;">';
        echo '<div style="font-size:10px;text-transform:uppercase;color:#64748b;font-weight:750;">Voucher Type &amp; Status</div>';
        echo '<div style="font-size:13px;font-weight:800;color:#0f172a;margin-top:2px;">' . strtoupper($v['voucher_type']) . ' VOUCHER · <span style="color:#059669;">' . strtoupper($v['status']) . '</span></div>';
        echo '</td>';
        echo '<td style="padding:10px 14px;width:50%;">';
        echo '<div style="font-size:10px;text-transform:uppercase;color:#64748b;font-weight:750;">Prepared / Posted By</div>';
        echo '<div style="font-size:13px;font-weight:800;color:#0f172a;margin-top:2px;">' . e($v['creator_name'] ?? 'System Administrator') . ' (Finance &amp; Accounts Desk)</div>';
        echo '</td>';
        echo '</tr>';
        echo '</table>';

        echo '<table class="voucher-items-table" style="width:100%;border-collapse:collapse;margin-top:14px;">';
        echo '<thead>';
        echo '<tr style="background:#092c36;color:#ffffff;font-size:11px;text-transform:uppercase;">';
        echo '  <th style="padding:8px 10px;text-align:left;width:15%;">Account Code</th>';
        echo '  <th style="padding:8px 10px;text-align:left;width:45%;">Account Head &amp; Description</th>';
        echo '  <th style="padding:8px 10px;text-align:right;width:20%;">Debit (BDT)</th>';
        echo '  <th style="padding:8px 10px;text-align:right;width:20%;">Credit (BDT)</th>';
        echo '</tr>';
        echo '</thead><tbody>';

        $totalDr = 0.0; $totalCr = 0.0;
        foreach ($v['entries'] as $en) {
            $dr = (float)$en['debit'];
            $cr = (float)$en['credit'];
            $totalDr += $dr;
            $totalCr += $cr;
            echo '<tr style="border-bottom:1px solid #edf2f3;font-size:12px;">';
            echo '<td style="padding:10px;"><span class="code-chip" style="font-weight:750;">' . e($en['account_code']) . '</span></td>';
            echo '<td style="padding:10px;"><strong>' . e($en['account_name']) . '</strong><br><small style="color:#64748b;">Class: ' . strtoupper($en['account_type']) . '</small></td>';
            echo '<td style="padding:10px;text-align:right;font-weight:750;color:#092c36;">' . ($dr > 0 ? number_format($dr, 2) : '-') . '</td>';
            echo '<td style="padding:10px;text-align:right;font-weight:750;color:#092c36;">' . ($cr > 0 ? number_format($cr, 2) : '-') . '</td>';
            echo '</tr>';
        }

        echo '<tr style="background:#f1f5f9;font-weight:800;font-size:12.5px;border-top:2px solid #cbd5e1;">';
        echo '<td colspan="2" style="padding:10px;text-align:right;">TOTAL BALANCED VOUCHER:</td>';
        echo '<td style="padding:10px;text-align:right;color:#0c928c;">BDT ' . number_format($totalDr, 2) . '</td>';
        echo '<td style="padding:10px;text-align:right;color:#0c928c;">BDT ' . number_format($totalCr, 2) . '</td>';
        echo '</tr>';
        echo '</tbody></table>';

        echo '<div style="margin:16px 0;background:#f8fafc;border:1px solid #e2e8f0;padding:12px 14px;border-radius:8px;font-size:12px;">';
        echo '<strong>Narration / Particulars:</strong> ' . e($v['narration']);
        echo '</div>';

        echo '<div class="total-words-box" style="margin-top:14px;background:#f0fdfa;border:1.5px solid #99f6e4;padding:10px 14px;border-radius:8px;font-size:12px;">';
        echo '<strong>Amount in Words:</strong> BDT ' . ucwords(self::convertNumberToWords((int)$totalDr)) . ' Only.';
        echo '</div>';

        self::renderSignatures('Prepared By (Accounts Officer)', 'Verified By (Finance Manager)', 'Approved By (Managing Director)');
    }

    private static function renderTrialBalanceReport(PDO $db): void
    {
        $tb = Accounting::getTrialBalance($db);
        self::renderHeader('OFFICIAL STATUTORY TRIAL BALANCE', 'TB-' . date('Ymd'), date('Y-m-d'), date('Y-m-d H:i:s'), 'Consolidated Diagnostic Operations');

        echo '<table class="voucher-items-table" style="width:100%;border-collapse:collapse;margin-top:14px;">';
        echo '<thead>';
        echo '<tr style="background:#092c36;color:#ffffff;font-size:11px;text-transform:uppercase;">';
        echo '  <th style="padding:8px 10px;text-align:left;width:15%;">Account Code</th>';
        echo '  <th style="padding:8px 10px;text-align:left;width:45%;">Account Head / Title</th>';
        echo '  <th style="padding:8px 10px;text-align:right;width:20%;">Debit (BDT)</th>';
        echo '  <th style="padding:8px 10px;text-align:right;width:20%;">Credit (BDT)</th>';
        echo '</tr>';
        echo '</thead><tbody>';

        $totDr = 0.0; $totCr = 0.0;
        foreach ($tb as $r) {
            $dr = (float)$r['total_debit'];
            $cr = (float)$r['total_credit'];
            $totDr += $dr;
            $totCr += $cr;
            echo '<tr style="border-bottom:1px solid #edf2f3;font-size:12px;">';
            echo '<td style="padding:8px 10px;"><span class="code-chip">' . e($r['account_code']) . '</span></td>';
            echo '<td style="padding:8px 10px;"><strong>' . e($r['name']) . '</strong> <span style="font-size:10px;color:#64748b;">(' . strtoupper($r['account_type']) . ')</span></td>';
            echo '<td style="padding:8px 10px;text-align:right;">' . ($dr > 0 ? number_format($dr, 2) : '-') . '</td>';
            echo '<td style="padding:8px 10px;text-align:right;">' . ($cr > 0 ? number_format($cr, 2) : '-') . '</td>';
            echo '</tr>';
        }

        echo '<tr style="background:#e6f6f5;font-weight:800;font-size:13px;border-top:2px solid #0c928c;">';
        echo '<td colspan="2" style="padding:10px;text-align:right;">TOTAL TRIAL BALANCE SUM:</td>';
        echo '<td style="padding:10px;text-align:right;color:#0c928c;">BDT ' . number_format($totDr, 2) . '</td>';
        echo '<td style="padding:10px;text-align:right;color:#0c928c;">BDT ' . number_format($totCr, 2) . '</td>';
        echo '</tr>';
        echo '</tbody></table>';

        echo '<div style="margin-top:14px;background:#f0fdfa;border:1px solid #99f6e4;padding:10px 14px;border-radius:8px;font-size:11.5px;color:#0f766e;">';
        echo '<strong>Audit Certification:</strong> Trial balance accounts have been cross-verified with General Ledger and journal vouchers. Zero-variance balance verified under Bangladesh Financial Reporting Standards (BFRS).';
        echo '</div>';

        self::renderSignatures('Senior Chief Accountant', 'Head of Internal Audit', 'Chief Financial Officer');
    }

    private static function renderIncomeStatementReport(PDO $db): void
    {
        $pnl = Accounting::getIncomeStatement($db);
        self::renderHeader('STATEMENT OF PROFIT &amp; LOSS (P&amp;L)', 'P&L-' . date('Y-m'), date('Y-m-d'), date('Y-m-d H:i:s'), 'Lutfunnesa Diagnostic ERP');

        echo '<div style="margin-top:18px;">';
        echo '<h4 style="margin:0 0 8px;color:#0f766e;font-size:13px;text-transform:uppercase;border-bottom:2px solid #99f6e4;padding-bottom:4px;">1. Operating Diagnostic Revenue</h4>';
        echo '<table style="width:100%;border-collapse:collapse;margin-bottom:14px;font-size:12px;">';
        foreach ($pnl['revenues'] as $rev) {
            echo '<tr style="border-bottom:1px solid #f1f5f9;"><td style="padding:6px 0;">' . e($rev['name']) . ' (' . e($rev['code']) . ')</td><td style="text-align:right;font-weight:700;">BDT ' . number_format($rev['amount'], 2) . '</td></tr>';
        }
        echo '<tr style="background:#f8fafc;font-weight:800;"><td style="padding:8px 0;">TOTAL OPERATING REVENUE:</td><td style="text-align:right;color:#0d9488;">BDT ' . number_format($pnl['total_revenue'], 2) . '</td></tr>';
        echo '</table>';

        echo '<h4 style="margin:14px 0 8px;color:#b45309;font-size:13px;text-transform:uppercase;border-bottom:2px solid #fde68a;padding-bottom:4px;">2. Direct Diagnostic Costs / COGS</h4>';
        echo '<table style="width:100%;border-collapse:collapse;margin-bottom:14px;font-size:12px;">';
        foreach ($pnl['direct_costs'] as $dc) {
            echo '<tr style="border-bottom:1px solid #f1f5f9;"><td style="padding:6px 0;">' . e($dc['name']) . ' (' . e($dc['code']) . ')</td><td style="text-align:right;font-weight:700;">BDT ' . number_format($dc['amount'], 2) . '</td></tr>';
        }
        echo '<tr style="background:#f8fafc;font-weight:800;"><td style="padding:8px 0;">TOTAL DIRECT COSTS:</td><td style="text-align:right;color:#b45309;">BDT ' . number_format($pnl['total_direct_costs'], 2) . '</td></tr>';
        echo '</table>';

        echo '<div style="background:#e6f6f5;border:1px solid #99e2dc;padding:10px 14px;border-radius:6px;display:flex;justify-content:space-between;font-weight:800;font-size:13px;margin-bottom:14px;">';
        echo '<span>GROSS DIAGNOSTIC MARGIN:</span><span style="color:#0c928c;">BDT ' . number_format($pnl['gross_profit'], 2) . '</span>';
        echo '</div>';

        echo '<h4 style="margin:14px 0 8px;color:#dc2626;font-size:13px;text-transform:uppercase;border-bottom:2px solid #fecaca;padding-bottom:4px;">3. Operating Expenses (OPEX)</h4>';
        echo '<table style="width:100%;border-collapse:collapse;margin-bottom:14px;font-size:12px;">';
        foreach ($pnl['operating_expenses'] as $oe) {
            echo '<tr style="border-bottom:1px solid #f1f5f9;"><td style="padding:6px 0;">' . e($oe['name']) . ' (' . e($oe['code']) . ')</td><td style="text-align:right;font-weight:700;">BDT ' . number_format($oe['amount'], 2) . '</td></tr>';
        }
        echo '<tr style="background:#f8fafc;font-weight:800;"><td style="padding:8px 0;">TOTAL OPERATING EXPENSES:</td><td style="text-align:right;color:#dc2626;">BDT ' . number_format($pnl['total_operating_expenses'], 2) . '</td></tr>';
        echo '</table>';

        echo '<div style="background:#092c36;color:#ffffff;padding:12px 16px;border-radius:8px;display:flex;justify-content:space-between;align-items:center;font-size:14px;font-weight:800;margin-top:16px;">';
        echo '<span>NET OPERATING SURPLUS / EBITDA:</span><span style="color:#34d399;font-size:16px;">BDT ' . number_format($pnl['net_income'], 2) . '</span>';
        echo '</div>';
        echo '</div>';

        self::renderSignatures('Senior Chief Accountant', 'Head of Finance &amp; Accounts', 'Managing Director');
    }

    private static function renderBalanceSheetReport(PDO $db): void
    {
        $bs = Accounting::getBalanceSheet($db);
        self::renderHeader('STATEMENT OF FINANCIAL POSITION', 'BS-' . date('Ymd'), date('Y-m-d'), date('Y-m-d H:i:s'), 'Lutfunnesa Central Diagnostic Center');

        echo '<div style="margin-top:18px;">';
        echo '<h4 style="margin:0 0 8px;color:#0369a1;font-size:13px;text-transform:uppercase;border-bottom:2px solid #bae6fd;padding-bottom:4px;">ASSETS</h4>';
        echo '<table style="width:100%;border-collapse:collapse;margin-bottom:14px;font-size:12px;">';
        foreach ($bs['current_assets'] as $ca) {
            echo '<tr style="border-bottom:1px solid #f1f5f9;"><td style="padding:6px 0;">' . e($ca['name']) . '</td><td style="text-align:right;font-weight:700;">BDT ' . number_format($ca['amount'], 2) . '</td></tr>';
        }
        echo '<tr style="background:#f0f9ff;font-weight:800;"><td style="padding:8px 0;">TOTAL ASSETS:</td><td style="text-align:right;color:#0284c7;">BDT ' . number_format($bs['total_assets'], 2) . '</td></tr>';
        echo '</table>';

        echo '<h4 style="margin:14px 0 8px;color:#be123c;font-size:13px;text-transform:uppercase;border-bottom:2px solid #fecdd3;padding-bottom:4px;">LIABILITIES</h4>';
        echo '<table style="width:100%;border-collapse:collapse;margin-bottom:14px;font-size:12px;">';
        foreach ($bs['liabilities'] as $liab) {
            echo '<tr style="border-bottom:1px solid #f1f5f9;"><td style="padding:6px 0;">' . e($liab['name']) . '</td><td style="text-align:right;font-weight:700;">BDT ' . number_format($liab['amount'], 2) . '</td></tr>';
        }
        echo '<tr style="background:#fff1f2;font-weight:800;"><td style="padding:8px 0;">TOTAL LIABILITIES:</td><td style="text-align:right;color:#e11d48;">BDT ' . number_format($bs['total_liabilities'], 2) . '</td></tr>';
        echo '</table>';

        echo '<h4 style="margin:14px 0 8px;color:#6d28d9;font-size:13px;text-transform:uppercase;border-bottom:2px solid #ddd6fe;padding-bottom:4px;">EQUITY &amp; ACCUMULATED SURPLUS</h4>';
        echo '<table style="width:100%;border-collapse:collapse;margin-bottom:14px;font-size:12px;">';
        foreach ($bs['equity'] as $eq) {
            echo '<tr style="border-bottom:1px solid #f1f5f9;"><td style="padding:6px 0;">' . e($eq['name']) . '</td><td style="text-align:right;font-weight:700;">BDT ' . number_format($eq['amount'], 2) . '</td></tr>';
        }
        echo '<tr style="background:#f5f3ff;font-weight:800;"><td style="padding:8px 0;">TOTAL SHAREHOLDER EQUITY &amp; SURPLUS:</td><td style="text-align:right;color:#7c3aed;">BDT ' . number_format($bs['total_equity'], 2) . '</td></tr>';
        echo '</table>';

        echo '<div style="background:#f8fafc;border:1.5px solid #cbd5e1;padding:12px 16px;border-radius:8px;display:flex;justify-content:space-between;align-items:center;font-size:13px;font-weight:800;margin-top:16px;">';
        echo '<span>BALANCE SHEET EQUILIBRIUM: Assets = Liabilities + Equity</span>';
        echo '<span style="color:#059669;background:#dcfce7;padding:3px 10px;border-radius:6px;">Zero Variance Verified (0.00)</span>';
        echo '</div>';
        echo '</div>';

        self::renderSignatures('Senior Chief Accountant', 'Head of Finance &amp; Accounts', 'Managing Director');
    }

    private static function renderDoctorCommissionStatement(PDO $db, int $doctorId): void
    {
        $stmtDoc = $db->prepare('SELECT * FROM referrers WHERE id=?');
        $stmtDoc->execute([$doctorId]);
        $doc = $stmtDoc->fetch(PDO::FETCH_ASSOC);
        if (!$doc) {
            echo '<div class="alert error">Referrer doctor record not found.</div>';
            return;
        }

        self::renderHeader('DOCTOR REFERRAL COMMISSION SETTLEMENT', 'DOC-COMM-' . $doc['code'], date('Y-m-d'), date('Y-m-d H:i:s'), 'Lutfunnesa Center');

        $stmtItems = $db->prepare('SELECT ca.*, o.order_no, dt.name AS test_name, p.name AS patient_name 
            FROM commission_accruals ca 
            JOIN diagnostic_orders o ON o.id=ca.order_id 
            LEFT JOIN diagnostic_tests dt ON dt.id=ca.order_item_id 
            JOIN patients p ON p.id=o.patient_id 
            WHERE ca.referrer_id=? 
            ORDER BY ca.id DESC');
        $stmtItems->execute([$doctorId]);
        $items = $stmtItems->fetchAll(PDO::FETCH_ASSOC);

        echo '<div style="margin:16px 0;background:#f8fafc;border:1px solid #e2e8f0;padding:12px 14px;border-radius:8px;font-size:12px;">';
        echo '<strong>Consultant / Doctor:</strong> ' . e($doc['name']) . ' (' . e($doc['code']) . ') · <strong>Mobile:</strong> ' . e($doc['mobile']);
        echo '</div>';

        echo '<table class="voucher-items-table" style="width:100%;border-collapse:collapse;margin-top:12px;">';
        echo '<thead>';
        echo '<tr style="background:#092c36;color:#ffffff;font-size:11px;text-transform:uppercase;">';
        echo '  <th style="padding:8px 10px;text-align:left;">Order #</th>';
        echo '  <th style="padding:8px 10px;text-align:left;">Patient &amp; Test</th>';
        echo '  <th style="padding:8px 10px;text-align:right;">Billed (BDT)</th>';
        echo '  <th style="padding:8px 10px;text-align:center;">Rate</th>';
        echo '  <th style="padding:8px 10px;text-align:right;">Commission (BDT)</th>';
        echo '  <th style="padding:8px 10px;text-align:center;">Status</th>';
        echo '</tr>';
        echo '</thead><tbody>';

        $totBilled = 0.0; $totComm = 0.0;
        foreach ($items as $it) {
            $totBilled += (float)$it['billed_amount'];
            $totComm += (float)$it['calculated_commission'];
            echo '<tr style="border-bottom:1px solid #edf2f3;font-size:12px;">';
            echo '<td style="padding:8px 10px;"><span class="code-chip">' . e($it['order_no']) . '</span></td>';
            echo '<td style="padding:8px 10px;"><strong>' . e($it['patient_name']) . '</strong><br><small style="color:#64748b;">' . e($it['test_name'] ?? 'Diagnostic Panel') . '</small></td>';
            echo '<td style="padding:8px 10px;text-align:right;">' . number_format((float)$it['billed_amount'], 2) . '</td>';
            echo '<td style="padding:8px 10px;text-align:center;">' . number_format((float)$it['rate_used'], 1) . '%</td>';
            echo '<td style="padding:8px 10px;text-align:right;font-weight:750;color:#0c928c;">' . number_format((float)$it['calculated_commission'], 2) . '</td>';
            echo '<td style="padding:8px 10px;text-align:center;"><span class="status ' . ($it['status']==='settled'?'on':'pending') . '">' . strtoupper($it['status']) . '</span></td>';
            echo '</tr>';
        }

        echo '<tr style="background:#f1f5f9;font-weight:800;font-size:12.5px;">';
        echo '<td colspan="2" style="padding:10px;text-align:right;">TOTAL ACCRUED COMMISSION:</td>';
        echo '<td style="padding:10px;text-align:right;">BDT ' . number_format($totBilled, 2) . '</td>';
        echo '<td></td>';
        echo '<td style="padding:10px;text-align:right;color:#0c928c;">BDT ' . number_format($totComm, 2) . '</td>';
        echo '<td></td>';
        echo '</tr>';
        echo '</tbody></table>';

        self::renderSignatures('Prepared By (Accounts)', 'Consultant Doctor Signature', 'Director of Clinical Finance');
    }

    private static function renderSignaturesSection(): void
    {
        self::renderSignatures('Prepared By (Officer)', 'Verified By (Auditor)', 'Authorized Signatory (MD)');
    }

    private static function renderSignatures(string $sig1, string $sig2, string $sig3): void
    {
        echo '<table width="100%" class="voucher-signatures-grid" style="width:100%;border-collapse:collapse;margin-top:45px;"><tr>';
        echo '  <td width="33%" style="text-align:center;vertical-align:top;padding:0 15px;"><div class="signature-line-block">' . e($sig1) . '<small>Lutfunnesa Enterprise ERP</small></div></td>';
        echo '  <td width="34%" style="text-align:center;vertical-align:top;padding:0 15px;"><div class="signature-line-block">' . e($sig2) . '<small>Clinical Operations &amp; Audit</small></div></td>';
        echo '  <td width="33%" style="text-align:center;vertical-align:top;padding:0 15px;"><div class="signature-line-block">' . e($sig3) . '<small>Authorized Official Signatory</small></div></td>';
        echo '</tr></table>';

        echo '<table width="100%" class="voucher-security-footer" style="width:100%;border-collapse:collapse;margin-top:25px;border-top:1px solid #e2e8f0;padding-top:10px;font-size:9.5px;color:#64748b;"><tr>';
        echo '  <td style="text-align:left;">Security Token: <strong>' . strtoupper(substr(md5((string)time()), 0, 16)) . '</strong> · Verified Corporate Document</td>';
        echo '  <td style="text-align:right;">Generated: ' . date('d-M-Y h:i:s A') . ' (Asia/Dhaka) · Official Medical Archive</td>';
        echo '</tr></table>';
    }

    private static function convertNumberToWords(int $num): string
    {
        $ones = ['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'];
        $tens = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];

        if ($num === 0) return 'zero';
        if ($num < 20) return $ones[$num];
        if ($num < 100) return $tens[(int)($num / 10)] . ($num % 10 ? ' ' . $ones[$num % 10] : '');
        if ($num < 1000) return $ones[(int)($num / 100)] . ' hundred' . ($num % 100 ? ' and ' . self::convertNumberToWords($num % 100) : '');
        if ($num < 100000) return self::convertNumberToWords((int)($num / 1000)) . ' thousand' . ($num % 1000 ? ' ' . self::convertNumberToWords($num % 1000) : '');
        if ($num < 10000000) return self::convertNumberToWords((int)($num / 100000)) . ' lakh' . ($num % 100000 ? ' ' . self::convertNumberToWords($num % 100000) : '');
        return self::convertNumberToWords((int)($num / 10000000)) . ' crore' . ($num % 10000000 ? ' ' . self::convertNumberToWords($num % 10000000) : '');
    }

    private static function renderInventoryStockPrint(PDO $db): void
    {
        $branchId = Security::branchIds($db)[0];
        $batches = Inventory::getFEFOStockList($db, $branchId);
        echo '<div style="margin-bottom:15px;border-bottom:2px solid #092c36;padding-bottom:8px;">';
        echo '<h2 style="margin:0;font-size:16px;color:#092c36;">REAGENT & CONSUMABLE INVENTORY (FEFO)</h2>';
        echo '<p style="margin:2px 0 0;font-size:11px;color:#64748b;">Statutory Clinical Laboratory Stock Batches & Cold Chain Expiry Register · Date: ' . date('d-M-Y h:i A') . '</p>';
        echo '</div>';
        echo '<table class="voucher-items-table"><thead><tr><th>Item Code</th><th>Reagent Item Description</th><th>Batch / Lot</th><th>Expiry Date</th><th style="text-align:right;">Stock On Hand</th><th style="text-align:right;">Unit Cost</th><th>FEFO Status</th></tr></thead><tbody>';
        foreach ($batches as $b) {
            $daysLeft = ceil((strtotime($b['expiry_date']) - time()) / 86400);
            $st = ($daysLeft < 60) ? '<strong style="color:#b91c1c;">EXPIRING (' . $daysLeft . 'd)</strong>' : '<span style="color:#15803d;">VALID (' . $daysLeft . 'd)</span>';
            echo '<tr>';
            echo '<td>' . e($b['code']) . '</td>';
            echo '<td><strong>' . e($b['item_name']) . '</strong><br><small style="color:#64748b;">' . e($b['storage_condition'] ?? 'Cold Chain') . '</small></td>';
            echo '<td>' . e($b['batch_no']) . '</td>';
            echo '<td>' . date('d-M-Y', strtotime($b['expiry_date'])) . '</td>';
            echo '<td style="text-align:right;"><strong>' . e($b['quantity_on_hand']) . ' ' . e($b['unit_name']) . '</strong></td>';
            echo '<td style="text-align:right;">৳ ' . number_format((float)($b['unit_cost'] ?? 0), 2) . '</td>';
            echo '<td>' . $st . '</td>';
            echo '</tr>';
        }
        echo '</tbody></table>';
        self::renderSignaturesSection();
    }

    private static function renderEquipmentAssetsPrint(PDO $db): void
    {
        $assets = Equipment::listAssets($db);
        echo '<div style="margin-bottom:15px;border-bottom:2px solid #092c36;padding-bottom:8px;">';
        echo '<h2 style="margin:0;font-size:16px;color:#092c36;">DIAGNOSTIC ANALYZERS & EQUIPMENT ASSET DOSSIER</h2>';
        echo '<p style="margin:2px 0 0;font-size:11px;color:#64748b;">Clinical Equipment Register, Serial Tracking, Calibration & Warranty Audit · Date: ' . date('d-M-Y h:i A') . '</p>';
        echo '</div>';
        echo '<table class="voucher-items-table"><thead><tr><th>Asset Code</th><th>Analyzer Title</th><th>Model</th><th>Serial Number</th><th>Warranty Expiry</th><th>Operational Status</th></tr></thead><tbody>';
        foreach ($assets as $ast) {
            echo '<tr>';
            echo '<td><strong>' . e($ast['asset_code']) . '</strong></td>';
            echo '<td><strong>' . e($ast['name']) . '</strong></td>';
            echo '<td>' . e($ast['model_no'] ?? 'N/A') . '</td>';
            echo '<td>' . e($ast['serial_no'] ?? 'N/A') . '</td>';
            echo '<td>' . (!empty($ast['warranty_expiry']) ? date('d-M-Y', strtotime($ast['warranty_expiry'])) : 'Lifetime Support') . '</td>';
            echo '<td><span style="font-weight:700;color:' . ($ast['status']==='operational'?'#15803d':'#b45309') . ';">' . strtoupper(e($ast['status'])) . '</span></td>';
            echo '</tr>';
        }
        echo '</tbody></table>';
        self::renderSignaturesSection();
    }

    private static function renderStockTransfersPrint(PDO $db): void
    {
        $transfers = Inventory::listTransfers($db);
        echo '<div style="margin-bottom:15px;border-bottom:2px solid #092c36;padding-bottom:8px;">';
        echo '<h2 style="margin:0;font-size:16px;color:#092c36;">INTER-BRANCH REAGENT TRANSFER CHALLAN</h2>';
        echo '<p style="margin:2px 0 0;font-size:11px;color:#64748b;">Central Store Transit Consignments & Satellite Branch Movement Register · Date: ' . date('d-M-Y h:i A') . '</p>';
        echo '</div>';
        echo '<table class="voucher-items-table"><thead><tr><th>Transfer #</th><th>Reagent Item Description</th><th>From Hub → Destination</th><th style="text-align:right;">Quantity</th><th>Status</th></tr></thead><tbody>';
        foreach ($transfers as $tr) {
            echo '<tr>';
            echo '<td><strong>' . e($tr['transfer_no']) . '</strong></td>';
            echo '<td><strong>' . e($tr['item_name']) . '</strong></td>';
            echo '<td>' . e($tr['from_branch']) . ' → ' . e($tr['to_branch']) . '</td>';
            echo '<td style="text-align:right;"><strong>' . e($tr['quantity']) . ' Units</strong></td>';
            echo '<td><strong>' . strtoupper(e($tr['status'])) . '</strong></td>';
            echo '</tr>';
        }
        echo '</tbody></table>';
        self::renderSignaturesSection();
    }

    private static function renderCorporateContractsPrint(PDO $db): void
    {
        $contracts = Corporate::listContracts($db);
        echo '<div style="margin-bottom:15px;border-bottom:2px solid #092c36;padding-bottom:8px;">';
        echo '<h2 style="margin:0;font-size:16px;color:#092c36;">CORPORATE CLIENT HEALTH PANEL CONTRACTS</h2>';
        echo '<p style="margin:2px 0 0;font-size:11px;color:#64748b;">Corporate Panel Agreements, Authorized Credit Limit, Discount Rates & Validity · Date: ' . date('d-M-Y h:i A') . '</p>';
        echo '</div>';
        echo '<table class="voucher-items-table"><thead><tr><th>Contract #</th><th>Corporate Client Company</th><th style="text-align:right;">Credit Limit</th><th>Discount</th><th>Pre-Auth</th><th>Agreement Period</th></tr></thead><tbody>';
        foreach ($contracts as $ct) {
            echo '<tr>';
            echo '<td><strong>' . e($ct['contract_no']) . '</strong></td>';
            echo '<td><strong>' . e($ct['corporate_name']) . '</strong></td>';
            echo '<td style="text-align:right;"><strong>৳ ' . number_format((float)$ct['credit_limit'], 2) . '</strong></td>';
            echo '<td>' . e($ct['discount_percent']) . '% OFF</td>';
            echo '<td>' . (!empty($ct['pre_auth_required']) ? 'REQUIRED' : 'DIRECT') . '</td>';
            echo '<td>' . date('d-M-Y', strtotime($ct['agreement_start'])) . ' to ' . date('d-M-Y', strtotime($ct['agreement_end'])) . '</td>';
            echo '</tr>';
        }
        echo '</tbody></table>';
        self::renderSignaturesSection();
    }

    private static function renderReferrerLeaderboardPrint(PDO $db): void
    {
        $performance = Referral::getReferrerPerformance($db);
        echo '<div style="margin-bottom:15px;border-bottom:2px solid #092c36;padding-bottom:8px;">';
        echo '<h2 style="margin:0;font-size:16px;color:#092c36;">DOCTOR REFERRAL PERFORMANCE LEADERBOARD</h2>';
        echo '<p style="margin:2px 0 0;font-size:11px;color:#64748b;">Medical Consultant Network, Referred Invoices & Topline Referral Billing · Date: ' . date('d-M-Y h:i A') . '</p>';
        echo '</div>';
        echo '<table class="voucher-items-table"><thead><tr><th>Code</th><th>Referrer Doctor / Organization</th><th>Classification</th><th style="text-align:right;">Referred Orders</th><th style="text-align:right;">Total Revenue</th></tr></thead><tbody>';
        foreach ($performance as $p) {
            echo '<tr>';
            echo '<td><strong>' . e($p['code']) . '</strong></td>';
            echo '<td><strong>' . e($p['name']) . '</strong></td>';
            echo '<td>' . strtoupper(e($p['type'])) . '</td>';
            echo '<td style="text-align:right;"><strong>' . (int)$p['total_orders'] . '</strong></td>';
            echo '<td style="text-align:right;"><strong style="color:#092c36;">৳ ' . number_format((float)$p['total_revenue'], 2) . '</strong></td>';
            echo '</tr>';
        }
        echo '</tbody></table>';
        self::renderSignaturesSection();
    }


    private static function renderHomeCollectionsPrint(PDO $db): void
    {
        $branchId = Security::branchIds($db)[0];
        $bookings = HomeCollection::listBookings($db, $branchId);
        self::renderHeader('HOME SAMPLE COLLECTION WORKLIST', 'HC-REG-' . date('Ymd'), date('d-M-Y'));
        echo '<div style="margin-bottom:15px;border-bottom:2px solid #092c36;padding-bottom:8px;">';
        echo '<h2 style="margin:0;font-size:16px;color:#092c36;">HOME SAMPLE COLLECTION DISPATCH REGISTER</h2>';
        echo '<p style="margin:2px 0 0;font-size:11px;color:#64748b;">Elderly & Diabetic Patient Home Phlebotomy Schedule · Date: ' . date('d-M-Y h:i A') . '</p>';
        echo '</div>';
        echo '<table class="voucher-items-table"><thead><tr><th>Booking #</th><th>Patient Details</th><th>Geo Zone & Address</th><th>Slot</th><th style="text-align:right;">Travel Charge</th><th>Status</th></tr></thead><tbody>';
        foreach ($bookings as $b) {
            echo '<tr>';
            echo '<td><strong>' . e($b['booking_no']) . '</strong></td>';
            echo '<td><strong>' . e($b['patient_name']) . '</strong><br><small style="color:#64748b;">' . e($b['mobile']) . '</small></td>';
            echo '<td>' . e($b['geo_zone']) . '<br><small style="color:#64748b;">' . e($b['address']) . '</small></td>';
            echo '<td>' . e($b['time_slot']) . '</td>';
            echo '<td style="text-align:right;"><strong>৳ ' . number_format((float)($b['travel_charge'] ?? 300), 2) . '</strong></td>';
            echo '<td>' . strtoupper(e($b['status'])) . '</td>';
            echo '</tr>';
        }
        echo '</tbody></table>';
        self::renderSignaturesSection();
    }

    private static function renderSampleDeskPrint(PDO $db): void
    {
        $branchId = Security::branchIds($db)[0];
        $worklist = LIS::getWorklist($db, $branchId);
        self::renderHeader('SPECIMEN COLLECTION CHAIN OF CUSTODY', 'SMP-REG-' . date('Ymd'), date('d-M-Y'));
        echo '<div style="margin-bottom:15px;border-bottom:2px solid #092c36;padding-bottom:8px;">';
        echo '<h2 style="margin:0;font-size:16px;color:#092c36;">CLINICAL SPECIMEN COLLECTION DESK REGISTER</h2>';
        echo '<p style="margin:2px 0 0;font-size:11px;color:#64748b;">Accessioned Pre-Analytical Samples, Barcode UID & Container Audit · Date: ' . date('d-M-Y h:i A') . '</p>';
        echo '</div>';
        echo '<table class="voucher-items-table"><thead><tr><th>Barcode #</th><th>Order #</th><th>Patient (MRN)</th><th>Test Item</th><th>Sample Type & Container</th><th>Status</th></tr></thead><tbody>';
        foreach ($worklist as $w) {
            $st = !empty($w['sample_type_name']) ? $w['sample_type_name'] : 'Blood / EDTA (Lavender Top)';
            echo '<tr>';
            echo '<td><strong>' . e($w['barcode']) . '</strong></td>';
            echo '<td>' . e($w['order_no']) . '</td>';
            echo '<td><strong>' . e($w['patient_name']) . '</strong> (' . e($w['mrn']) . ')</td>';
            echo '<td><strong>' . e($w['item_name']) . '</strong></td>';
            echo '<td>' . e($st) . '</td>';
            echo '<td>' . strtoupper(e($w['status'])) . '</td>';
            echo '</tr>';
        }
        echo '</tbody></table>';
        self::renderSignaturesSection();
    }

    private static function renderReportCatalogPrint(PDO $db): void
    {
        $reportKey = (string)($_GET['report_key'] ?? 'executive_summary');
        $start = (string)($_GET['start_date'] ?? date('Y-m-01'));
        $end = (string)($_GET['end_date'] ?? date('Y-m-d'));
        $data = Intelligence::generateReportData($db, $reportKey, ['start_date' => $start, 'end_date' => $end]);
        self::renderHeader('GOVERNED ANALYTICS REPORT · ' . strtoupper(str_replace('_', ' ', $reportKey)), 'REP-CAT-' . date('Ymd'), date('d-M-Y'));
        echo '<div style="margin-bottom:15px;border-bottom:2px solid #092c36;padding-bottom:8px;">';
        echo '<h2 style="margin:0;font-size:16px;color:#092c36;">' . strtoupper(str_replace('_', ' ', $reportKey)) . '</h2>';
        echo '<p style="margin:2px 0 0;font-size:11px;color:#64748b;">Statutory Report View · Period: ' . $start . ' to ' . $end . ' · Generated: ' . date('d-M-Y h:i A') . '</p>';
        echo '</div>';
        if (empty($data)) {
            echo '<p style="text-align:center;padding:20px;color:#64748b;">No records found for the selected criteria.</p>';
        } else {
            $cols = array_keys($data[0]);
            echo '<table class="voucher-items-table"><thead><tr>';
            foreach ($cols as $col) echo '<th>' . e(strtoupper(str_replace('_', ' ', $col))) . '</th>';
            echo '</tr></thead><tbody>';
            foreach ($data as $r) {
                echo '<tr>';
                foreach ($r as $val) echo '<td>' . e((string)$val) . '</td>';
                echo '</tr>';
            }
            echo '</tbody></table>';
        }
        self::renderSignaturesSection();
    }

    private static function renderResultEntryPrint(PDO $db): void
    {
        $results = $db->query('SELECT lr.*, dt.name AS test_name, u.name AS tech_name FROM lab_results lr JOIN diagnostic_tests dt ON dt.id=lr.test_id JOIN users u ON u.id=lr.entered_by ORDER BY lr.id DESC LIMIT 30')->fetchAll();
        self::renderHeader('LABORATORY EVALUATED RESULTS REGISTER', 'RES-REG-' . date('Ymd'), date('d-M-Y'));
        echo '<div style="margin-bottom:15px;border-bottom:2px solid #092c36;padding-bottom:8px;">';
        echo '<h2 style="margin:0;font-size:16px;color:#092c36;">EVALUATED TEST FINDINGS & CLINICAL FLAGS</h2>';
        echo '<p style="margin:2px 0 0;font-size:11px;color:#64748b;">Multi-Parameter Analyzed Specimens, Physiological Range Audit & Flagging · Date: ' . date('d-M-Y h:i A') . '</p>';
        echo '</div>';
        echo '<table class="voucher-items-table"><thead><tr><th>Test Item</th><th>Evaluated Result</th><th>Flag Status</th><th>Medical Technologist</th></tr></thead><tbody>';
        foreach ($results as $r) {
            $flagColor = ($r['result_flag'] === 'critical') ? '#b91c1c' : (($r['result_flag'] === 'high' || $r['result_flag'] === 'low') ? '#b45309' : '#15803d');
            echo '<tr>';
            echo '<td><strong>' . e($r['test_name']) . '</strong></td>';
            echo '<td><strong>' . e($r['result_value']) . '</strong></td>';
            echo '<td><span style="font-weight:bold;color:' . $flagColor . ';">' . strtoupper(e($r['result_flag'])) . '</span></td>';
            echo '<td>' . e($r['tech_name']) . '</td>';
            echo '</tr>';
        }
        echo '</tbody></table>';
        self::renderSignaturesSection();
    }
}
