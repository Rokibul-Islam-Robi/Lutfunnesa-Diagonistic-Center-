<?php
require __DIR__ . '/diagnostic/src/bootstrap.php';
$db = db();

echo "Starting seeding...\n";

// 1. Seed Analyzers
$analyzers = [
    ['code' => 'SYS-XN550', 'name' => 'Sysmex XN-550 Automated Hematology Analyzer (Japan)', 'protocol' => 'astm'],
    ['code' => 'COB-C311', 'name' => 'Roche Cobas c311 Clinical Chemistry System (Switzerland)', 'protocol' => 'hl7'],
    ['code' => 'ABB-ARCH', 'name' => 'Abbott ARCHITECT i1000SR Immunoassay Analyzer (USA)', 'protocol' => 'hl7'],
    ['code' => 'BAC-FX40', 'name' => 'BD BACTEC FX40 Automated Blood Culture System', 'protocol' => 'astm'],
    ['code' => 'BIO-D10', 'name' => 'Bio-Rad D-10 Hemoglobin A1c HPLC Testing System', 'protocol' => 'file'],
    ['code' => 'ROCH-AVL', 'name' => 'Roche 9180 Electrolyte Analyzer (ISE Direct)', 'protocol' => 'astm']
];

foreach ($analyzers as $a) {
    $stmt = $db->prepare('SELECT id FROM analyzer_connectors WHERE code=?');
    $stmt->execute([$a['code']]);
    if (!$stmt->fetchColumn()) {
        $ins = $db->prepare('INSERT INTO analyzer_connectors (code, name, protocol, active) VALUES (?, ?, ?, 1)');
        $ins->execute([$a['code'], $a['name'], $a['protocol']]);
        echo "Inserted analyzer: {$a['code']}\n";
    }
}

// 2. Ensure sample collections exist for orders 6, 7, 8
$itemsToCollect = [
    ['order_id' => 6, 'order_item_id' => 15, 'barcode' => 'BAR-261011-8812'],
    ['order_id' => 7, 'order_item_id' => 16, 'barcode' => 'BAR-261011-8813'],
    ['order_id' => 8, 'order_item_id' => 17, 'barcode' => 'BAR-261011-8814'],
];

foreach ($itemsToCollect as $itc) {
    $stmt = $db->prepare('SELECT id FROM sample_collections WHERE order_item_id=?');
    $stmt->execute([$itc['order_item_id']]);
    if (!$stmt->fetchColumn()) {
        $ins = $db->prepare('INSERT INTO sample_collections (barcode, order_id, order_item_id, branch_id, status, collected_by, collected_at) VALUES (?, ?, ?, 1, "collected", 1, NOW())');
        $ins->execute([$itc['barcode'], $itc['order_id'], $itc['order_item_id']]);
        echo "Inserted sample collection for item {$itc['order_item_id']}\n";
    }
}

// 3. Seed Microbiology Cultures
$cultures = [
    [
        'order_item_id' => 11, // Urine Culture
        'sample_collection_id' => 11,
        'specimen_quality' => 'Adequate Midstream Urine Specimen',
        'gram_stain_findings' => 'Moderate Gram-negative bacilli observed with 15-20 Pus cells/HPF',
        'growth_status' => 'growth_observed',
        'isolated_organism' => 'Escherichia coli (Significant Growth)',
        'colony_count' => '>10^5 CFU/mL',
        'reported_by' => 1,
        'sensitivities' => [
            ['Amikacin', 'S', '<=2 ug/mL'],
            ['Meropenem', 'S', '<=0.5 ug/mL'],
            ['Ceftriaxone', 'R', '>=16 ug/mL'],
            ['Ciprofloxacin', 'R', '>=4 ug/mL'],
            ['Nitrofurantoin', 'S', '<=16 ug/mL'],
            ['Cotrimoxazole', 'R', '>=80 ug/mL']
        ]
    ],
    [
        'order_item_id' => 15, // Sputum / TB
        'sample_collection_id' => 13,
        'specimen_quality' => 'Early Morning Mucopurulent Sputum',
        'gram_stain_findings' => 'Numerous Polymorphs, Gram-positive cocci in pairs, ZN Stain: AFB Positive (2+)',
        'growth_status' => 'incubation',
        'isolated_organism' => 'Mycobacterium tuberculosis complex (GeneXpert Detected, Rifampicin Resistance NOT Detected)',
        'colony_count' => 'Moderate (GeneXpert Medium)',
        'reported_by' => 1,
        'sensitivities' => []
    ],
    [
        'order_item_id' => 16, // Urine / Culture screening
        'sample_collection_id' => 14,
        'specimen_quality' => 'Clean Catch Midstream Urine',
        'gram_stain_findings' => 'No bacteria or significant pus cells seen (<2 HPF)',
        'growth_status' => 'no_growth',
        'isolated_organism' => 'No bacterial growth after 48 hours of aerobic incubation at 37°C',
        'colony_count' => '0 CFU/mL',
        'reported_by' => 1,
        'sensitivities' => []
    ]
];

foreach ($cultures as $c) {
    $stmt = $db->prepare('SELECT id FROM microbiology_cultures WHERE order_item_id=?');
    $stmt->execute([$c['order_item_id']]);
    $cid = $stmt->fetchColumn();
    if (!$cid) {
        $ins = $db->prepare('INSERT INTO microbiology_cultures (order_item_id, sample_collection_id, specimen_quality, gram_stain_findings, growth_status, isolated_organism, colony_count, reported_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
        $ins->execute([
            $c['order_item_id'],
            $c['sample_collection_id'],
            $c['specimen_quality'],
            $c['gram_stain_findings'],
            $c['growth_status'],
            $c['isolated_organism'],
            $c['colony_count'],
            $c['reported_by']
        ]);
        $cid = (int)$db->lastInsertId();
        echo "Inserted culture ID: {$cid}\n";

        foreach ($c['sensitivities'] as $s) {
            $sIns = $db->prepare('INSERT INTO culture_sensitivities (culture_id, antibiotic_name, susceptibility, mic_value) VALUES (?, ?, ?, ?)');
            $sIns->execute([$cid, $s[0], $s[1], $s[2]]);
        }
    }
}

// 4. Seed Histopathology & Cytology Cases
$pathologyCases = [
    [
        'accession_no' => 'BIO-2026-0041',
        'order_item_id' => 17, // Cervical Cytology
        'gross_description' => 'Received single liquid-based cytology vial containing cervical brush specimen in 20mL PreservCyt fixative.',
        'microscopic_description' => 'Smears show adequate cellularity consisting of superficial and intermediate squamous cells along with endocervical cells. No atypical squamous or glandular cells seen. Background shows lactobacilli with mild inflammation.',
        'diagnosis' => 'Negative for Intraepithelial Lesion or Malignancy (NILM), Bethesda System 2014. Mild nonspecific reactive cellular changes.',
        'comments' => 'Routine follow-up screening recommended after 3 years.',
        'pathologist_id' => 1,
        'status' => 'approved'
    ],
    [
        'accession_no' => 'BIO-2026-0042',
        'order_item_id' => 15,
        'gross_description' => 'Received multiple mucosal tissue fragments together measuring 0.6 x 0.4 x 0.3 cm. Entire tissue submitted in cassette A1.',
        'microscopic_description' => 'Sections show gastric antral mucosa exhibiting dense lymphoplasmacytic infiltration in the lamina propria with glandular atrophy and neutrophilic activity. Giemsa stain highlights Helicobacter pylori organisms on luminal surface.',
        'diagnosis' => 'Endoscopic Gastric Antral Biopsy: Chronic Active Gastritis with H. pylori colonization (Updated Sydney System).',
        'comments' => 'Triple therapy eradication regimen advised under gastroenterologist supervision.',
        'pathologist_id' => 1,
        'status' => 'microscopy'
    ],
    [
        'accession_no' => 'BIO-2026-0043',
        'order_item_id' => 16,
        'gross_description' => 'Received a punch biopsy of skin measuring 4mm in diameter and 3mm in depth with formal orientation intact.',
        'microscopic_description' => 'Processing in laboratory. Microtome sectioning and H&E staining in progress.',
        'diagnosis' => 'Histopathology evaluation in progress.',
        'comments' => 'Special stain (PAS & Fite) requested.',
        'pathologist_id' => 1,
        'status' => 'grossed'
    ]
];

foreach ($pathologyCases as $pc) {
    $stmt = $db->prepare('SELECT id FROM pathology_accessions WHERE accession_no=?');
    $stmt->execute([$pc['accession_no']]);
    if (!$stmt->fetchColumn()) {
        $ins = $db->prepare('INSERT INTO pathology_accessions (accession_no, order_item_id, gross_description, microscopic_description, diagnosis, comments, pathologist_id, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
        $ins->execute([
            $pc['accession_no'],
            $pc['order_item_id'],
            $pc['gross_description'],
            $pc['microscopic_description'],
            $pc['diagnosis'],
            $pc['comments'],
            $pc['pathologist_id'],
            $pc['status']
        ]);
        echo "Inserted pathology case: {$pc['accession_no']}\n";
    }
}

// 5. Seed Draft Lab Results for Pathologist Approval Desk
$draftResults = [
    [
        'order_id' => 6,
        'order_item_id' => 15,
        'test_id' => 30, // GeneXpert MTB
        'result_value' => 'MTB Detected (Medium), Rifampicin Resistance NOT Detected',
        'result_flag' => 'high',
        'reference_range_text' => 'Not Detected',
        'comments' => 'Correlate clinically with chest X-ray findings and clinical history.',
        'entered_by' => 1,
        'status' => 'draft'
    ],
    [
        'order_id' => 7,
        'order_item_id' => 16,
        'test_id' => 30, // GeneXpert MTB
        'result_value' => 'MTB NOT Detected',
        'result_flag' => 'normal',
        'reference_range_text' => 'Not Detected',
        'comments' => 'Negative for Mycobacterium tuberculosis DNA.',
        'entered_by' => 1,
        'status' => 'draft'
    ],
    [
        'order_id' => 8,
        'order_item_id' => 17,
        'test_id' => 28, // Cervical Cytology
        'result_value' => 'NILM - Negative for Intraepithelial Lesion or Malignancy',
        'result_flag' => 'normal',
        'reference_range_text' => 'Normal / NILM',
        'comments' => 'Satisfactory for evaluation. Endocervical component present.',
        'entered_by' => 1,
        'status' => 'draft'
    ],
    [
        'order_id' => 5,
        'order_item_id' => 14,
        'test_id' => 6, // Serum Uric Acid
        'result_value' => '8.9 mg/dL',
        'result_flag' => 'high',
        'reference_range_text' => '3.4 - 7.0 mg/dL',
        'comments' => 'Hyperuricemia noted. Re-check after dietary purine restriction.',
        'entered_by' => 1,
        'status' => 'draft'
    ]
];

foreach ($draftResults as $dr) {
    $stmt = $db->prepare('SELECT id FROM lab_results WHERE order_id=? AND test_id=? AND status="draft"');
    $stmt->execute([$dr['order_id'], $dr['test_id']]);
    if (!$stmt->fetchColumn()) {
        $ins = $db->prepare('INSERT INTO lab_results (order_id, order_item_id, test_id, result_value, result_flag, reference_range_text, comments, entered_by, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)');
        $ins->execute([
            $dr['order_id'],
            $dr['order_item_id'],
            $dr['test_id'],
            $dr['result_value'],
            $dr['result_flag'],
            $dr['reference_range_text'],
            $dr['comments'],
            $dr['entered_by'],
            $dr['status']
        ]);
        echo "Inserted draft result for order {$dr['order_id']} test {$dr['test_id']}\n";
    }
}

echo "All seeding complete!\n";
