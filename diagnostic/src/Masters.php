<?php
declare(strict_types=1);
namespace Diagnostic;

use PDO;
use RuntimeException;

final class Masters
{
    public static function all(): array
    {
        $f = static fn(array $more = []): array => array_merge(['code' => 'text', 'name' => 'text', 'active' => 'bool'], $more);
        return [
            'organizations' => ['label'=>'Organizations','fields'=>['name'=>'text','short_name'=>'text','facility_identifier'=>'text?','phone'=>'text?','email'=>'email?','address'=>'textarea?','active'=>'bool']],
            'branches' => ['label'=>'Branches','fields'=>$f(['organization_id'=>'ref:organizations','address'=>'textarea?','phone'=>'text?','timezone'=>'text'])],
            'departments' => ['label'=>'Departments','fields'=>$f(['branch_id'=>'ref:branches','kind'=>'enum:clinical,administrative,support'])],
            'service_units' => ['label'=>'Service units','fields'=>$f(['branch_id'=>'ref:branches','department_id'=>'ref:departments?'])],
            'rooms' => ['label'=>'Rooms','fields'=>$f(['branch_id'=>'ref:branches','service_unit_id'=>'ref:service_units?'])],
            'counters' => ['label'=>'Counters','fields'=>$f(['branch_id'=>'ref:branches','purpose'=>'enum:registration,billing,delivery,other'])],
            'collection_booths' => ['label'=>'Collection booths','fields'=>$f(['branch_id'=>'ref:branches'])],
            'cost_centers' => ['label'=>'Cost centers','fields'=>$f(['branch_id'=>'ref:branches'])],
            'sample_types' => ['label'=>'Sample types','fields'=>$f()],
            'containers' => ['label'=>'Containers','fields'=>$f()],
            'methodologies' => ['label'=>'Methodologies','fields'=>$f()],
            'measurement_units' => ['label'=>'Measurement units','fields'=>$f()],
            'report_templates' => ['label'=>'Report templates','fields'=>$f(['template_kind'=>'enum:lab,radiology,other'])],
            'diagnostic_tests' => ['label'=>'Diagnostic tests','fields'=>$f(['department_id'=>'ref:departments?','sample_type_id'=>'ref:sample_types?','container_id'=>'ref:containers?','methodology_id'=>'ref:methodologies?','unit_id'=>'ref:measurement_units?','report_template_id'=>'ref:report_templates?','turnaround_minutes'=>'int?'])],
            'test_panels' => ['label'=>'Test panels','fields'=>$f()],
            'doctors' => ['label'=>'Doctors','fields'=>$f(['mobile'=>'text?','registration_no'=>'text?','specialty'=>'text?'])],
            'referrers' => ['label'=>'Referrers','fields'=>$f(['mobile'=>'text?','type'=>'enum:doctor,organization,other'])],
            'corporate_clients' => ['label'=>'Corporate clients','fields'=>$f(['phone'=>'text?','email'=>'email?'])],
            'suppliers' => ['label'=>'Suppliers','fields'=>$f(['phone'=>'text?','email'=>'email?'])],
            'banks' => ['label'=>'Banks','fields'=>$f()],
            'payment_methods' => ['label'=>'Payment methods','fields'=>$f(['kind'=>'enum:cash,card,bank,mfs,online,other'])],
            'discount_types' => ['label'=>'Discount types','fields'=>$f()],
            'reason_codes' => ['label'=>'Reason codes','fields'=>$f(['category'=>'enum:discount,refund,correction,cancellation,other'])],
            'tax_rules' => ['label'=>'Tax / VAT rules','fields'=>$f(['rate_percent'=>'decimal','effective_from'=>'date','effective_to'=>'date?'])],
        ];
    }

    public static function spec(string $entity): array
    {
        return self::all()[$entity] ?? throw new RuntimeException('Unknown master.');
    }

    public static function scoped(PDO $db, string $entity, int $limit = 100, string $search = ''): array
    {
        $spec = self::spec($entity);
        Security::requirePermission($db, 'masters.view');
        $where = []; $bind = [];
        if (isset($spec['fields']['branch_id'])) {
            $ids = Security::branchIds($db);
            if (!$ids) return [];
            $where[] = 'branch_id IN (' . implode(',', array_fill(0, count($ids), '?')) . ')';
            array_push($bind, ...$ids);
        } elseif ($entity === 'branches') {
            $ids = Security::branchIds($db);
            if (!$ids) return [];
            $where[] = 'id IN (' . implode(',', array_fill(0, count($ids), '?')) . ')';
            array_push($bind, ...$ids);
        } elseif ($entity === 'diagnostic_tests') {
            $ids = Security::branchIds($db);
            if (!$ids) return [];
            $where[] = '(department_id IS NULL OR department_id IN (SELECT id FROM departments WHERE branch_id IN (' . implode(',', array_fill(0, count($ids), '?')) . ')))';
            array_push($bind, ...$ids);
        }
        if ($search !== '') {
            $where[] = '(name LIKE ?' . (isset($spec['fields']['code']) ? ' OR code LIKE ?' : '') . ')';
            $term = '%' . $search . '%';
            $bind[] = $term;
            if (isset($spec['fields']['code'])) $bind[] = $term;
        }
        $sql = 'SELECT * FROM ' . $entity . ($where ? ' WHERE ' . implode(' AND ', $where) : '') . ' ORDER BY id DESC LIMIT ' . max(1, min(200, $limit));
        $stmt = $db->prepare($sql); $stmt->execute($bind);
        return $stmt->fetchAll();
    }

    public static function one(PDO $db, string $entity, int $id): array
    {
        $stmt = $db->prepare('SELECT * FROM ' . self::table($entity) . ' WHERE id=?');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        if (!$row) throw new RuntimeException('Record not found.');
        self::checkScope($db, $entity, $row);
        return $row;
    }

    private static function table(string $entity): string { self::spec($entity); return $entity; }

    public static function checkScope(PDO $db, string $entity, array $row): void
    {
        if (isset($row['branch_id'])) Security::requireBranch($db, (int) $row['branch_id']);
        if ($entity === 'branches') Security::requireBranch($db, (int) $row['id']);
        if ($entity === 'diagnostic_tests' && !empty($row['department_id'])) {
            $stmt = $db->prepare('SELECT branch_id FROM departments WHERE id=?');
            $stmt->execute([$row['department_id']]);
            Security::requireBranch($db, (int) $stmt->fetchColumn());
        }
    }

    public static function save(PDO $db, string $entity, array $submitted, int $id = 0): int
    {
        $spec = self::spec($entity);
        Security::requirePermission($db, 'masters.edit');
        if (in_array($entity, ['organizations','branches','tax_rules'], true)) Security::requirePermission($db, 'settings.manage');
        $before = $id ? self::one($db, $entity, $id) : null;
        $data = [];
        foreach ($spec['fields'] as $key => $type) {
            $optional = str_ends_with($type, '?');
            $base = rtrim($type, '?');
            if ($base === 'bool') { $data[$key] = !empty($submitted[$key]) ? 1 : 0; continue; }
            $raw = trim((string) ($submitted[$key] ?? ''));
            if ($raw === '') {
                if (!$optional) throw new RuntimeException(ucwords(str_replace('_', ' ', $key)) . ' is required.');
                $data[$key] = null; continue;
            }
            if (mb_strlen($raw) > ($base === 'textarea' ? 3000 : 190)) throw new RuntimeException('Input is too long.');
            if (str_starts_with($base, 'enum:') && !in_array($raw, explode(',', substr($base, 5)), true)) throw new RuntimeException('Invalid selection.');
            if ($base === 'email' && !filter_var($raw, FILTER_VALIDATE_EMAIL)) throw new RuntimeException('Invalid email.');
            if ($base === 'date' && !self::validDate($raw)) throw new RuntimeException('Invalid date.');
            if ($base === 'int' && (!ctype_digit($raw) || (int) $raw > 10000000)) throw new RuntimeException('Invalid number.');
            if ($base === 'decimal' && (!is_numeric($raw) || (float) $raw < 0 || (float) $raw > 100)) throw new RuntimeException('Invalid percentage.');
            if ($key === 'code' && (!preg_match('/^[A-Za-z0-9_-]{2,30}$/', $raw)
                || mb_strlen($raw) > (in_array($entity, ['diagnostic_tests','test_panels'], true) ? 30 : 25))) {
                throw new RuntimeException('Code is invalid or too long for this master.');
            }
            if (str_starts_with($base, 'ref:')) {
                if (!ctype_digit($raw) || (int) $raw < 1) throw new RuntimeException('Invalid reference.');
                $target = substr($base, 4);
                $ref = self::one($db, $target, (int) $raw);
                $raw = (int) $ref['id'];
            }
            $data[$key] = $raw;
        }
        if (isset($data['branch_id']) && $data['branch_id']) Security::requireBranch($db, (int) $data['branch_id']);
        if (!empty($data['department_id'])) {
            Security::requireDepartment($db, (int) $data['department_id']);
            $department = self::one($db, 'departments', (int) $data['department_id']);
            if (!empty($data['branch_id']) && (int) $department['branch_id'] !== (int) $data['branch_id']) throw new RuntimeException('Department must belong to selected branch.');
        }
        if (!empty($data['service_unit_id']) && !empty($data['branch_id'])) {
            $unit = self::one($db, 'service_units', (int) $data['service_unit_id']);
            if ((int) $unit['branch_id'] !== (int) $data['branch_id']) throw new RuntimeException('Service unit must belong to selected branch.');
        }
        if (isset($data['effective_from'], $data['effective_to']) && $data['effective_to'] && $data['effective_to'] < $data['effective_from']) throw new RuntimeException('End date must be later than start date.');
        $db->beginTransaction();
        try {
            $columns = array_keys($data);
            if ($id) {
                $assign = implode(',', array_map(static fn($c) => $c . '=?', $columns));
                $db->prepare('UPDATE ' . $entity . ' SET ' . $assign . ' WHERE id=?')->execute([...array_values($data), $id]);
            } else {
                $db->prepare('INSERT INTO ' . $entity . '(' . implode(',', $columns) . ') VALUES(' . implode(',', array_fill(0, count($columns), '?')) . ')')->execute(array_values($data));
                $id = (int) $db->lastInsertId();
                if ($entity === 'branches') {
                    $db->prepare('INSERT INTO user_branches(user_id,branch_id) VALUES(?,?)')->execute([$_SESSION['user_id'], $id]);
                    foreach (['patient'=>'PAT-','order'=>'ORD-','invoice'=>'INV-','receipt'=>'RCT-','barcode'=>'SMP-','report'=>'RPT-','voucher'=>'VCH-','purchase'=>'PUR-','employee'=>'EMP-'] as $type => $prefix) {
                        $db->prepare('INSERT INTO number_sequences(document_type,branch_id,prefix) VALUES(?,?,?)')->execute([$type,$id,$prefix]);
                    }
                }
            }
            $after = $db->query('SELECT * FROM ' . $entity . ' WHERE id=' . $id)->fetch();
            \audit($db, $entity, (string) $id, $before ? 'update' : 'create', $before, $after, isset($after['branch_id']) ? (int) $after['branch_id'] : ($entity === 'branches' ? $id : null));
            $db->commit();
            return $id;
        } catch (\Throwable $e) { $db->rollBack(); throw $e; }
    }

    private static function validDate(string $date): bool
    {
        $parsed = \DateTimeImmutable::createFromFormat('!Y-m-d', $date);
        return $parsed && $parsed->format('Y-m-d') === $date;
    }

    public static function choices(PDO $db, string $target): array
    {
        $rows = self::scoped($db, $target, 200);
        return array_values(array_filter($rows, static fn($row) => (int) $row['active'] === 1));
    }
}
