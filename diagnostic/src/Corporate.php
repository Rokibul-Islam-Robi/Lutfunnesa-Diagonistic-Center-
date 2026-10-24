<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class Corporate
{
    public static function createContract(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $corporateClientId = (int) ($data['corporate_client_id'] ?? 0);
        $startDate = trim((string) ($data['agreement_start'] ?? date('Y-m-d')));
        $endDate = trim((string) ($data['agreement_end'] ?? date('Y-12-31')));
        $creditLimit = (float) ($data['credit_limit'] ?? 500000.00);
        $discountPercent = (float) ($data['discount_percent'] ?? 0.00);
        $preAuthRequired = !empty($data['pre_auth_required']) ? 1 : 0;

        if (!$corporateClientId) throw new RuntimeException('Corporate Client is required.');

        $db->beginTransaction();
        try {
            $contractNo = Numbering::next($db, 'voucher', 1);
            $contractNo = str_replace('VOU-', 'CORP-', $contractNo);

            $stmt = $db->prepare('INSERT INTO corporate_contracts (corporate_client_id, contract_no, agreement_start, agreement_end, credit_limit, discount_percent, pre_auth_required) 
                VALUES (?, ?, ?, ?, ?, ?, ?)');
            $stmt->execute([$corporateClientId, $contractNo, $startDate, $endDate, $creditLimit, $discountPercent, $preAuthRequired]);
            $id = (int) $db->lastInsertId();

            audit($db, 'corporate_contracts', (string) $id, 'create_contract', null, [
                'contract_no' => $contractNo, 'credit_limit' => $creditLimit
            ], 1);

            $db->commit();
            return $id;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function listContracts(PDO $db): array
    {
        $stmt = $db->query('SELECT cc.*, c.name AS corporate_name, c.code AS corporate_code 
            FROM corporate_contracts cc 
            JOIN corporate_clients c ON c.id=cc.corporate_client_id 
            ORDER BY cc.id DESC');
        return $stmt->fetchAll();
    }

    public static function createInvoice(PDO $db, array $data, int $userId): int
    {
        Security::requirePermission($db, 'dashboard.view');
        $corporateClientId = (int) ($data['corporate_client_id'] ?? 0);
        $branchId = (int) ($data['branch_id'] ?? Security::branchIds($db)[0]);
        $period = trim((string) ($data['billing_period'] ?? date('F Y')));
        $totalAmount = (float) ($data['total_amount'] ?? 0.00);

        if (!$corporateClientId || $totalAmount <= 0) throw new RuntimeException('Corporate Client and valid total amount are required.');

        $db->beginTransaction();
        try {
            $invNo = Numbering::next($db, 'invoice', $branchId);
            $invNo = str_replace('INV-', 'C-INV-', $invNo);

            $stmt = $db->prepare('INSERT INTO corporate_invoices (invoice_no, corporate_client_id, branch_id, billing_period, total_amount, due_amount, status, created_by) 
                VALUES (?, ?, ?, ?, ?, ?, "submitted", ?)');
            $stmt->execute([$invNo, $corporateClientId, $branchId, $period, $totalAmount, $totalAmount, $userId]);
            $id = (int) $db->lastInsertId();

            audit($db, 'corporate_invoices', (string) $id, 'create_corporate_invoice', null, [
                'invoice_no' => $invNo, 'total_amount' => $totalAmount
            ], $branchId);

            $db->commit();
            return $id;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    public static function listInvoices(PDO $db): array
    {
        $stmt = $db->query('SELECT ci.*, c.name AS corporate_name, b.name AS branch_name, u.name AS creator_name 
            FROM corporate_invoices ci 
            JOIN corporate_clients c ON c.id=ci.corporate_client_id 
            JOIN branches b ON b.id=ci.branch_id 
            JOIN users u ON u.id=ci.created_by 
            ORDER BY ci.id DESC');
        return $stmt->fetchAll();
    }
}
