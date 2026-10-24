<?php
require dirname(__DIR__) . '/src/bootstrap.php';
$db = db();

echo "Starting full realistic data seeding for QC, CAPA, SOP, Licenses, Approval Policies & Approval Requests...\n";

// 1. Approval Policies
$db->exec("DELETE FROM approval_requests");
$db->exec("DELETE FROM approval_policies");

$policies = [
    ['discount', null, 0.00, 50000.00, 'approvals.decide'],
    ['refund', null, 0.00, 100000.00, 'approvals.decide'],
    ['result_correction', null, 0.00, 10000.00, 'approvals.decide'],
    ['credit_note', null, 0.00, 50000.00, 'approvals.decide'],
    ['purchase', null, 0.00, 500000.00, 'approvals.decide'],
    ['journal_posting', null, 0.00, 1000000.00, 'approvals.decide'],
];

$policyStmt = $db->prepare("INSERT INTO approval_policies (action_type, branch_id, min_amount, max_amount, approver_permission, active, created_at) VALUES (?, ?, ?, ?, ?, 1, NOW())");
$policyMap = [];
foreach ($policies as $p) {
    $policyStmt->execute([$p[0], $p[1], $p[2], $p[3], $p[4]]);
    $policyMap[$p[0]] = (int)$db->lastInsertId();
}
echo "Inserted " . count($policies) . " approval policies.\n";

// 2. Approval Requests (Realistic data for 5th image: Dhaka Main Branch, Uttara, Dhanmondi)
$approvals = [
    [
        'policy_key' => 'discount',
        'action_type' => 'discount',
        'entity_type' => 'invoice',
        'entity_id' => 'INV-2026-00001',
        'branch_id' => 1,
        'amount' => 450.00,
        'maker_id' => 2, // Receptionist
        'checker_id' => null,
        'status' => 'pending',
        'request_reason' => 'Special 15% discount for verified Freedom Fighter / Senior Citizen diabetic patient (Nasir Uddin).',
        'created_at' => date('Y-m-d H:i:s', strtotime('-2 hours'))
    ],
    [
        'policy_key' => 'refund',
        'action_type' => 'refund',
        'entity_type' => 'invoice',
        'entity_id' => 'INV-2026-00003',
        'branch_id' => 1,
        'amount' => 1200.00,
        'maker_id' => 2,
        'checker_id' => null,
        'status' => 'pending',
        'request_reason' => 'Patient duplicate payment refund request due to MFS bKash double deduction at counter.',
        'created_at' => date('Y-m-d H:i:s', strtotime('-4 hours'))
    ],
    [
        'policy_key' => 'purchase',
        'action_type' => 'purchase',
        'entity_type' => 'purchase_order',
        'entity_id' => 'PO-2026-0089',
        'branch_id' => 1,
        'amount' => 64500.00,
        'maker_id' => 5, // Pharmacy/Center Staff
        'checker_id' => null,
        'status' => 'pending',
        'request_reason' => 'Urgent procurement requisition for Sysmex Hematology Reagent packs & Bio-Rad controls.',
        'created_at' => date('Y-m-d H:i:s', strtotime('-6 hours'))
    ],
    [
        'policy_key' => 'result_correction',
        'action_type' => 'result_correction',
        'entity_type' => 'lab_report',
        'entity_id' => 'REP-2026-00845',
        'branch_id' => 1,
        'amount' => 0.00,
        'maker_id' => 3, // Lab Tech
        'checker_id' => null,
        'status' => 'pending',
        'request_reason' => 'Correction in Serum Potassium decimal transcription following analyzer rerun verification.',
        'created_at' => date('Y-m-d H:i:s', strtotime('-18 hours'))
    ],
    [
        'policy_key' => 'discount',
        'action_type' => 'discount',
        'entity_type' => 'invoice',
        'entity_id' => 'INV-2026-00002',
        'branch_id' => 2,
        'amount' => 600.00,
        'maker_id' => 2,
        'checker_id' => 1,
        'status' => 'approved',
        'request_reason' => 'Corporate MoU package rebate for Biman Bangladesh Airlines executive health checkup.',
        'created_at' => date('Y-m-d H:i:s', strtotime('-1 day'))
    ],
    [
        'policy_key' => 'credit_note',
        'action_type' => 'credit_note',
        'entity_type' => 'corporate_invoice',
        'entity_id' => 'CORP-INV-2026-014',
        'branch_id' => 1,
        'amount' => 18500.00,
        'maker_id' => 2,
        'checker_id' => 1,
        'status' => 'approved',
        'request_reason' => 'Adjustment credit note for bulk employee annual health screening at Dhaka Main Branch.',
        'created_at' => date('Y-m-d H:i:s', strtotime('-2 days'))
    ]
];

$appStmt = $db->prepare("INSERT INTO approval_requests (policy_id, action_type, entity_type, entity_id, branch_id, amount, maker_id, checker_id, status, request_reason, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
foreach ($approvals as $a) {
    $policyId = $policyMap[$a['policy_key']];
    $appStmt->execute([
        $policyId,
        $a['action_type'],
        $a['entity_type'],
        $a['entity_id'],
        $a['branch_id'],
        $a['amount'],
        $a['maker_id'],
        $a['checker_id'],
        $a['status'],
        $a['request_reason'],
        $a['created_at']
    ]);
}
echo "Inserted " . count($approvals) . " approval requests.\n";

// 3. Quality Controls (QC & Westgard logs for 1st image)
$db->exec("DELETE FROM quality_controls");
$qcRows = [
    ['Biochemistry', 1, 'level_1', 100.0000, 100.8000, 'passed', date('Y-m-d H:i:s', strtotime('-1 hour'))],
    ['Biochemistry', 1, 'level_2', 250.0000, 252.4000, 'passed', date('Y-m-d H:i:s', strtotime('-2 hours'))],
    ['Biochemistry', 3, 'level_1', 5.8000, 5.7600, 'passed', date('Y-m-d H:i:s', strtotime('-3 hours'))],
    ['Hematology', 9, 'level_1', 14.5000, 14.4200, 'passed', date('Y-m-d H:i:s', strtotime('-4 hours'))],
    ['Hematology', 9, 'level_2', 8.2000, 8.1800, 'passed', date('Y-m-d H:i:s', strtotime('-5 hours'))],
    ['Immunology', 4, 'level_1', 2.4500, 2.4800, 'passed', date('Y-m-d H:i:s', strtotime('-6 hours'))],
    ['Biochemistry', 8, 'level_3', 3.2000, 3.8200, 'out_of_control', date('Y-m-d H:i:s', strtotime('-8 hours'))],
    ['Microbiology', null, 'level_1', 99.5000, 99.2000, 'passed', date('Y-m-d H:i:s', strtotime('-12 hours'))],
    ['Biochemistry', 4, 'level_1', 1.0500, 1.0400, 'passed', date('Y-m-d H:i:s', strtotime('-1 day'))],
    ['Hematology', 9, 'level_3', 4.1000, 4.0800, 'passed', date('Y-m-d H:i:s', strtotime('-1 day 2 hours'))]
];

$qcStmt = $db->prepare("INSERT INTO quality_controls (section_name, test_id, qc_level, target_value, observed_value, status, logged_at) VALUES (?, ?, ?, ?, ?, ?, ?)");
foreach ($qcRows as $r) {
    $qcStmt->execute($r);
}
echo "Inserted " . count($qcRows) . " QC logs.\n";

// 4. CAPA Incidents (2nd image)
$db->exec("DELETE FROM capa_incidents");
$capaRows = [
    [
        'incident_no' => 'CAPA-2026-001',
        'department_id' => 3, // Pathology
        'severity' => 'major',
        'issue_description' => 'Specimen hemolyzed during peak hour transit due to courier cold-chain container seal breakdown.',
        'root_cause' => 'Defective gasket seal on secondary insulated cooler transport box.',
        'corrective_action' => 'Immediately replaced transport boxes with certified medical cooler units equipped with digital temperature data loggers.',
        'preventive_action' => 'Daily cold chain temperature audit log before courier vehicle departure.',
        'target_date' => date('Y-m-d', strtotime('+7 days')),
        'status' => 'open',
        'reported_by' => 3,
        'created_at' => date('Y-m-d H:i:s', strtotime('-5 hours'))
    ],
    [
        'incident_no' => 'CAPA-2026-002',
        'department_id' => 3,
        'severity' => 'minor',
        'issue_description' => 'Minor barcode scan mismatch during high-throughput rack loading on Sysmex XN-550.',
        'root_cause' => 'Thermal barcode label ribbon low density causing minor print smudging.',
        'corrective_action' => 'Printer ribbon replaced and print darkness density recalibrated from 8 to 12.',
        'preventive_action' => 'Weekly maintenance checklist item added for barcode label thermal head cleaning.',
        'target_date' => date('Y-m-d', strtotime('+3 days')),
        'status' => 'open',
        'reported_by' => 3,
        'created_at' => date('Y-m-d H:i:s', strtotime('-1 day'))
    ],
    [
        'incident_no' => 'CAPA-2026-003',
        'department_id' => 4, // Radiology
        'severity' => 'critical',
        'issue_description' => 'PACS DICOM gateway transfer latency exceeded TAT threshold during emergency CT upload.',
        'root_cause' => 'LAN switch uplink port packet drop due to unshielded Cat6 cable termination bend.',
        'corrective_action' => 'Switched to redundant optical fiber gigabit backbone uplink.',
        'preventive_action' => 'Annual structured cabling certification and redundant network routing enabled.',
        'target_date' => date('Y-m-d', strtotime('+14 days')),
        'status' => 'in_progress',
        'reported_by' => 1,
        'created_at' => date('Y-m-d H:i:s', strtotime('-2 days'))
    ],
    [
        'incident_no' => 'CAPA-2026-004',
        'department_id' => 9, // Front desk
        'severity' => 'minor',
        'issue_description' => 'Patient phone number transcription error on registration slip during peak rush.',
        'root_cause' => 'Verbal intake noise interference in counter queue #2.',
        'corrective_action' => 'Counter display screen activated showing patient entered info for immediate patient confirmation.',
        'preventive_action' => 'Two-way customer verification display installed at all billing booths.',
        'target_date' => date('Y-m-d', strtotime('-1 day')),
        'status' => 'closed',
        'reported_by' => 2,
        'created_at' => date('Y-m-d H:i:s', strtotime('-5 days'))
    ]
];

$capaStmt = $db->prepare("INSERT INTO capa_incidents (incident_no, department_id, severity, issue_description, root_cause, corrective_action, preventive_action, target_date, status, reported_by, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
foreach ($capaRows as $cp) {
    $capaStmt->execute([
        $cp['incident_no'],
        $cp['department_id'],
        $cp['severity'],
        $cp['issue_description'],
        $cp['root_cause'],
        $cp['corrective_action'],
        $cp['preventive_action'],
        $cp['target_date'],
        $cp['status'],
        $cp['reported_by'],
        $cp['created_at']
    ]);
}
echo "Inserted " . count($capaRows) . " CAPA incidents.\n";

// 5. Controlled Documents / SOPs (3rd image)
$db->exec("DELETE FROM controlled_documents");
$sopRows = [
    [
        'doc_no' => 'SOP-CLIN-001',
        'title' => 'Critical Laboratory Result Immediate Telephone Notification SOP',
        'category' => 'sop',
        'version' => '2.1',
        'effective_date' => '2026-01-01',
        'review_date' => '2027-01-01',
        'status' => 'approved',
        'created_at' => '2026-01-01 09:00:00'
    ],
    [
        'doc_no' => 'SOP-CLIN-002',
        'title' => 'Phlebotomy Standard Protocol & Specimen Identification Verification',
        'category' => 'sop',
        'version' => '3.0',
        'effective_date' => '2026-02-15',
        'review_date' => '2027-02-15',
        'status' => 'approved',
        'created_at' => '2026-02-15 10:00:00'
    ],
    [
        'doc_no' => 'POL-QMS-005',
        'title' => 'Quality Management System & Multi-Level Westgard QC Policy',
        'category' => 'policy',
        'version' => '1.4',
        'effective_date' => '2026-03-01',
        'review_date' => '2027-03-01',
        'status' => 'approved',
        'created_at' => '2026-03-01 11:30:00'
    ],
    [
        'doc_no' => 'SOP-RAD-008',
        'title' => 'Radiation Safety, Lead Shielding & BAERA Compliance Protocol',
        'category' => 'sop',
        'version' => '2.0',
        'effective_date' => '2026-04-10',
        'review_date' => '2027-04-10',
        'status' => 'approved',
        'created_at' => '2026-04-10 14:00:00'
    ],
    [
        'doc_no' => 'FRM-BIO-012',
        'title' => 'Daily High-Risk Biomedical Waste Disposal & Decontamination Log Form',
        'category' => 'form',
        'version' => '1.2',
        'effective_date' => '2026-05-01',
        'review_date' => '2027-05-01',
        'status' => 'approved',
        'created_at' => '2026-05-01 08:30:00'
    ],
    [
        'doc_no' => 'POL-SEC-003',
        'title' => 'Patient Medical Record Confidentiality & Digital Privacy Policy',
        'category' => 'policy',
        'version' => '1.1',
        'effective_date' => '2026-06-01',
        'review_date' => '2027-06-01',
        'status' => 'approved',
        'created_at' => '2026-06-01 10:00:00'
    ]
];

$sopStmt = $db->prepare("INSERT INTO controlled_documents (doc_no, title, category, version, effective_date, review_date, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
foreach ($sopRows as $sp) {
    $sopStmt->execute([
        $sp['doc_no'],
        $sp['title'],
        $sp['category'],
        $sp['version'],
        $sp['effective_date'],
        $sp['review_date'],
        $sp['status'],
        $sp['created_at']
    ]);
}
echo "Inserted " . count($sopRows) . " controlled documents.\n";

// 6. Regulatory & Compliance Licenses (4th image)
$db->exec("DELETE FROM compliance_licenses");
$licenseRows = [
    [
        'license_no' => 'DGHS-DIAG-DHAKA-2026-089',
        'title' => 'DGHS Clinical Diagnostic Center & Pathology Lab Facility License',
        'category' => 'facility',
        'issuing_authority' => 'Directorate General of Health Services (DGHS Bangladesh)',
        'effective_date' => '2026-01-01',
        'expiry_date' => '2026-12-31',
        'status' => 'active',
        'created_at' => '2026-01-01 10:00:00'
    ],
    [
        'license_no' => 'BAERA-RAD-SAFETY-2026-441',
        'title' => 'Bangladesh Atomic Energy Regulatory Authority (BAERA) Radiation Safety License (X-Ray & CT)',
        'category' => 'radiation',
        'issuing_authority' => 'BAERA Bangladesh',
        'effective_date' => '2025-07-01',
        'expiry_date' => '2027-06-30',
        'status' => 'active',
        'created_at' => '2025-07-01 11:00:00'
    ],
    [
        'license_no' => 'FSCD-FIRE-DHAKA-9021',
        'title' => 'Fire Prevention, Emergency Evacuation & Fire Safety Clearance Certificate',
        'category' => 'fire_safety',
        'issuing_authority' => 'Fire Service and Civil Defence (FSCD Bangladesh)',
        'effective_date' => '2025-11-15',
        'expiry_date' => '2026-11-14',
        'status' => 'renewal_due',
        'created_at' => '2025-11-15 12:00:00'
    ],
    [
        'license_no' => 'DOE-ENV-MEDWASTE-3042',
        'title' => 'Department of Environment (DoE) Bio-medical Waste Management & Environmental Clearance',
        'category' => 'environment',
        'issuing_authority' => 'Department of Environment, Ministry of Environment Bangladesh',
        'effective_date' => '2026-02-01',
        'expiry_date' => '2027-01-31',
        'status' => 'active',
        'created_at' => '2026-02-01 09:30:00'
    ],
    [
        'license_no' => 'DNCC-TRADE-LIC-008741',
        'title' => 'Dhaka North City Corporation (DNCC) Commercial Healthcare Trade License',
        'category' => 'trade',
        'issuing_authority' => 'Dhaka North City Corporation (Zone-3)',
        'effective_date' => '2026-07-01',
        'expiry_date' => '2027-06-30',
        'status' => 'active',
        'created_at' => '2026-07-01 10:00:00'
    ],
    [
        'license_no' => 'DGDA-DRUG-STORE-5521',
        'title' => 'Directorate General of Drug Administration (DGDA) Retail Pharmacy Dispensing License',
        'category' => 'facility',
        'issuing_authority' => 'Directorate General of Drug Administration (DGDA)',
        'effective_date' => '2026-01-10',
        'expiry_date' => '2028-01-09',
        'status' => 'active',
        'created_at' => '2026-01-10 11:00:00'
    ]
];

$licStmt = $db->prepare("INSERT INTO compliance_licenses (license_no, title, category, issuing_authority, effective_date, expiry_date, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
foreach ($licenseRows as $lc) {
    $licStmt->execute([
        $lc['license_no'],
        $lc['title'],
        $lc['category'],
        $lc['issuing_authority'],
        $lc['effective_date'],
        $lc['expiry_date'],
        $lc['status'],
        $lc['created_at']
    ]);
}
echo "Inserted " . count($licenseRows) . " compliance licenses.\n";

// 7. Notification Logs & Critical Alerts (to populate notification hub)
$db->exec("DELETE FROM critical_alert_logs");
$criticalAlerts = [
    [
        'order_item_id' => 1,
        'critical_parameter' => 'Fasting Blood Sugar (Glucose)',
        'critical_value' => '24.8 mmol/L (Severe Hyperglycemia - Panic Value)',
        'notified_to' => 'Dr. Specialist Doctor Consultant & On-Duty Medical Officer',
        'status' => 'pending',
        'logged_at' => date('Y-m-d H:i:s', strtotime('-15 minutes'))
    ],
    [
        'order_item_id' => 9,
        'critical_parameter' => 'Serum Potassium (K+)',
        'critical_value' => '2.6 mmol/L (Critical Hypokalemia)',
        'notified_to' => 'Patient Consultant & Ward Nurse Desk',
        'status' => 'notified',
        'logged_at' => date('Y-m-d H:i:s', strtotime('-1 hour'))
    ]
];

$critStmt = $db->prepare("INSERT INTO critical_alert_logs (order_item_id, critical_parameter, critical_value, notified_to, status, logged_at) VALUES (?, ?, ?, ?, ?, ?)");
foreach ($criticalAlerts as $ca) {
    $critStmt->execute([
        $ca['order_item_id'],
        $ca['critical_parameter'],
        $ca['critical_value'],
        $ca['notified_to'],
        $ca['status'],
        $ca['logged_at']
    ]);
}
echo "Inserted " . count($criticalAlerts) . " critical alerts.\n";

$db->exec("DELETE FROM notification_logs");
$notifs = [
    [
        'patient_id' => 1,
        'channel' => 'sms',
        'template_key' => 'report_ready',
        'recipient' => '01711-000001',
        'language' => 'bn',
        'content' => 'লুৎফুন্নেসা ডায়াবেটিস সেন্টার: আপনার ডায়াগনস্টিক রিপোর্ট প্রস্তুত হয়েছে। অনলাইন পোর্টাল থেকে ডাউনলোড করতে ভিজিট করুন।',
        'status' => 'sent',
        'provider_response' => 'HTTP 200 OK - Sent via SMS Gateway',
        'created_at' => date('Y-m-d H:i:s', strtotime('-25 minutes')),
        'sent_at' => date('Y-m-d H:i:s', strtotime('-24 minutes'))
    ],
    [
        'patient_id' => 2,
        'channel' => 'sms',
        'template_key' => 'appointment_confirm',
        'recipient' => '01811-000002',
        'language' => 'bn',
        'content' => 'আপনার অ্যাপয়েন্টমেন্ট সফলভাবে কনফার্ম করা হয়েছে। অ্যাপয়েন্টমেন্ট নং: APT-2026-0042, সময়: বিকাল ৪:৩০।',
        'status' => 'sent',
        'provider_response' => 'HTTP 200 OK - Sent via SMS Gateway',
        'created_at' => date('Y-m-d H:i:s', strtotime('-1 hour')),
        'sent_at' => date('Y-m-d H:i:s', strtotime('-1 hour'))
    ]
];

$notifStmt = $db->prepare("INSERT INTO notification_logs (patient_id, channel, template_key, recipient, language, content, status, provider_response, created_at, sent_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
foreach ($notifs as $n) {
    $notifStmt->execute([
        $n['patient_id'],
        $n['channel'],
        $n['template_key'],
        $n['recipient'],
        $n['language'],
        $n['content'],
        $n['status'],
        $n['provider_response'],
        $n['created_at'],
        $n['sent_at']
    ]);
}
echo "Inserted " . count($notifs) . " patient notification logs.\n";

echo "All real data seeded successfully!\n";
