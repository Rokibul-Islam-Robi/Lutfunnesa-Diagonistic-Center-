<?php
declare(strict_types=1);

require __DIR__ . '/../src/bootstrap.php';

$db = db();
echo "Executing Phase 14.1 - National & Global Drug Master Data Ingestion Pipeline (ETL)...";

$drugs = [
    // --- DIABETES CARE & INSULINS (Cold Chain 2°C - 8°C) ---
    ['Insuman 30/70 SoloStar 100 IU/ml', 'Human Insulin (30% Soluble / 70% Isophane)', '100 IU/ml 3ml Pen', 'Insulin Injection Pen', 'Sanofi Bangladesh Ltd', 'DAR-026-3121-08', 'Anti-Diabetic / Insulin', 'A10AD01', 0, '2°C - 8°C Cold Chain', 850.00],
    ['Mixtard 30 Penfill 100 IU/ml', 'Biphasic Isophane Insulin', '100 IU/ml 3ml Cartridge', 'Insulin Cartridge', 'Novo Nordisk A/S', 'DAR-012-9981-01', 'Anti-Diabetic / Insulin', 'A10AD01', 0, '2°C - 8°C Cold Chain', 920.00],
    ['Lantus SoloStar Pen 100 IU/ml', 'Insulin Glargine (Long-Acting)', '100 IU/ml 3ml Pen', 'Insulin Injection Pen', 'Sanofi Bangladesh Ltd', 'DAR-026-4412-11', 'Anti-Diabetic / Insulin', 'A10AE04', 0, '2°C - 8°C Cold Chain', 1450.00],
    ['Novorapid FlexPen 100 IU/ml', 'Insulin Aspart (Rapid-Acting)', '100 IU/ml 3ml Pen', 'Insulin Injection Pen', 'Novo Nordisk A/S', 'DAR-012-7711-04', 'Anti-Diabetic / Insulin', 'A10AB05', 0, '2°C - 8°C Cold Chain', 1250.00],
    ['Ryzodeg 70/30 FlexTouch', 'Insulin Degludec + Insulin Aspart', '100 U/ml 3ml Pen', 'Insulin Injection Pen', 'Novo Nordisk A/S', 'DAR-012-8832-09', 'Anti-Diabetic / Insulin', 'A10AD06', 0, '2°C - 8°C Cold Chain', 1850.00],
    ['Humulin N 100 IU/ml Vial', 'Isophane Insulin NPH', '100 IU/ml 10ml Vial', 'Vial Injection', 'Eli Lilly / Incepta', 'DAR-018-2234-02', 'Anti-Diabetic / Insulin', 'A10AC01', 0, '2°C - 8°C Cold Chain', 750.00],

    // --- ORAL ANTI-DIABETIC MEDICINES ---
    ['Secrin 2mg Tablet', 'Glimepiride', '2mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-4412-05', 'Anti-Diabetic / Sulfonylurea', 'A10BB12', 0, '15°C - 25°C Ambient', 8.00],
    ['Secrin 1mg Tablet', 'Glimepiride', '1mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-4411-04', 'Anti-Diabetic / Sulfonylurea', 'A10BB12', 0, '15°C - 25°C Ambient', 5.00],
    ['Secrin 3mg Tablet', 'Glimepiride', '3mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-4413-06', 'Anti-Diabetic / Sulfonylurea', 'A10BB12', 0, '15°C - 25°C Ambient', 11.00],
    ['Combitrust 50/500 Tablet', 'Vildagliptin + Metformin HCl', '50mg/500mg', 'Tablet', 'Incepta Pharmaceuticals Ltd', 'DAR-018-8831-01', 'Anti-Diabetic / DPP-4 + Biguanide', 'A10BD08', 0, '15°C - 25°C Ambient', 18.00],
    ['Sugamet 500mg Tablet', 'Metformin Hydrochloride', '500mg', 'Tablet', 'Beximco Pharmaceuticals Ltd', 'DAR-002-1204-03', 'Anti-Diabetic / Biguanide', 'A10BA02', 0, '15°C - 25°C Ambient', 3.50],
    ['Sugamet 850mg Tablet', 'Metformin Hydrochloride', '850mg', 'Tablet', 'Beximco Pharmaceuticals Ltd', 'DAR-002-1205-04', 'Anti-Diabetic / Biguanide', 'A10BA02', 0, '15°C - 25°C Ambient', 5.50],
    ['Sugamet XR 1000mg Tablet', 'Metformin Hydrochloride (Extended Release)', '1000mg', 'Tablet', 'Beximco Pharmaceuticals Ltd', 'DAR-002-1206-05', 'Anti-Diabetic / Biguanide', 'A10BA02', 0, '15°C - 25°C Ambient', 8.00],
    ['Linaglip 5mg Tablet', 'Linagliptin', '5mg', 'Tablet', 'Healthcare Pharmaceuticals Ltd', 'DAR-042-3312-01', 'Anti-Diabetic / DPP-4 Inhibitor', 'A10BH05', 0, '15°C - 25°C Ambient', 15.00],
    ['Linaglip M 2.5/500 Tablet', 'Linagliptin + Metformin HCl', '2.5mg/500mg', 'Tablet', 'Healthcare Pharmaceuticals Ltd', 'DAR-042-3315-04', 'Anti-Diabetic / DPP-4 + Biguanide', 'A10BD11', 0, '15°C - 25°C Ambient', 16.00],
    ['Glitus 10mg Tablet', 'Empagliflozin', '10mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-9921-02', 'Anti-Diabetic / SGLT2 Inhibitor', 'A10BK03', 0, '15°C - 25°C Ambient', 25.00],
    ['Dapa 10mg Tablet', 'Dapagliflozin', '10mg', 'Tablet', 'Incepta Pharmaceuticals Ltd', 'DAR-018-7741-09', 'Anti-Diabetic / SGLT2 Inhibitor', 'A10BK01', 0, '15°C - 25°C Ambient', 22.00],
    ['Diamicron MR 60mg Tablet', 'Gliclazide Modified Release', '60mg', 'Tablet', 'Servier / Opsonin', 'DAR-015-1102-08', 'Anti-Diabetic / Sulfonylurea', 'A10BB09', 0, '15°C - 25°C Ambient', 14.00],

    // --- CARDIOVASCULAR, HYPERTENSION & LIPID LOWERING ---
    ['Angilock 50mg Tablet', 'Losartan Potassium', '50mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-2210-09', 'Cardiovascular / ARB', 'C09CA01', 0, '15°C - 25°C Ambient', 8.00],
    ['Angilock 25mg Tablet', 'Losartan Potassium', '25mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-2209-08', 'Cardiovascular / ARB', 'C09CA01', 0, '15°C - 25°C Ambient', 5.00],
    ['Angilock 50 Plus Tablet', 'Losartan Potassium + Hydrochlorothiazide', '50mg/12.5mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-2212-11', 'Cardiovascular / ARB + Diuretic', 'C09DA01', 0, '15°C - 25°C Ambient', 10.00],
    ['Bizoran 5/20 Tablet', 'Amlodipine Besilate + Olmesartan Medoxomil', '5mg/20mg', 'Tablet', 'Incepta Pharmaceuticals Ltd', 'DAR-018-6621-01', 'Cardiovascular / CCB + ARB', 'C09DB02', 0, '15°C - 25°C Ambient', 12.00],
    ['Bizoran 5/40 Tablet', 'Amlodipine Besilate + Olmesartan Medoxomil', '5mg/40mg', 'Tablet', 'Incepta Pharmaceuticals Ltd', 'DAR-018-6622-02', 'Cardiovascular / CCB + ARB', 'C09DB02', 0, '15°C - 25°C Ambient', 16.00],
    ['Lipicon 10mg Tablet', 'Atorvastatin Calcium', '10mg', 'Tablet', 'Beximco Pharmaceuticals Ltd', 'DAR-002-3310-02', 'Cardiovascular / Statin', 'C10AA05', 0, '15°C - 25°C Ambient', 10.00],
    ['Rosuva 10mg Tablet', 'Rosuvastatin Calcium', '10mg', 'Tablet', 'Renata Limited', 'DAR-006-8812-04', 'Cardiovascular / Statin', 'C10AA07', 0, '15°C - 25°C Ambient', 15.00],
    ['Anclog 75mg Tablet', 'Clopidogrel Bisulfate', '75mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-7714-03', 'Cardiovascular / Antiplatelet', 'B01AC04', 0, '15°C - 25°C Ambient', 12.00],
    ['Ecosprin 75mg Tablet', 'Aspirin (Gastro-Resistant)', '75mg', 'Tablet', 'ACME Laboratories Ltd', 'DAR-004-1102-01', 'Cardiovascular / Antiplatelet', 'B01AC06', 0, '15°C - 25°C Ambient', 1.50],
    ['Tenoren 50mg Tablet', 'Atenolol', '50mg', 'Tablet', 'Opsonin Pharma Ltd', 'DAR-015-4401-02', 'Cardiovascular / Beta-Blocker', 'C07AB03', 0, '15°C - 25°C Ambient', 4.00],

    // --- GASTROINTESTINAL & PPIs ---
    ['Seclo 20mg Capsule', 'Omeprazole', '20mg', 'Capsule', 'Square Pharmaceuticals PLC', 'DAR-001-0020-01', 'Gastrointestinal / PPI', 'A02BC01', 0, '15°C - 25°C Ambient', 6.00],
    ['Seclo 40mg Injection', 'Omeprazole Sodium', '40mg', 'IV Injection', 'Square Pharmaceuticals PLC', 'DAR-001-0040-02', 'Gastrointestinal / PPI', 'A02BC01', 0, '15°C - 25°C Ambient', 85.00],
    ['Sergel 20mg Capsule', 'Esomeprazole Magnesium', '20mg', 'Capsule', 'Healthcare Pharmaceuticals Ltd', 'DAR-042-1020-03', 'Gastrointestinal / PPI', 'A02BC05', 0, '15°C - 25°C Ambient', 7.00],
    ['Sergel 40mg Capsule', 'Esomeprazole Magnesium', '40mg', 'Capsule', 'Healthcare Pharmaceuticals Ltd', 'DAR-042-1040-04', 'Gastrointestinal / PPI', 'A02BC05', 0, '15°C - 25°C Ambient', 10.00],
    ['Maxpro 20mg Capsule', 'Esomeprazole Magnesium', '20mg', 'Capsule', 'Renata Limited', 'DAR-006-2020-01', 'Gastrointestinal / PPI', 'A02BC05', 0, '15°C - 25°C Ambient', 7.00],
    ['Pantonix 20mg Tablet', 'Pantoprazole Sodium', '20mg', 'Tablet', 'Incepta Pharmaceuticals Ltd', 'DAR-018-3020-05', 'Gastrointestinal / PPI', 'A02BC02', 0, '15°C - 25°C Ambient', 6.00],
    ['Omidon 10mg Tablet', 'Domperidone', '10mg', 'Tablet', 'Incepta Pharmaceuticals Ltd', 'DAR-018-5010-09', 'Gastrointestinal / Prokinetic', 'A03FA03', 0, '15°C - 25°C Ambient', 3.00],
    ['Emistat 4mg Tablet', 'Ondansetron Hydrochloride', '4mg', 'Tablet', 'Healthcare Pharmaceuticals Ltd', 'DAR-042-8804-01', 'Gastrointestinal / Antiemetic', 'A04AA01', 0, '15°C - 25°C Ambient', 10.00],

    // --- ANTIBIOTICS & ANTIMICROBIALS ---
    ['Cef-3 400mg Capsule', 'Cefixime Trihydrate', '400mg', 'Capsule', 'Square Pharmaceuticals PLC', 'DAR-001-3400-08', 'Antibiotics / Cephalosporin', 'J01DD08', 0, '15°C - 25°C Ambient', 50.00],
    ['Cef-3 100mg/5ml Suspension', 'Cefixime Trihydrate', '100mg/5ml 50ml', 'Dry Suspension', 'Square Pharmaceuticals PLC', 'DAR-001-3100-07', 'Antibiotics / Cephalosporin', 'J01DD08', 0, '15°C - 25°C Ambient', 210.00],
    ['Furocef 500mg Tablet', 'Cefuroxime Axetil', '500mg', 'Tablet', 'Incepta Pharmaceuticals Ltd', 'DAR-018-5500-02', 'Antibiotics / Cephalosporin', 'J01DC02', 0, '15°C - 25°C Ambient', 45.00],
    ['Azithrocin 500mg Tablet', 'Azithromycin Monohydrate', '500mg', 'Tablet', 'Beximco Pharmaceuticals Ltd', 'DAR-002-5500-04', 'Antibiotics / Macrolide', 'J01FA10', 0, '15°C - 25°C Ambient', 35.00],
    ['Tobil 500mg Tablet', 'Levofloxacin Hemi-Hydrate', '500mg', 'Tablet', 'Aristopharma Ltd', 'DAR-021-7750-01', 'Antibiotics / Fluoroquinolone', 'J01MA12', 0, '15°C - 25°C Ambient', 18.00],
    ['Neofloxin 500mg Tablet', 'Ciprofloxacin Hydrochloride', '500mg', 'Tablet', 'Beximco Pharmaceuticals Ltd', 'DAR-002-9950-09', 'Antibiotics / Fluoroquinolone', 'J01MA02', 0, '15°C - 25°C Ambient', 15.00],
    ['Moxacil 500mg Capsule', 'Amoxicillin Trihydrate', '500mg', 'Capsule', 'Square Pharmaceuticals PLC', 'DAR-001-1500-01', 'Antibiotics / Penicillin', 'J01CA04', 0, '15°C - 25°C Ambient', 8.00],

    // --- ANALGESICS, NSAIDs & PAIN MANAGEMENT ---
    ['Napa 500mg Tablet', 'Paracetamol / Acetaminophen', '500mg', 'Tablet', 'Beximco Pharmaceuticals Ltd', 'DAR-002-0500-01', 'Analgesics & Antipyretics', 'N02BE01', 0, '15°C - 25°C Ambient', 1.20],
    ['Napa Extra Tablet', 'Paracetamol + Caffeine', '500mg/65mg', 'Tablet', 'Beximco Pharmaceuticals Ltd', 'DAR-002-0505-02', 'Analgesics & Antipyretics', 'N02BE51', 0, '15°C - 25°C Ambient', 2.50],
    ['Napa Extend 665mg Tablet', 'Paracetamol Extended Release', '665mg', 'Tablet', 'Beximco Pharmaceuticals Ltd', 'DAR-002-0665-03', 'Analgesics & Antipyretics', 'N02BE01', 0, '15°C - 25°C Ambient', 2.00],
    ['Ace 500mg Tablet', 'Paracetamol', '500mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-0500-02', 'Analgesics & Antipyretics', 'N02BE01', 0, '15°C - 25°C Ambient', 1.20],
    ['Clofenac 50mg Tablet', 'Diclofenac Sodium', '50mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-5050-09', 'NSAIDs / Analgesic', 'M01AB05', 0, '15°C - 25°C Ambient', 4.00],
    ['Fastflam 10mg Tablet', 'Ketorolac Tromethamine', '10mg', 'Tablet', 'Incepta Pharmaceuticals Ltd', 'DAR-018-1010-03', 'NSAIDs / Analgesic', 'M01AB15', 0, '15°C - 25°C Ambient', 12.00],
    ['Etorix 90mg Tablet', 'Etoricoxib', '90mg', 'Tablet', 'Incepta Pharmaceuticals Ltd', 'DAR-018-9090-06', 'NSAIDs / COX-2 Inhibitor', 'M01AH05', 0, '15°C - 25°C Ambient', 15.00],

    // --- RESPIRATORY & ANTI-ALLERGICS ---
    ['Monas 10mg Tablet', 'Montelukast Sodium', '10mg', 'Tablet', 'ACME Laboratories Ltd', 'DAR-004-8810-01', 'Respiratory / Anti-Asthmatic', 'R03DC03', 0, '15°C - 25°C Ambient', 16.00],
    ['Monas 4mg Chewable Tablet', 'Montelukast Sodium', '4mg', 'Chewable Tablet', 'ACME Laboratories Ltd', 'DAR-004-8804-02', 'Respiratory / Anti-Asthmatic', 'R03DC03', 0, '15°C - 25°C Ambient', 8.00],
    ['Alatrol 10mg Tablet', 'Cetirizine Dihydrochloride', '10mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-1010-05', 'Anti-Allergic / Antihistamine', 'R06AE07', 0, '15°C - 25°C Ambient', 3.50],
    ['Fenofex 120mg Tablet', 'Fexofenadine Hydrochloride', '120mg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-1212-08', 'Anti-Allergic / Antihistamine', 'R06AX26', 0, '15°C - 25°C Ambient', 9.00],
    ['Ventolin Inhaler 100mcg', 'Salbutamol Sulfate', '100mcg/dose (200 Puffs)', 'Metered Dose Inhaler', 'GlaxoSmithKline / Beximco', 'DAR-002-9900-01', 'Respiratory / Bronchodilator', 'R03AC02', 0, '15°C - 25°C Ambient', 250.00],

    // --- VITAMINS, MINERALS & NUTRITIONAL SUPPLEMENTS ---
    ['Aristovit B Tablet', 'Vitamin B-Complex (B1+B2+B6+B12)', 'Standard', 'Tablet', 'Aristopharma Ltd', 'DAR-021-1102-04', 'Vitamins & Supplements', 'A11BA', 0, '15°C - 25°C Ambient', 2.00],
    ['Neuro-B Tablet', 'Vitamin B1 + B6 + B12 (Neurotropic)', '100mg/200mg/200mcg', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-8812-09', 'Vitamins & Supplements', 'A11DB', 0, '15°C - 25°C Ambient', 8.00],
    ['Calbo-D Tablet', 'Calcium Carbonate + Vitamin D3', '500mg/200IU', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-5020-04', 'Vitamins & Minerals', 'A12AX', 0, '15°C - 25°C Ambient', 7.00],
    ['D-Rise 20000 IU Capsule', 'Cholecalciferol (Vitamin D3)', '20000 IU', 'Capsule', 'Incepta Pharmaceuticals Ltd', 'DAR-018-2000-01', 'Vitamins & Supplements', 'A11CC05', 0, '15°C - 25°C Ambient', 45.00],
    ['Filwel Gold Tablet', 'Multivitamin & Multimineral A-Z', 'A-Z Formula', 'Tablet', 'Square Pharmaceuticals PLC', 'DAR-001-9988-02', 'Vitamins & Minerals', 'A11AA03', 0, '15°C - 25°C Ambient', 10.00]
];

$stmt = $db->prepare('INSERT INTO pharmacy_medicines_global 
    (brand_name, generic_name, strength, dosage_form, manufacturer, dgda_dar_no, therapeutic_class, who_atc_code, is_narcotic, storage_temp, indicative_mrp)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE 
    brand_name=VALUES(brand_name), generic_name=VALUES(generic_name), strength=VALUES(strength), dosage_form=VALUES(dosage_form), 
    manufacturer=VALUES(manufacturer), dgda_dar_no=VALUES(dgda_dar_no), therapeutic_class=VALUES(therapeutic_class), 
    storage_temp=VALUES(storage_temp), indicative_mrp=VALUES(indicative_mrp)');

$count = 0;
foreach ($drugs as $d) {
    $stmt->execute($d);
    $count++;
}

echo "Successfully ingested {$count} DGDA National & Global Medicines Master records into pharmacy_medicines_global!\n";

// Phase 14.3: Clone top 12 essential items (especially Diabetes Care & Insulins) into Lutfunnesa Center local pharmacy items
echo "Phase 14.3 - Mapping Global Master to Lutfunnesa Center Local Inventory Catalog...\n";

$globals = $db->query('SELECT * FROM pharmacy_medicines_global ORDER BY id ASC LIMIT 15')->fetchAll();
$itemStmt = $db->prepare('INSERT INTO pharmacy_items 
    (global_medicine_id, sku_code, custom_name, rack_location, reorder_level, unit_type, pieces_per_strip, purchase_price, mrp, vat_percentage, cold_chain_required, is_active)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
    ON DUPLICATE KEY UPDATE custom_name=VALUES(custom_name), mrp=VALUES(mrp)');

$batchStmt = $db->prepare('INSERT INTO pharmacy_batches 
    (pharmacy_item_id, batch_number, mfg_date, expiry_date, purchase_rate, mrp, current_stock, cold_chain_verified)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)');

$mappedCount = 0;
foreach ($globals as $idx => $g) {
    $sku = 'SKU-LUDC-PHARM-' . str_pad((string)($idx + 101), 5, '0', STR_PAD_LEFT);
    $coldChain = str_contains(strtolower($g['storage_temp']), 'cold') ? 1 : 0;
    $purchasePrice = round((float)$g['indicative_mrp'] * 0.85, 2);
    $mrp = (float)$g['indicative_mrp'];
    $rack = $coldChain ? 'Refrigerator Unit A (2°C - 8°C)' : 'Rack ' . chr(65 + ($idx % 5)) . '-0' . (($idx % 3) + 1);

    $itemStmt->execute([
        $g['id'],
        $sku,
        $g['brand_name'] . ' (' . $g['generic_name'] . ')',
        $rack,
        20.00,
        str_contains(strtolower($g['dosage_form']), 'pen') || str_contains(strtolower($g['dosage_form']), 'inhaler') ? 'Piece' : 'Box',
        10,
        $purchasePrice,
        $mrp,
        0.00,
        $coldChain
    ]);
    $itemId = (int)$db->lastInsertId();

    if ($itemId > 0) {
        $batchNo = 'BATCH-' . strtoupper(substr(md5((string)$itemId), 0, 6)) . '-2026';
        $expDate = date('Y-m-d', strtotime('+' . (12 + ($idx * 2)) . ' months'));
        $stock = $coldChain ? 25.00 : 150.00;

        $batchStmt->execute([
            $itemId,
            $batchNo,
            date('Y-m-01'),
            $expDate,
            $purchasePrice,
            $mrp,
            $stock,
            $coldChain
        ]);
        $mappedCount++;
    }
}

echo "Successfully cloned and mapped {$mappedCount} medicines to Lutfunnesa Diabetes & Diagnostic Center stock with auto SKU & FEFO Batches!\n";
