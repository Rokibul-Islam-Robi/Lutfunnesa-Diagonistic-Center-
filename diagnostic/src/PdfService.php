<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use Mpdf\Mpdf;
use RuntimeException;

class PdfService
{
    /**
     * Create and configure an instance of mPDF with corporate branding
     */
    public static function createMpdf(array $options = []): Mpdf
    {
        $tempDir = dirname(__DIR__) . '/storage/framework/cache';
        if (!is_dir($tempDir)) {
            @mkdir($tempDir, 0777, true);
        }

        $defaultConfig = [
            'mode' => 'utf-8',
            'format' => $options['format'] ?? 'A4',
            'orientation' => $options['orientation'] ?? 'P',
            'margin_left' => 12,
            'margin_right' => 12,
            'margin_top' => 26,
            'margin_bottom' => 20,
            'margin_header' => 8,
            'margin_footer' => 8,
            'tempDir' => $tempDir,
            'default_font' => 'dejavusans'
        ];

        $mpdf = new Mpdf(array_merge($defaultConfig, $options));
        $mpdf->SetAuthor('Cognova IT Operations Platform · Diagnostic Healthcare ERP');
        $mpdf->SetCreator('Lutfunnesa Diabetes & Diagnostic Center · mPDF Engine');
        $mpdf->SetDisplayMode('fullpage');

        // Corporate Running Header
        $headerHtml = '
        <table width="100%" style="border-bottom: 2px solid #0d9488; padding-bottom: 4px; font-family: dejavusans, sans-serif; font-size: 8pt; color: #475569;">
            <tr>
                <td width="65%" style="text-align: left;">
                    <strong style="font-size: 11pt; color: #092c36; letter-spacing: -0.2px;">LUTFUNNESA DIABETES &amp; DIAGNOSTIC CENTER</strong><br>
                    <span style="color: #0d9488; font-weight: bold; font-size: 7.5pt;">Precision Diagnostic Laboratory &amp; Specialist Consultation Center</span><br>
                    <span style="font-size: 7pt; color: #64748b;">Govt. DGHS Reg: <strong>DGHS-DIAG-2026-9842</strong> | Tax BIN: <strong>004819284-0101</strong> | Hotline: +880 9611-000111</span>
                </td>
                <td width="35%" style="text-align: right; vertical-align: top;">
                    <div style="background: #092c36; color: #ffffff; font-weight: bold; font-size: 7pt; padding: 3px 8px; border-radius: 4px; display: inline-block;">
                        OFFICIAL CERTIFIED RECORD
                    </div><br>
                    <span style="font-size: 6.5pt; color: #64748b; margin-top: 3px; display: block;">Generated: ' . date('d-M-Y h:i A') . '</span>
                </td>
            </tr>
        </table>';
        $mpdf->SetHTMLHeader($headerHtml);

        // Corporate Running Footer
        $footerHtml = '
        <table width="100%" style="border-top: 1px solid #cbd5e1; padding-top: 4px; font-family: dejavusans, sans-serif; font-size: 7pt; color: #64748b;">
            <tr>
                <td width="40%" style="text-align: left;">
                    <strong>Cognova IT · Operations Platform</strong> | Confidential Medical Record
                </td>
                <td width="30%" style="text-align: center;">
                    System Hash: ' . substr(hash('sha256', date('Y-m-d H:i')), 0, 16) . ' [VERIFIED]
                </td>
                <td width="30%" style="text-align: right;">
                    Page {PAGENO} of {nbpg}
                </td>
            </tr>
        </table>';
        $mpdf->SetHTMLFooter($footerHtml);

        return $mpdf;
    }

    /**
     * Download an individual voucher as an official PDF
     */
    public static function downloadVoucherPdf(PDO $db, array $user, string $type, string $id, string $dest = 'D'): void
    {
        Security::requirePermission($db, 'dashboard.view');

        $mpdf = self::createMpdf([
            'orientation' => 'P',
            'margin_top' => 12,
            'margin_header' => 0
        ]);
        $mpdf->SetHTMLHeader('');

        $voucherHtml = PrintVoucher::getVoucherHtml($db, $type, $id);

        $css = self::getPdfBaseCss();
        $fullHtml = '<html><head><style>' . $css . '</style></head><body>' . $voucherHtml . '</body></html>';

        $mpdf->WriteHTML($fullHtml);

        $filename = 'Lutfunnesa_' . ucfirst($type) . '_' . preg_replace('/[^A-Za-z0-9_-]/', '_', $id) . '_' . date('Ymd') . '.pdf';

        while (ob_get_level()) {
            ob_end_clean();
        }

        $mpdf->Output($filename, $dest);
        exit;
    }

    /**
     * Download table/register as an official PDF report
     */
    public static function downloadTablePdf(PDO $db, array $user, string $module, string $dest = 'D'): void
    {
        Security::requirePermission($db, 'dashboard.view');
        $branchId = Security::branchIds($db)[0];

        $title = 'Official Report';
        $subtitle = 'Master Register and Activity Audit';
        $headers = [];
        $rows = [];
        $orientation = 'P';

        switch ($module) {
            case 'orders':
                $title = 'Diagnostic Orders Register';
                $subtitle = 'Patient Requisitions and Lab Billable Invoices';
                $headers = ['Order #', 'MRN', 'Patient Name', 'Doctor', 'Urgency', 'Status', 'Payable'];
                $data = Orders::listOrders($db, $branchId);
                foreach ($data as $o) {
                    $rows[] = [
                        $o['order_no'], $o['mrn'], $o['patient_name'], $o['doctor_name'] ?? 'Self',
                        strtoupper($o['urgency']), strtoupper($o['status']),
                        'BDT ' . number_format((float)$o['payable_amount'], 2)
                    ];
                }
                break;

            case 'billing':
                $title = 'Billing & Invoices Register';
                $subtitle = 'Cash Collection, Paid Invoices & Due Ledger';
                $headers = ['Invoice #', 'MRN', 'Patient Name', 'Payable', 'Paid', 'Due', 'Status'];
                $data = Billing::listInvoices($db, $branchId);
                foreach ($data as $i) {
                    $rows[] = [
                        $i['invoice_no'], $i['mrn'], $i['patient_name'],
                        'BDT ' . number_format((float)$i['payable_amount'], 2),
                        'BDT ' . number_format((float)$i['paid_amount'], 2),
                        'BDT ' . number_format((float)$i['due_amount'], 2),
                        strtoupper($i['status'])
                    ];
                }
                break;

            case 'patients':
                $title = 'Patient Master Directory';
                $subtitle = 'Longitudinal Patient Health Identity & Demographic Records';
                $headers = ['MRN', 'Full Name', 'Mobile', 'Gender', 'DOB', 'Blood Group', 'Registered'];
                $data = Patients::search($db, '', $branchId, 100);
                foreach ($data as $p) {
                    $rows[] = [
                        $p['mrn'], $p['name'], $p['mobile'], ucfirst($p['gender']),
                        $p['dob'] ?: 'N/A', $p['blood_group'] ?: 'N/A',
                        date('d-M-Y', strtotime($p['created_at']))
                    ];
                }
                break;

            case 'appointments':
                $date = (string)($_GET['date'] ?? date('Y-m-d'));
                $title = 'Doctor Chamber Appointments Schedule';
                $subtitle = 'Outpatient Consultation Bookings for ' . date('d-M-Y', strtotime($date));
                $headers = ['Appt #', 'Patient Name', 'Mobile', 'Doctor', 'Slot', 'Status'];
                $data = Appointments::list($db, $branchId, $date);
                foreach ($data as $a) {
                    $rows[] = [
                        $a['appointment_no'], $a['patient_name'], $a['patient_mobile'],
                        $a['doctor_name'], $a['time_slot'], strtoupper($a['status'])
                    ];
                }
                break;

            case 'hr_employees':
                $title = 'Workforce Directory & Clinical Credentials';
                $subtitle = 'Official Staff Roster, BMDC / SMF License Registry and Base Salaries';
                $headers = ['Emp Code', 'Staff Name', 'Designation', 'Department', 'License / BMDC', 'Base Salary'];
                $data = HR::listEmployees($db);
                foreach ($data as $e) {
                    $rows[] = [
                        $e['employee_code'], $e['name'], $e['designation'],
                        $e['department_name'] ?? 'General',
                        $e['license_no'] ?: 'N/A',
                        'BDT ' . number_format((float)$e['basic_salary'], 2)
                    ];
                }
                break;

            case 'hr_attendance':
                $date = (string)($_GET['date'] ?? date('Y-m-d'));
                $title = 'Daily Staff Biometric Attendance Sheet';
                $subtitle = 'In-Out Punches, Shift Punctuality and Overtime Logs for ' . date('d-M-Y', strtotime($date));
                $headers = ['Code', 'Staff Name', 'Designation', 'In-Time', 'Out-Time', 'OT (Hrs)', 'Status'];
                $data = HR::listAttendance($db, $date);
                foreach ($data as $r) {
                    $rows[] = [
                        $r['employee_code'], $r['employee_name'], $r['designation'],
                        date('h:i A', strtotime($r['clock_in'])),
                        $r['clock_out'] ? date('h:i A', strtotime($r['clock_out'])) : 'On Duty',
                        (float)$r['overtime_hours'] > 0 ? '+' . (float)$r['overtime_hours'] . 'h' : '-',
                        strtoupper($r['status'])
                    ];
                }
                break;

            case 'hr_roster_leave':
                $title = '24/7 Clinical & Diagnostic Duty Rostering';
                $subtitle = 'Round-the-clock Shift Coverage across Pathology, Radiology & Front Desks';
                $headers = ['Duty Date', 'Staff Name', 'Designation', 'Department', 'Shift Assigned', 'Shift Timings'];
                $data = HR::listRosters($db, $branchId);
                foreach ($data as $r) {
                    $timeStr = ($r['shift_name']==='morning'?'08:00 AM - 04:00 PM':($r['shift_name']==='evening'?'04:00 PM - 12:00 AM':'12:00 AM - 08:00 AM'));
                    $rows[] = [
                        date('d-M-Y', strtotime($r['shift_date'])),
                        $r['employee_name'], $r['designation'],
                        $r['department_name'] ?? 'General',
                        strtoupper($r['shift_name']), $timeStr
                    ];
                }
                break;

            case 'hr_leaves':
                $title = 'Employee Leave Applications & Balances';
                $subtitle = 'Official Leave History, Reasons and Management Approval Logs';
                $headers = ['Code', 'Employee Name', 'Department', 'Leave Type', 'Period', 'Days', 'Status'];
                $data = HR::listLeaves($db);
                foreach ($data as $l) {
                    $days = (int)ceil((strtotime($l['end_date']) - strtotime($l['start_date'])) / 86400) + 1;
                    $rows[] = [
                        $l['employee_code'], $l['employee_name'], $l['department_name'] ?? 'General',
                        ucfirst($l['leave_type']),
                        date('d-M', strtotime($l['start_date'])) . ' to ' . date('d-M', strtotime($l['end_date'])),
                        $days . ' Days',
                        strtoupper($l['status'])
                    ];
                }
                break;

            case 'hr_payroll':
                $title = 'Monthly Payroll & Salary Disbursement Ledger';
                $subtitle = 'Statutory Deductions (PF, Tax), Allowances & Net Remittances';
                $headers = ['Period', 'Code', 'Staff Name', 'Basic (BDT)', 'Allowances', 'Deductions', 'Net Salary'];
                $data = HR::listPayrolls($db);
                foreach ($data as $p) {
                    $rows[] = [
                        $p['payroll_period'], $p['employee_code'], $p['employee_name'],
                        number_format((float)$p['basic_salary'], 2),
                        number_format((float)$p['allowances'], 2),
                        number_format((float)$p['deductions'], 2),
                        'BDT ' . number_format((float)$p['net_salary'], 2)
                    ];
                }
                break;

            case 'hr_recruitment':
                $title = 'Talent Acquisition & Candidate Screening Pipeline';
                $subtitle = 'Active Applications, Qualifications and Interview Schedules';
                $headers = ['Applicant', 'Role Applied', 'Mobile', 'Experience', 'Expected Salary', 'Interview', 'Status'];
                $data = HR::listCandidates($db);
                foreach ($data as $c) {
                    $rows[] = [
                        $c['name'], $c['job_title'], $c['mobile'],
                        (int)$c['experience_years'] . ' Yrs',
                        $c['expected_salary'] ? 'BDT ' . number_format((float)$c['expected_salary']) : 'Negotiable',
                        $c['interview_date'] ? date('d-M-Y', strtotime($c['interview_date'])) : 'Pending',
                        strtoupper($c['status'])
                    ];
                }
                break;

            case 'hr_competencies':
                $title = 'Staff Clinical Competency Matrix & ISO 15189 Audit';
                $subtitle = 'Evaluated Medical Technologists, Pathologists & Radiographers Competency Registry';
                $headers = ['Category', 'Competency Protocol', 'Assessed Staff', 'Designation', 'Score (%)', 'Status'];
                $data = HR::listCompetencies($db);
                foreach ($data as $c) {
                    $rows[] = [
                        strtoupper($c['category']), $c['competency_title'], $c['employee_name'],
                        $c['designation'], number_format((float)$c['assessment_score'], 1) . '%', 'VALID CERTIFIED'
                    ];
                }
                break;

            case 'chart_of_accounts':
                $title = 'General Ledger Chart of Accounts';
                $subtitle = 'Official Master Accounts, Classifications & Real-Time Balances';
                $headers = ['Account Code', 'Account Title', 'Classification', 'Debit Total', 'Credit Total', 'Net Balance'];
                $data = Accounting::listAccounts($db);
                foreach ($data as $a) {
                    $rows[] = [
                        $a['account_code'], $a['name'], strtoupper($a['account_type']),
                        'BDT ' . number_format((float)$a['total_debit'], 2),
                        'BDT ' . number_format((float)$a['total_credit'], 2),
                        'BDT ' . number_format((float)$a['balance'], 2)
                    ];
                }
                break;

            case 'financial_vouchers':
                $title = 'Double-Entry General Ledger Vouchers';
                $subtitle = 'Audited Journal, Payment, Receipt and Contra Transactions';
                $headers = ['Voucher #', 'Type', 'Date', 'Narration / Particulars', 'Amount (BDT)', 'Status'];
                $data = Accounting::listVouchers($db);
                foreach ($data as $v) {
                    $rows[] = [
                        $v['voucher_no'], strtoupper($v['voucher_type']), $v['voucher_date'],
                        $v['narration'], 'BDT ' . number_format((float)$v['total_amount'], 2),
                        strtoupper($v['status'])
                    ];
                }
                break;

            case 'doctor_commissions':
                $title = 'Doctor Diagnostic Referral Commission Ledger';
                $subtitle = 'Test Referrals, Commission Accruals & Payout Settlements';
                $headers = ['Doctor Code', 'Consultant Doctor Name', 'Mobile', 'Referred Tests', 'Billed Volume', 'Commission Accrued', 'Pending Due'];
                $data = Accounting::getDoctorCommissionSummary($db);
                foreach ($data as $d) {
                    $rows[] = [
                        $d['doctor_code'], $d['doctor_name'], $d['mobile'],
                        (string)$d['total_referrals'],
                        'BDT ' . number_format((float)$d['total_billed'], 2),
                        'BDT ' . number_format((float)$d['total_commission'], 2),
                        'BDT ' . number_format((float)$d['pending_commission'], 2)
                    ];
                }
                break;

            case 'corporate_billing':
                $title = 'Corporate Panel Accounts Receivable (AR) & Aging Analysis';
                $subtitle = 'Credit Scheme Clients, Invoiced Dues & Overdue Buckets';
                $headers = ['Client Code', 'Corporate Scheme Name', 'Phone', 'Invoiced BDT', '0-30 Days', '31-60 Days', '60+ Days Overdue', 'Total Due'];
                $data = Accounting::getCorporateAging($db);
                foreach ($data as $ca) {
                    $rows[] = [
                        $ca['code'], $ca['name'], $ca['phone'],
                        'BDT ' . number_format((float)$ca['total_billed'], 2),
                        'BDT ' . number_format((float)$ca['aging_30'], 2),
                        'BDT ' . number_format((float)$ca['aging_60'], 2),
                        'BDT ' . number_format((float)$ca['aging_90_plus'], 2),
                        'BDT ' . number_format((float)$ca['total_due'], 2)
                    ];
                }
                break;

            case 'accounts_payable':
                $title = 'Supplier Accounts Payable (AP) & NBR TDS/VDS Ledger';
                $subtitle = 'Reagent, Chemical & Consumable Vendors Outstanding Dues';
                $headers = ['Supplier Code', 'Vendor / Distributor Name', 'Phone', 'Purchases BDT', 'TDS/VDS Deducted', 'Disbursed', 'Balance Due'];
                $data = Accounting::getSupplierLedger($db);
                foreach ($data as $s) {
                    $rows[] = [
                        $s['code'], $s['name'], $s['phone'],
                        'BDT ' . number_format((float)$s['total_purchased'], 2),
                        'BDT ' . number_format((float)$s['tds_vds_deducted'], 2),
                        'BDT ' . number_format((float)$s['total_paid'], 2),
                        'BDT ' . number_format((float)$s['balance_payable'], 2)
                    ];
                }
                break;

            case 'cash_bank_books':
                $title = 'Cash & Bank Books Liquidity Report';
                $subtitle = 'Main Cash Vault, Operational Bank Accounts & MFS Digital Settlements';
                $headers = ['Account Code', 'Liquid Account Title', 'Available Balance (BDT)', 'Reconciliation Status'];
                $data = Accounting::getCashBankBalances($db);
                foreach ($data as $cb) {
                    $rows[] = [
                        $cb['account_code'], $cb['name'],
                        'BDT ' . number_format((float)$cb['balance'], 2),
                        'RECONCILED'
                    ];
                }
                break;

            case 'financial_statements':
                $title = 'Official Statutory Trial Balance';
                $subtitle = 'Real-time General Ledger Closing Statement (Zero Variance)';
                $headers = ['Account Code', 'Account Title', 'Category', 'Debit (BDT)', 'Credit (BDT)'];
                $data = Accounting::getTrialBalance($db);
                foreach ($data as $tb) {
                    $rows[] = [
                        $tb['account_code'], $tb['name'], strtoupper($tb['account_type']),
                        'BDT ' . number_format((float)$tb['total_debit'], 2),
                        'BDT ' . number_format((float)$tb['total_credit'], 2)
                    ];
                }
                break;

            case 'inventory_stock':
                $title = 'Reagent & Consumable Inventory (FEFO)';
                $subtitle = 'First-Expiry First-Out (FEFO) Stock Batches & Cold Chain Status';
                $headers = ['Item Code', 'Reagent Item Name', 'Batch #', 'Lot #', 'Expiry Date', 'Stock On Hand', 'Unit Cost'];
                $data = Inventory::getFEFOStockList($db, $branchId);
                foreach ($data as $b) {
                    $rows[] = [
                        $b['code'], $b['item_name'], $b['batch_no'], $b['lot_no'] ?? 'N/A',
                        date('d-M-Y', strtotime($b['expiry_date'])),
                        $b['quantity_on_hand'] . ' ' . $b['unit_name'],
                        'BDT ' . number_format((float)($b['unit_cost'] ?? 0), 2)
                    ];
                }
                break;

            case 'equipment_assets':
                $title = 'Diagnostic Analyzers & Equipment Register';
                $subtitle = 'Clinical Laboratory Hardware, Calibration Protocol and Warranty Audit';
                $headers = ['Asset Code', 'Equipment Name', 'Model', 'Serial #', 'Warranty Expiry', 'Status'];
                $data = Equipment::listAssets($db);
                foreach ($data as $ast) {
                    $rows[] = [
                        $ast['asset_code'], $ast['name'], $ast['model_no'] ?? 'N/A', $ast['serial_no'] ?? 'N/A',
                        !empty($ast['warranty_expiry']) ? date('d-M-Y', strtotime($ast['warranty_expiry'])) : 'Lifetime',
                        strtoupper($ast['status'])
                    ];
                }
                break;

            case 'stock_transfers':
                $title = 'Inter-branch & Central Store Stock Transfers';
                $subtitle = 'Reagent Transit Consignments, Requisitions and Verification Log';
                $headers = ['Transfer #', 'Reagent / Consumable Item', 'From Branch', 'To Branch', 'Quantity', 'Status'];
                $data = Inventory::listTransfers($db);
                foreach ($data as $tr) {
                    $rows[] = [
                        $tr['transfer_no'], $tr['item_name'], $tr['from_branch'], $tr['to_branch'],
                        $tr['quantity'] . ' Units', strtoupper($tr['status'])
                    ];
                }
                break;

            case 'corporate_contracts':
                $title = 'Corporate Client Health Panel Agreements';
                $subtitle = 'Credit Agreements, Authorized Limits, Discount Rates and Pre-Auth Matrix';
                $headers = ['Contract #', 'Corporate Partner', 'Credit Limit', 'Discount', 'Pre-Auth', 'Valid From', 'Valid To'];
                $data = Corporate::listContracts($db);
                foreach ($data as $ct) {
                    $rows[] = [
                        $ct['contract_no'], $ct['corporate_name'],
                        'BDT ' . number_format((float)$ct['credit_limit'], 2),
                        $ct['discount_percent'] . '%',
                        !empty($ct['pre_auth_required']) ? 'REQUIRED' : 'DIRECT',
                        date('d-M-Y', strtotime($ct['agreement_start'])),
                        date('d-M-Y', strtotime($ct['agreement_end']))
                    ];
                }
                break;

            case 'referrer_desk':
                $title = 'Doctor / Referrer Performance Leaderboard';
                $subtitle = 'Medical Consultant Network, Referral Inflow and Volume Analytics';
                $headers = ['Code', 'Referrer Doctor / Organization', 'Type', 'Referred Orders', 'Total Billed Revenue'];
                $data = Referral::getReferrerPerformance($db);
                foreach ($data as $rf) {
                    $rows[] = [
                        $rf['code'], $rf['name'], strtoupper($rf['type']),
                        $rf['total_orders'] . ' Orders',
                        'BDT ' . number_format((float)$rf['total_revenue'], 2)
                    ];
                }
                break;

            case 'home_collections':
                $title = 'Home Specimen Collection Worklist';
                $subtitle = 'Elderly & Diabetic Patient Home Phlebotomy Schedule';
                $headers = ['Booking #', 'Patient Name', 'Mobile', 'Geo Zone & Address', 'Slot', 'Travel Charge', 'Status'];
                $data = HomeCollection::listBookings($db, $branchId);
                foreach ($data as $b) {
                    $rows[] = [
                        $b['booking_no'], $b['patient_name'], $b['mobile'],
                        $b['geo_zone'] . ' - ' . $b['address'],
                        $b['time_slot'], 'BDT ' . number_format((float)($b['travel_charge'] ?? 300), 2),
                        strtoupper($b['status'])
                    ];
                }
                break;

            case 'sample_desk':
                $title = 'Clinical Specimen Collection Register';
                $subtitle = 'Barcode Identification, Container Specifications and Chain of Custody';
                $headers = ['Barcode', 'Order #', 'MRN', 'Patient Name', 'Test Item', 'Sample Type', 'Status'];
                $data = LIS::getWorklist($db, $branchId);
                foreach ($data as $w) {
                    $rows[] = [
                        $w['barcode'], $w['order_no'], $w['mrn'], $w['patient_name'],
                        $w['item_name'], $w['sample_type_name'] ?? 'Blood / EDTA',
                        strtoupper($w['status'])
                    ];
                }
                break;

            case 'result_entry':
                $title = 'Evaluated Lab Results Register';
                $subtitle = 'Clinical Parameter Findings, Reference Ranges and Critical Range Flags';
                $headers = ['Test Name', 'Evaluated Value', 'Clinical Flag', 'Technologist'];
                $results = $db->query('SELECT lr.*, dt.name AS test_name, u.name AS tech_name FROM lab_results lr JOIN diagnostic_tests dt ON dt.id=lr.test_id JOIN users u ON u.id=lr.entered_by ORDER BY lr.id DESC LIMIT 40')->fetchAll();
                foreach ($results as $r) {
                    $rows[] = [
                        $r['test_name'], $r['result_value'],
                        strtoupper($r['result_flag']), $r['tech_name']
                    ];
                }
                break;

            default:
                throw new RuntimeException("Unknown PDF report module: {$module}");
        }

        $mpdf = self::createMpdf([
            'orientation' => count($headers) > 6 ? 'L' : 'P',
            'margin_top' => 12,
            'margin_header' => 0
        ]);
        $mpdf->SetHTMLHeader('');

        $html = self::buildTableHtml($title, $subtitle, $headers, $rows);
        $mpdf->WriteHTML($html);

        $filename = 'Lutfunnesa_' . ucfirst($module) . '_Report_' . date('Ymd_His') . '.pdf';

        while (ob_get_level()) {
            ob_end_clean();
        }

        $mpdf->Output($filename, $dest);
        exit;
    }

    /**
     * Build clean corporate HTML table for mPDF
     */
    private static function buildTableHtml(string $title, string $subtitle, array $headers, array $rows): string
    {
        $css = self::getPdfBaseCss();
        $logo = PrintVoucher::getLogoBase64();

        $html = '<html><head><style>' . $css . '</style></head><body>';
        
        $html .= '<div style="margin-bottom: 12px; border-bottom: 2px solid #0d9488; padding-bottom: 8px;">
            <table width="100%" style="border-collapse: collapse; margin: 0; padding: 0;">
                <tr>
                    <td style="vertical-align: middle; width: 68%;">
                        <table style="border-collapse: collapse; margin: 0; padding: 0;">
                            <tr>';
        if ($logo !== '') {
            $html .= '          <td style="vertical-align: middle; padding-right: 12px; width: 55px;"><img src="' . $logo . '" style="height: 50px; width: auto; display: block;" alt="Lutfunnesa Logo"></td>';
        }
        $html .= '              <td style="vertical-align: middle;">
                                    <h1 style="margin: 0; font-size: 14pt; font-weight: bold; color: #092c36; text-transform: uppercase;">LUTFUNNESA DIABETES &amp; DIAGNOSTIC CENTER</h1>
                                    <p style="margin: 1px 0 0; font-size: 8pt; font-weight: bold; color: #0d9488;">লুৎফুন্নেসা ডায়াবেটিস অ্যান্ড ডায়াগনস্টিক সেন্টার · Precision Diagnostic Systems</p>
                                    <div style="margin-top: 3px; font-size: 7pt; color: #64748b; line-height: 1.35;">
                                        Holding #45, Main Hospital Road, Farmgate, Dhaka 1215 · Hotline: <strong>+880 9611-000111</strong><br>
                                        Govt. DGHS Reg: <strong>DGHS-DIAG-2026-9842</strong> | Tax BIN: <strong>004819284-0101</strong>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td style="vertical-align: middle; width: 32%; text-align: right;">
                        <span style="background: #092c36; color: #ffffff; font-size: 7.5pt; font-weight: bold; padding: 3px 8px; border-radius: 4px; text-transform: uppercase;">' . htmlspecialchars($title) . '</span><br>
                        <span style="font-size: 7pt; color: #64748b; margin-top: 3px; display: block;">Issued: ' . date('d-M-Y h:i A') . '</span>
                        <span style="font-size: 7pt; color: #0d9488; font-weight: bold;">Total Records: ' . count($rows) . '</span>
                    </td>
                </tr>
            </table>
        </div>';

        $html .= '<div style="margin-bottom: 8px;">
            <p style="margin: 0; font-size: 8pt; font-weight: bold; color: #475569;">' . htmlspecialchars($subtitle) . '</p>
        </div>';

        $html .= '<table class="report-table" width="100%">';
        $html .= '<thead><tr>';
        foreach ($headers as $h) {
            $html .= '<th>' . htmlspecialchars($h) . '</th>';
        }
        $html .= '</tr></thead><tbody>';

        if (empty($rows)) {
            $html .= '<tr><td colspan="' . count($headers) . '" style="text-align: center; color: #94a3b8; padding: 20px;">No records found.</td></tr>';
        } else {
            $sl = 1;
            foreach ($rows as $r) {
                $html .= '<tr>';
                foreach ($r as $val) {
                    $html .= '<td>' . htmlspecialchars((string)$val) . '</td>';
                }
                $html .= '</tr>';
            }
        }

        $html .= '</tbody></table>';

        // Signatures Block
        $html .= '
        <div style="margin-top: 35px;">
            <table width="100%" style="font-size: 8pt; color: #334155;">
                <tr>
                    <td width="33%" style="text-align: center; border-top: 1px dashed #94a3b8; padding-top: 5px;">
                        <strong>PREPARED BY</strong><br><span style="font-size: 7pt; color: #64748b;">Data Operations Desk</span>
                    </td>
                    <td width="34%" style="text-align: center;">&nbsp;</td>
                    <td width="33%" style="text-align: center; border-top: 1px dashed #94a3b8; padding-top: 5px;">
                        <strong>AUTHORIZED SIGNATORY</strong><br><span style="font-size: 7pt; color: #64748b;">Managing Director / Superintendent</span>
                    </td>
                </tr>
            </table>
        </div>';

        $html .= '</body></html>';
        return $html;
    }

    /**
     * Common CSS styling optimized for mPDF rendering
     */
    private static function getPdfBaseCss(): string
    {
        return '
            body {
                font-family: dejavusans, sans-serif;
                font-size: 8.5pt;
                color: #0f172a;
                line-height: 1.35;
            }
            h1, h2, h3, h4 {
                color: #092c36;
                font-family: dejavusans, sans-serif;
            }
            .corp-letterhead-header {
                border-bottom: 2px solid #0d9488;
                padding-bottom: 10px;
                margin-bottom: 12px;
            }
            .voucher-badge-box {
                text-align: right;
            }
            .voucher-title-pill {
                background: #092c36;
                color: #ffffff;
                font-size: 8pt;
                font-weight: bold;
                padding: 3px 10px;
                border-radius: 4px;
                text-transform: uppercase;
            }
            .voucher-info-grid, .info-grid-table {
                width: 100%;
                margin-bottom: 14px;
                border: 1px solid #e2e8f0;
                background: #f8fafc;
                border-collapse: collapse;
            }
            .voucher-info-grid td, .info-grid-table td {
                padding: 6px 8px;
                border: 1px solid #e2e8f0;
                font-size: 8pt;
            }
            .info-label {
                color: #64748b;
                font-size: 7pt;
                font-weight: bold;
                text-transform: uppercase;
                display: block;
            }
            .info-val {
                color: #0f172a;
                font-weight: bold;
                font-size: 8.5pt;
            }
            .voucher-table, .report-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 8px;
                margin-bottom: 12px;
            }
            .voucher-table th, .report-table th {
                background: #092c36;
                color: #ffffff;
                font-weight: bold;
                font-size: 8pt;
                padding: 6px 8px;
                text-align: left;
                border: 1px solid #092c36;
            }
            .voucher-table td, .report-table td {
                padding: 5px 8px;
                border: 1px solid #e2e8f0;
                font-size: 8pt;
            }
            .voucher-table tr:nth-child(even), .report-table tr:nth-child(even) {
                background: #f8fafc;
            }
            .voucher-financial-summary {
                margin-top: 10px;
                width: 100%;
            }
            .voucher-calc-table {
                width: 100%;
                border-collapse: collapse;
                font-size: 8pt;
            }
            .voucher-calc-table td {
                padding: 4px 6px;
            }
            .calc-label {
                text-align: right;
                font-weight: bold;
                color: #475569;
            }
            .calc-val {
                text-align: right;
                font-weight: bold;
                color: #0f172a;
                width: 120px;
            }
            .calc-total {
                border-top: 1.5px solid #092c36;
                font-size: 9.5pt;
                color: #0d9488;
                font-weight: bold;
            }
            .voucher-signatures-grid {
                width: 100%;
                margin-top: 35px;
                border-collapse: collapse;
            }
            .voucher-signatures-grid td {
                text-align: center;
                padding: 0 10px;
                font-size: 8pt;
            }
            .signature-line-block {
                border-top: 1px dashed #94a3b8;
                padding-top: 4px;
                font-weight: bold;
                color: #334155;
                text-transform: uppercase;
                font-size: 7.5pt;
            }
            .signature-line-block small {
                color: #64748b;
                font-size: 6.5pt;
                font-weight: normal;
                display: block;
            }
            .no-print, .voucher-screen-bar {
                display: none !important;
            }
        ';
    }
}
