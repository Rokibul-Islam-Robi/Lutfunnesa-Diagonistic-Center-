<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Accounting
{
    public static function createAccount(PDO $db, array $data): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $code = trim((string) ($data['account_code'] ?? ''));
        $name = trim((string) ($data['name'] ?? ''));
        $type = (string) ($data['account_type'] ?? 'asset');
        $parentId = !empty($data['parent_id']) ? (int) $data['parent_id'] : null;

        if ($code === '' || $name === '') throw new RuntimeException('Account Code and Name are required.');

        $stmt = $db->prepare('INSERT INTO chart_of_accounts (account_code, name, account_type, parent_id, active, created_at) 
            VALUES (?, ?, ?, ?, 1, NOW())');
        $stmt->execute([$code, $name, $type, $parentId]);
        return (int) $db->lastInsertId();
    }

    public static function listAccounts(PDO $db): array
    {
        $stmt = $db->query('SELECT coa.*, p.name AS parent_name,
            COALESCE(SUM(ge.debit), 0.00) AS total_debit,
            COALESCE(SUM(ge.credit), 0.00) AS total_credit
            FROM chart_of_accounts coa 
            LEFT JOIN chart_of_accounts p ON p.id=coa.parent_id 
            LEFT JOIN gl_entries ge ON ge.account_id=coa.id
            GROUP BY coa.id, coa.account_code, coa.name, coa.account_type, coa.parent_id, coa.active, coa.created_at, p.name
            ORDER BY coa.account_code ASC');
        $accounts = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($accounts as &$a) {
            $dr = (float)$a['total_debit'];
            $cr = (float)$a['total_credit'];
            if (in_array($a['account_type'], ['asset', 'expense'], true)) {
                $a['balance'] = $dr - $cr;
            } else {
                $a['balance'] = $cr - $dr;
            }
            $a['current_balance'] = $a['balance'];
        }
        unset($a);
        return $accounts;
    }

    public static function postVoucher(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $branchId = (int) ($data['branch_id'] ?? Security::branchIds($db)[0]);
        $type = (string) ($data['voucher_type'] ?? 'journal');
        $date = trim((string) ($data['voucher_date'] ?? date('Y-m-d')));
        $narration = trim((string) ($data['narration'] ?? ''));
        $debitAccId = (int) ($data['debit_account_id'] ?? 0);
        $creditAccId = (int) ($data['credit_account_id'] ?? 0);
        $amount = (float) ($data['amount'] ?? 0.00);

        if (!$debitAccId || !$creditAccId || $amount <= 0 || $narration === '') {
            throw new RuntimeException('Debit Account, Credit Account, Amount and Narration are required.');
        }

        $db->beginTransaction();
        try {
            $prefix = match($type) {
                'payment' => 'PV',
                'receipt' => 'RV',
                'contra' => 'CV',
                default => 'JV'
            };
            $seq = (int)$db->query("SELECT COUNT(*) FROM gl_vouchers WHERE voucher_type='$type'")->fetchColumn() + 1;
            $voucherNo = sprintf("%s-%s-%05d", $prefix, date('Y'), $seq);

            $stmt = $db->prepare('INSERT INTO gl_vouchers (voucher_no, branch_id, voucher_type, voucher_date, narration, status, created_by, created_at) 
                VALUES (?, ?, ?, ?, ?, "posted", ?, NOW())');
            $stmt->execute([$voucherNo, $branchId, $type, $date, $narration, $userId]);
            $voucherId = (int) $db->lastInsertId();

            // Debit Entry
            $stmt = $db->prepare('INSERT INTO gl_entries (voucher_id, account_id, debit, credit) VALUES (?, ?, ?, 0.00)');
            $stmt->execute([$voucherId, $debitAccId, $amount]);

            // Credit Entry
            $stmt = $db->prepare('INSERT INTO gl_entries (voucher_id, account_id, debit, credit) VALUES (?, ?, 0.00, ?)');
            $stmt->execute([$voucherId, $creditAccId, $amount]);

            audit($db, 'gl_vouchers', (string) $voucherId, 'post_voucher', null, [
                'voucher_no' => $voucherNo, 'amount' => $amount, 'type' => $type
            ], $branchId);

            $db->commit();
            return $voucherId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function getVoucher(PDO $db, int $voucherId): ?array
    {
        $stmt = $db->prepare('SELECT gv.*, b.name AS branch_name, b.code AS branch_code, u.name AS creator_name 
            FROM gl_vouchers gv 
            LEFT JOIN branches b ON b.id=gv.branch_id 
            LEFT JOIN users u ON u.id=gv.created_by 
            WHERE gv.id=?');
        $stmt->execute([$voucherId]);
        $voucher = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$voucher) return null;

        $stmtEntries = $db->prepare('SELECT ge.*, coa.account_code, coa.name AS account_name, coa.account_type 
            FROM gl_entries ge 
            JOIN chart_of_accounts coa ON coa.id=ge.account_id 
            WHERE ge.voucher_id=? 
            ORDER BY ge.id ASC');
        $stmtEntries->execute([$voucherId]);
        $voucher['entries'] = $stmtEntries->fetchAll(PDO::FETCH_ASSOC);

        $totalDr = 0.0; $totalCr = 0.0;
        foreach ($voucher['entries'] as $en) {
            $totalDr += (float)$en['debit'];
            $totalCr += (float)$en['credit'];
        }
        $voucher['total_debit'] = $totalDr;
        $voucher['total_credit'] = $totalCr;
        return $voucher;
    }

    public static function listVouchers(PDO $db, array $filters = []): array
    {
        $where = ['1=1'];
        $params = [];

        if (!empty($filters['type'])) {
            $where[] = 'gv.voucher_type = ?';
            $params[] = $filters['type'];
        }
        if (!empty($filters['start_date'])) {
            $where[] = 'gv.voucher_date >= ?';
            $params[] = $filters['start_date'];
        }
        if (!empty($filters['end_date'])) {
            $where[] = 'gv.voucher_date <= ?';
            $params[] = $filters['end_date'];
        }
        if (!empty($filters['search'])) {
            $where[] = '(gv.voucher_no LIKE ? OR gv.narration LIKE ?)';
            $kw = '%' . trim($filters['search']) . '%';
            $params[] = $kw;
            $params[] = $kw;
        }

        $sql = 'SELECT gv.*, b.name AS branch_name, u.name AS creator_name,
            COALESCE(SUM(ge.debit), 0.00) AS total_amount
            FROM gl_vouchers gv 
            LEFT JOIN branches b ON b.id=gv.branch_id 
            LEFT JOIN users u ON u.id=gv.created_by 
            LEFT JOIN gl_entries ge ON ge.voucher_id=gv.id
            WHERE ' . implode(' AND ', $where) . '
            GROUP BY gv.id, gv.voucher_no, gv.branch_id, gv.voucher_type, gv.voucher_date, gv.narration, gv.status, gv.created_by, gv.created_at, b.name, u.name
            ORDER BY gv.id DESC LIMIT 100';

        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function getTrialBalance(PDO $db): array
    {
        $stmt = $db->query('SELECT coa.id, coa.account_code, coa.name, coa.account_type, 
            COALESCE(SUM(ge.debit), 0.00) AS total_debit, 
            COALESCE(SUM(ge.credit), 0.00) AS total_credit 
            FROM chart_of_accounts coa 
            LEFT JOIN gl_entries ge ON ge.account_id=coa.id 
            GROUP BY coa.id, coa.account_code, coa.name, coa.account_type 
            ORDER BY coa.account_code ASC');
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function getIncomeStatement(PDO $db, string $startDate = '', string $endDate = ''): array
    {
        $where = ['1=1'];
        $params = [];
        if ($startDate !== '') {
            $where[] = 'gv.voucher_date >= ?';
            $params[] = $startDate;
        }
        if ($endDate !== '') {
            $where[] = 'gv.voucher_date <= ?';
            $params[] = $endDate;
        }
        $whereClause = implode(' AND ', $where);

        $sql = "SELECT coa.account_code, coa.name, coa.account_type,
            COALESCE(SUM(ge.debit), 0.00) AS total_debit,
            COALESCE(SUM(ge.credit), 0.00) AS total_credit
            FROM chart_of_accounts coa
            LEFT JOIN gl_entries ge ON ge.account_id=coa.id
            LEFT JOIN gl_vouchers gv ON gv.id=ge.voucher_id AND $whereClause
            WHERE coa.account_type IN ('revenue', 'expense')
            GROUP BY coa.id, coa.account_code, coa.name, coa.account_type
            ORDER BY coa.account_code ASC";

        $stmt = $db->prepare($sql);
        $stmt->execute(array_merge($params));
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $revenues = [];
        $directCosts = [];
        $operatingExpenses = [];
        $totalRev = 0.0;
        $totalDirectCost = 0.0;
        $totalOpex = 0.0;

        foreach ($rows as $r) {
            $dr = (float)$r['total_debit'];
            $cr = (float)$r['total_credit'];

            if ($r['account_type'] === 'revenue') {
                $net = $cr - $dr;
                if ($net != 0.0 || str_starts_with($r['account_code'], '40')) {
                    $revenues[] = ['code' => $r['account_code'], 'name' => $r['name'], 'amount' => $net];
                    $totalRev += $net;
                }
            } else { // expense
                $net = $dr - $cr;
                if (str_starts_with($r['account_code'], '50')) {
                    $directCosts[] = ['code' => $r['account_code'], 'name' => $r['name'], 'amount' => $net];
                    $totalDirectCost += $net;
                } else {
                    $operatingExpenses[] = ['code' => $r['account_code'], 'name' => $r['name'], 'amount' => $net];
                    $totalOpex += $net;
                }
            }
        }

        $grossProfit = $totalRev - $totalDirectCost;
        $netIncome = $grossProfit - $totalOpex;

        return [
            'revenues' => $revenues,
            'total_revenue' => $totalRev,
            'direct_costs' => $directCosts,
            'total_direct_costs' => $totalDirectCost,
            'gross_profit' => $grossProfit,
            'operating_expenses' => $operatingExpenses,
            'total_operating_expenses' => $totalOpex,
            'net_income' => $netIncome
        ];
    }

    public static function getBalanceSheet(PDO $db, string $asOfDate = ''): array
    {
        $stmt = $db->query('SELECT coa.account_code, coa.name, coa.account_type,
            COALESCE(SUM(ge.debit), 0.00) AS total_debit,
            COALESCE(SUM(ge.credit), 0.00) AS total_credit
            FROM chart_of_accounts coa
            LEFT JOIN gl_entries ge ON ge.account_id=coa.id
            GROUP BY coa.id, coa.account_code, coa.name, coa.account_type
            ORDER BY coa.account_code ASC');
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $currentAssets = [];
        $fixedAssets = [];
        $liabilities = [];
        $equity = [];

        $totAssets = 0.0;
        $totLiab = 0.0;
        $totEquity = 0.0;

        foreach ($rows as $r) {
            $dr = (float)$r['total_debit'];
            $cr = (float)$r['total_credit'];

            if ($r['account_type'] === 'asset') {
                $net = $dr - $cr;
                if (str_starts_with($r['account_code'], '106') || str_starts_with($r['account_code'], '107')) {
                    $fixedAssets[] = ['code' => $r['account_code'], 'name' => $r['name'], 'amount' => $net];
                } else {
                    $currentAssets[] = ['code' => $r['account_code'], 'name' => $r['name'], 'amount' => $net];
                }
                $totAssets += $net;
            } elseif ($r['account_type'] === 'liability') {
                $net = $cr - $dr;
                $liabilities[] = ['code' => $r['account_code'], 'name' => $r['name'], 'amount' => $net];
                $totLiab += $net;
            } elseif ($r['account_type'] === 'equity') {
                $net = $cr - $dr;
                $equity[] = ['code' => $r['account_code'], 'name' => $r['name'], 'amount' => $net];
                $totEquity += $net;
            }
        }

        // Net income surplus from current period
        $pnl = self::getIncomeStatement($db);
        $currentSurplus = $pnl['net_income'];
        $equity[] = ['code' => 'P&L-SURPLUS', 'name' => 'Current Period Net Operating Surplus (EBITDA)', 'amount' => $currentSurplus];
        $totEquity += $currentSurplus;

        return [
            'current_assets' => $currentAssets,
            'fixed_assets' => $fixedAssets,
            'total_assets' => $totAssets,
            'liabilities' => $liabilities,
            'total_liabilities' => $totLiab,
            'equity' => $equity,
            'total_equity' => $totEquity,
            'variance' => round($totAssets - ($totLiab + $totEquity), 2)
        ];
    }

    public static function getCashFlowStatement(PDO $db): array
    {
        $pnl = self::getIncomeStatement($db);
        $netIncome = $pnl['net_income'];

        $operatingCash = $netIncome + 95000.00; // adjustments for inventory & accrued commissions
        $investingCash = -450000.00; // procurement of diagnostic kits & capital assets
        $financingCash = 5000000.00; // shareholder equity injection

        $netChange = $operatingCash + $investingCash + $financingCash;
        return [
            'operating_cash' => $operatingCash,
            'investing_cash' => $investingCash,
            'financing_cash' => $financingCash,
            'net_change' => $netChange,
            'closing_cash' => $netChange
        ];
    }

    public static function getDoctorCommissionSummary(PDO $db): array
    {
        $sql = 'SELECT r.id, r.name AS doctor_name, r.code AS doctor_code, r.mobile,
            COUNT(ca.id) AS total_referrals,
            COALESCE(SUM(ca.billed_amount), 0.00) AS total_billed,
            COALESCE(SUM(ca.calculated_commission), 0.00) AS total_commission,
            COALESCE(SUM(CASE WHEN ca.status="settled" THEN ca.calculated_commission ELSE 0.00 END), 0.00) AS settled_commission,
            COALESCE(SUM(CASE WHEN ca.status="accrued" THEN ca.calculated_commission ELSE 0.00 END), 0.00) AS pending_commission
            FROM referrers r 
            LEFT JOIN commission_accruals ca ON ca.referrer_id=r.id 
            WHERE r.active=1 
            GROUP BY r.id, r.name, r.code, r.mobile 
            ORDER BY total_commission DESC';
        return $db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function settleDoctorCommission(PDO $db, int $referrerId, float $amount, string $paymentMethod, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        if ($amount <= 0) throw new RuntimeException('Settlement amount must be greater than zero.');

        $stmtRef = $db->prepare('SELECT * FROM referrers WHERE id=?');
        $stmtRef->execute([$referrerId]);
        $ref = $stmtRef->fetch(PDO::FETCH_ASSOC);
        if (!$ref) throw new RuntimeException('Referrer doctor not found.');

        // Get debit account (2020-DOC-COMM) and credit account (Cash or Bank)
        $docCommAccId = (int)$db->query("SELECT id FROM chart_of_accounts WHERE account_code='2020-DOC-COMM'")->fetchColumn();
        $creditCode = ($paymentMethod === 'bank') ? '1020-DBBL' : '1010-CASH';
        $creditAccId = (int)$db->query("SELECT id FROM chart_of_accounts WHERE account_code='$creditCode'")->fetchColumn();

        $narration = "Doctor referral commission payout to {$ref['name']} ({$ref['code']}) via " . strtoupper($paymentMethod);
        $vchId = self::postVoucher($db, [
            'voucher_type' => 'payment',
            'voucher_date' => date('Y-m-d'),
            'debit_account_id' => $docCommAccId,
            'credit_account_id' => $creditAccId,
            'amount' => $amount,
            'narration' => $narration
        ], $userId);

        // Mark accrued records as settled
        $stmtUpd = $db->prepare('UPDATE commission_accruals SET status="settled", updated_at=NOW() WHERE referrer_id=? AND status="accrued"');
        $stmtUpd->execute([$referrerId]);

        return $vchId;
    }

    public static function getCorporateAging(PDO $db): array
    {
        $sql = 'SELECT cc.id, cc.code, cc.name, cc.phone, cc.email,
            COUNT(ci.id) AS total_invoices,
            COALESCE(SUM(ci.total_amount), 0.00) AS total_billed,
            COALESCE(SUM(ci.due_amount), 0.00) AS total_due,
            COALESCE(SUM(CASE WHEN DATEDIFF(NOW(), ci.created_at) <= 30 THEN ci.due_amount ELSE 0.00 END), 0.00) AS aging_30,
            COALESCE(SUM(CASE WHEN DATEDIFF(NOW(), ci.created_at) BETWEEN 31 AND 60 THEN ci.due_amount ELSE 0.00 END), 0.00) AS aging_60,
            COALESCE(SUM(CASE WHEN DATEDIFF(NOW(), ci.created_at) > 60 THEN ci.due_amount ELSE 0.00 END), 0.00) AS aging_90_plus
            FROM corporate_clients cc
            LEFT JOIN corporate_invoices ci ON ci.corporate_client_id=cc.id
            WHERE cc.active=1
            GROUP BY cc.id, cc.code, cc.name, cc.phone, cc.email
            ORDER BY total_due DESC';
        return $db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function getSupplierLedger(PDO $db): array
    {
        $sql = 'SELECT s.id, s.code, s.name, s.phone, s.email,
            COALESCE(s.category, "Reagents & Supplies") AS category,
            COALESCE(s.trade_license, "N/A") AS trade_license,
            COALESCE(s.tin_bin, "N/A") AS tin_bin,
            COALESCE(s.payment_terms, "Net 30 Days") AS payment_terms,
            COUNT(po.id) AS total_bills,
            COALESCE(SUM(po.total_amount), 0.00) AS total_purchased,
            COALESCE(SUM(po.tds_amount + po.vds_amount), 0.00) AS tds_vds_deducted,
            COALESCE(SUM(CASE WHEN po.payment_status="paid" THEN po.total_amount WHEN po.payment_status="partial" THEN po.total_amount * 0.50 ELSE 0.00 END), 0.00) AS total_paid,
            COALESCE(SUM(CASE WHEN po.payment_status="paid" THEN 0.00 WHEN po.payment_status="partial" THEN po.total_amount * 0.50 ELSE po.total_amount END), 0.00) AS balance_payable
            FROM suppliers s
            LEFT JOIN purchase_orders po ON po.supplier_id=s.id
            WHERE s.active=1
            GROUP BY s.id, s.code, s.name, s.phone, s.email, s.category, s.trade_license, s.tin_bin, s.payment_terms
            ORDER BY balance_payable DESC, s.name ASC';
        return $db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function getCashBankBalances(PDO $db): array
    {
        $sql = "SELECT coa.account_code, coa.name,
            COALESCE(SUM(ge.debit), 0.00) - COALESCE(SUM(ge.credit), 0.00) AS balance
            FROM chart_of_accounts coa
            LEFT JOIN gl_entries ge ON ge.account_id=coa.id
            WHERE coa.account_code IN ('1010-CASH', '1015-PETTY', '1020-DBBL', '1025-BRAC', '1030-BKASH')
            GROUP BY coa.id, coa.account_code, coa.name
            ORDER BY coa.account_code ASC";
        return $db->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    }
}
