-- Tigersoft Diagnostic ERP Database Dump
-- Generated on: 2026-10-24 13:23:38

SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
START TRANSACTION;
SET time_zone = '+00:00';

-- Table structure for table `analyzer_connectors`
DROP TABLE IF EXISTS `analyzer_connectors`;
CREATE TABLE `analyzer_connectors` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `name` varchar(150) NOT NULL,
  `protocol` enum('astm','hl7','file','custom') NOT NULL DEFAULT 'astm',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `analyzer_connectors`
INSERT INTO `analyzer_connectors` (`id`, `code`, `name`, `protocol`, `active`, `created_at`) VALUES ('1', 'SYS-XN550', 'Sysmex XN-550 Automated Hematology Analyzer (Japan)', 'astm', '1', '2026-10-11 17:23:12');
INSERT INTO `analyzer_connectors` (`id`, `code`, `name`, `protocol`, `active`, `created_at`) VALUES ('2', 'COB-C311', 'Roche Cobas c311 Clinical Chemistry System (Switzerland)', 'hl7', '1', '2026-10-11 17:23:12');
INSERT INTO `analyzer_connectors` (`id`, `code`, `name`, `protocol`, `active`, `created_at`) VALUES ('3', 'ABB-ARCH', 'Abbott ARCHITECT i1000SR Immunoassay Analyzer (USA)', 'hl7', '1', '2026-10-11 17:23:12');
INSERT INTO `analyzer_connectors` (`id`, `code`, `name`, `protocol`, `active`, `created_at`) VALUES ('4', 'BAC-FX40', 'BD BACTEC FX40 Automated Blood Culture System', 'astm', '1', '2026-10-11 17:23:12');
INSERT INTO `analyzer_connectors` (`id`, `code`, `name`, `protocol`, `active`, `created_at`) VALUES ('5', 'BIO-D10', 'Bio-Rad D-10 Hemoglobin A1c HPLC Testing System', 'file', '1', '2026-10-11 17:23:12');
INSERT INTO `analyzer_connectors` (`id`, `code`, `name`, `protocol`, `active`, `created_at`) VALUES ('6', 'ROCH-AVL', 'Roche 9180 Electrolyte Analyzer (ISE Direct)', 'astm', '1', '2026-10-11 17:23:12');

-- Table structure for table `analyzer_mappings`
DROP TABLE IF EXISTS `analyzer_mappings`;
CREATE TABLE `analyzer_mappings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `connector_id` bigint(20) unsigned NOT NULL,
  `analyzer_test_code` varchar(80) NOT NULL,
  `erp_test_id` bigint(20) unsigned NOT NULL,
  `multiplier` decimal(10,4) NOT NULL DEFAULT 1.0000,
  PRIMARY KEY (`id`),
  KEY `connector_id` (`connector_id`),
  KEY `erp_test_id` (`erp_test_id`),
  CONSTRAINT `analyzer_mappings_ibfk_1` FOREIGN KEY (`connector_id`) REFERENCES `analyzer_connectors` (`id`),
  CONSTRAINT `analyzer_mappings_ibfk_2` FOREIGN KEY (`erp_test_id`) REFERENCES `diagnostic_tests` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `analyzer_messages`
DROP TABLE IF EXISTS `analyzer_messages`;
CREATE TABLE `analyzer_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `connector_id` bigint(20) unsigned NOT NULL,
  `raw_payload` text NOT NULL,
  `processed` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `connector_id` (`connector_id`),
  CONSTRAINT `analyzer_messages_ibfk_1` FOREIGN KEY (`connector_id`) REFERENCES `analyzer_connectors` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `appointments`
DROP TABLE IF EXISTS `appointments`;
CREATE TABLE `appointments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `appointment_no` varchar(30) NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `doctor_id` bigint(20) unsigned NOT NULL,
  `room_id` bigint(20) unsigned DEFAULT NULL,
  `booking_source` enum('walkin','phone','website','app') NOT NULL DEFAULT 'walkin',
  `appointment_date` date NOT NULL,
  `time_slot` varchar(20) NOT NULL,
  `consultation_fee` decimal(12,2) NOT NULL DEFAULT 1000.00,
  `discount_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `payable_amount` decimal(12,2) NOT NULL DEFAULT 1000.00,
  `paid_amount` decimal(12,2) NOT NULL DEFAULT 1000.00,
  `payment_method` varchar(50) DEFAULT 'CASH',
  `payment_status` varchar(50) DEFAULT 'paid',
  `referrer_id` bigint(20) unsigned DEFAULT NULL,
  `voucher_code` varchar(100) DEFAULT NULL,
  `token_no` varchar(50) DEFAULT NULL,
  `status` enum('scheduled','confirmed','arrived','rescheduled','cancelled','no_show') NOT NULL DEFAULT 'scheduled',
  `clinical_notes` text DEFAULT NULL,
  `created_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `appointment_no` (`appointment_no`),
  KEY `branch_id` (`branch_id`),
  KEY `patient_id` (`patient_id`),
  KEY `doctor_id` (`doctor_id`),
  KEY `room_id` (`room_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`),
  CONSTRAINT `appointments_ibfk_3` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`),
  CONSTRAINT `appointments_ibfk_4` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`),
  CONSTRAINT `appointments_ibfk_5` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `appointments`
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('1', 'APT-2026-00001', '1', '3', '8', NULL, 'walkin', '2026-10-11', '10:00PM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'scheduled', NULL, '1', '2026-10-11 12:23:20', '2026-10-11 12:23:20');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('2', 'APT-2026-00004', '1', '6', '8', NULL, 'website', '2026-10-11', '10:00PM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'scheduled', NULL, '1', '2026-10-11 15:57:22', '2026-10-11 15:57:22');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('3', 'APT-2026-00084', '1', '6', '1', '5', 'website', '2026-10-18', '10:30 AM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'confirmed', 'Quarterly diabetes assessment and HbA1c titration review.', '1', '2026-10-20 10:55:37', '2026-10-20 10:55:37');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('4', 'APT-2026-00091', '1', '6', '2', '1', 'website', '2026-10-20', '04:00 PM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'confirmed', 'Cardiovascular health follow-up and ECG review.', '1', '2026-10-20 10:55:37', '2026-10-20 10:55:37');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('5', 'APT-2026-00103', '1', '6', '3', '2', 'website', '2026-10-25', '11:00 AM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'scheduled', 'Routine preventive check-up and clinical ultrasound consultation.', '1', '2026-10-20 10:55:37', '2026-10-20 10:55:37');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('6', 'APT-2026-00201', '2', '7', '1', NULL, 'walkin', '2026-10-20', '05:30 PM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'confirmed', 'Evening follow-up HbA1c review', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('7', 'APT-2026-00202', '2', '8', '4', NULL, 'walkin', '2026-10-20', '06:00 PM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'confirmed', 'Whole Abdomen USG Consultation', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('8', 'APT-2026-00203', '2', '9', '5', NULL, 'walkin', '2026-10-20', '06:30 PM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'scheduled', 'Renal function screening', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('9', 'APT-2026-00204', '2', '10', '6', NULL, 'walkin', '2026-10-20', '07:00 PM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'arrived', 'General health checkup', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('10', 'APT-2026-00301', '3', '11', '2', NULL, 'walkin', '2026-10-20', '10:30 AM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'confirmed', 'Cardiology ECG & ECHO follow-up', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('11', 'APT-2026-00302', '3', '12', '7', NULL, 'walkin', '2026-10-20', '11:15 AM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'scheduled', 'GI Endoscopy pre-consultation', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('12', 'APT-2026-00303', '3', '13', '8', NULL, 'walkin', '2026-10-20', '12:00 PM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'arrived', 'Antenatal Routine Checkup', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('13', 'APT-2026-00008', '1', '6', '9', NULL, 'walkin', '2026-10-21', '10:00PM', '1000.00', '0.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, NULL, NULL, 'scheduled', NULL, '1', '2026-10-21 14:25:01', '2026-10-21 14:25:01');
INSERT INTO `appointments` (`id`, `appointment_no`, `branch_id`, `patient_id`, `doctor_id`, `room_id`, `booking_source`, `appointment_date`, `time_slot`, `consultation_fee`, `discount_amount`, `payable_amount`, `paid_amount`, `payment_method`, `payment_status`, `referrer_id`, `voucher_code`, `token_no`, `status`, `clinical_notes`, `created_by`, `created_at`, `updated_at`) VALUES ('14', 'APT-2026-00010', '1', '22', '1', NULL, 'walkin', '2026-10-21', '10:30 AM', '1200.00', '200.00', '1000.00', '1000.00', 'CASH', 'paid', NULL, 'VIP200', 'DOC-002', 'scheduled', NULL, '1', '2026-10-21 18:16:57', '2026-10-21 18:16:57');

-- Table structure for table `approval_policies`
DROP TABLE IF EXISTS `approval_policies`;
CREATE TABLE `approval_policies` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `action_type` enum('discount','refund','result_correction','credit_note','purchase','journal_posting') NOT NULL,
  `branch_id` bigint(20) unsigned DEFAULT NULL,
  `min_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `max_amount` decimal(15,2) DEFAULT NULL,
  `approver_permission` varchar(90) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `approval_policies_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `approval_policies`
INSERT INTO `approval_policies` (`id`, `action_type`, `branch_id`, `min_amount`, `max_amount`, `approver_permission`, `active`, `created_at`) VALUES ('1', 'discount', NULL, '0.00', '50000.00', 'approvals.decide', '1', '2026-10-21 11:12:17');
INSERT INTO `approval_policies` (`id`, `action_type`, `branch_id`, `min_amount`, `max_amount`, `approver_permission`, `active`, `created_at`) VALUES ('2', 'refund', NULL, '0.00', '100000.00', 'approvals.decide', '1', '2026-10-21 11:12:17');
INSERT INTO `approval_policies` (`id`, `action_type`, `branch_id`, `min_amount`, `max_amount`, `approver_permission`, `active`, `created_at`) VALUES ('3', 'result_correction', NULL, '0.00', '10000.00', 'approvals.decide', '1', '2026-10-21 11:12:17');
INSERT INTO `approval_policies` (`id`, `action_type`, `branch_id`, `min_amount`, `max_amount`, `approver_permission`, `active`, `created_at`) VALUES ('4', 'credit_note', NULL, '0.00', '50000.00', 'approvals.decide', '1', '2026-10-21 11:12:17');
INSERT INTO `approval_policies` (`id`, `action_type`, `branch_id`, `min_amount`, `max_amount`, `approver_permission`, `active`, `created_at`) VALUES ('5', 'purchase', NULL, '0.00', '500000.00', 'approvals.decide', '1', '2026-10-21 11:12:17');
INSERT INTO `approval_policies` (`id`, `action_type`, `branch_id`, `min_amount`, `max_amount`, `approver_permission`, `active`, `created_at`) VALUES ('6', 'journal_posting', NULL, '0.00', '1000000.00', 'approvals.decide', '1', '2026-10-21 11:12:17');

-- Table structure for table `approval_requests`
DROP TABLE IF EXISTS `approval_requests`;
CREATE TABLE `approval_requests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `policy_id` bigint(20) unsigned NOT NULL,
  `action_type` varchar(40) NOT NULL,
  `entity_type` varchar(80) NOT NULL,
  `entity_id` varchar(80) NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `maker_id` bigint(20) unsigned NOT NULL,
  `checker_id` bigint(20) unsigned DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `request_reason` varchar(500) NOT NULL,
  `decision_reason` varchar(500) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `decided_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_approval_queue` (`status`,`branch_id`,`created_at`),
  KEY `policy_id` (`policy_id`),
  KEY `branch_id` (`branch_id`),
  KEY `maker_id` (`maker_id`),
  KEY `checker_id` (`checker_id`),
  CONSTRAINT `approval_requests_ibfk_1` FOREIGN KEY (`policy_id`) REFERENCES `approval_policies` (`id`),
  CONSTRAINT `approval_requests_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `approval_requests_ibfk_3` FOREIGN KEY (`maker_id`) REFERENCES `users` (`id`),
  CONSTRAINT `approval_requests_ibfk_4` FOREIGN KEY (`checker_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `approval_requests`
INSERT INTO `approval_requests` (`id`, `policy_id`, `action_type`, `entity_type`, `entity_id`, `branch_id`, `amount`, `maker_id`, `checker_id`, `status`, `request_reason`, `decision_reason`, `created_at`, `decided_at`) VALUES ('1', '1', 'discount', 'invoice', 'INV-2026-00001', '1', '450.00', '2', NULL, 'pending', 'Special 15% discount for verified Freedom Fighter / Senior Citizen diabetic patient (Nasir Uddin).', NULL, '2026-10-21 09:12:17', NULL);
INSERT INTO `approval_requests` (`id`, `policy_id`, `action_type`, `entity_type`, `entity_id`, `branch_id`, `amount`, `maker_id`, `checker_id`, `status`, `request_reason`, `decision_reason`, `created_at`, `decided_at`) VALUES ('2', '2', 'refund', 'invoice', 'INV-2026-00003', '1', '1200.00', '2', NULL, 'pending', 'Patient duplicate payment refund request due to MFS bKash double deduction at counter.', NULL, '2026-10-21 07:12:17', NULL);
INSERT INTO `approval_requests` (`id`, `policy_id`, `action_type`, `entity_type`, `entity_id`, `branch_id`, `amount`, `maker_id`, `checker_id`, `status`, `request_reason`, `decision_reason`, `created_at`, `decided_at`) VALUES ('3', '5', 'purchase', 'purchase_order', 'PO-2026-0089', '1', '64500.00', '5', NULL, 'pending', 'Urgent procurement requisition for Sysmex Hematology Reagent packs & Bio-Rad controls.', NULL, '2026-10-21 05:12:17', NULL);
INSERT INTO `approval_requests` (`id`, `policy_id`, `action_type`, `entity_type`, `entity_id`, `branch_id`, `amount`, `maker_id`, `checker_id`, `status`, `request_reason`, `decision_reason`, `created_at`, `decided_at`) VALUES ('4', '3', 'result_correction', 'lab_report', 'REP-2026-00845', '1', '0.00', '3', NULL, 'pending', 'Correction in Serum Potassium decimal transcription following analyzer rerun verification.', NULL, '2026-10-20 17:12:17', NULL);
INSERT INTO `approval_requests` (`id`, `policy_id`, `action_type`, `entity_type`, `entity_id`, `branch_id`, `amount`, `maker_id`, `checker_id`, `status`, `request_reason`, `decision_reason`, `created_at`, `decided_at`) VALUES ('5', '1', 'discount', 'invoice', 'INV-2026-00002', '2', '600.00', '2', '1', 'approved', 'Corporate MoU package rebate for Biman Bangladesh Airlines executive health checkup.', NULL, '2026-10-20 11:12:17', NULL);
INSERT INTO `approval_requests` (`id`, `policy_id`, `action_type`, `entity_type`, `entity_id`, `branch_id`, `amount`, `maker_id`, `checker_id`, `status`, `request_reason`, `decision_reason`, `created_at`, `decided_at`) VALUES ('6', '4', 'credit_note', 'corporate_invoice', 'CORP-INV-2026-014', '1', '18500.00', '2', '1', 'approved', 'Adjustment credit note for bulk employee annual health screening at Dhaka Main Branch.', NULL, '2026-10-19 11:12:17', NULL);

-- Table structure for table `audit_logs`
DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `actor_id` bigint(20) unsigned DEFAULT NULL,
  `branch_id` bigint(20) unsigned DEFAULT NULL,
  `entity_type` varchar(80) NOT NULL,
  `entity_id` varchar(80) NOT NULL,
  `action` varchar(50) NOT NULL,
  `before_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`before_json`)),
  `after_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`after_json`)),
  `reason` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) NOT NULL,
  `occurred_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_audit_entity` (`entity_type`,`entity_id`,`occurred_at`),
  KEY `idx_audit_time` (`occurred_at`),
  KEY `actor_id` (`actor_id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`),
  CONSTRAINT `audit_logs_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=219 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `audit_logs`
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('1', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '103.170.173.79', '2026-09-28 19:31:22');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('2', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 13:56:19');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('3', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 13:56:33');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('4', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 13:56:58');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('5', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 14:00:17');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('6', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 14:22:19');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('7', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 14:27:40');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('8', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 14:28:43');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('9', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 14:36:10');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('10', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 14:50:05');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('11', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 14:51:06');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('12', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 14:56:58');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('13', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 14:59:33');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('14', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 15:13:48');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('15', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 15:18:12');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('16', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 15:20:10');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('17', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 15:27:17');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('18', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 15:28:37');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('19', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 15:43:27');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('20', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 16:59:35');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('21', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 17:00:00');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('22', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 17:00:13');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('23', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 17:14:13');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('24', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 17:31:14');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('25', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 17:31:52');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('26', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 17:53:10');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('27', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 17:58:25');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('28', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 18:38:19');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('29', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 18:49:30');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('30', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 18:49:35');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('31', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 21:33:58');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('32', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 22:05:18');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('33', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 22:05:49');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('34', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-10 22:48:02');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('35', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 00:33:58');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('36', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 00:57:07');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('37', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 00:59:15');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('38', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 01:38:03');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('39', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 01:40:24');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('40', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 01:47:43');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('41', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 01:50:50');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('42', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 02:32:28');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('43', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 02:32:36');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('44', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 02:37:55');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('45', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 02:50:28');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('46', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 02:50:49');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('47', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 10:50:01');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('48', '1', '1', 'lab_reports', '6', 'pathologist_approve', NULL, '{\"report_no\":\"REP-2026-00001\"}', NULL, '127.0.0.1', '2026-10-11 11:08:36');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('49', '1', '1', 'appointments', '1', 'create', NULL, '{\"appointment_no\":\"APT-2026-00001\",\"doctor_id\":8,\"date\":\"2026-10-11\"}', NULL, '127.0.0.1', '2026-10-11 12:23:20');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('50', '1', '1', 'invoices', '1', 'create', NULL, '{\"invoice_no\":\"INV-2026-00001\",\"payable\":2500}', NULL, '127.0.0.1', '2026-10-11 12:34:14');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('51', '1', '1', 'invoices', '2', 'create', NULL, '{\"invoice_no\":\"INV-2026-00002\",\"payable\":2500}', NULL, '127.0.0.1', '2026-10-11 12:38:09');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('52', '1', '1', 'invoices', '3', 'create', NULL, '{\"invoice_no\":\"INV-2026-00003\",\"payable\":2500}', NULL, '127.0.0.1', '2026-10-11 13:10:51');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('53', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:24:49');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('54', '1', '1', 'invoices', '4', 'create', NULL, '{\"invoice_no\":\"INV-2026-00004\",\"payable\":2500}', NULL, '127.0.0.1', '2026-10-11 14:30:39');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('55', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:43:39');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('56', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:43:47');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('57', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:43:54');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('58', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:44:02');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('59', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:44:10');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('60', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:44:27');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('61', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:56:42');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('62', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:56:50');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('63', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:56:54');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('64', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:56:57');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('65', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 14:57:02');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('66', '1', '1', 'diagnostic_orders', '6', 'create', NULL, '{\"order_no\":\"ORD-2026-00002\",\"total\":1000,\"payable\":500}', NULL, '127.0.0.1', '2026-10-11 15:12:51');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('67', '1', '1', 'diagnostic_orders', '7', 'create', NULL, '{\"order_no\":\"ORD-2026-00003\",\"total\":1000,\"payable\":500}', NULL, '127.0.0.1', '2026-10-11 15:42:21');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('68', '1', '1', 'queue_tokens', '2', 'call_next', NULL, '{\"token_no\":\"BIL-001\",\"counter_id\":6}', NULL, '127.0.0.1', '2026-10-11 15:42:41');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('69', '1', '1', 'queue_tokens', '3', 'call_next', NULL, '{\"token_no\":\"BIL-002\",\"counter_id\":6}', NULL, '127.0.0.1', '2026-10-11 15:42:55');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('70', '1', '1', 'invoices', '5', 'create', NULL, '{\"invoice_no\":\"INV-2026-00005\",\"payable\":500}', NULL, '127.0.0.1', '2026-10-11 15:44:13');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('71', '1', '1', 'invoices', '6', 'create', NULL, '{\"invoice_no\":\"INV-2026-00006\",\"payable\":500}', NULL, '127.0.0.1', '2026-10-11 15:46:45');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('72', '1', '1', 'patients', '6', 'create', NULL, '{\"mrn\":\"PAT-2026-00001\",\"name\":\"JAHIDUL HASSAN RESHAD\",\"mobile\":\"01531150655\",\"branch_id\":1}', NULL, '127.0.0.1', '2026-10-11 15:56:28');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('73', '1', '1', 'appointments', '2', 'create', NULL, '{\"appointment_no\":\"APT-2026-00004\",\"doctor_id\":8,\"date\":\"2026-10-11\"}', NULL, '127.0.0.1', '2026-10-11 15:57:22');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('74', '1', '1', 'diagnostic_orders', '8', 'create', NULL, '{\"order_no\":\"ORD-2026-00005\",\"total\":1000,\"payable\":1000}', NULL, '127.0.0.1', '2026-10-11 15:57:30');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('75', '1', '1', 'invoices', '7', 'create', NULL, '{\"invoice_no\":\"INV-2026-00007\",\"payable\":1000}', NULL, '127.0.0.1', '2026-10-11 15:57:53');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('76', '1', '1', 'invoices', '8', 'create', NULL, '{\"invoice_no\":\"INV-2026-00008\",\"payable\":2500}', NULL, '127.0.0.1', '2026-10-11 16:19:48');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('77', '1', '1', 'diagnostic_orders', '1', 'status_change', '{\"id\":1,\"order_no\":\"ORD-2026-00101\",\"branch_id\":1,\"patient_id\":1,\"doctor_id\":null,\"referrer_id\":null,\"corporate_client_id\":null,\"urgency\":\"routine\",\"collection_location\":\"Main Specimen Booth #2\",\"clinical_notes\":\"Routine Clinical Workup & Investigation\",\"status\":\"completed\",\"total_amount\":\"2500.00\",\"discount_amount\":\"0.00\",\"payable_amount\":\"2500.00\",\"created_by\":1,\"created_at\":\"2026-10-05 18:31:34\",\"updated_at\":\"2026-10-10 18:31:34\",\"patient_name\":\"Nasir Uddin\",\"mrn\":\"MRN-2026-001\",\"patient_mobile\":\"01711-000001\",\"doctor_name\":null,\"referrer_name\":null,\"corporate_name\":null,\"items\":[{\"id\":1,\"order_id\":1,\"item_type\":\"test\",\"item_id\":1,\"item_name\":\"Fasting Blood Sugar (FBS \\/ Glucose)\",\"price\":\"200.00\",\"fasting_required\":0,\"preparation_notes\":\"Standard laboratory handling\",\"status\":\"completed\"},{\"id\":2,\"order_id\":1,\"item_type\":\"test\",\"item_id\":3,\"item_name\":\"HbA1c (Glycated Hemoglobin) by HPLC\",\"price\":\"1000.00\",\"fasting_required\":0,\"preparation_notes\":\"Standard laboratory handling\",\"status\":\"completed\"},{\"id\":3,\"order_id\":1,\"item_type\":\"test\",\"item_id\":5,\"item_name\":\"Lipid Profile Full Panel (Chol, Trig, HDL, LDL)\",\"price\":\"1200.00\",\"fasting_required\":0,\"preparation_notes\":\"Standard laboratory handling\",\"status\":\"completed\"}]}', '{\"new_status\":\"ready_for_collection\"}', NULL, '127.0.0.1', '2026-10-11 16:20:09');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('78', '1', '1', 'payments', '1', 'received', NULL, '{\"receipt_no\":\"REC-2026-00001\",\"amount\":2500,\"new_status\":\"paid\"}', NULL, '127.0.0.1', '2026-10-11 16:20:09');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('79', '1', '1', 'cashier_shifts', '1', 'open_shift', NULL, '{\"counter_id\":5,\"float\":500}', NULL, '127.0.0.1', '2026-10-11 16:22:49');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('80', '1', '1', 'diagnostic_orders', '8', 'status_change', '{\"id\":8,\"order_no\":\"ORD-2026-00005\",\"branch_id\":1,\"patient_id\":6,\"doctor_id\":null,\"referrer_id\":null,\"corporate_client_id\":null,\"urgency\":\"routine\",\"collection_location\":\"Main Counter\",\"clinical_notes\":null,\"status\":\"pending_payment\",\"total_amount\":\"1000.00\",\"discount_amount\":\"0.00\",\"payable_amount\":\"1000.00\",\"created_by\":1,\"created_at\":\"2026-10-11 15:57:30\",\"updated_at\":\"2026-10-11 15:57:30\",\"patient_name\":\"JAHIDUL HASSAN RESHAD\",\"mrn\":\"PAT-2026-00001\",\"patient_mobile\":\"01531150655\",\"doctor_name\":null,\"referrer_name\":null,\"corporate_name\":null,\"items\":[{\"id\":17,\"order_id\":8,\"item_type\":\"test\",\"item_id\":28,\"item_name\":\"Cervical Cytology (Liquid Based Pap Smear)\",\"price\":\"1000.00\",\"fasting_required\":0,\"preparation_notes\":null,\"status\":\"pending\"}]}', '{\"new_status\":\"ready_for_collection\"}', NULL, '127.0.0.1', '2026-10-11 17:14:04');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('81', '1', '1', 'payments', '2', 'received', NULL, '{\"receipt_no\":\"REC-2026-00002\",\"amount\":1000,\"new_status\":\"paid\"}', NULL, '127.0.0.1', '2026-10-11 17:14:04');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('82', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 17:19:43');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('83', '1', '1', 'lab_reports', '7', 'pathologist_approve', NULL, '{\"report_no\":\"REP-2026-00002\"}', NULL, '127.0.0.1', '2026-10-11 17:31:08');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('84', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 18:31:41');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('85', '1', '1', 'lab_reports', '8', 'pathologist_approve', NULL, '{\"report_no\":\"REP-2026-00003\"}', NULL, '127.0.0.1', '2026-10-11 18:33:02');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('86', '1', '1', 'lab_reports', '9', 'pathologist_approve', NULL, '{\"report_no\":\"REP-2026-00004\"}', NULL, '127.0.0.1', '2026-10-11 18:36:24');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('87', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 18:42:46');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('88', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 22:10:42');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('89', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 22:36:36');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('90', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-11 22:40:29');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('91', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-12 01:34:48');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('92', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-13 14:19:34');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('93', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-13 16:06:42');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('94', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-15 20:37:14');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('95', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-15 22:25:21');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('96', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 00:08:05');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('97', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 00:35:49');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('98', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 00:39:09');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('99', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 00:41:01');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('100', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 00:42:26');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('101', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 01:06:11');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('102', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 01:07:18');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('103', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 01:13:38');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('104', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 01:14:15');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('105', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 01:39:03');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('106', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 01:43:16');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('107', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 02:29:08');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('108', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 02:31:28');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('109', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 02:49:22');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('110', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 02:50:41');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('111', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, 'CLI', '2026-10-16 02:59:58');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('112', '2', NULL, 'users', '2', 'login', NULL, '{\"email\":\"clinic@cognovait.com\"}', NULL, 'CLI', '2026-10-16 02:59:58');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('113', '3', NULL, 'users', '3', 'login', NULL, '{\"email\":\"lab@cognovait.com\"}', NULL, 'CLI', '2026-10-16 02:59:58');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('114', '4', NULL, 'users', '4', 'login', NULL, '{\"email\":\"doctor@cognovait.com\"}', NULL, 'CLI', '2026-10-16 02:59:59');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('115', '5', NULL, 'users', '5', 'login', NULL, '{\"email\":\"staff@cognovait.com\"}', NULL, 'CLI', '2026-10-16 02:59:59');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('116', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:02:14');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('117', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:02:25');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('118', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:04:44');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('119', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:04:50');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('120', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, 'CLI', '2026-10-16 03:06:29');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('121', '2', NULL, 'users', '2', 'login', NULL, '{\"email\":\"clinic@cognovait.com\"}', NULL, 'CLI', '2026-10-16 03:06:29');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('122', '3', NULL, 'users', '3', 'login', NULL, '{\"email\":\"lab@cognovait.com\"}', NULL, 'CLI', '2026-10-16 03:06:29');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('123', '4', NULL, 'users', '4', 'login', NULL, '{\"email\":\"doctor@cognovait.com\"}', NULL, 'CLI', '2026-10-16 03:06:30');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('124', '5', NULL, 'users', '5', 'login', NULL, '{\"email\":\"staff@cognovait.com\"}', NULL, 'CLI', '2026-10-16 03:06:30');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('125', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:09:29');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('126', '2', NULL, 'users', '2', 'login', NULL, '{\"email\":\"clinic@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:11:06');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('127', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:11:10');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('128', '2', NULL, 'users', '2', 'login', NULL, '{\"email\":\"clinic@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:11:11');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('129', '3', NULL, 'users', '3', 'login', NULL, '{\"email\":\"lab@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:11:11');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('130', '4', NULL, 'users', '4', 'login', NULL, '{\"email\":\"doctor@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:11:12');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('131', '5', NULL, 'users', '5', 'login', NULL, '{\"email\":\"staff@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:11:13');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('132', '5', NULL, 'users', '5', 'login', NULL, '{\"email\":\"staff@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:11:32');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('133', '4', NULL, 'users', '4', 'login', NULL, '{\"email\":\"doctor@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:12:21');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('134', '2', NULL, 'users', '2', 'login', NULL, '{\"email\":\"clinic@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:14:47');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('135', '3', NULL, 'users', '3', 'login', NULL, '{\"email\":\"lab@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:14:51');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('136', '2', NULL, 'users', '2', 'login', NULL, '{\"email\":\"clinic@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:17:12');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('137', '4', NULL, 'users', '4', 'login', NULL, '{\"email\":\"doctor@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:17:23');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('138', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:21:20');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('139', '2', NULL, 'users', '2', 'login', NULL, '{\"email\":\"clinic@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:21:21');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('140', '3', NULL, 'users', '3', 'login', NULL, '{\"email\":\"lab@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:21:22');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('141', '4', NULL, 'users', '4', 'login', NULL, '{\"email\":\"doctor@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:21:23');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('142', '5', NULL, 'users', '5', 'login', NULL, '{\"email\":\"staff@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 03:21:24');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('143', '2', NULL, 'users', '2', 'login', NULL, '{\"email\":\"clinic@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 19:29:44');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('144', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 19:29:49');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('145', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 22:04:12');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('146', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 22:19:44');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('147', '2', NULL, 'users', '2', 'login', NULL, '{\"email\":\"clinic@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 22:19:45');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('148', '3', NULL, 'users', '3', 'login', NULL, '{\"email\":\"lab@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 22:19:45');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('149', '4', NULL, 'users', '4', 'login', NULL, '{\"email\":\"doctor@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 22:19:46');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('150', '5', NULL, 'users', '5', 'login', NULL, '{\"email\":\"staff@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-16 22:19:46');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('151', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-17 00:56:21');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('152', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-17 14:06:01');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('153', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-17 14:06:24');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('154', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 10:31:08');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('155', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 10:49:50');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('156', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 10:58:22');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('157', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 11:10:02');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('158', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 11:12:56');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('159', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 11:24:02');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('160', '1', '1', 'invoices', '9', 'create', NULL, '{\"invoice_no\":\"INV-2026-00009\",\"payable\":4000}', NULL, '127.0.0.1', '2026-10-20 11:34:14');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('161', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 11:42:44');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('162', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 12:03:44');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('163', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 12:03:58');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('164', '1', '1', 'invoices', '10', 'create', NULL, '{\"invoice_no\":\"INV-2026-00010\",\"payable\":2600}', NULL, '127.0.0.1', '2026-10-20 12:09:30');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('165', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 12:23:32');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('166', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 12:30:30');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('167', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 12:31:16');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('168', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 12:57:44');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('169', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 13:08:22');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('170', '1', '1', 'diagnostic_orders', '13', 'create', NULL, '{\"order_no\":\"ORD-2026-00006\",\"total\":2000,\"payable\":2000}', NULL, '127.0.0.1', '2026-10-20 13:23:49');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('171', '1', '1', 'queue_tokens', '7', 'call_next', NULL, '{\"token_no\":\"BIL-001\",\"counter_id\":6}', NULL, '127.0.0.1', '2026-10-20 13:23:59');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('172', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 13:33:11');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('173', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 13:34:44');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('174', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 13:36:56');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('175', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 13:39:09');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('176', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 13:42:39');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('177', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 14:27:18');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('178', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 15:01:17');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('179', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 15:02:42');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('180', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 15:26:58');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('181', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 15:27:47');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('182', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 15:46:55');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('183', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 16:05:18');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('184', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 16:25:51');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('185', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 16:38:22');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('186', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 17:00:23');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('187', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 17:01:04');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('188', '2', NULL, 'users', '2', 'login', NULL, '{\"email\":\"clinic@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 17:04:54');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('189', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 17:07:03');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('190', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 17:20:44');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('191', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 17:34:35');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('192', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 17:38:35');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('193', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 17:54:24');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('194', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 17:57:49');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('195', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 18:00:24');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('196', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 18:01:27');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('197', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 18:01:45');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('198', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 18:02:16');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('199', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 18:02:36');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('200', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 18:03:00');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('201', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 18:03:45');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('202', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 18:04:33');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('203', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 18:06:24');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('204', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-20 18:12:26');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('205', '1', NULL, 'users', '1', 'login', NULL, '{\"email\":\"admin@cognovait.com\"}', NULL, '127.0.0.1', '2026-10-21 10:42:26');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('206', '1', '1', 'diagnostic_orders', '19', 'create', NULL, '{\"order_no\":\"ORD-2026-00007\",\"total\":1000,\"payable\":1000}', NULL, '127.0.0.1', '2026-10-21 12:24:28');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('207', '1', '1', 'appointments', '13', 'create', NULL, '{\"appointment_no\":\"APT-2026-00008\",\"doctor_id\":9,\"date\":\"2026-10-21\"}', NULL, '127.0.0.1', '2026-10-21 14:25:01');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('208', '1', '1', 'patients', '14', 'create', NULL, '{\"mrn\":\"PAT-2026-00002\",\"name\":\"Engr. Mahfuzur Rahman\",\"mobile\":\"+8801711223344\",\"branch_id\":1}', NULL, '127.0.0.1', '2026-10-21 14:41:48');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('209', '1', '1', 'diagnostic_orders', '20', 'create', NULL, '{\"order_no\":\"ORD-2026-00009\",\"total\":1000,\"payable\":1000}', NULL, '127.0.0.1', '2026-10-21 14:46:41');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('210', '1', '1', 'home_collections', '6', 'book_home_collection', NULL, '{\"booking_no\":\"BAR-2026-00001\",\"zone\":\"Gulshan \\/ Banani Zone\"}', NULL, '127.0.0.1', '2026-10-21 15:58:54');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('211', '1', '1', 'home_collections', '7', 'book_home_collection', NULL, '{\"booking_no\":\"BAR-2026-00002\",\"zone\":\"Gulshan \\/ Banani Zone\"}', NULL, '127.0.0.1', '2026-10-21 15:59:17');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('212', '1', '1', 'home_collections', '8', 'book_home_collection', NULL, '{\"booking_no\":\"BAR-2026-00003\",\"zone\":\"Gulshan \\/ Banani Zone\"}', NULL, '127.0.0.1', '2026-10-21 15:59:43');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('213', '1', '1', 'patients', '16', 'create', NULL, '{\"mrn\":\"PAT-2026-00003\",\"name\":\"ROhim\",\"mobile\":\"01827693729\",\"branch_id\":1}', NULL, '127.0.0.1', '2026-10-21 16:16:14');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('214', '1', '1', 'patients', '17', 'create', NULL, '{\"mrn\":\"PAT-2026-00004\",\"name\":\"ROhim\",\"mobile\":\"01827693729\",\"branch_id\":1}', NULL, '127.0.0.1', '2026-10-21 16:17:06');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('215', '1', '1', 'patients', '18', 'create', NULL, '{\"mrn\":\"PAT-2026-00005\",\"name\":\"kawsar\",\"mobile\":\"01970010098\",\"branch_id\":1}', NULL, '127.0.0.1', '2026-10-21 16:18:10');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('216', '1', '1', 'patients', '19', 'create', NULL, '{\"mrn\":\"PAT-2026-00006\",\"name\":\"rakib\",\"mobile\":\"01970010099\",\"branch_id\":1}', NULL, '127.0.0.1', '2026-10-21 16:19:42');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('217', '1', '1', 'home_collections', '9', 'book_home_collection', NULL, '{\"booking_no\":\"BAR-2026-00004\",\"patient_id\":20,\"total_payable\":650}', NULL, 'CLI', '2026-10-21 18:03:17');
INSERT INTO `audit_logs` (`id`, `actor_id`, `branch_id`, `entity_type`, `entity_id`, `action`, `before_json`, `after_json`, `reason`, `ip_address`, `occurred_at`) VALUES ('218', '1', '1', 'appointments', '14', 'book_chamber_consultation', NULL, '{\"appointment_no\":\"APT-2026-00010\",\"token_no\":\"DOC-002\",\"payable\":1000,\"paid\":1000}', NULL, 'CLI', '2026-10-21 18:16:57');

-- Table structure for table `banks`
DROP TABLE IF EXISTS `banks`;
CREATE TABLE `banks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `branches`
DROP TABLE IF EXISTS `branches`;
CREATE TABLE `branches` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` bigint(20) unsigned NOT NULL,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `address` text DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `timezone` varchar(64) NOT NULL DEFAULT 'Asia/Dhaka',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `organization_id` (`organization_id`),
  CONSTRAINT `branches_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `branches`
INSERT INTO `branches` (`id`, `organization_id`, `code`, `name`, `address`, `phone`, `timezone`, `active`, `created_at`, `updated_at`) VALUES ('1', '1', 'DHA', 'Dhaka Main Branch', 'Dhaka, Bangladesh', NULL, 'Asia/Dhaka', '1', '2026-09-28 19:30:57', '2026-09-28 19:30:57');
INSERT INTO `branches` (`id`, `organization_id`, `code`, `name`, `address`, `phone`, `timezone`, `active`, `created_at`, `updated_at`) VALUES ('2', '1', 'UTT', 'Uttara Diagnostics Branch & Collection Hub', 'House 42, Road 11, Sector 4, Uttara, Dhaka', '01711002233', 'Asia/Dhaka', '1', '2026-10-20 15:19:14', '2026-10-20 15:19:14');
INSERT INTO `branches` (`id`, `organization_id`, `code`, `name`, `address`, `phone`, `timezone`, `active`, `created_at`, `updated_at`) VALUES ('3', '1', 'DHK-S', 'Dhanmondi Specialised Diagnostic Centre', 'Satmasjid Road, Dhanmondi, Dhaka', '01711004455', 'Asia/Dhaka', '1', '2026-10-20 15:19:14', '2026-10-20 15:19:14');
INSERT INTO `branches` (`id`, `organization_id`, `code`, `name`, `address`, `phone`, `timezone`, `active`, `created_at`, `updated_at`) VALUES ('4', '1', 'MIR-01', 'Mirpur Comprehensive Diagnostic Annex', 'Plot 15, Section 10, Mirpur, Dhaka', '01711223344', 'Asia/Dhaka', '1', '2026-10-20 18:04:37', '2026-10-20 18:04:37');
INSERT INTO `branches` (`id`, `organization_id`, `code`, `name`, `address`, `phone`, `timezone`, `active`, `created_at`, `updated_at`) VALUES ('5', '1', 'BAN-02', 'Banani VIP Executive Consultation Centre', 'Road 11, Block D, Banani, Dhaka', '01711445566', 'Asia/Dhaka', '1', '2026-10-20 18:04:37', '2026-10-20 18:04:37');

-- Table structure for table `budgets`
DROP TABLE IF EXISTS `budgets`;
CREATE TABLE `budgets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `fiscal_year` int(10) unsigned NOT NULL,
  `account_id` bigint(20) unsigned NOT NULL,
  `budgeted_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `branch_id` (`branch_id`),
  KEY `department_id` (`department_id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `budgets_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `budgets_ibfk_2` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `budgets_ibfk_3` FOREIGN KEY (`account_id`) REFERENCES `chart_of_accounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `capa_incidents`
DROP TABLE IF EXISTS `capa_incidents`;
CREATE TABLE `capa_incidents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `incident_no` varchar(30) NOT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `severity` enum('minor','major','critical') NOT NULL DEFAULT 'minor',
  `issue_description` text NOT NULL,
  `root_cause` text DEFAULT NULL,
  `corrective_action` text DEFAULT NULL,
  `preventive_action` text DEFAULT NULL,
  `target_date` date DEFAULT NULL,
  `status` enum('open','in_progress','closed') NOT NULL DEFAULT 'open',
  `reported_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `incident_no` (`incident_no`),
  KEY `department_id` (`department_id`),
  KEY `reported_by` (`reported_by`),
  CONSTRAINT `capa_incidents_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `capa_incidents_ibfk_2` FOREIGN KEY (`reported_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `capa_incidents`
INSERT INTO `capa_incidents` (`id`, `incident_no`, `department_id`, `severity`, `issue_description`, `root_cause`, `corrective_action`, `preventive_action`, `target_date`, `status`, `reported_by`, `created_at`) VALUES ('1', 'CAPA-2026-001', '3', 'major', 'Specimen hemolyzed during peak hour transit due to courier cold-chain container seal breakdown.', 'Defective gasket seal on secondary insulated cooler transport box.', 'Immediately replaced transport boxes with certified medical cooler units equipped with digital temperature data loggers.', 'Daily cold chain temperature audit log before courier vehicle departure.', '2026-10-28', 'open', '3', '2026-10-21 06:12:17');
INSERT INTO `capa_incidents` (`id`, `incident_no`, `department_id`, `severity`, `issue_description`, `root_cause`, `corrective_action`, `preventive_action`, `target_date`, `status`, `reported_by`, `created_at`) VALUES ('2', 'CAPA-2026-002', '3', 'minor', 'Minor barcode scan mismatch during high-throughput rack loading on Sysmex XN-550.', 'Thermal barcode label ribbon low density causing minor print smudging.', 'Printer ribbon replaced and print darkness density recalibrated from 8 to 12.', 'Weekly maintenance checklist item added for barcode label thermal head cleaning.', '2026-10-24', 'open', '3', '2026-10-20 11:12:17');
INSERT INTO `capa_incidents` (`id`, `incident_no`, `department_id`, `severity`, `issue_description`, `root_cause`, `corrective_action`, `preventive_action`, `target_date`, `status`, `reported_by`, `created_at`) VALUES ('3', 'CAPA-2026-003', '4', 'critical', 'PACS DICOM gateway transfer latency exceeded TAT threshold during emergency CT upload.', 'LAN switch uplink port packet drop due to unshielded Cat6 cable termination bend.', 'Switched to redundant optical fiber gigabit backbone uplink.', 'Annual structured cabling certification and redundant network routing enabled.', '2026-11-04', 'in_progress', '1', '2026-10-19 11:12:17');
INSERT INTO `capa_incidents` (`id`, `incident_no`, `department_id`, `severity`, `issue_description`, `root_cause`, `corrective_action`, `preventive_action`, `target_date`, `status`, `reported_by`, `created_at`) VALUES ('4', 'CAPA-2026-004', '9', 'minor', 'Patient phone number transcription error on registration slip during peak rush.', 'Verbal intake noise interference in counter queue #2.', 'Counter display screen activated showing patient entered info for immediate patient confirmation.', 'Two-way customer verification display installed at all billing booths.', '2026-10-20', 'closed', '2', '2026-10-16 11:12:17');

-- Table structure for table `cashier_shifts`
DROP TABLE IF EXISTS `cashier_shifts`;
CREATE TABLE `cashier_shifts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `counter_id` bigint(20) unsigned NOT NULL,
  `shift_code` varchar(50) DEFAULT 'SHIFT-001',
  `cashier_id` bigint(20) unsigned NOT NULL,
  `opening_float` decimal(15,2) NOT NULL DEFAULT 0.00,
  `system_expected_cash` decimal(15,2) NOT NULL DEFAULT 0.00,
  `declared_cash` decimal(15,2) NOT NULL DEFAULT 0.00,
  `variance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `status` enum('open','closed') NOT NULL DEFAULT 'open',
  `supervisor_approved` tinyint(1) DEFAULT 0,
  `opened_at` datetime NOT NULL DEFAULT current_timestamp(),
  `closed_at` datetime DEFAULT NULL,
  `supervisor_id` bigint(20) unsigned DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branch_id` (`branch_id`),
  KEY `counter_id` (`counter_id`),
  KEY `cashier_id` (`cashier_id`),
  KEY `supervisor_id` (`supervisor_id`),
  CONSTRAINT `cashier_shifts_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `cashier_shifts_ibfk_2` FOREIGN KEY (`counter_id`) REFERENCES `counters` (`id`),
  CONSTRAINT `cashier_shifts_ibfk_3` FOREIGN KEY (`cashier_id`) REFERENCES `users` (`id`),
  CONSTRAINT `cashier_shifts_ibfk_4` FOREIGN KEY (`supervisor_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `cashier_shifts`
INSERT INTO `cashier_shifts` (`id`, `branch_id`, `counter_id`, `shift_code`, `cashier_id`, `opening_float`, `system_expected_cash`, `declared_cash`, `variance`, `status`, `supervisor_approved`, `opened_at`, `closed_at`, `supervisor_id`, `notes`) VALUES ('1', '1', '5', 'SHIFT-001', '1', '500.00', '500.00', '0.00', '0.00', 'open', '0', '2026-10-11 16:22:49', NULL, NULL, NULL);

-- Table structure for table `chart_of_accounts`
DROP TABLE IF EXISTS `chart_of_accounts`;
CREATE TABLE `chart_of_accounts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_code` varchar(30) NOT NULL,
  `name` varchar(180) NOT NULL,
  `account_type` enum('asset','liability','equity','revenue','expense') NOT NULL,
  `parent_id` bigint(20) unsigned DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_code` (`account_code`),
  KEY `parent_id` (`parent_id`),
  CONSTRAINT `chart_of_accounts_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `chart_of_accounts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `chart_of_accounts`
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('1', '1010-CASH', 'Cash in Hand - Pharmacy POS Desk', 'asset', NULL, '1', '2026-10-11 02:29:28');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('2', '1020-MFS', 'bKash / Nagad MFS Settlement Account', 'asset', NULL, '1', '2026-10-11 02:29:28');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('3', '1050-PHARM-INV', 'Pharmacy Inventory Asset Account', 'asset', NULL, '1', '2026-10-11 02:29:28');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('4', '4010-PHARM-REV', 'Pharmacy Sales Revenue Account', 'revenue', NULL, '1', '2026-10-11 02:29:28');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('5', '5010-PHARM-COGS', 'Cost of Goods Sold (COGS) - Pharmacy', 'expense', NULL, '1', '2026-10-11 02:29:28');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('6', '1015-PETTY', 'Petty Cash & Emergency Medical Expense Box', 'asset', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('7', '1020-DBBL', 'Dutch-Bangla Bank (Corporate A/C #110.120.9842)', 'asset', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('8', '1025-BRAC', 'BRAC Bank Operations A/C #150.210.4321', 'asset', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('9', '1030-BKASH', 'bKash / Nagad Corporate Merchant Settlement', 'asset', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('10', '1040-AR-CORP', 'Accounts Receivable - Corporate Panel Clients', 'asset', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('11', '1045-AR-PAT', 'Accounts Receivable - Patient Diagnostic Dues', 'asset', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('12', '1050-REAG-INV', 'Central Pathology Reagents & Chemistry Kits Inventory', 'asset', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('13', '1060-FA-DIAG', 'Medical Diagnostic Analyzers & Equipment', 'asset', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('14', '1065-FA-IMAG', 'Radiology CT/MRI & Ultrasound Imaging Systems', 'asset', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('15', '1070-FA-ACCDEP', 'Accumulated Depreciation - Medical Equipment', 'asset', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('16', '2010-AP-SUPP', 'Accounts Payable - Reagent & Lab Supply Vendors', 'liability', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('17', '2015-AP-PHARM', 'Accounts Payable - Pharmaceutical Distributors', 'liability', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('18', '2020-DOC-COMM', 'Doctor Referral Fees & Consultant Commission Payable', 'liability', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('19', '2030-SAL-PAY', 'Clinical & Administrative Staff Salaries Payable', 'liability', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('20', '2040-TDS-NBR', 'Statutory Tax Deducted at Source (TDS) Payable to NBR', 'liability', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('21', '2045-VDS-NBR', 'Value Added Tax Deducted at Source (VDS) Payable to NBR', 'liability', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('22', '3010-CAPITAL', 'Lutfunnesa Healthcare Shareholder Capital', 'equity', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('23', '3020-RETAINED', 'Retained Earnings & Accumulated Surplus', 'equity', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('24', '4010-REV-PATH', 'Clinical Pathology & Biochemistry Lab Revenue', 'revenue', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('25', '4020-REV-IMAG', 'Radiology, Ultrasound & Imaging Diagnostic Revenue', 'revenue', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('26', '4030-REV-OPD', 'Doctor Consultation Chamber Facility Share', 'revenue', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('27', '4050-REV-CORP', 'Corporate Health Screening & Annual Checkup Contracts', 'revenue', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('28', '4060-REV-HOME', 'Home Specimen Collection Service Surcharge', 'revenue', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('29', '5010-COGS-REAG', 'Pathology Reagents & Chemical Calibrators Consumed', 'expense', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('30', '5020-COGS-TUBES', 'Vacutainer Specimen Tubes, Syringes & Consumables', 'expense', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('31', '5030-COGS-REFLAB', 'External Reference Lab Specialized Testing Charges', 'expense', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('32', '5040-COGS-DOCCOMM', 'Doctor Diagnostic Referral Commission Expense', 'expense', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('33', '6010-EXP-SAL', 'Medical, Nursing & Technical Staff Salaries & Allowances', 'expense', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('34', '6020-EXP-RENT', 'Diagnostic Center Facility & Chamber Lease Rent', 'expense', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('35', '6030-EXP-UTIL', 'Cold Chain & Analyzer Electricity, Water & Utilities', 'expense', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('36', '6040-EXP-AMC', 'Analyzer Maintenance AMC, Bio-Rad EQAS & Calibration', 'expense', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('37', '6050-EXP-WASTE', 'Clinical Biomedical Hazardous Waste Disposal Fees', 'expense', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('38', '6060-EXP-PRINT', 'Diagnostic Test Report Pads, Barcode Labels & Stationery', 'expense', NULL, '1', '2026-10-20 13:04:22');
INSERT INTO `chart_of_accounts` (`id`, `account_code`, `name`, `account_type`, `parent_id`, `active`, `created_at`) VALUES ('39', '6070-EXP-DEP', 'Medical Diagnostic Equipment Depreciation Expense', 'expense', NULL, '1', '2026-10-20 13:04:22');

-- Table structure for table `collection_booths`
DROP TABLE IF EXISTS `collection_booths`;
CREATE TABLE `collection_booths` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_booth` (`branch_id`,`code`),
  CONSTRAINT `collection_booths_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `commission_accruals`
DROP TABLE IF EXISTS `commission_accruals`;
CREATE TABLE `commission_accruals` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) unsigned NOT NULL,
  `order_item_id` bigint(20) unsigned NOT NULL,
  `referrer_id` bigint(20) unsigned NOT NULL,
  `billed_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `realized_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `rate_used` decimal(10,2) NOT NULL DEFAULT 0.00,
  `calculated_commission` decimal(15,2) NOT NULL DEFAULT 0.00,
  `status` enum('provisional','accrued','on_hold','approved','settled','reversed') NOT NULL DEFAULT 'provisional',
  `hold_reason` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `order_item_id` (`order_item_id`),
  KEY `referrer_id` (`referrer_id`),
  CONSTRAINT `commission_accruals_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `diagnostic_orders` (`id`),
  CONSTRAINT `commission_accruals_ibfk_2` FOREIGN KEY (`order_item_id`) REFERENCES `diagnostic_order_items` (`id`),
  CONSTRAINT `commission_accruals_ibfk_3` FOREIGN KEY (`referrer_id`) REFERENCES `referrers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `commission_accruals`
INSERT INTO `commission_accruals` (`id`, `order_id`, `order_item_id`, `referrer_id`, `billed_amount`, `realized_amount`, `rate_used`, `calculated_commission`, `status`, `hold_reason`, `created_at`, `updated_at`) VALUES ('6', '1', '1', '1', '2500.00', '2500.00', '15.00', '375.00', 'accrued', NULL, '2026-10-11 12:00:00', '2026-10-20 13:12:43');
INSERT INTO `commission_accruals` (`id`, `order_id`, `order_item_id`, `referrer_id`, `billed_amount`, `realized_amount`, `rate_used`, `calculated_commission`, `status`, `hold_reason`, `created_at`, `updated_at`) VALUES ('7', '1', '1', '1', '4000.00', '4000.00', '15.00', '600.00', 'accrued', NULL, '2026-10-12 14:00:00', '2026-10-20 13:12:43');
INSERT INTO `commission_accruals` (`id`, `order_id`, `order_item_id`, `referrer_id`, `billed_amount`, `realized_amount`, `rate_used`, `calculated_commission`, `status`, `hold_reason`, `created_at`, `updated_at`) VALUES ('8', '1', '1', '2', '3500.00', '3500.00', '12.00', '420.00', 'accrued', NULL, '2026-10-14 16:30:00', '2026-10-20 13:12:43');
INSERT INTO `commission_accruals` (`id`, `order_id`, `order_item_id`, `referrer_id`, `billed_amount`, `realized_amount`, `rate_used`, `calculated_commission`, `status`, `hold_reason`, `created_at`, `updated_at`) VALUES ('9', '1', '1', '2', '1800.00', '1800.00', '12.00', '216.00', 'accrued', NULL, '2026-10-15 10:15:00', '2026-10-20 13:12:43');
INSERT INTO `commission_accruals` (`id`, `order_id`, `order_item_id`, `referrer_id`, `billed_amount`, `realized_amount`, `rate_used`, `calculated_commission`, `status`, `hold_reason`, `created_at`, `updated_at`) VALUES ('10', '1', '1', '3', '5500.00', '5500.00', '15.00', '825.00', 'settled', NULL, '2026-10-05 11:00:00', '2026-10-20 13:12:43');

-- Table structure for table `commission_rules`
DROP TABLE IF EXISTS `commission_rules`;
CREATE TABLE `commission_rules` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `referrer_id` bigint(20) unsigned DEFAULT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `test_id` bigint(20) unsigned DEFAULT NULL,
  `rate_type` enum('fixed','percent_gross','percent_realized') NOT NULL DEFAULT 'percent_gross',
  `rate_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `max_commission` decimal(10,2) DEFAULT NULL,
  `effective_from` date NOT NULL,
  `effective_to` date DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `referrer_id` (`referrer_id`),
  KEY `department_id` (`department_id`),
  KEY `test_id` (`test_id`),
  CONSTRAINT `commission_rules_ibfk_1` FOREIGN KEY (`referrer_id`) REFERENCES `referrers` (`id`),
  CONSTRAINT `commission_rules_ibfk_2` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `commission_rules_ibfk_3` FOREIGN KEY (`test_id`) REFERENCES `diagnostic_tests` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `commission_rules`
INSERT INTO `commission_rules` (`id`, `referrer_id`, `department_id`, `test_id`, `rate_type`, `rate_value`, `max_commission`, `effective_from`, `effective_to`, `active`, `created_at`) VALUES ('1', NULL, NULL, NULL, 'percent_gross', '15.00', NULL, '2026-07-22', NULL, '1', '2026-10-20 15:44:03');
INSERT INTO `commission_rules` (`id`, `referrer_id`, `department_id`, `test_id`, `rate_type`, `rate_value`, `max_commission`, `effective_from`, `effective_to`, `active`, `created_at`) VALUES ('2', '1', NULL, NULL, 'percent_gross', '18.00', NULL, '2026-07-22', NULL, '1', '2026-10-20 15:44:03');
INSERT INTO `commission_rules` (`id`, `referrer_id`, `department_id`, `test_id`, `rate_type`, `rate_value`, `max_commission`, `effective_from`, `effective_to`, `active`, `created_at`) VALUES ('3', '2', NULL, NULL, 'percent_gross', '15.00', NULL, '2026-07-22', NULL, '1', '2026-10-20 15:44:03');
INSERT INTO `commission_rules` (`id`, `referrer_id`, `department_id`, `test_id`, `rate_type`, `rate_value`, `max_commission`, `effective_from`, `effective_to`, `active`, `created_at`) VALUES ('4', '4', NULL, NULL, 'percent_gross', '20.00', NULL, '2026-07-22', NULL, '1', '2026-10-20 15:44:03');

-- Table structure for table `commission_settlement_batches`
DROP TABLE IF EXISTS `commission_settlement_batches`;
CREATE TABLE `commission_settlement_batches` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `batch_no` varchar(30) NOT NULL,
  `referrer_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `gross_commission` decimal(15,2) NOT NULL DEFAULT 0.00,
  `tds_deduction` decimal(15,2) NOT NULL DEFAULT 0.00,
  `net_payable` decimal(15,2) NOT NULL DEFAULT 0.00,
  `status` enum('draft','approved','paid') NOT NULL DEFAULT 'draft',
  `paid_at` datetime DEFAULT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `created_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `batch_no` (`batch_no`),
  KEY `referrer_id` (`referrer_id`),
  KEY `branch_id` (`branch_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `commission_settlement_batches_ibfk_1` FOREIGN KEY (`referrer_id`) REFERENCES `referrers` (`id`),
  CONSTRAINT `commission_settlement_batches_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `commission_settlement_batches_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `commission_settlement_batches`
INSERT INTO `commission_settlement_batches` (`id`, `batch_no`, `referrer_id`, `branch_id`, `period_start`, `period_end`, `gross_commission`, `tds_deduction`, `net_payable`, `status`, `paid_at`, `payment_reference`, `created_by`, `created_at`) VALUES ('1', 'BAT-2026-001', '1', '1', '2026-09-01', '2026-09-30', '18500.00', '1850.00', '16650.00', 'paid', '2026-10-20 15:44:03', 'EFT-DBBL-99120', '1', '2026-10-20 15:44:03');
INSERT INTO `commission_settlement_batches` (`id`, `batch_no`, `referrer_id`, `branch_id`, `period_start`, `period_end`, `gross_commission`, `tds_deduction`, `net_payable`, `status`, `paid_at`, `payment_reference`, `created_by`, `created_at`) VALUES ('2', 'BAT-2026-002', '2', '1', '2026-09-01', '2026-09-30', '12000.00', '1200.00', '10800.00', 'paid', '2026-10-20 15:44:03', 'CHQ-BRAC-44102', '1', '2026-10-20 15:44:03');
INSERT INTO `commission_settlement_batches` (`id`, `batch_no`, `referrer_id`, `branch_id`, `period_start`, `period_end`, `gross_commission`, `tds_deduction`, `net_payable`, `status`, `paid_at`, `payment_reference`, `created_by`, `created_at`) VALUES ('3', 'BAT-2026-003', '4', '1', '2026-09-01', '2026-09-30', '24000.00', '2400.00', '21600.00', 'approved', '2026-10-20 15:44:03', 'Pending Disbursement', '1', '2026-10-20 15:44:03');
INSERT INTO `commission_settlement_batches` (`id`, `batch_no`, `referrer_id`, `branch_id`, `period_start`, `period_end`, `gross_commission`, `tds_deduction`, `net_payable`, `status`, `paid_at`, `payment_reference`, `created_by`, `created_at`) VALUES ('4', 'BAT-2026-004', '3', '1', '2026-10-01', '2026-10-15', '8500.00', '850.00', '7650.00', 'approved', '2026-10-20 15:44:03', 'Pending Disbursement', '1', '2026-10-20 15:44:03');

-- Table structure for table `compliance_licenses`
DROP TABLE IF EXISTS `compliance_licenses`;
CREATE TABLE `compliance_licenses` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `license_no` varchar(80) NOT NULL,
  `title` varchar(180) NOT NULL,
  `category` enum('facility','radiation','fire_safety','environment','trade') NOT NULL DEFAULT 'facility',
  `issuing_authority` varchar(150) NOT NULL,
  `effective_date` date NOT NULL,
  `expiry_date` date NOT NULL,
  `status` enum('active','renewal_due','expired') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `license_no` (`license_no`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `compliance_licenses`
INSERT INTO `compliance_licenses` (`id`, `license_no`, `title`, `category`, `issuing_authority`, `effective_date`, `expiry_date`, `status`, `created_at`) VALUES ('1', 'DGHS-DIAG-DHAKA-2026-089', 'DGHS Clinical Diagnostic Center & Pathology Lab Facility License', 'facility', 'Directorate General of Health Services (DGHS Bangladesh)', '2026-01-01', '2026-12-31', 'active', '2026-01-01 10:00:00');
INSERT INTO `compliance_licenses` (`id`, `license_no`, `title`, `category`, `issuing_authority`, `effective_date`, `expiry_date`, `status`, `created_at`) VALUES ('2', 'BAERA-RAD-SAFETY-2026-441', 'Bangladesh Atomic Energy Regulatory Authority (BAERA) Radiation Safety License (X-Ray & CT)', 'radiation', 'BAERA Bangladesh', '2025-07-01', '2027-06-30', 'active', '2025-07-01 11:00:00');
INSERT INTO `compliance_licenses` (`id`, `license_no`, `title`, `category`, `issuing_authority`, `effective_date`, `expiry_date`, `status`, `created_at`) VALUES ('3', 'FSCD-FIRE-DHAKA-9021', 'Fire Prevention, Emergency Evacuation & Fire Safety Clearance Certificate', 'fire_safety', 'Fire Service and Civil Defence (FSCD Bangladesh)', '2025-11-15', '2026-11-14', 'renewal_due', '2025-11-15 12:00:00');
INSERT INTO `compliance_licenses` (`id`, `license_no`, `title`, `category`, `issuing_authority`, `effective_date`, `expiry_date`, `status`, `created_at`) VALUES ('4', 'DOE-ENV-MEDWASTE-3042', 'Department of Environment (DoE) Bio-medical Waste Management & Environmental Clearance', 'environment', 'Department of Environment, Ministry of Environment Bangladesh', '2026-02-01', '2027-01-31', 'active', '2026-02-01 09:30:00');
INSERT INTO `compliance_licenses` (`id`, `license_no`, `title`, `category`, `issuing_authority`, `effective_date`, `expiry_date`, `status`, `created_at`) VALUES ('5', 'DNCC-TRADE-LIC-008741', 'Dhaka North City Corporation (DNCC) Commercial Healthcare Trade License', 'trade', 'Dhaka North City Corporation (Zone-3)', '2026-07-01', '2027-06-30', 'active', '2026-07-01 10:00:00');
INSERT INTO `compliance_licenses` (`id`, `license_no`, `title`, `category`, `issuing_authority`, `effective_date`, `expiry_date`, `status`, `created_at`) VALUES ('6', 'DGDA-DRUG-STORE-5521', 'Directorate General of Drug Administration (DGDA) Retail Pharmacy Dispensing License', 'facility', 'Directorate General of Drug Administration (DGDA)', '2026-01-10', '2028-01-09', 'active', '2026-01-10 11:00:00');

-- Table structure for table `containers`
DROP TABLE IF EXISTS `containers`;
CREATE TABLE `containers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `controlled_documents`
DROP TABLE IF EXISTS `controlled_documents`;
CREATE TABLE `controlled_documents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `doc_no` varchar(30) NOT NULL,
  `title` varchar(180) NOT NULL,
  `category` enum('sop','policy','form') NOT NULL DEFAULT 'sop',
  `version` varchar(20) NOT NULL DEFAULT '1.0',
  `effective_date` date NOT NULL,
  `review_date` date DEFAULT NULL,
  `status` enum('draft','approved','obsolete') NOT NULL DEFAULT 'approved',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `doc_no` (`doc_no`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `controlled_documents`
INSERT INTO `controlled_documents` (`id`, `doc_no`, `title`, `category`, `version`, `effective_date`, `review_date`, `status`, `created_at`) VALUES ('1', 'SOP-CLIN-001', 'Critical Laboratory Result Immediate Telephone Notification SOP', 'sop', '2.1', '2026-01-01', '2027-01-01', 'approved', '2026-01-01 09:00:00');
INSERT INTO `controlled_documents` (`id`, `doc_no`, `title`, `category`, `version`, `effective_date`, `review_date`, `status`, `created_at`) VALUES ('2', 'SOP-CLIN-002', 'Phlebotomy Standard Protocol & Specimen Identification Verification', 'sop', '3.0', '2026-02-15', '2027-02-15', 'approved', '2026-02-15 10:00:00');
INSERT INTO `controlled_documents` (`id`, `doc_no`, `title`, `category`, `version`, `effective_date`, `review_date`, `status`, `created_at`) VALUES ('3', 'POL-QMS-005', 'Quality Management System & Multi-Level Westgard QC Policy', 'policy', '1.4', '2026-03-01', '2027-03-01', 'approved', '2026-03-01 11:30:00');
INSERT INTO `controlled_documents` (`id`, `doc_no`, `title`, `category`, `version`, `effective_date`, `review_date`, `status`, `created_at`) VALUES ('4', 'SOP-RAD-008', 'Radiation Safety, Lead Shielding & BAERA Compliance Protocol', 'sop', '2.0', '2026-04-10', '2027-04-10', 'approved', '2026-04-10 14:00:00');
INSERT INTO `controlled_documents` (`id`, `doc_no`, `title`, `category`, `version`, `effective_date`, `review_date`, `status`, `created_at`) VALUES ('5', 'FRM-BIO-012', 'Daily High-Risk Biomedical Waste Disposal & Decontamination Log Form', 'form', '1.2', '2026-05-01', '2027-05-01', 'approved', '2026-05-01 08:30:00');
INSERT INTO `controlled_documents` (`id`, `doc_no`, `title`, `category`, `version`, `effective_date`, `review_date`, `status`, `created_at`) VALUES ('6', 'POL-SEC-003', 'Patient Medical Record Confidentiality & Digital Privacy Policy', 'policy', '1.1', '2026-06-01', '2027-06-01', 'approved', '2026-06-01 10:00:00');

-- Table structure for table `corporate_clients`
DROP TABLE IF EXISTS `corporate_clients`;
CREATE TABLE `corporate_clients` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(180) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `corporate_clients`
INSERT INTO `corporate_clients` (`id`, `code`, `name`, `phone`, `email`, `active`, `created_at`, `updated_at`) VALUES ('1', 'CORP-001', 'Grameenphone Corporate Health Scheme', '01711-998877', 'health@grameenphone.com', '1', '2026-10-20 13:11:16', '2026-10-20 13:11:16');
INSERT INTO `corporate_clients` (`id`, `code`, `name`, `phone`, `email`, `active`, `created_at`, `updated_at`) VALUES ('2', 'CORP-002', 'BRAC Bank Employees Medical Panel', '01819-887766', 'benefits@bracbank.com', '1', '2026-10-20 13:11:16', '2026-10-20 13:11:16');
INSERT INTO `corporate_clients` (`id`, `code`, `name`, `phone`, `email`, `active`, `created_at`, `updated_at`) VALUES ('3', 'CORP-003', 'Robi Axiata Wellness Program', '01612-776655', 'wellness@robi.com.bd', '1', '2026-10-20 13:11:16', '2026-10-20 13:11:16');
INSERT INTO `corporate_clients` (`id`, `code`, `name`, `phone`, `email`, `active`, `created_at`, `updated_at`) VALUES ('4', 'CORP-004', 'Square Group Executive Health Scheme', '01914-665544', 'medical@squaregroup.com', '1', '2026-10-20 13:11:16', '2026-10-20 13:11:16');

-- Table structure for table `corporate_contracts`
DROP TABLE IF EXISTS `corporate_contracts`;
CREATE TABLE `corporate_contracts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `corporate_client_id` bigint(20) unsigned NOT NULL,
  `contract_no` varchar(30) NOT NULL,
  `agreement_start` date NOT NULL,
  `agreement_end` date NOT NULL,
  `credit_limit` decimal(15,2) NOT NULL DEFAULT 500000.00,
  `current_balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `discount_percent` decimal(5,2) NOT NULL DEFAULT 0.00,
  `pre_auth_required` tinyint(1) NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `contract_no` (`contract_no`),
  KEY `corporate_client_id` (`corporate_client_id`),
  CONSTRAINT `corporate_contracts_ibfk_1` FOREIGN KEY (`corporate_client_id`) REFERENCES `corporate_clients` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `corporate_contracts`
INSERT INTO `corporate_contracts` (`id`, `corporate_client_id`, `contract_no`, `agreement_start`, `agreement_end`, `credit_limit`, `current_balance`, `discount_percent`, `pre_auth_required`, `active`, `created_at`, `updated_at`) VALUES ('1', '1', 'CNT-2026-GP01', '2026-01-01', '2026-12-31', '1500000.00', '345000.00', '20.00', '1', '1', '2026-10-20 15:19:14', '2026-10-20 15:19:14');
INSERT INTO `corporate_contracts` (`id`, `corporate_client_id`, `contract_no`, `agreement_start`, `agreement_end`, `credit_limit`, `current_balance`, `discount_percent`, `pre_auth_required`, `active`, `created_at`, `updated_at`) VALUES ('2', '2', 'CNT-2026-BRAC02', '2026-02-01', '2026-12-31', '800000.00', '180000.00', '15.00', '0', '1', '2026-10-20 15:19:14', '2026-10-20 15:19:14');
INSERT INTO `corporate_contracts` (`id`, `corporate_client_id`, `contract_no`, `agreement_start`, `agreement_end`, `credit_limit`, `current_balance`, `discount_percent`, `pre_auth_required`, `active`, `created_at`, `updated_at`) VALUES ('3', '3', 'CNT-2026-ROBI03', '2026-03-01', '2026-12-31', '600000.00', '95000.00', '18.00', '1', '1', '2026-10-20 15:19:14', '2026-10-20 15:19:14');
INSERT INTO `corporate_contracts` (`id`, `corporate_client_id`, `contract_no`, `agreement_start`, `agreement_end`, `credit_limit`, `current_balance`, `discount_percent`, `pre_auth_required`, `active`, `created_at`, `updated_at`) VALUES ('4', '4', 'CNT-2026-SQR04', '2026-01-15', '2026-12-31', '2000000.00', '520000.00', '25.00', '1', '1', '2026-10-20 15:19:14', '2026-10-20 15:19:14');

-- Table structure for table `corporate_employees`
DROP TABLE IF EXISTS `corporate_employees`;
CREATE TABLE `corporate_employees` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `corporate_client_id` bigint(20) unsigned NOT NULL,
  `employee_code` varchar(50) NOT NULL,
  `name` varchar(150) NOT NULL,
  `designation` varchar(100) DEFAULT NULL,
  `relation` enum('self','spouse','child','parent') NOT NULL DEFAULT 'self',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `corporate_client_id` (`corporate_client_id`),
  CONSTRAINT `corporate_employees_ibfk_1` FOREIGN KEY (`corporate_client_id`) REFERENCES `corporate_clients` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `corporate_invoices`
DROP TABLE IF EXISTS `corporate_invoices`;
CREATE TABLE `corporate_invoices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `invoice_no` varchar(30) NOT NULL,
  `corporate_client_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `billing_period` varchar(30) NOT NULL,
  `total_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `disputed_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `due_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `status` enum('draft','submitted','acknowledged','partially_paid','paid') NOT NULL DEFAULT 'draft',
  `submitted_at` datetime DEFAULT NULL,
  `created_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_no` (`invoice_no`),
  KEY `corporate_client_id` (`corporate_client_id`),
  KEY `branch_id` (`branch_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `corporate_invoices_ibfk_1` FOREIGN KEY (`corporate_client_id`) REFERENCES `corporate_clients` (`id`),
  CONSTRAINT `corporate_invoices_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `corporate_invoices_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `corporate_invoices`
INSERT INTO `corporate_invoices` (`id`, `invoice_no`, `corporate_client_id`, `branch_id`, `billing_period`, `total_amount`, `disputed_amount`, `due_amount`, `status`, `submitted_at`, `created_by`, `created_at`) VALUES ('1', 'CORP-INV-2026-001', '1', '1', 'Sep 2026', '185000.00', '0.00', '45000.00', 'partially_paid', '2026-10-01 10:00:00', '1', '2026-10-01 10:00:00');
INSERT INTO `corporate_invoices` (`id`, `invoice_no`, `corporate_client_id`, `branch_id`, `billing_period`, `total_amount`, `disputed_amount`, `due_amount`, `status`, `submitted_at`, `created_by`, `created_at`) VALUES ('2', 'CORP-INV-2026-002', '2', '1', 'Oct 2026', '120000.00', '0.00', '120000.00', 'submitted', '2026-10-15 11:30:00', '1', '2026-10-15 11:30:00');
INSERT INTO `corporate_invoices` (`id`, `invoice_no`, `corporate_client_id`, `branch_id`, `billing_period`, `total_amount`, `disputed_amount`, `due_amount`, `status`, `submitted_at`, `created_by`, `created_at`) VALUES ('3', 'CORP-INV-2026-003', '3', '1', 'Aug 2026', '95000.00', '0.00', '0.00', 'paid', '2026-09-01 09:00:00', '1', '2026-09-01 09:00:00');

-- Table structure for table `corporate_payments`
DROP TABLE IF EXISTS `corporate_payments`;
CREATE TABLE `corporate_payments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `receipt_no` varchar(30) NOT NULL,
  `corporate_invoice_id` bigint(20) unsigned NOT NULL,
  `amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `payment_method_id` bigint(20) unsigned NOT NULL,
  `reference_no` varchar(100) DEFAULT NULL,
  `received_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `receipt_no` (`receipt_no`),
  KEY `corporate_invoice_id` (`corporate_invoice_id`),
  KEY `payment_method_id` (`payment_method_id`),
  KEY `received_by` (`received_by`),
  CONSTRAINT `corporate_payments_ibfk_1` FOREIGN KEY (`corporate_invoice_id`) REFERENCES `corporate_invoices` (`id`),
  CONSTRAINT `corporate_payments_ibfk_2` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`id`),
  CONSTRAINT `corporate_payments_ibfk_3` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `cost_centers`
DROP TABLE IF EXISTS `cost_centers`;
CREATE TABLE `cost_centers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cost_center` (`branch_id`,`code`),
  CONSTRAINT `cost_centers_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `counters`
DROP TABLE IF EXISTS `counters`;
CREATE TABLE `counters` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `purpose` enum('registration','billing','delivery','other') NOT NULL DEFAULT 'registration',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_counter` (`branch_id`,`code`),
  CONSTRAINT `counters_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `counters`
INSERT INTO `counters` (`id`, `branch_id`, `code`, `name`, `purpose`, `active`, `created_at`, `updated_at`) VALUES ('1', '1', 'CTR-REG-01', 'Registration & Patient Reception (Desk 1)', 'registration', '1', '2026-10-11 14:26:19', '2026-10-11 14:26:19');
INSERT INTO `counters` (`id`, `branch_id`, `code`, `name`, `purpose`, `active`, `created_at`, `updated_at`) VALUES ('2', '1', 'CTR-BIL-02', 'Main Diagnostic Cash & Billing Counter (Desk 2)', 'billing', '1', '2026-10-11 14:26:19', '2026-10-11 14:26:19');
INSERT INTO `counters` (`id`, `branch_id`, `code`, `name`, `purpose`, `active`, `created_at`, `updated_at`) VALUES ('3', '1', 'CTR-OPD-03', 'Specialist Doctor OPD Billing Counter (Desk 3)', 'billing', '1', '2026-10-11 14:26:19', '2026-10-11 14:26:19');
INSERT INTO `counters` (`id`, `branch_id`, `code`, `name`, `purpose`, `active`, `created_at`, `updated_at`) VALUES ('4', '1', 'CTR-LAB-04', 'Lab Sample & Pathology Billing Desk (Desk 4)', 'billing', '1', '2026-10-11 14:26:19', '2026-10-11 14:26:19');
INSERT INTO `counters` (`id`, `branch_id`, `code`, `name`, `purpose`, `active`, `created_at`, `updated_at`) VALUES ('5', '1', 'CTR-RAD-05', 'Radiology & Imaging Cash Counter (Desk 5)', 'billing', '1', '2026-10-11 14:26:19', '2026-10-11 14:26:19');
INSERT INTO `counters` (`id`, `branch_id`, `code`, `name`, `purpose`, `active`, `created_at`, `updated_at`) VALUES ('6', '1', 'CTR-DEL-06', 'Report Delivery & Inquiry Counter (Desk 6)', 'delivery', '1', '2026-10-11 14:26:19', '2026-10-11 14:26:19');

-- Table structure for table `critical_alert_logs`
DROP TABLE IF EXISTS `critical_alert_logs`;
CREATE TABLE `critical_alert_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_item_id` bigint(20) unsigned NOT NULL,
  `critical_parameter` varchar(150) NOT NULL,
  `critical_value` varchar(150) NOT NULL,
  `notified_to` varchar(255) DEFAULT NULL,
  `status` enum('pending','notified','acknowledged') NOT NULL DEFAULT 'pending',
  `logged_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `critical_alert_logs`
INSERT INTO `critical_alert_logs` (`id`, `order_item_id`, `critical_parameter`, `critical_value`, `notified_to`, `status`, `logged_at`) VALUES ('1', '1', 'Fasting Blood Sugar (Glucose)', '24.8 mmol/L (Severe Hyperglycemia - Panic Value)', 'Dr. Specialist Doctor Consultant & On-Duty Medical Officer', 'pending', '2026-10-21 10:57:17');
INSERT INTO `critical_alert_logs` (`id`, `order_item_id`, `critical_parameter`, `critical_value`, `notified_to`, `status`, `logged_at`) VALUES ('2', '9', 'Serum Potassium (K+)', '2.6 mmol/L (Critical Hypokalemia)', 'Patient Consultant & Ward Nurse Desk', 'notified', '2026-10-21 10:12:17');

-- Table structure for table `crm_leads`
DROP TABLE IF EXISTS `crm_leads`;
CREATE TABLE `crm_leads` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `company_name` varchar(180) NOT NULL,
  `contact_person` varchar(150) NOT NULL,
  `phone` varchar(30) NOT NULL,
  `email` varchar(190) DEFAULT NULL,
  `status` enum('lead','prospect','proposal','contracted','lost') NOT NULL DEFAULT 'lead',
  `assigned_to` bigint(20) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `assigned_to` (`assigned_to`),
  CONSTRAINT `crm_leads_ibfk_1` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `crm_leads`
INSERT INTO `crm_leads` (`id`, `company_name`, `contact_person`, `phone`, `email`, `status`, `assigned_to`, `notes`, `created_at`, `updated_at`) VALUES ('1', 'Grameenphone Corporate HQ', 'Rahat Chowdhury (Head of HR)', '+8801711998877', 'rahat.c@grameenphone.com', 'contracted', '1', 'Annual executive health package and executive wellness screening contract finalized.', '2026-10-20 15:44:03', '2026-10-20 15:44:03');
INSERT INTO `crm_leads` (`id`, `company_name`, `contact_person`, `phone`, `email`, `status`, `assigned_to`, `notes`, `created_at`, `updated_at`) VALUES ('2', 'BRAC Bank Operations Division', 'Nusrat Jahan (Senior HR Manager)', '+8801722883344', 'nusrat.j@bracbank.com', 'proposal', '1', 'Proposal submitted for employee pre-employment medical examinations & OPD discount panel.', '2026-10-20 15:44:03', '2026-10-20 15:44:03');
INSERT INTO `crm_leads` (`id`, `company_name`, `contact_person`, `phone`, `email`, `status`, `assigned_to`, `notes`, `created_at`, `updated_at`) VALUES ('3', 'Unilever Bangladesh Ltd', 'Tanvir Alam (Employee Benefits)', '+8801819223344', 'tanvir.a@unilever.com', 'prospect', '1', 'Initial pitch delivered for comprehensive occupational health checkups across factory & HQ.', '2026-10-20 15:44:03', '2026-10-20 15:44:03');
INSERT INTO `crm_leads` (`id`, `company_name`, `contact_person`, `phone`, `email`, `status`, `assigned_to`, `notes`, `created_at`, `updated_at`) VALUES ('4', 'Beximco Pharmaceuticals Ltd', 'Dr. Shahedur Rahman (Medical Director)', '+8801733445566', 'shahed.r@beximco.com', 'lead', '1', 'Follow up on joint clinical CME symposium & employee discount corporate panel.', '2026-10-20 15:44:03', '2026-10-20 15:44:03');

-- Table structure for table `culture_sensitivities`
DROP TABLE IF EXISTS `culture_sensitivities`;
CREATE TABLE `culture_sensitivities` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `culture_id` bigint(20) unsigned NOT NULL,
  `antibiotic_name` varchar(150) NOT NULL,
  `susceptibility` enum('S','I','R') NOT NULL DEFAULT 'S',
  `mic_value` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `culture_id` (`culture_id`),
  CONSTRAINT `culture_sensitivities_ibfk_1` FOREIGN KEY (`culture_id`) REFERENCES `microbiology_cultures` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `culture_sensitivities`
INSERT INTO `culture_sensitivities` (`id`, `culture_id`, `antibiotic_name`, `susceptibility`, `mic_value`) VALUES ('1', '1', 'Amikacin', 'S', '<=2 ug/mL');
INSERT INTO `culture_sensitivities` (`id`, `culture_id`, `antibiotic_name`, `susceptibility`, `mic_value`) VALUES ('2', '1', 'Meropenem', 'S', '<=0.5 ug/mL');
INSERT INTO `culture_sensitivities` (`id`, `culture_id`, `antibiotic_name`, `susceptibility`, `mic_value`) VALUES ('3', '1', 'Ceftriaxone', 'R', '>=16 ug/mL');
INSERT INTO `culture_sensitivities` (`id`, `culture_id`, `antibiotic_name`, `susceptibility`, `mic_value`) VALUES ('4', '1', 'Ciprofloxacin', 'R', '>=4 ug/mL');
INSERT INTO `culture_sensitivities` (`id`, `culture_id`, `antibiotic_name`, `susceptibility`, `mic_value`) VALUES ('5', '1', 'Nitrofurantoin', 'S', '<=16 ug/mL');
INSERT INTO `culture_sensitivities` (`id`, `culture_id`, `antibiotic_name`, `susceptibility`, `mic_value`) VALUES ('6', '1', 'Cotrimoxazole', 'R', '>=80 ug/mL');

-- Table structure for table `departments`
DROP TABLE IF EXISTS `departments`;
CREATE TABLE `departments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `kind` enum('clinical','administrative','support') NOT NULL DEFAULT 'clinical',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_department_branch_code` (`branch_id`,`code`),
  CONSTRAINT `departments_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `departments`
INSERT INTO `departments` (`id`, `branch_id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('1', '1', 'DEPT-OPD-DIA', 'Diabetology & Endocrinology OPD', 'clinical', '1', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `departments` (`id`, `branch_id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('2', '1', 'DEPT-OPD-CARD', 'Cardiology & Cardiovascular Unit', 'clinical', '1', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `departments` (`id`, `branch_id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('3', '1', 'DEPT-LAB-LIS', 'Clinical Pathology & LIS Reference Lab', 'clinical', '1', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `departments` (`id`, `branch_id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('4', '1', 'DEPT-RAD-PACS', 'Digital Radiology & PACS Imaging', 'clinical', '1', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `departments` (`id`, `branch_id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('5', '1', 'DEPT-PHARM', 'Pharmacy & Therapeutics Dispensary', 'support', '1', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `departments` (`id`, `branch_id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('6', '1', 'DEPT-NEPHRO', 'Nephrology & Renal Medicine', 'clinical', '1', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `departments` (`id`, `branch_id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('7', '1', 'DEPT-GEN-MED', 'Internal & General Medicine', 'clinical', '1', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `departments` (`id`, `branch_id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('8', '1', 'DEPT-EMERG', 'Emergency & Daycare Observation', 'clinical', '1', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `departments` (`id`, `branch_id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('9', '1', 'DEPT-FRONT', 'Reception, Billing & Queue Desk', 'administrative', '1', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `departments` (`id`, `branch_id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('10', '1', 'DEPT-ADMIN', 'Hospital Executive Administration', 'administrative', '1', '2026-10-10 17:53:29', '2026-10-10 17:53:29');

-- Table structure for table `diagnostic_order_items`
DROP TABLE IF EXISTS `diagnostic_order_items`;
CREATE TABLE `diagnostic_order_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) unsigned NOT NULL,
  `item_type` enum('test','panel') NOT NULL DEFAULT 'test',
  `item_id` bigint(20) unsigned NOT NULL,
  `item_name` varchar(180) NOT NULL,
  `price` decimal(15,2) NOT NULL DEFAULT 0.00,
  `fasting_required` tinyint(1) NOT NULL DEFAULT 0,
  `preparation_notes` text DEFAULT NULL,
  `status` enum('pending','collected','in_lab','completed') NOT NULL DEFAULT 'pending',
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `diagnostic_order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `diagnostic_orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `diagnostic_order_items`
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('1', '1', 'test', '1', 'Fasting Blood Sugar (FBS / Glucose)', '200.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('2', '1', 'test', '3', 'HbA1c (Glycated Hemoglobin) by HPLC', '1000.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('3', '1', 'test', '5', 'Lipid Profile Full Panel (Chol, Trig, HDL, LDL)', '1200.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('4', '2', 'test', '13', 'Thyroid Stimulating Hormone (TSH) Ultra-sensitive', '700.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('5', '2', 'test', '14', 'Free Thyroxine (FT4) Chemiluminescence', '800.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('6', '2', 'test', '16', '25-Hydroxy Vitamin D (Total D2 + D3)', '2500.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('7', '3', 'test', '9', 'Complete Blood Count (CBC) with 5-Part Diff & ESR', '450.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('8', '3', 'test', '4', 'Serum Creatinine with eGFR', '350.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('9', '3', 'test', '8', 'Serum Electrolytes (Na+, K+, Cl-) by ISE', '800.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('10', '4', 'test', '22', 'Urine Routine & Microscopic Examination (Urine R/M/E)', '250.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('11', '4', 'test', '25', 'Urine Culture & Antibiotic Sensitivity (AST)', '1000.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('12', '5', 'test', '1', 'Fasting Blood Sugar (FBS / Glucose)', '200.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('13', '5', 'test', '4', 'Serum Creatinine with eGFR', '350.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('14', '5', 'test', '6', 'Serum Uric Acid', '400.00', '0', 'Standard laboratory handling', 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('15', '6', 'test', '30', 'GeneXpert MTB/RIF for Mycobacterium Tuberculosis', '1000.00', '0', NULL, 'pending');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('16', '7', 'test', '30', 'GeneXpert MTB/RIF for Mycobacterium Tuberculosis', '1000.00', '0', NULL, 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('17', '8', 'test', '28', 'Cervical Cytology (Liquid Based Pap Smear)', '1000.00', '0', NULL, 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('18', '10', 'test', '1', 'HbA1c Glycated Hemoglobin', '1200.00', '1', NULL, 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('19', '10', 'test', '1', 'Fasting Blood Sugar (FBS) & 2h ABF', '600.00', '1', NULL, 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('20', '10', 'test', '1', 'Lipid Profile Complete Panel', '2000.00', '1', NULL, 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('21', '11', 'test', '1', 'Complete Blood Count (CBC) with ESR', '800.00', '1', NULL, 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('22', '11', 'test', '1', 'Serum Creatinine & eGFR', '700.00', '1', NULL, 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('23', '11', 'test', '1', 'Digital 12-Lead Electrocardiogram (ECG)', '1300.00', '1', NULL, 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('24', '12', 'test', '1', 'Digital Chest Radiograph X-Ray P/A View', '1500.00', '1', NULL, 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('25', '12', 'test', '1', 'Thyroid Stimulating Hormone (TSH, Ultra)', '1800.00', '1', NULL, 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('26', '12', 'test', '1', 'Serum Electrolytes (Na+, K+, Cl-)', '1200.00', '1', NULL, 'completed');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('27', '13', 'test', '30', 'GeneXpert MTB/RIF for Mycobacterium Tuberculosis', '1000.00', '0', NULL, 'pending');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('28', '13', 'test', '29', 'HBV DNA Real-Time Quantitative PCR', '1000.00', '0', NULL, 'pending');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('29', '19', 'test', '30', 'GeneXpert MTB/RIF for Mycobacterium Tuberculosis', '1000.00', '0', NULL, 'pending');
INSERT INTO `diagnostic_order_items` (`id`, `order_id`, `item_type`, `item_id`, `item_name`, `price`, `fasting_required`, `preparation_notes`, `status`) VALUES ('30', '20', 'test', '30', 'GeneXpert MTB/RIF for Mycobacterium Tuberculosis', '1000.00', '0', NULL, 'pending');

-- Table structure for table `diagnostic_orders`
DROP TABLE IF EXISTS `diagnostic_orders`;
CREATE TABLE `diagnostic_orders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_no` varchar(30) NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `doctor_id` bigint(20) unsigned DEFAULT NULL,
  `referrer_id` bigint(20) unsigned DEFAULT NULL,
  `corporate_client_id` bigint(20) unsigned DEFAULT NULL,
  `urgency` enum('routine','urgent','stat') NOT NULL DEFAULT 'routine',
  `collection_location` varchar(150) DEFAULT NULL,
  `clinical_notes` text DEFAULT NULL,
  `status` enum('pending_payment','ready_for_collection','sample_collected','processing','completed','delivered') NOT NULL DEFAULT 'pending_payment',
  `total_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `payable_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `created_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_no` (`order_no`),
  KEY `branch_id` (`branch_id`),
  KEY `patient_id` (`patient_id`),
  KEY `doctor_id` (`doctor_id`),
  KEY `referrer_id` (`referrer_id`),
  KEY `corporate_client_id` (`corporate_client_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `diagnostic_orders_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `diagnostic_orders_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`),
  CONSTRAINT `diagnostic_orders_ibfk_3` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`),
  CONSTRAINT `diagnostic_orders_ibfk_4` FOREIGN KEY (`referrer_id`) REFERENCES `referrers` (`id`),
  CONSTRAINT `diagnostic_orders_ibfk_5` FOREIGN KEY (`corporate_client_id`) REFERENCES `corporate_clients` (`id`),
  CONSTRAINT `diagnostic_orders_ibfk_6` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `diagnostic_orders`
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('1', 'ORD-2026-00101', '1', '1', NULL, '1', NULL, 'routine', 'Main Specimen Booth #2', 'Routine Clinical Workup & Investigation', 'ready_for_collection', '2500.00', '0.00', '2500.00', '1', '2026-10-05 18:31:34', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('2', 'ORD-2026-00102', '1', '2', NULL, '1', NULL, 'routine', 'Main Specimen Booth #2', 'Routine Clinical Workup & Investigation', 'completed', '2500.00', '0.00', '2500.00', '1', '2026-10-06 18:31:34', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('3', 'ORD-2026-00103', '1', '3', NULL, '1', NULL, 'routine', 'Main Specimen Booth #2', 'Routine Clinical Workup & Investigation', 'completed', '2500.00', '0.00', '2500.00', '1', '2026-10-07 18:31:34', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('4', 'ORD-2026-00104', '1', '4', NULL, '1', NULL, 'routine', 'Main Specimen Booth #2', 'Routine Clinical Workup & Investigation', 'completed', '2500.00', '0.00', '2500.00', '1', '2026-10-08 18:31:34', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('5', 'ORD-2026-00105', '1', '5', NULL, '2', NULL, 'stat', 'Main Specimen Booth #2', 'Routine Clinical Workup & Investigation', 'completed', '2500.00', '0.00', '2500.00', '1', '2026-10-09 18:31:34', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('6', 'ORD-2026-00002', '1', '5', NULL, '2', NULL, 'routine', 'Main Counter', NULL, 'pending_payment', '1000.00', '500.00', '500.00', '1', '2026-10-11 15:12:51', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('7', 'ORD-2026-00003', '1', '4', NULL, '2', NULL, 'routine', 'Main Counter', NULL, 'completed', '1000.00', '500.00', '500.00', '1', '2026-10-11 15:42:21', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('8', 'ORD-2026-00005', '1', '6', NULL, '3', NULL, 'routine', 'Main Counter', NULL, 'completed', '1000.00', '0.00', '1000.00', '1', '2026-10-11 15:57:30', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('10', 'ORD-2026-00108', '1', '6', '1', '3', NULL, 'routine', NULL, NULL, 'completed', '3800.00', '300.00', '3500.00', '1', '2026-10-18 10:30:00', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('11', 'ORD-2026-00115', '1', '6', '2', '4', NULL, 'routine', NULL, NULL, 'processing', '2800.00', '200.00', '2600.00', '1', '2026-10-19 14:15:00', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('12', 'ORD-2026-00122', '1', '6', '5', '4', NULL, 'stat', NULL, NULL, 'completed', '4500.00', '500.00', '4000.00', '1', '2026-10-20 09:00:00', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('13', 'ORD-2026-00006', '1', '6', NULL, '4', NULL, 'routine', 'Main Counter', NULL, 'pending_payment', '2000.00', '0.00', '2000.00', '1', '2026-10-20 13:23:49', '2026-10-20 15:19:14');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('14', 'ORD-2026-00201', '2', '7', '1', NULL, NULL, 'routine', 'Branch Sample Booth', 'Uttara Hub Morning Lab Screening', 'completed', '3200.00', '0.00', '3200.00', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('15', 'ORD-2026-00202', '2', '8', '4', NULL, NULL, 'routine', 'Branch Sample Booth', 'Ultrasonography & Blood Work', 'ready_for_collection', '1800.00', '0.00', '1800.00', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('16', 'ORD-2026-00203', '2', '9', '5', NULL, NULL, 'routine', 'Branch Sample Booth', 'Serum Creatinine & Electrolytes', 'completed', '2500.00', '0.00', '2500.00', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('17', 'ORD-2026-00301', '3', '11', '2', NULL, NULL, 'routine', 'Branch Sample Booth', 'Cardiac Enzyme Panel & Lipid Profile', 'completed', '4500.00', '0.00', '4500.00', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('18', 'ORD-2026-00302', '3', '12', '7', NULL, NULL, 'routine', 'Branch Sample Booth', 'Liver Function & Viral Markers', 'processing', '2200.00', '0.00', '2200.00', '1', '2026-10-20 17:27:12', '2026-10-20 17:27:12');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('19', 'ORD-2026-00007', '1', '1', NULL, NULL, NULL, 'routine', 'Main Counter', NULL, 'pending_payment', '1000.00', '0.00', '1000.00', '1', '2026-10-21 12:24:28', '2026-10-21 12:24:28');
INSERT INTO `diagnostic_orders` (`id`, `order_no`, `branch_id`, `patient_id`, `doctor_id`, `referrer_id`, `corporate_client_id`, `urgency`, `collection_location`, `clinical_notes`, `status`, `total_amount`, `discount_amount`, `payable_amount`, `created_by`, `created_at`, `updated_at`) VALUES ('20', 'ORD-2026-00009', '1', '14', NULL, NULL, NULL, 'routine', 'Main Counter', NULL, 'pending_payment', '1000.00', '0.00', '1000.00', '1', '2026-10-21 14:46:41', '2026-10-21 14:46:41');

-- Table structure for table `diagnostic_tests`
DROP TABLE IF EXISTS `diagnostic_tests`;
CREATE TABLE `diagnostic_tests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `name` varchar(180) NOT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `category_id` bigint(20) unsigned DEFAULT NULL,
  `sample_type_id` bigint(20) unsigned DEFAULT NULL,
  `container_id` bigint(20) unsigned DEFAULT NULL,
  `methodology_id` bigint(20) unsigned DEFAULT NULL,
  `unit_id` bigint(20) unsigned DEFAULT NULL,
  `report_template_id` bigint(20) unsigned DEFAULT NULL,
  `turnaround_minutes` int(10) unsigned DEFAULT NULL,
  `price` decimal(15,2) DEFAULT 500.00,
  `normal_range` varchar(150) DEFAULT NULL,
  `sample_requirement` varchar(150) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `department_id` (`department_id`),
  KEY `sample_type_id` (`sample_type_id`),
  KEY `container_id` (`container_id`),
  KEY `methodology_id` (`methodology_id`),
  KEY `unit_id` (`unit_id`),
  KEY `report_template_id` (`report_template_id`),
  CONSTRAINT `diagnostic_tests_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `diagnostic_tests_ibfk_2` FOREIGN KEY (`sample_type_id`) REFERENCES `sample_types` (`id`),
  CONSTRAINT `diagnostic_tests_ibfk_3` FOREIGN KEY (`container_id`) REFERENCES `containers` (`id`),
  CONSTRAINT `diagnostic_tests_ibfk_4` FOREIGN KEY (`methodology_id`) REFERENCES `methodologies` (`id`),
  CONSTRAINT `diagnostic_tests_ibfk_5` FOREIGN KEY (`unit_id`) REFERENCES `measurement_units` (`id`),
  CONSTRAINT `diagnostic_tests_ibfk_6` FOREIGN KEY (`report_template_id`) REFERENCES `report_templates` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `diagnostic_tests`
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('1', 'BIO-001', 'Fasting Blood Sugar (FBS / Glucose)', '3', '1', NULL, NULL, NULL, NULL, NULL, '60', '200.00', '70.0 - 99.0 mg/dL', '8-10 Hours Overnight Fasting (Fluoride/Grey or Serum)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('2', 'BIO-002', 'Blood Sugar 2 Hours Post-Prandial (2HABF)', '3', '1', NULL, NULL, NULL, NULL, NULL, '60', '200.00', '< 140.0 mg/dL', '2 Hours after completion of standard meal', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('3', 'BIO-003', 'HbA1c (Glycated Hemoglobin) by HPLC', '3', '1', NULL, NULL, NULL, NULL, NULL, '120', '1000.00', '< 5.7 % (Normal), 5.7-6.4% (Pre-diabetic)', 'Whole Blood EDTA (Purple Top), Fasting not mandatory', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('4', 'BIO-004', 'Serum Creatinine with eGFR', '3', '1', NULL, NULL, NULL, NULL, NULL, '60', '350.00', '0.7 - 1.3 mg/dL (Male), 0.6 - 1.1 mg/dL (Female)', 'Serum (Yellow/Red Top)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('5', 'BIO-005', 'Lipid Profile Full Panel (Chol, Trig, HDL, LDL)', '3', '1', NULL, NULL, NULL, NULL, NULL, '120', '1200.00', 'Chol < 200, Trig < 150, HDL > 40, LDL < 100 mg/dL', '12 Hours Strict Overnight Fasting (Serum)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('6', 'BIO-006', 'Serum Uric Acid', '3', '1', NULL, NULL, NULL, NULL, NULL, '60', '400.00', '3.5 - 7.2 mg/dL', 'Serum (Red Top)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('7', 'BIO-007', 'Liver Function Test (LFT: SGPT, SGOT, Bilirubin, Alk Phos)', '3', '1', NULL, NULL, NULL, NULL, NULL, '120', '1400.00', 'SGPT: < 45 U/L, SGOT: < 35 U/L, Total Bilirubin: 0.2-1.2 mg/dL', 'Serum (Yellow Top Gel Separator)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('8', 'BIO-008', 'Serum Electrolytes (Na+, K+, Cl-) by ISE', '3', '1', NULL, NULL, NULL, NULL, NULL, '60', '800.00', 'Na: 136-145 mmol/L, K: 3.5-5.1 mmol/L, Cl: 98-107 mmol/L', 'Serum / Lithium Heparin Plasma', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('9', 'HEM-001', 'Complete Blood Count (CBC) with 5-Part Diff & ESR', '3', '2', NULL, NULL, NULL, NULL, NULL, '60', '450.00', 'Hb: 13.0-17.0 g/dL, WBC: 4.0-11.0 x10^9/L, Plt: 150-450 x10^9/L', 'Whole Blood EDTA (Purple Top)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('10', 'HEM-002', 'Peripheral Blood Film (PBF) Examination', '3', '2', NULL, NULL, NULL, NULL, NULL, '180', '500.00', 'Normocytic Normochromic Red Cells, Normal WBC & Platelets', 'Whole Blood EDTA + Fresh Blood Smears', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('11', 'HEM-003', 'Prothrombin Time with INR (PT/INR)', '3', '2', NULL, NULL, NULL, NULL, NULL, '90', '750.00', 'Control: 12.0s, INR: 0.9 - 1.15', 'Sodium Citrate 3.2% (Blue Top 9:1 blood ratio)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('12', 'HEM-004', 'Hemoglobin Electrophoresis (HPLC Method)', '3', '2', NULL, NULL, NULL, NULL, NULL, '360', '1800.00', 'HbA: 95.0-98.0%, HbA2: 2.0-3.5%, HbF: < 1.0%', 'Whole Blood EDTA (Purple Top)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('13', 'END-001', 'Thyroid Stimulating Hormone (TSH) Ultra-sensitive', '3', '3', NULL, NULL, NULL, NULL, NULL, '180', '700.00', '0.35 - 4.94 uIU/mL', 'Serum (Red Top) Morning Specimen', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('14', 'END-002', 'Free Thyroxine (FT4) Chemiluminescence', '3', '3', NULL, NULL, NULL, NULL, NULL, '180', '800.00', '0.70 - 1.48 ng/dL', 'Serum (Yellow Top Gel)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('15', 'END-003', 'Serum Fasting Insulin Level', '3', '3', NULL, NULL, NULL, NULL, NULL, '240', '1200.00', '2.6 - 24.9 uIU/mL', 'Overnight Fasting Serum (Red Top)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('16', 'END-004', '25-Hydroxy Vitamin D (Total D2 + D3)', '3', '3', NULL, NULL, NULL, NULL, NULL, '240', '2500.00', 'Deficient: < 20 ng/mL, Sufficient: 30 - 100 ng/mL', 'Serum (Yellow Top) Light Protected', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('17', 'END-005', 'Serum Vitamin B12 (Cyanocobalamin)', '3', '3', NULL, NULL, NULL, NULL, NULL, '240', '1800.00', '211 - 911 pg/mL', 'Serum (Yellow Top Gel)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('18', 'IMM-001', 'Hepatitis B Surface Antigen (HBsAg) Confirmatory', '3', '4', NULL, NULL, NULL, NULL, NULL, '120', '500.00', 'Negative / Non-reactive (< 0.90 S/CO)', 'Serum (Red Top)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('19', 'IMM-002', 'Anti-HCV Total Antibodies by CLIA', '3', '4', NULL, NULL, NULL, NULL, NULL, '120', '1000.00', 'Negative / Non-reactive', 'Serum (Red Top)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('20', 'IMM-003', 'Dengue NS1 Antigen & IgM/IgG Rapid Panel', '3', '4', NULL, NULL, NULL, NULL, NULL, '60', '800.00', 'Negative for NS1, IgM, IgG', 'Serum or Whole Blood EDTA', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('21', 'IMM-004', 'C-Reactive Protein (CRP) Quantitative High-Sensitivity', '3', '4', NULL, NULL, NULL, NULL, NULL, '90', '600.00', '< 5.0 mg/L (Normal)', 'Serum (Yellow Top Gel)', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('22', 'CLN-001', 'Urine Routine & Microscopic Examination (Urine R/M/E)', '3', '5', NULL, NULL, NULL, NULL, NULL, '45', '250.00', 'Pus Cells: 0-2/HPF, RBC: Nil, Albumin: Nil, Sugar: Nil', 'Clean Catch Midstream Morning Urine in Sterile Container', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('23', 'CLN-002', 'Urine for Microalbumin / Creatinine Ratio (ACR)', '3', '5', NULL, NULL, NULL, NULL, NULL, '120', '900.00', '< 30.0 mg/g creatinine (Normal)', 'Random Midstream Urine Container', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('24', 'CLN-003', 'Stool Routine & Occult Blood Test (OBT)', '3', '5', NULL, NULL, NULL, NULL, NULL, '60', '300.00', 'Occult Blood: Negative, Ova/Parasite: Not Seen', 'Fresh Stool Specimen in Leak-proof Cup', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('25', 'MIC-001', 'Urine Culture & Antibiotic Sensitivity (AST)', '3', '6', NULL, NULL, NULL, NULL, NULL, '2880', '1000.00', 'No Significant Bacterial Growth (< 10^4 CFU/mL)', 'Sterile Midstream Urine Cup, Prior to Antibiotics', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('26', 'MIC-002', 'Blood Culture & Automated Sensitivity (BACTEC)', '3', '6', NULL, NULL, NULL, NULL, NULL, '4320', '2200.00', 'Aerobic & Anaerobic No Growth after 5 Days', 'Paired Blood Culture Bottles under Aseptic Technique', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('27', 'HST-001', 'Histopathology - Small Biopsy / Punch / Endoscopy Specimen', '3', '7', NULL, NULL, NULL, NULL, NULL, '4320', '2500.00', 'Definitive Tissue Narrative & Margins', 'Tissue Specimen strictly preserved in 10% Neutral Buffered Formalin', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('28', 'HST-002', 'Cervical Cytology (Liquid Based Pap Smear)', '3', '7', NULL, NULL, NULL, NULL, NULL, '2880', '1500.00', 'NILM (Negative for Intraepithelial Lesion or Malignancy)', 'Endocervical Brush Specimen in Preservative Vial', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('29', 'MOL-001', 'HBV DNA Real-Time Quantitative PCR', '3', '8', NULL, NULL, NULL, NULL, NULL, '1440', '5500.00', 'Target Not Detected (< 10 IU/mL)', 'Plasma EDTA Frozen within 2 Hours', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `diagnostic_tests` (`id`, `code`, `name`, `department_id`, `category_id`, `sample_type_id`, `container_id`, `methodology_id`, `unit_id`, `report_template_id`, `turnaround_minutes`, `price`, `normal_range`, `sample_requirement`, `active`, `created_at`, `updated_at`) VALUES ('30', 'MOL-002', 'GeneXpert MTB/RIF for Mycobacterium Tuberculosis', '3', '8', NULL, NULL, NULL, NULL, NULL, '240', '3000.00', 'MTB Not Detected', 'Early Morning Sputum in Falcon Tube', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');

-- Table structure for table `discount_types`
DROP TABLE IF EXISTS `discount_types`;
CREATE TABLE `discount_types` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `doctor_schedules`
DROP TABLE IF EXISTS `doctor_schedules`;
CREATE TABLE `doctor_schedules` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `doctor_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `room_id` bigint(20) unsigned DEFAULT NULL,
  `day_of_week` enum('sun','mon','tue','wed','thu','fri','sat') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `slot_duration_minutes` smallint(5) unsigned NOT NULL DEFAULT 15,
  `max_slots` smallint(5) unsigned NOT NULL DEFAULT 20,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `doctor_id` (`doctor_id`),
  KEY `branch_id` (`branch_id`),
  KEY `room_id` (`room_id`),
  CONSTRAINT `doctor_schedules_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`),
  CONSTRAINT `doctor_schedules_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `doctor_schedules_ibfk_3` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `doctors`
DROP TABLE IF EXISTS `doctors`;
CREATE TABLE `doctors` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `mobile` varchar(25) DEFAULT NULL,
  `registration_no` varchar(80) DEFAULT NULL,
  `specialty` varchar(120) DEFAULT NULL,
  `consultation_fee` decimal(12,2) NOT NULL DEFAULT 1000.00,
  `profile_image` varchar(255) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `doctors`
INSERT INTO `doctors` (`id`, `code`, `name`, `mobile`, `registration_no`, `specialty`, `consultation_fee`, `profile_image`, `active`, `created_at`, `updated_at`) VALUES ('1', 'DOC-001', 'Prof. Dr. M. Rahman', '01711-223344', 'BMDC-A-28491', 'Diabetology & Endocrinology', '1000.00', '/assets/img/doctors/doc1.jpg', '1', '2026-10-10 17:53:29', '2026-10-21 12:02:05');
INSERT INTO `doctors` (`id`, `code`, `name`, `mobile`, `registration_no`, `specialty`, `consultation_fee`, `profile_image`, `active`, `created_at`, `updated_at`) VALUES ('2', 'DOC-002', 'Dr. Farhana Ahmed', '01819-334455', 'BMDC-A-34902', 'Cardiology & Vascular Medicine', '1000.00', '/assets/img/doctors/doc2.jpg', '1', '2026-10-10 17:53:29', '2026-10-21 12:02:05');
INSERT INTO `doctors` (`id`, `code`, `name`, `mobile`, `registration_no`, `specialty`, `consultation_fee`, `profile_image`, `active`, `created_at`, `updated_at`) VALUES ('3', 'DOC-003', 'Dr. Tanvir Hossain', '01912-445566', 'BMDC-A-41285', 'Clinical Pathology & Laboratory Medicine', '1000.00', '/assets/img/doctors/doc3.jpg', '1', '2026-10-10 17:53:29', '2026-10-21 12:02:05');
INSERT INTO `doctors` (`id`, `code`, `name`, `mobile`, `registration_no`, `specialty`, `consultation_fee`, `profile_image`, `active`, `created_at`, `updated_at`) VALUES ('4', 'DOC-004', 'Dr. Nusrat Jahan', '01715-556677', 'BMDC-A-39820', 'Radiology & Imaging Specialist', '1000.00', '/assets/img/doctors/doc4.jpg', '1', '2026-10-10 17:53:29', '2026-10-21 12:02:05');
INSERT INTO `doctors` (`id`, `code`, `name`, `mobile`, `registration_no`, `specialty`, `consultation_fee`, `profile_image`, `active`, `created_at`, `updated_at`) VALUES ('5', 'DOC-005', 'Dr. Mahfuzur Rahman', '01611-667788', 'BMDC-A-45910', 'Nephrology & Renal Medicine', '1000.00', '/assets/img/doctors/doc5.jpg', '1', '2026-10-10 17:53:29', '2026-10-21 12:02:05');
INSERT INTO `doctors` (`id`, `code`, `name`, `mobile`, `registration_no`, `specialty`, `consultation_fee`, `profile_image`, `active`, `created_at`, `updated_at`) VALUES ('6', 'DOC-006', 'Dr. Ayesha Siddiqua', '01511-778899', 'BMDC-A-48321', 'Internal & General Medicine', '1000.00', '/assets/img/doctors/doc6.jpg', '1', '2026-10-10 17:53:29', '2026-10-21 12:02:05');
INSERT INTO `doctors` (`id`, `code`, `name`, `mobile`, `registration_no`, `specialty`, `consultation_fee`, `profile_image`, `active`, `created_at`, `updated_at`) VALUES ('7', 'DOC-007', 'Dr. Tariqul Islam', '01720-889900', 'BMDC-A-50124', 'Gastroenterology & Hepatology', '1000.00', '/assets/img/doctors/doc7.jpg', '1', '2026-10-10 17:53:29', '2026-10-21 12:02:05');
INSERT INTO `doctors` (`id`, `code`, `name`, `mobile`, `registration_no`, `specialty`, `consultation_fee`, `profile_image`, `active`, `created_at`, `updated_at`) VALUES ('8', 'DOC-008', 'Dr. Shamima Akhter', '01822-990011', 'BMDC-A-52843', 'Obstetrics & Gynecology', '1000.00', '/assets/img/doctors/doc8.jpg', '1', '2026-10-10 17:53:29', '2026-10-21 12:02:05');
INSERT INTO `doctors` (`id`, `code`, `name`, `mobile`, `registration_no`, `specialty`, `consultation_fee`, `profile_image`, `active`, `created_at`, `updated_at`) VALUES ('9', 'DOC-009', 'Dr. Kamrul Ahsan', NULL, 'BMDC-A-59102', 'Pediatric Endocrinology & Metabolism', '1000.00', NULL, '1', '2026-10-20 18:04:55', '2026-10-20 18:04:55');

-- Table structure for table `employee_competencies`
DROP TABLE IF EXISTS `employee_competencies`;
CREATE TABLE `employee_competencies` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint(20) unsigned NOT NULL,
  `competency_title` varchar(180) NOT NULL,
  `category` enum('lab','radiology','quality') NOT NULL DEFAULT 'lab',
  `assessment_score` decimal(5,2) NOT NULL DEFAULT 100.00,
  `expiry_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `employee_competencies_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `hr_employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `employee_competencies`
INSERT INTO `employee_competencies` (`id`, `employee_id`, `competency_title`, `category`, `assessment_score`, `expiry_date`, `created_at`) VALUES ('1', '1', 'Histopathology & Cytopathology Biopsy Reporting Standards', 'lab', '99.50', '2027-12-31', '2026-10-20 11:27:02');
INSERT INTO `employee_competencies` (`id`, `employee_id`, `competency_title`, `category`, `assessment_score`, `expiry_date`, `created_at`) VALUES ('2', '2', 'High-Resolution 4D Ultrasonography & Doppler Evaluation', 'radiology', '98.00', '2027-10-31', '2026-10-20 11:27:02');
INSERT INTO `employee_competencies` (`id`, `employee_id`, `competency_title`, `category`, `assessment_score`, `expiry_date`, `created_at`) VALUES ('3', '3', 'Automated 5-Part Hematology Analyzer Calibration & Westgard Rules', 'lab', '100.00', '2026-11-30', '2026-10-20 11:27:02');
INSERT INTO `employee_competencies` (`id`, `employee_id`, `competency_title`, `category`, `assessment_score`, `expiry_date`, `created_at`) VALUES ('4', '4', 'ISO 15189 Internal Quality Auditing & Biosafety Protocol', 'quality', '96.00', '2027-06-30', '2026-10-20 11:27:02');
INSERT INTO `employee_competencies` (`id`, `employee_id`, `competency_title`, `category`, `assessment_score`, `expiry_date`, `created_at`) VALUES ('5', '5', 'Radiation Protection, ALARA Principle & Shielding Verification', 'radiology', '100.00', '2026-08-31', '2026-10-20 11:27:02');
INSERT INTO `employee_competencies` (`id`, `employee_id`, `competency_title`, `category`, `assessment_score`, `expiry_date`, `created_at`) VALUES ('6', '6', 'Cardiac Life Support (BLS/ACLS) & Emergency Resuscitation', 'quality', '95.00', '2028-04-30', '2026-10-20 11:27:02');
INSERT INTO `employee_competencies` (`id`, `employee_id`, `competency_title`, `category`, `assessment_score`, `expiry_date`, `created_at`) VALUES ('7', '10', 'Pediatric & Geriatric Venipuncture & Cold-Chain Specimen Handling', 'lab', '98.50', '2026-09-30', '2026-10-20 11:27:02');

-- Table structure for table `employee_rosters`
DROP TABLE IF EXISTS `employee_rosters`;
CREATE TABLE `employee_rosters` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `shift_date` date NOT NULL,
  `shift_name` enum('morning','evening','night') NOT NULL DEFAULT 'morning',
  `start_time` time NOT NULL DEFAULT '08:00:00',
  `end_time` time NOT NULL DEFAULT '16:00:00',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `employee_rosters_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `hr_employees` (`id`),
  CONSTRAINT `employee_rosters_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `employee_rosters`
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('1', '1', '1', '2026-10-17', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('2', '2', '1', '2026-10-17', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('3', '3', '1', '2026-10-17', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('4', '4', '1', '2026-10-17', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('5', '5', '1', '2026-10-17', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('6', '6', '1', '2026-10-17', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('7', '7', '1', '2026-10-17', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('8', '8', '1', '2026-10-17', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('9', '9', '1', '2026-10-17', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('10', '10', '1', '2026-10-17', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('11', '1', '1', '2026-10-18', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('12', '2', '1', '2026-10-18', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('13', '3', '1', '2026-10-18', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('14', '4', '1', '2026-10-18', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('15', '5', '1', '2026-10-18', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('16', '6', '1', '2026-10-18', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('17', '7', '1', '2026-10-18', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('18', '8', '1', '2026-10-18', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('19', '9', '1', '2026-10-18', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('20', '10', '1', '2026-10-18', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('21', '1', '1', '2026-10-19', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('22', '2', '1', '2026-10-19', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('23', '3', '1', '2026-10-19', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('24', '4', '1', '2026-10-19', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('25', '5', '1', '2026-10-19', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('26', '6', '1', '2026-10-19', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('27', '7', '1', '2026-10-19', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('28', '8', '1', '2026-10-19', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('29', '9', '1', '2026-10-19', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('30', '10', '1', '2026-10-19', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('31', '1', '1', '2026-10-20', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('32', '2', '1', '2026-10-20', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('33', '3', '1', '2026-10-20', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('34', '4', '1', '2026-10-20', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('35', '5', '1', '2026-10-20', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('36', '6', '1', '2026-10-20', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('37', '7', '1', '2026-10-20', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('38', '8', '1', '2026-10-20', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('39', '9', '1', '2026-10-20', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('40', '10', '1', '2026-10-20', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('41', '1', '1', '2026-10-21', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('42', '2', '1', '2026-10-21', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('43', '3', '1', '2026-10-21', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('44', '4', '1', '2026-10-21', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('45', '5', '1', '2026-10-21', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('46', '6', '1', '2026-10-21', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('47', '7', '1', '2026-10-21', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('48', '8', '1', '2026-10-21', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('49', '9', '1', '2026-10-21', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('50', '10', '1', '2026-10-21', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('51', '1', '1', '2026-10-22', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('52', '2', '1', '2026-10-22', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('53', '3', '1', '2026-10-22', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('54', '4', '1', '2026-10-22', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('55', '5', '1', '2026-10-22', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('56', '6', '1', '2026-10-22', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('57', '7', '1', '2026-10-22', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('58', '8', '1', '2026-10-22', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('59', '9', '1', '2026-10-22', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('60', '10', '1', '2026-10-22', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('61', '1', '1', '2026-10-23', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('62', '2', '1', '2026-10-23', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('63', '3', '1', '2026-10-23', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('64', '4', '1', '2026-10-23', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('65', '5', '1', '2026-10-23', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('66', '6', '1', '2026-10-23', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('67', '7', '1', '2026-10-23', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('68', '8', '1', '2026-10-23', 'evening', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('69', '9', '1', '2026-10-23', 'night', '08:00:00', '16:00:00', '2026-10-20 11:27:01');
INSERT INTO `employee_rosters` (`id`, `employee_id`, `branch_id`, `shift_date`, `shift_name`, `start_time`, `end_time`, `created_at`) VALUES ('70', '10', '1', '2026-10-23', 'morning', '08:00:00', '16:00:00', '2026-10-20 11:27:01');

-- Table structure for table `equipment_assets`
DROP TABLE IF EXISTS `equipment_assets`;
CREATE TABLE `equipment_assets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `asset_code` varchar(30) NOT NULL,
  `name` varchar(180) NOT NULL,
  `model_no` varchar(100) DEFAULT NULL,
  `serial_no` varchar(100) DEFAULT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `supplier_id` bigint(20) unsigned DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `warranty_expiry` date DEFAULT NULL,
  `status` enum('operational','under_maintenance','decommissioned') NOT NULL DEFAULT 'operational',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `asset_code` (`asset_code`),
  KEY `department_id` (`department_id`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `equipment_assets_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `equipment_assets_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `equipment_assets`
INSERT INTO `equipment_assets` (`id`, `asset_code`, `name`, `model_no`, `serial_no`, `department_id`, `supplier_id`, `purchase_date`, `warranty_expiry`, `status`, `created_at`) VALUES ('1', 'EQ-ROCHE-01', 'Roche Cobas C311 Fully Automated Clinical Chemistry Analyzer', 'Cobas C311', 'SN-C311-BD-8921', '3', '1', '2024-03-15', '2027-03-15', 'operational', '2026-10-20 15:18:21');
INSERT INTO `equipment_assets` (`id`, `asset_code`, `name`, `model_no`, `serial_no`, `department_id`, `supplier_id`, `purchase_date`, `warranty_expiry`, `status`, `created_at`) VALUES ('2', 'EQ-SYSMX-02', 'Sysmex XN-550 5-Part Automated Hematology Analyzer', 'XN-550', 'SN-XN550-BD-4420', '3', '2', '2024-06-20', '2027-06-20', 'operational', '2026-10-20 15:18:21');
INSERT INTO `equipment_assets` (`id`, `asset_code`, `name`, `model_no`, `serial_no`, `department_id`, `supplier_id`, `purchase_date`, `warranty_expiry`, `status`, `created_at`) VALUES ('3', 'EQ-SIEMS-03', 'Siemens Multix Impact Digital Floor-Mounted X-Ray System', 'Multix Impact DR', 'SN-SMX-DR-1092', '4', '3', '2023-11-10', '2026-11-10', 'operational', '2026-10-20 15:18:21');
INSERT INTO `equipment_assets` (`id`, `asset_code`, `name`, `model_no`, `serial_no`, `department_id`, `supplier_id`, `purchase_date`, `warranty_expiry`, `status`, `created_at`) VALUES ('4', 'EQ-GEUSG-04', 'GE Voluson E8 Expert 4D/HDlive Color Doppler Ultrasound', 'Voluson E8', 'SN-GE-VE8-7719', '4', '3', '2024-01-12', '2027-01-12', 'operational', '2026-10-20 15:18:21');
INSERT INTO `equipment_assets` (`id`, `asset_code`, `name`, `model_no`, `serial_no`, `department_id`, `supplier_id`, `purchase_date`, `warranty_expiry`, `status`, `created_at`) VALUES ('5', 'EQ-BIORD-05', 'Bio-Rad D-10 Hemoglobin HbA1c HPLC Testing System', 'D-10 HPLC', 'SN-BR-D10-3321', '3', '4', '2024-08-01', '2027-08-01', 'operational', '2026-10-20 15:18:21');
INSERT INTO `equipment_assets` (`id`, `asset_code`, `name`, `model_no`, `serial_no`, `department_id`, `supplier_id`, `purchase_date`, `warranty_expiry`, `status`, `created_at`) VALUES ('6', 'EQ-ELISA-06', 'Awareness Technology Stat Fax 4200 Microplate Reader', 'Stat Fax 4200', 'SN-SF-4200-9182', '3', '1', '2023-09-05', '2026-09-05', 'under_maintenance', '2026-10-20 15:18:21');

-- Table structure for table `equipment_maintenance_tickets`
DROP TABLE IF EXISTS `equipment_maintenance_tickets`;
CREATE TABLE `equipment_maintenance_tickets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_no` varchar(30) NOT NULL,
  `asset_id` bigint(20) unsigned NOT NULL,
  `maintenance_kind` enum('preventive','breakdown','calibration') NOT NULL DEFAULT 'breakdown',
  `priority` enum('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  `issue_description` text NOT NULL,
  `cost` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` enum('open','in_progress','resolved') NOT NULL DEFAULT 'open',
  `reported_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `ticket_no` (`ticket_no`),
  KEY `asset_id` (`asset_id`),
  KEY `reported_by` (`reported_by`),
  CONSTRAINT `equipment_maintenance_tickets_ibfk_1` FOREIGN KEY (`asset_id`) REFERENCES `equipment_assets` (`id`),
  CONSTRAINT `equipment_maintenance_tickets_ibfk_2` FOREIGN KEY (`reported_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `equipment_maintenance_tickets`
INSERT INTO `equipment_maintenance_tickets` (`id`, `ticket_no`, `asset_id`, `maintenance_kind`, `priority`, `issue_description`, `cost`, `status`, `reported_by`, `created_at`) VALUES ('1', 'TKT-2026-002', '1', 'preventive', 'medium', 'Quarterly routine preventive maintenance (PM) and probe fluidic wash cycle completed.', '8500.00', 'resolved', '1', '2026-10-20 15:18:21');
INSERT INTO `equipment_maintenance_tickets` (`id`, `ticket_no`, `asset_id`, `maintenance_kind`, `priority`, `issue_description`, `cost`, `status`, `reported_by`, `created_at`) VALUES ('2', 'TKT-2026-001', '6', 'breakdown', 'high', 'Optical photometer filter lamp alignment calibration error during ELISA assay run.', '12500.00', 'in_progress', '1', '2026-10-20 15:18:21');

-- Table structure for table `executive_kpi_snapshots`
DROP TABLE IF EXISTS `executive_kpi_snapshots`;
CREATE TABLE `executive_kpi_snapshots` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `snapshot_date` date NOT NULL,
  `daily_revenue` decimal(12,2) NOT NULL DEFAULT 0.00,
  `mtd_revenue` decimal(12,2) NOT NULL DEFAULT 0.00,
  `ytd_revenue` decimal(14,2) NOT NULL DEFAULT 0.00,
  `patient_count` int(10) unsigned NOT NULL DEFAULT 0,
  `test_count` int(10) unsigned NOT NULL DEFAULT 0,
  `avg_bill_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_discounts` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_refunds` decimal(12,2) NOT NULL DEFAULT 0.00,
  `pending_dues` decimal(12,2) NOT NULL DEFAULT 0.00,
  `critical_alerts_count` int(10) unsigned NOT NULL DEFAULT 0,
  `tat_breaches_count` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `snapshot_date` (`snapshot_date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `family_health_members`
DROP TABLE IF EXISTS `family_health_members`;
CREATE TABLE `family_health_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `primary_mobile` varchar(20) NOT NULL,
  `member_name` varchar(150) NOT NULL,
  `relation` varchar(50) NOT NULL DEFAULT 'Self',
  `uhid` varchar(50) DEFAULT NULL,
  `age` int(11) NOT NULL DEFAULT 30,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_mobile` (`primary_mobile`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `family_health_members`
INSERT INTO `family_health_members` (`id`, `primary_mobile`, `member_name`, `relation`, `uhid`, `age`, `created_at`) VALUES ('1', '01711000001', 'Mr. Jahangir Alam', 'Self', 'UHID-10001', '58', '2026-10-11 02:29:29');
INSERT INTO `family_health_members` (`id`, `primary_mobile`, `member_name`, `relation`, `uhid`, `age`, `created_at`) VALUES ('2', '01711000001', 'Nusrat Jahan (Daughter)', 'Child', 'UHID-10005', '14', '2026-10-11 02:29:29');
INSERT INTO `family_health_members` (`id`, `primary_mobile`, `member_name`, `relation`, `uhid`, `age`, `created_at`) VALUES ('3', '01711000001', 'Rehana Parvin (Wife)', 'Spouse', 'UHID-10006', '52', '2026-10-11 02:29:29');

-- Table structure for table `fiscal_periods`
DROP TABLE IF EXISTS `fiscal_periods`;
CREATE TABLE `fiscal_periods` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `period_name` varchar(30) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `is_closed` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `period_name` (`period_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `fixed_asset_register`
DROP TABLE IF EXISTS `fixed_asset_register`;
CREATE TABLE `fixed_asset_register` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `asset_code` varchar(30) NOT NULL,
  `name` varchar(180) NOT NULL,
  `account_id` bigint(20) unsigned NOT NULL,
  `purchase_cost` decimal(15,2) NOT NULL DEFAULT 0.00,
  `accumulated_depreciation` decimal(15,2) NOT NULL DEFAULT 0.00,
  `net_book_value` decimal(15,2) NOT NULL DEFAULT 0.00,
  `depreciation_method` enum('straight_line','reducing_balance') NOT NULL DEFAULT 'straight_line',
  `useful_life_years` int(10) unsigned NOT NULL DEFAULT 5,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `asset_code` (`asset_code`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `fixed_asset_register_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `chart_of_accounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `gl_entries`
DROP TABLE IF EXISTS `gl_entries`;
CREATE TABLE `gl_entries` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `voucher_id` bigint(20) unsigned NOT NULL,
  `account_id` bigint(20) unsigned NOT NULL,
  `cost_center_id` bigint(20) unsigned DEFAULT NULL,
  `debit` decimal(15,2) NOT NULL DEFAULT 0.00,
  `credit` decimal(15,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `voucher_id` (`voucher_id`),
  KEY `account_id` (`account_id`),
  KEY `cost_center_id` (`cost_center_id`),
  CONSTRAINT `gl_entries_ibfk_1` FOREIGN KEY (`voucher_id`) REFERENCES `gl_vouchers` (`id`),
  CONSTRAINT `gl_entries_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `chart_of_accounts` (`id`),
  CONSTRAINT `gl_entries_ibfk_3` FOREIGN KEY (`cost_center_id`) REFERENCES `cost_centers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `gl_entries`
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('1', '1', '7', NULL, '5000000.00', '0.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('2', '1', '22', NULL, '0.00', '5000000.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('3', '2', '1', NULL, '300000.00', '0.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('4', '2', '7', NULL, '0.00', '300000.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('5', '3', '12', NULL, '450000.00', '0.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('6', '3', '7', NULL, '0.00', '450000.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('7', '4', '1', NULL, '385000.00', '0.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('8', '4', '24', NULL, '0.00', '385000.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('9', '5', '1', NULL, '240000.00', '0.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('10', '5', '25', NULL, '0.00', '240000.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('11', '6', '29', NULL, '95000.00', '0.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('12', '6', '12', NULL, '0.00', '95000.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('13', '7', '32', NULL, '48000.00', '0.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('14', '7', '18', NULL, '0.00', '48000.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('15', '8', '18', NULL, '40000.00', '0.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('16', '8', '7', NULL, '0.00', '40000.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('17', '9', '34', NULL, '120000.00', '0.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('18', '9', '7', NULL, '0.00', '120000.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('19', '10', '35', NULL, '38000.00', '0.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('20', '10', '1', NULL, '0.00', '38000.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('21', '11', '33', NULL, '195000.00', '0.00');
INSERT INTO `gl_entries` (`id`, `voucher_id`, `account_id`, `cost_center_id`, `debit`, `credit`) VALUES ('22', '11', '7', NULL, '0.00', '195000.00');

-- Table structure for table `gl_vouchers`
DROP TABLE IF EXISTS `gl_vouchers`;
CREATE TABLE `gl_vouchers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `voucher_no` varchar(30) NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `voucher_type` enum('journal','receipt','payment','contra') NOT NULL DEFAULT 'journal',
  `voucher_date` date NOT NULL,
  `narration` text NOT NULL,
  `status` enum('draft','posted') NOT NULL DEFAULT 'draft',
  `created_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `voucher_no` (`voucher_no`),
  KEY `branch_id` (`branch_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `gl_vouchers_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `gl_vouchers_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `gl_vouchers`
INSERT INTO `gl_vouchers` (`id`, `voucher_no`, `branch_id`, `voucher_type`, `voucher_date`, `narration`, `status`, `created_by`, `created_at`) VALUES ('1', 'VCH-2026-00001', '1', 'receipt', '2026-10-01', 'Initial capital equity deposited by founders into Dutch-Bangla Corporate Account.', 'posted', '1', '2026-10-20 13:04:22');
INSERT INTO `gl_vouchers` (`id`, `voucher_no`, `branch_id`, `voucher_type`, `voucher_date`, `narration`, `status`, `created_by`, `created_at`) VALUES ('2', 'VCH-2026-00002', '1', 'contra', '2026-10-02', 'Cash withdrawal from DBBL Bank to fund Main Cash Vault & Reception Counters.', 'posted', '1', '2026-10-20 13:04:22');
INSERT INTO `gl_vouchers` (`id`, `voucher_no`, `branch_id`, `voucher_type`, `voucher_date`, `narration`, `status`, `created_by`, `created_at`) VALUES ('3', 'VCH-2026-00003', '1', 'payment', '2026-10-05', 'Procurement of Roche Cobas & Sysmex reagent kits from supplier via DBBL Bank transfer.', 'posted', '1', '2026-10-20 13:04:22');
INSERT INTO `gl_vouchers` (`id`, `voucher_no`, `branch_id`, `voucher_type`, `voucher_date`, `narration`, `status`, `created_by`, `created_at`) VALUES ('4', 'VCH-2026-00004', '1', 'receipt', '2026-10-10', 'Cash collection from outpatient clinical pathology and biochemistry lab test services.', 'posted', '1', '2026-10-20 13:04:22');
INSERT INTO `gl_vouchers` (`id`, `voucher_no`, `branch_id`, `voucher_type`, `voucher_date`, `narration`, `status`, `created_by`, `created_at`) VALUES ('5', 'VCH-2026-00005', '1', 'receipt', '2026-10-12', 'Revenue realized from Radiology & Ultrasound imaging services.', 'posted', '1', '2026-10-20 13:04:22');
INSERT INTO `gl_vouchers` (`id`, `voucher_no`, `branch_id`, `voucher_type`, `voucher_date`, `narration`, `status`, `created_by`, `created_at`) VALUES ('6', 'VCH-2026-00006', '1', 'journal', '2026-10-14', 'Recognition of pathology reagents consumed in diagnostic testing during the period.', 'posted', '1', '2026-10-20 13:04:22');
INSERT INTO `gl_vouchers` (`id`, `voucher_no`, `branch_id`, `voucher_type`, `voucher_date`, `narration`, `status`, `created_by`, `created_at`) VALUES ('7', 'VCH-2026-00007', '1', 'journal', '2026-10-15', 'Doctor referral commission accrual for outpatient diagnostic test recommendations.', 'posted', '1', '2026-10-20 13:04:22');
INSERT INTO `gl_vouchers` (`id`, `voucher_no`, `branch_id`, `voucher_type`, `voucher_date`, `narration`, `status`, `created_by`, `created_at`) VALUES ('8', 'VCH-2026-00008', '1', 'payment', '2026-10-16', 'Referral commission disbursement to consultant physicians via BRAC Bank.', 'posted', '1', '2026-10-20 13:04:22');
INSERT INTO `gl_vouchers` (`id`, `voucher_no`, `branch_id`, `voucher_type`, `voucher_date`, `narration`, `status`, `created_by`, `created_at`) VALUES ('9', 'VCH-2026-00009', '1', 'payment', '2026-10-17', 'Monthly facility lease rent payment for Farmgate Main Center Building.', 'posted', '1', '2026-10-20 13:04:22');
INSERT INTO `gl_vouchers` (`id`, `voucher_no`, `branch_id`, `voucher_type`, `voucher_date`, `narration`, `status`, `created_by`, `created_at`) VALUES ('10', 'VCH-2026-00010', '1', 'payment', '2026-10-18', 'Payment for DESCO electricity for cold chain reagent storage and automated analyzers.', 'posted', '1', '2026-10-20 13:04:22');
INSERT INTO `gl_vouchers` (`id`, `voucher_no`, `branch_id`, `voucher_type`, `voucher_date`, `narration`, `status`, `created_by`, `created_at`) VALUES ('11', 'VCH-2026-00011', '1', 'payment', '2026-10-19', 'Clinical laboratory staff, biochemists and phlebotomists monthly payroll disbursement.', 'posted', '1', '2026-10-20 13:04:22');

-- Table structure for table `goods_received_notes`
DROP TABLE IF EXISTS `goods_received_notes`;
CREATE TABLE `goods_received_notes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `grn_no` varchar(30) NOT NULL,
  `po_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `supplier_invoice_no` varchar(80) DEFAULT NULL,
  `received_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `grn_no` (`grn_no`),
  KEY `po_id` (`po_id`),
  KEY `branch_id` (`branch_id`),
  KEY `received_by` (`received_by`),
  CONSTRAINT `goods_received_notes_ibfk_1` FOREIGN KEY (`po_id`) REFERENCES `purchase_orders` (`id`),
  CONSTRAINT `goods_received_notes_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `goods_received_notes_ibfk_3` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `goods_received_notes`
INSERT INTO `goods_received_notes` (`id`, `grn_no`, `po_id`, `branch_id`, `supplier_invoice_no`, `received_by`, `created_at`) VALUES ('1', 'GRN-20261020-001', '1', '1', 'INV-C4CA4238', '1', '2026-10-20 14:54:04');
INSERT INTO `goods_received_notes` (`id`, `grn_no`, `po_id`, `branch_id`, `supplier_invoice_no`, `received_by`, `created_at`) VALUES ('2', 'GRN-20261020-002', '2', '1', 'INV-C81E728D', '1', '2026-10-20 14:54:04');
INSERT INTO `goods_received_notes` (`id`, `grn_no`, `po_id`, `branch_id`, `supplier_invoice_no`, `received_by`, `created_at`) VALUES ('3', 'GRN-20261020-004', '4', '1', 'INV-A87FF679', '1', '2026-10-20 14:54:05');

-- Table structure for table `home_collections`
DROP TABLE IF EXISTS `home_collections`;
CREATE TABLE `home_collections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `booking_no` varchar(30) NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `patient_category` varchar(50) DEFAULT 'doctor_prescribed',
  `branch_id` bigint(20) unsigned NOT NULL,
  `collector_id` bigint(20) unsigned DEFAULT NULL,
  `geo_zone` varchar(100) DEFAULT NULL,
  `address` text NOT NULL,
  `time_slot` varchar(50) NOT NULL,
  `travel_charge` decimal(10,2) NOT NULL DEFAULT 0.00,
  `tests_json` text DEFAULT NULL,
  `tests_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount_approved_by` varchar(150) DEFAULT NULL,
  `total_payable` decimal(12,2) NOT NULL DEFAULT 0.00,
  `paid_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `payment_method` varchar(50) DEFAULT 'CASH',
  `payment_status` varchar(50) DEFAULT 'paid',
  `status` enum('pending','assigned','collected','handed_over') NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_no` (`booking_no`),
  KEY `patient_id` (`patient_id`),
  KEY `branch_id` (`branch_id`),
  KEY `collector_id` (`collector_id`),
  CONSTRAINT `home_collections_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`),
  CONSTRAINT `home_collections_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `home_collections_ibfk_3` FOREIGN KEY (`collector_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `home_collections`
INSERT INTO `home_collections` (`id`, `booking_no`, `patient_id`, `patient_category`, `branch_id`, `collector_id`, `geo_zone`, `address`, `time_slot`, `travel_charge`, `tests_json`, `tests_amount`, `discount_amount`, `discount_approved_by`, `total_payable`, `paid_amount`, `payment_method`, `payment_status`, `status`, `created_at`, `updated_at`) VALUES ('1', 'HC-202610-001', '1', 'doctor_prescribed', '1', '1', 'Gulshan / Banani Zone', 'House 42, Road 11, Block D, Banani, Dhaka-1213 (Floor 4, Apt B4)', '07:00 AM - 09:00 AM', '300.00', NULL, '0.00', '0.00', NULL, '0.00', '0.00', 'CASH', 'paid', 'handed_over', '2026-10-18 06:45:00', '2026-10-20 16:11:11');
INSERT INTO `home_collections` (`id`, `booking_no`, `patient_id`, `patient_category`, `branch_id`, `collector_id`, `geo_zone`, `address`, `time_slot`, `travel_charge`, `tests_json`, `tests_amount`, `discount_amount`, `discount_approved_by`, `total_payable`, `paid_amount`, `payment_method`, `payment_status`, `status`, `created_at`, `updated_at`) VALUES ('2', 'HC-202610-002', '2', 'doctor_prescribed', '1', '1', 'Uttara Zone', 'House 18, Road 7, Sector 4, Uttara Model Town, Dhaka (Senior Citizen)', '07:30 AM - 09:30 AM', '450.00', NULL, '0.00', '0.00', NULL, '0.00', '0.00', 'CASH', 'paid', 'collected', '2026-10-19 07:15:00', '2026-10-20 16:11:11');
INSERT INTO `home_collections` (`id`, `booking_no`, `patient_id`, `patient_category`, `branch_id`, `collector_id`, `geo_zone`, `address`, `time_slot`, `travel_charge`, `tests_json`, `tests_amount`, `discount_amount`, `discount_approved_by`, `total_payable`, `paid_amount`, `payment_method`, `payment_status`, `status`, `created_at`, `updated_at`) VALUES ('3', 'HC-202610-003', '3', 'doctor_prescribed', '1', '1', 'Dhanmondi Zone', 'Flat 5A, Concord Tower, Road 27 (Old), Dhanmondi R/A, Dhaka', '09:00 AM - 11:00 AM', '350.00', NULL, '0.00', '0.00', NULL, '0.00', '0.00', 'CASH', 'paid', 'assigned', '2026-10-20 08:30:00', '2026-10-20 16:11:11');
INSERT INTO `home_collections` (`id`, `booking_no`, `patient_id`, `patient_category`, `branch_id`, `collector_id`, `geo_zone`, `address`, `time_slot`, `travel_charge`, `tests_json`, `tests_amount`, `discount_amount`, `discount_approved_by`, `total_payable`, `paid_amount`, `payment_method`, `payment_status`, `status`, `created_at`, `updated_at`) VALUES ('4', 'HC-202610-004', '4', 'doctor_prescribed', '1', NULL, 'Mirpur Zone', 'House 10, Road 3, Block C, Mirpur-2, Dhaka (Bedridden Diabetic Patient)', '04:00 PM - 06:00 PM', '400.00', NULL, '0.00', '0.00', NULL, '0.00', '0.00', 'CASH', 'paid', 'pending', '2026-10-20 10:15:00', '2026-10-20 16:11:11');
INSERT INTO `home_collections` (`id`, `booking_no`, `patient_id`, `patient_category`, `branch_id`, `collector_id`, `geo_zone`, `address`, `time_slot`, `travel_charge`, `tests_json`, `tests_amount`, `discount_amount`, `discount_approved_by`, `total_payable`, `paid_amount`, `payment_method`, `payment_status`, `status`, `created_at`, `updated_at`) VALUES ('5', 'HC-202610-005', '5', 'doctor_prescribed', '1', '1', 'Gulshan / Banani Zone', 'Apartment 7B, Lake View Residence, Road 71, Gulshan-2, Dhaka', '08:00 AM - 10:00 AM', '300.00', NULL, '0.00', '0.00', NULL, '0.00', '0.00', 'CASH', 'paid', 'collected', '2026-10-20 08:00:00', '2026-10-20 16:11:11');
INSERT INTO `home_collections` (`id`, `booking_no`, `patient_id`, `patient_category`, `branch_id`, `collector_id`, `geo_zone`, `address`, `time_slot`, `travel_charge`, `tests_json`, `tests_amount`, `discount_amount`, `discount_approved_by`, `total_payable`, `paid_amount`, `payment_method`, `payment_status`, `status`, `created_at`, `updated_at`) VALUES ('6', 'BAR-2026-00001', '1', 'doctor_prescribed', '1', NULL, 'Gulshan / Banani Zone', 'House 12, Road 5, Block B, Niketan, Gulshan, Dhaka', '07:00 AM - 09:00 AM', '300.00', NULL, '0.00', '0.00', NULL, '0.00', '0.00', 'CASH', 'paid', 'pending', '2026-10-21 15:58:54', '2026-10-21 15:58:54');
INSERT INTO `home_collections` (`id`, `booking_no`, `patient_id`, `patient_category`, `branch_id`, `collector_id`, `geo_zone`, `address`, `time_slot`, `travel_charge`, `tests_json`, `tests_amount`, `discount_amount`, `discount_approved_by`, `total_payable`, `paid_amount`, `payment_method`, `payment_status`, `status`, `created_at`, `updated_at`) VALUES ('7', 'BAR-2026-00002', '2', 'doctor_prescribed', '1', NULL, 'Gulshan / Banani Zone', 'House 12, Road 5, Block B, Niketan, Gulshan, Dhaka', '07:00 AM - 09:00 AM', '500.00', NULL, '0.00', '0.00', NULL, '0.00', '0.00', 'CASH', 'paid', 'pending', '2026-10-21 15:59:17', '2026-10-21 15:59:17');
INSERT INTO `home_collections` (`id`, `booking_no`, `patient_id`, `patient_category`, `branch_id`, `collector_id`, `geo_zone`, `address`, `time_slot`, `travel_charge`, `tests_json`, `tests_amount`, `discount_amount`, `discount_approved_by`, `total_payable`, `paid_amount`, `payment_method`, `payment_status`, `status`, `created_at`, `updated_at`) VALUES ('8', 'BAR-2026-00003', '2', 'doctor_prescribed', '1', NULL, 'Gulshan / Banani Zone', 'House 12, Road 5, Block B, Niketan, Gulshan, Dhaka', '07:00 AM - 09:00 AM', '300.00', NULL, '0.00', '0.00', NULL, '0.00', '0.00', 'CASH', 'paid', 'pending', '2026-10-21 15:59:43', '2026-10-21 15:59:43');
INSERT INTO `home_collections` (`id`, `booking_no`, `patient_id`, `patient_category`, `branch_id`, `collector_id`, `geo_zone`, `address`, `time_slot`, `travel_charge`, `tests_json`, `tests_amount`, `discount_amount`, `discount_approved_by`, `total_payable`, `paid_amount`, `payment_method`, `payment_status`, `status`, `created_at`, `updated_at`) VALUES ('9', 'BAR-2026-00004', '20', 'clinical_patient', '1', NULL, 'Gulshan / Banani Zone', 'House 44, Road 11, Banani, Dhaka', '07:00 AM - 09:00 AM', '300.00', '[{\"id\":1,\"code\":\"BIO-001\",\"name\":\"Fasting Blood Sugar (FBS \\/ Glucose)\",\"price\":200},{\"id\":2,\"code\":\"BIO-002\",\"name\":\"Blood Sugar 2 Hours Post-Prandial (2HABF)\",\"price\":200}]', '400.00', '50.00', 'Managing Director', '650.00', '650.00', 'BKASH', 'paid', 'pending', '2026-10-21 18:03:17', '2026-10-21 18:03:17');

-- Table structure for table `hr_attendance`
DROP TABLE IF EXISTS `hr_attendance`;
CREATE TABLE `hr_attendance` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL DEFAULT 1,
  `attendance_date` date NOT NULL,
  `clock_in` time NOT NULL,
  `clock_out` time DEFAULT NULL,
  `overtime_hours` decimal(4,2) NOT NULL DEFAULT 0.00,
  `status` enum('present','late','half_day','absent','on_leave') NOT NULL DEFAULT 'present',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_emp_date` (`employee_id`,`attendance_date`),
  KEY `idx_date` (`attendance_date`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `hr_attendance`
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('1', '1', '1', '2026-10-15', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('2', '2', '1', '2026-10-15', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('3', '3', '1', '2026-10-15', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('4', '4', '1', '2026-10-15', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('5', '5', '1', '2026-10-15', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('6', '6', '1', '2026-10-15', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('7', '7', '1', '2026-10-15', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('8', '8', '1', '2026-10-15', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('9', '9', '1', '2026-10-15', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('10', '10', '1', '2026-10-15', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('11', '1', '1', '2026-10-16', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('12', '2', '1', '2026-10-16', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('13', '3', '1', '2026-10-16', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('14', '4', '1', '2026-10-16', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('15', '5', '1', '2026-10-16', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('16', '6', '1', '2026-10-16', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('17', '7', '1', '2026-10-16', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('18', '8', '1', '2026-10-16', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('19', '9', '1', '2026-10-16', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('20', '10', '1', '2026-10-16', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('21', '1', '1', '2026-10-17', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('22', '2', '1', '2026-10-17', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('23', '3', '1', '2026-10-17', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('24', '4', '1', '2026-10-17', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('25', '5', '1', '2026-10-17', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('26', '6', '1', '2026-10-17', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('27', '7', '1', '2026-10-17', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('28', '8', '1', '2026-10-17', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('29', '9', '1', '2026-10-17', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('30', '10', '1', '2026-10-17', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('31', '1', '1', '2026-10-18', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('32', '2', '1', '2026-10-18', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('33', '3', '1', '2026-10-18', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('34', '4', '1', '2026-10-18', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('35', '5', '1', '2026-10-18', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('36', '6', '1', '2026-10-18', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('37', '7', '1', '2026-10-18', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('38', '8', '1', '2026-10-18', '07:55:00', '16:05:00', '0.00', 'on_leave', 'Pre-approved casual leave', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('39', '9', '1', '2026-10-18', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('40', '10', '1', '2026-10-18', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('41', '1', '1', '2026-10-19', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('42', '2', '1', '2026-10-19', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('43', '3', '1', '2026-10-19', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('44', '4', '1', '2026-10-19', '08:42:00', '16:05:00', '1.50', 'late', 'Traffic delay reported', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('45', '5', '1', '2026-10-19', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('46', '6', '1', '2026-10-19', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('47', '7', '1', '2026-10-19', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('48', '8', '1', '2026-10-19', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('49', '9', '1', '2026-10-19', '07:55:00', '16:05:00', '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('50', '10', '1', '2026-10-19', '07:55:00', '16:05:00', '1.50', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('51', '1', '1', '2026-10-20', '07:55:00', NULL, '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('52', '2', '1', '2026-10-20', '07:55:00', NULL, '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('53', '3', '1', '2026-10-20', '07:55:00', NULL, '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('54', '4', '1', '2026-10-20', '07:55:00', NULL, '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('55', '5', '1', '2026-10-20', '07:55:00', NULL, '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('56', '6', '1', '2026-10-20', '07:55:00', NULL, '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('57', '7', '1', '2026-10-20', '07:55:00', NULL, '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('58', '8', '1', '2026-10-20', '07:55:00', NULL, '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('59', '9', '1', '2026-10-20', '07:55:00', NULL, '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');
INSERT INTO `hr_attendance` (`id`, `employee_id`, `branch_id`, `attendance_date`, `clock_in`, `clock_out`, `overtime_hours`, `status`, `notes`, `created_at`) VALUES ('60', '10', '1', '2026-10-20', '07:55:00', NULL, '0.00', 'present', 'Normal shift', '2026-10-20 11:27:01');

-- Table structure for table `hr_candidates`
DROP TABLE IF EXISTS `hr_candidates`;
CREATE TABLE `hr_candidates` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `recruitment_id` bigint(20) unsigned NOT NULL,
  `name` varchar(150) NOT NULL,
  `mobile` varchar(25) NOT NULL,
  `email` varchar(190) DEFAULT NULL,
  `experience_years` int(11) NOT NULL DEFAULT 2,
  `expected_salary` decimal(12,2) DEFAULT NULL,
  `interview_date` date DEFAULT NULL,
  `status` enum('applied','shortlisted','interviewed','offered','rejected','hired') NOT NULL DEFAULT 'applied',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `hr_candidates`
INSERT INTO `hr_candidates` (`id`, `recruitment_id`, `name`, `mobile`, `email`, `experience_years`, `expected_salary`, `interview_date`, `status`, `notes`, `created_at`) VALUES ('1', '1', 'Tariqul Anam', '01755-123987', 'tariqul.bio@gmail.com', '4', '50000.00', '2026-10-22', 'shortlisted', 'Strong background in Roche Cobas analyzers', '2026-10-20 11:27:02');
INSERT INTO `hr_candidates` (`id`, `recruitment_id`, `name`, `mobile`, `email`, `experience_years`, `expected_salary`, `interview_date`, `status`, `notes`, `created_at`) VALUES ('2', '1', 'Mahmuda Begum', '01866-234876', 'mahmuda.lab@gmail.com', '3', '48000.00', '2026-10-23', 'applied', 'M.Sc in Biochemistry from DU', '2026-10-20 11:27:02');

-- Table structure for table `hr_employees`
DROP TABLE IF EXISTS `hr_employees`;
CREATE TABLE `hr_employees` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `employee_code` varchar(30) NOT NULL,
  `name` varchar(150) NOT NULL,
  `designation` varchar(100) NOT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `mobile` varchar(25) NOT NULL,
  `email` varchar(190) DEFAULT NULL,
  `license_no` varchar(80) DEFAULT NULL,
  `license_expiry` date DEFAULT NULL,
  `basic_salary` decimal(15,2) NOT NULL DEFAULT 35000.00,
  `joining_date` date NOT NULL,
  `status` enum('active','separated') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `employee_code` (`employee_code`),
  KEY `department_id` (`department_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `hr_employees_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `hr_employees_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `hr_employees`
INSERT INTO `hr_employees` (`id`, `employee_code`, `name`, `designation`, `department_id`, `user_id`, `mobile`, `email`, `license_no`, `license_expiry`, `basic_salary`, `joining_date`, `status`, `created_at`) VALUES ('1', 'EMP-1001', 'Dr. Ahsan Habib', 'Chief Medical Officer & Senior Pathologist', '1', NULL, '01711-234567', 'ahsan.habib@lutfunnesa.com', 'BMDC-A-41205', '2028-12-31', '95000.00', '2022-01-15', 'active', '2026-10-20 11:27:01');
INSERT INTO `hr_employees` (`id`, `employee_code`, `name`, `designation`, `department_id`, `user_id`, `mobile`, `email`, `license_no`, `license_expiry`, `basic_salary`, `joining_date`, `status`, `created_at`) VALUES ('2', 'EMP-1002', 'Dr. Farhana Sultana', 'Consultant Radiologist & Ultrasonologist', '2', NULL, '01819-345678', 'farhana.sultana@lutfunnesa.com', 'BMDC-A-56891', '2027-10-31', '85000.00', '2022-03-01', 'active', '2026-10-20 11:27:01');
INSERT INTO `hr_employees` (`id`, `employee_code`, `name`, `designation`, `department_id`, `user_id`, `mobile`, `email`, `license_no`, `license_expiry`, `basic_salary`, `joining_date`, `status`, `created_at`) VALUES ('3', 'EMP-1003', 'Md. Rafiqul Islam', 'Senior Lab Technologist & Biochemist', '1', NULL, '01912-456789', 'rafiq.lab@lutfunnesa.com', 'SMF-L-10294', '2026-11-30', '48000.00', '2022-06-10', 'active', '2026-10-20 11:27:01');
INSERT INTO `hr_employees` (`id`, `employee_code`, `name`, `designation`, `department_id`, `user_id`, `mobile`, `email`, `license_no`, `license_expiry`, `basic_salary`, `joining_date`, `status`, `created_at`) VALUES ('4', 'EMP-1004', 'Nusrat Jahan', 'Clinical Microbiologist & QC Officer', '1', NULL, '01723-567890', 'nusrat.micro@lutfunnesa.com', 'SMF-L-11842', '2027-05-15', '46000.00', '2023-01-10', 'active', '2026-10-20 11:27:01');
INSERT INTO `hr_employees` (`id`, `employee_code`, `name`, `designation`, `department_id`, `user_id`, `mobile`, `email`, `license_no`, `license_expiry`, `basic_salary`, `joining_date`, `status`, `created_at`) VALUES ('5', 'EMP-1005', 'Tanvir Ahmed', 'Senior Radiographer & CT Specialist', '2', NULL, '01611-678901', 'tanvir.xray@lutfunnesa.com', 'BAERA-R-8742', '2026-08-31', '44000.00', '2023-02-15', 'active', '2026-10-20 11:27:01');
INSERT INTO `hr_employees` (`id`, `employee_code`, `name`, `designation`, `department_id`, `user_id`, `mobile`, `email`, `license_no`, `license_expiry`, `basic_salary`, `joining_date`, `status`, `created_at`) VALUES ('6', 'EMP-1006', 'Sharmin Akter', 'Head Nurse & Chamber Supervisor', '3', NULL, '01511-789012', 'sharmin.nurse@lutfunnesa.com', 'BNC-N-34190', '2028-04-20', '38000.00', '2023-05-01', 'active', '2026-10-20 11:27:01');
INSERT INTO `hr_employees` (`id`, `employee_code`, `name`, `designation`, `department_id`, `user_id`, `mobile`, `email`, `license_no`, `license_expiry`, `basic_salary`, `joining_date`, `status`, `created_at`) VALUES ('7', 'EMP-1007', 'Kamrul Hassan', 'Head Pharmacist & Drug Store Manager', '1', NULL, '01733-890123', 'kamrul.pharma@lutfunnesa.com', 'PCB-P-22419', '2027-09-30', '42000.00', '2023-07-15', 'active', '2026-10-20 11:27:01');
INSERT INTO `hr_employees` (`id`, `employee_code`, `name`, `designation`, `department_id`, `user_id`, `mobile`, `email`, `license_no`, `license_expiry`, `basic_salary`, `joining_date`, `status`, `created_at`) VALUES ('8', 'EMP-1008', 'Sabrina Rahman', 'Front Desk Officer & Patient Receptionist', '1', NULL, '01822-901234', 'sabrina.reception@lutfunnesa.com', NULL, NULL, '28000.00', '2023-09-01', 'active', '2026-10-20 11:27:01');
INSERT INTO `hr_employees` (`id`, `employee_code`, `name`, `designation`, `department_id`, `user_id`, `mobile`, `email`, `license_no`, `license_expiry`, `basic_salary`, `joining_date`, `status`, `created_at`) VALUES ('9', 'EMP-1009', 'Jahangir Alam', 'Senior Cashier & Billing Executive', '1', NULL, '01933-012345', 'jahangir.billing@lutfunnesa.com', NULL, NULL, '30000.00', '2023-11-01', 'active', '2026-10-20 11:27:01');
INSERT INTO `hr_employees` (`id`, `employee_code`, `name`, `designation`, `department_id`, `user_id`, `mobile`, `email`, `license_no`, `license_expiry`, `basic_salary`, `joining_date`, `status`, `created_at`) VALUES ('10', 'EMP-1010', 'Belal Hossain', 'Phlebotomist & Sample Collector', '1', NULL, '01622-123456', 'belal.phlebo@lutfunnesa.com', 'SMF-P-55102', '2026-09-15', '26000.00', '2024-01-15', 'active', '2026-10-20 11:27:01');

-- Table structure for table `hr_recruitment`
DROP TABLE IF EXISTS `hr_recruitment`;
CREATE TABLE `hr_recruitment` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `job_title` varchar(150) NOT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `vacancy_count` int(11) NOT NULL DEFAULT 1,
  `experience_required` varchar(80) NOT NULL DEFAULT '2+ Years',
  `job_type` enum('full_time','part_time','visiting','contract') NOT NULL DEFAULT 'full_time',
  `status` enum('open','closed','draft','interviewing') NOT NULL DEFAULT 'open',
  `salary_range` varchar(80) NOT NULL DEFAULT '35,000 - 60,000 BDT',
  `deadline` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `hr_recruitment`
INSERT INTO `hr_recruitment` (`id`, `job_title`, `department_id`, `vacancy_count`, `experience_required`, `job_type`, `status`, `salary_range`, `deadline`, `created_at`) VALUES ('1', 'Senior Clinical Biochemist', '1', '1', '3-5 Years in Accredited Lab', 'full_time', 'interviewing', '45,000 - 55,000 BDT', '2026-11-04', '2026-10-20 11:27:02');
INSERT INTO `hr_recruitment` (`id`, `job_title`, `department_id`, `vacancy_count`, `experience_required`, `job_type`, `status`, `salary_range`, `deadline`, `created_at`) VALUES ('2', 'Consultant Sonologist (Part-Time)', '2', '2', 'MBBS, PGT/DMU with 2+ Years Exp', 'part_time', 'open', '60,000 - 80,000 BDT', '2026-11-09', '2026-10-20 11:27:02');
INSERT INTO `hr_recruitment` (`id`, `job_title`, `department_id`, `vacancy_count`, `experience_required`, `job_type`, `status`, `salary_range`, `deadline`, `created_at`) VALUES ('3', 'Night Duty Phlebotomist', '1', '2', 'Diploma in Medical Tech (Lab)', 'full_time', 'open', '25,000 - 30,000 BDT', '2026-10-30', '2026-10-20 11:27:02');

-- Table structure for table `integration_webhooks`
DROP TABLE IF EXISTS `integration_webhooks`;
CREATE TABLE `integration_webhooks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_type` varchar(60) NOT NULL,
  `idempotency_key` varchar(100) NOT NULL,
  `payload_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`payload_json`)),
  `target_url` varchar(255) NOT NULL,
  `status` enum('pending','sent','failed') NOT NULL DEFAULT 'pending',
  `http_code` int(11) DEFAULT NULL,
  `response_body` text DEFAULT NULL,
  `retry_count` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idempotency_key` (`idempotency_key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `inventory_batches`
DROP TABLE IF EXISTS `inventory_batches`;
CREATE TABLE `inventory_batches` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `item_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `batch_no` varchar(50) NOT NULL,
  `lot_no` varchar(50) DEFAULT NULL,
  `expiry_date` date NOT NULL,
  `quantity_on_hand` decimal(10,2) NOT NULL DEFAULT 0.00,
  `unit_cost` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `item_id` (`item_id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `inventory_batches_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`),
  CONSTRAINT `inventory_batches_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `inventory_batches`
INSERT INTO `inventory_batches` (`id`, `item_id`, `branch_id`, `batch_no`, `lot_no`, `expiry_date`, `quantity_on_hand`, `unit_cost`, `created_at`) VALUES ('1', '1', '1', 'LOT-2026-CB11', 'RO-99120', '2026-11-15', '45.00', '12500.00', '2026-10-20 15:18:21');
INSERT INTO `inventory_batches` (`id`, `item_id`, `branch_id`, `batch_no`, `lot_no`, `expiry_date`, `quantity_on_hand`, `unit_cost`, `created_at`) VALUES ('2', '2', '1', 'LOT-2026-SX55', 'SY-88231', '2026-12-30', '80.00', '4800.00', '2026-10-20 15:18:21');
INSERT INTO `inventory_batches` (`id`, `item_id`, `branch_id`, `batch_no`, `lot_no`, `expiry_date`, `quantity_on_hand`, `unit_cost`, `created_at`) VALUES ('3', '3', '1', 'LOT-2026-QC03', 'BR-77342', '2027-02-28', '24.00', '8900.00', '2026-10-20 15:18:21');
INSERT INTO `inventory_batches` (`id`, `item_id`, `branch_id`, `batch_no`, `lot_no`, `expiry_date`, `quantity_on_hand`, `unit_cost`, `created_at`) VALUES ('4', '4', '1', 'LOT-2026-BD04', 'BD-66453', '2027-06-30', '150.00', '1400.00', '2026-10-20 15:18:21');
INSERT INTO `inventory_batches` (`id`, `item_id`, `branch_id`, `batch_no`, `lot_no`, `expiry_date`, `quantity_on_hand`, `unit_cost`, `created_at`) VALUES ('5', '5', '1', 'LOT-2026-GL05', 'HT-55564', '2028-01-31', '200.00', '650.00', '2026-10-20 15:18:21');
INSERT INTO `inventory_batches` (`id`, `item_id`, `branch_id`, `batch_no`, `lot_no`, `expiry_date`, `quantity_on_hand`, `unit_cost`, `created_at`) VALUES ('6', '6', '1', 'LOT-2026-GLU6', 'BX-44675', '2026-11-30', '60.00', '3200.00', '2026-10-20 15:18:21');

-- Table structure for table `inventory_items`
DROP TABLE IF EXISTS `inventory_items`;
CREATE TABLE `inventory_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `name` varchar(180) NOT NULL,
  `category` enum('reagent','consumable','spare_part','other') NOT NULL DEFAULT 'reagent',
  `unit_name` varchar(50) NOT NULL DEFAULT 'pcs',
  `manufacturer` varchar(150) DEFAULT NULL,
  `min_reorder_level` decimal(10,2) NOT NULL DEFAULT 10.00,
  `storage_condition` varchar(100) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `inventory_items`
INSERT INTO `inventory_items` (`id`, `code`, `name`, `category`, `unit_name`, `manufacturer`, `min_reorder_level`, `storage_condition`, `active`, `created_at`) VALUES ('1', 'RGT-COB-01', 'Roche Cobas C311 Clinical Chemistry Reagent Pack', 'reagent', 'Kits', 'Roche Diagnostics', '10.00', '2°C - 8°C Cold Chain', '1', '2026-10-20 15:18:21');
INSERT INTO `inventory_items` (`id`, `code`, `name`, `category`, `unit_name`, `manufacturer`, `min_reorder_level`, `storage_condition`, `active`, `created_at`) VALUES ('2', 'RGT-SYS-02', 'Sysmex Cellpack DCL Diluent & Lyse Reagent', 'reagent', 'Packs', 'Sysmex Corporation', '15.00', '15°C - 25°C Room Temp', '1', '2026-10-20 15:18:21');
INSERT INTO `inventory_items` (`id`, `code`, `name`, `category`, `unit_name`, `manufacturer`, `min_reorder_level`, `storage_condition`, `active`, `created_at`) VALUES ('3', 'RGT-BRD-03', 'Bio-Rad Lyphochek Immunoassay Control Tri-Level', 'reagent', 'Vials', 'Bio-Rad Laboratories', '8.00', '-20°C Deep Freeze', '1', '2026-10-20 15:18:21');
INSERT INTO `inventory_items` (`id`, `code`, `name`, `category`, `unit_name`, `manufacturer`, `min_reorder_level`, `storage_condition`, `active`, `created_at`) VALUES ('4', 'CSM-BDV-04', 'BD Vacutainer K2-EDTA 3ml Blood Collection Tubes', 'consumable', 'Boxes (100 pcs)', 'Becton Dickinson', '25.00', 'Ambient / Dry', '1', '2026-10-20 15:18:21');
INSERT INTO `inventory_items` (`id`, `code`, `name`, `category`, `unit_name`, `manufacturer`, `min_reorder_level`, `storage_condition`, `active`, `created_at`) VALUES ('5', 'CSM-GLV-05', 'Medical Grade Powder-Free Nitrile Examination Gloves (M)', 'consumable', 'Boxes (100 pcs)', 'Hartalega Medical', '30.00', 'Cool & Dry', '1', '2026-10-20 15:18:21');
INSERT INTO `inventory_items` (`id`, `code`, `name`, `category`, `unit_name`, `manufacturer`, `min_reorder_level`, `storage_condition`, `active`, `created_at`) VALUES ('6', 'RGT-BIO-06', 'Biorex Glucose GOD-PAP Enzymatic Assay Reagent Kit', 'reagent', 'Kits', 'Biorex Diagnostics', '12.00', '2°C - 8°C Cold Chain', '1', '2026-10-20 15:18:21');

-- Table structure for table `inventory_transfers`
DROP TABLE IF EXISTS `inventory_transfers`;
CREATE TABLE `inventory_transfers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `transfer_no` varchar(30) NOT NULL,
  `from_branch_id` bigint(20) unsigned NOT NULL,
  `to_branch_id` bigint(20) unsigned NOT NULL,
  `item_id` bigint(20) unsigned NOT NULL,
  `quantity` decimal(10,2) NOT NULL DEFAULT 1.00,
  `status` enum('pending','in_transit','received') NOT NULL DEFAULT 'pending',
  `requested_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `transfer_no` (`transfer_no`),
  KEY `from_branch_id` (`from_branch_id`),
  KEY `to_branch_id` (`to_branch_id`),
  KEY `item_id` (`item_id`),
  KEY `requested_by` (`requested_by`),
  CONSTRAINT `inventory_transfers_ibfk_1` FOREIGN KEY (`from_branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `inventory_transfers_ibfk_2` FOREIGN KEY (`to_branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `inventory_transfers_ibfk_3` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`),
  CONSTRAINT `inventory_transfers_ibfk_4` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `inventory_transfers`
INSERT INTO `inventory_transfers` (`id`, `transfer_no`, `from_branch_id`, `to_branch_id`, `item_id`, `quantity`, `status`, `requested_by`, `created_at`) VALUES ('1', 'TRF-2026-001', '1', '2', '1', '10.00', 'received', '1', '2026-10-18 15:19:14');
INSERT INTO `inventory_transfers` (`id`, `transfer_no`, `from_branch_id`, `to_branch_id`, `item_id`, `quantity`, `status`, `requested_by`, `created_at`) VALUES ('2', 'TRF-2026-002', '1', '2', '2', '15.00', 'in_transit', '1', '2026-10-18 15:19:14');
INSERT INTO `inventory_transfers` (`id`, `transfer_no`, `from_branch_id`, `to_branch_id`, `item_id`, `quantity`, `status`, `requested_by`, `created_at`) VALUES ('3', 'TRF-2026-003', '1', '3', '4', '30.00', 'pending', '1', '2026-10-18 15:19:14');
INSERT INTO `inventory_transfers` (`id`, `transfer_no`, `from_branch_id`, `to_branch_id`, `item_id`, `quantity`, `status`, `requested_by`, `created_at`) VALUES ('4', 'TRF-2026-004', '1', '3', '5', '25.00', 'received', '1', '2026-10-18 15:19:14');

-- Table structure for table `invoices`
DROP TABLE IF EXISTS `invoices`;
CREATE TABLE `invoices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `invoice_no` varchar(30) NOT NULL,
  `order_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `total_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `payable_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `paid_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `due_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `status` enum('unpaid','partially_paid','paid','refunded') NOT NULL DEFAULT 'unpaid',
  `created_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_no` (`invoice_no`),
  KEY `order_id` (`order_id`),
  KEY `branch_id` (`branch_id`),
  KEY `patient_id` (`patient_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `diagnostic_orders` (`id`),
  CONSTRAINT `invoices_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `invoices_ibfk_3` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`),
  CONSTRAINT `invoices_ibfk_4` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `invoices`
INSERT INTO `invoices` (`id`, `invoice_no`, `order_id`, `branch_id`, `patient_id`, `total_amount`, `discount_amount`, `payable_amount`, `paid_amount`, `due_amount`, `status`, `created_by`, `created_at`, `updated_at`) VALUES ('1', 'INV-2026-00001', '5', '1', '5', '2500.00', '0.00', '2500.00', '0.00', '2500.00', 'unpaid', '1', '2026-10-11 12:34:14', '2026-10-11 12:34:14');
INSERT INTO `invoices` (`id`, `invoice_no`, `order_id`, `branch_id`, `patient_id`, `total_amount`, `discount_amount`, `payable_amount`, `paid_amount`, `due_amount`, `status`, `created_by`, `created_at`, `updated_at`) VALUES ('2', 'INV-2026-00002', '4', '1', '4', '2500.00', '0.00', '2500.00', '0.00', '2500.00', 'unpaid', '1', '2026-10-11 12:38:09', '2026-10-11 12:38:09');
INSERT INTO `invoices` (`id`, `invoice_no`, `order_id`, `branch_id`, `patient_id`, `total_amount`, `discount_amount`, `payable_amount`, `paid_amount`, `due_amount`, `status`, `created_by`, `created_at`, `updated_at`) VALUES ('3', 'INV-2026-00003', '3', '1', '3', '2500.00', '0.00', '2500.00', '0.00', '2500.00', 'unpaid', '1', '2026-10-11 13:10:51', '2026-10-11 13:10:51');
INSERT INTO `invoices` (`id`, `invoice_no`, `order_id`, `branch_id`, `patient_id`, `total_amount`, `discount_amount`, `payable_amount`, `paid_amount`, `due_amount`, `status`, `created_by`, `created_at`, `updated_at`) VALUES ('4', 'INV-2026-00004', '2', '1', '2', '2500.00', '0.00', '2500.00', '0.00', '2500.00', 'unpaid', '1', '2026-10-11 14:30:39', '2026-10-11 14:30:39');
INSERT INTO `invoices` (`id`, `invoice_no`, `order_id`, `branch_id`, `patient_id`, `total_amount`, `discount_amount`, `payable_amount`, `paid_amount`, `due_amount`, `status`, `created_by`, `created_at`, `updated_at`) VALUES ('5', 'INV-2026-00005', '7', '1', '4', '1000.00', '500.00', '500.00', '0.00', '500.00', 'unpaid', '1', '2026-10-11 15:44:13', '2026-10-11 15:44:13');
INSERT INTO `invoices` (`id`, `invoice_no`, `order_id`, `branch_id`, `patient_id`, `total_amount`, `discount_amount`, `payable_amount`, `paid_amount`, `due_amount`, `status`, `created_by`, `created_at`, `updated_at`) VALUES ('6', 'INV-2026-00006', '6', '1', '5', '1000.00', '500.00', '500.00', '0.00', '500.00', 'unpaid', '1', '2026-10-11 15:46:45', '2026-10-11 15:46:45');
INSERT INTO `invoices` (`id`, `invoice_no`, `order_id`, `branch_id`, `patient_id`, `total_amount`, `discount_amount`, `payable_amount`, `paid_amount`, `due_amount`, `status`, `created_by`, `created_at`, `updated_at`) VALUES ('7', 'INV-2026-00007', '8', '1', '6', '1000.00', '0.00', '1000.00', '1000.00', '0.00', 'paid', '1', '2026-10-11 15:57:53', '2026-10-11 17:14:04');
INSERT INTO `invoices` (`id`, `invoice_no`, `order_id`, `branch_id`, `patient_id`, `total_amount`, `discount_amount`, `payable_amount`, `paid_amount`, `due_amount`, `status`, `created_by`, `created_at`, `updated_at`) VALUES ('8', 'INV-2026-00008', '1', '1', '1', '2500.00', '0.00', '2500.00', '2500.00', '0.00', 'paid', '1', '2026-10-11 16:19:48', '2026-10-11 16:20:09');
INSERT INTO `invoices` (`id`, `invoice_no`, `order_id`, `branch_id`, `patient_id`, `total_amount`, `discount_amount`, `payable_amount`, `paid_amount`, `due_amount`, `status`, `created_by`, `created_at`, `updated_at`) VALUES ('9', 'INV-2026-00009', '12', '1', '6', '4500.00', '500.00', '4000.00', '0.00', '4000.00', 'unpaid', '1', '2026-10-20 11:34:14', '2026-10-20 11:34:14');
INSERT INTO `invoices` (`id`, `invoice_no`, `order_id`, `branch_id`, `patient_id`, `total_amount`, `discount_amount`, `payable_amount`, `paid_amount`, `due_amount`, `status`, `created_by`, `created_at`, `updated_at`) VALUES ('10', 'INV-2026-00010', '11', '1', '6', '2800.00', '200.00', '2600.00', '0.00', '2600.00', 'unpaid', '1', '2026-10-20 12:09:30', '2026-10-20 12:09:30');

-- Table structure for table `lab_reports`
DROP TABLE IF EXISTS `lab_reports`;
CREATE TABLE `lab_reports` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `report_no` varchar(30) NOT NULL,
  `order_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `status` enum('draft','approved','amended') NOT NULL DEFAULT 'draft',
  `approved_by` bigint(20) unsigned DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `version` smallint(5) unsigned NOT NULL DEFAULT 1,
  `pdf_watermark` enum('draft','final','corrected') NOT NULL DEFAULT 'draft',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_no` (`report_no`),
  KEY `order_id` (`order_id`),
  KEY `branch_id` (`branch_id`),
  KEY `patient_id` (`patient_id`),
  KEY `approved_by` (`approved_by`),
  CONSTRAINT `lab_reports_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `diagnostic_orders` (`id`),
  CONSTRAINT `lab_reports_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `lab_reports_ibfk_3` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`),
  CONSTRAINT `lab_reports_ibfk_4` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `lab_reports`
INSERT INTO `lab_reports` (`id`, `report_no`, `order_id`, `branch_id`, `patient_id`, `status`, `approved_by`, `approved_at`, `version`, `pdf_watermark`, `created_at`) VALUES ('1', 'REP-2026-00841', '1', '1', '1', 'approved', '1', '2026-10-10 18:31:34', '1', 'final', '2026-10-05 18:31:34');
INSERT INTO `lab_reports` (`id`, `report_no`, `order_id`, `branch_id`, `patient_id`, `status`, `approved_by`, `approved_at`, `version`, `pdf_watermark`, `created_at`) VALUES ('2', 'REP-2026-00842', '2', '1', '2', 'approved', '1', '2026-10-10 18:31:34', '1', 'final', '2026-10-06 18:31:34');
INSERT INTO `lab_reports` (`id`, `report_no`, `order_id`, `branch_id`, `patient_id`, `status`, `approved_by`, `approved_at`, `version`, `pdf_watermark`, `created_at`) VALUES ('3', 'REP-2026-00843', '3', '1', '3', 'approved', '1', '2026-10-10 18:31:34', '1', 'final', '2026-10-07 18:31:34');
INSERT INTO `lab_reports` (`id`, `report_no`, `order_id`, `branch_id`, `patient_id`, `status`, `approved_by`, `approved_at`, `version`, `pdf_watermark`, `created_at`) VALUES ('4', 'REP-2026-00844', '4', '1', '4', 'approved', '1', '2026-10-10 18:31:34', '1', 'final', '2026-10-08 18:31:34');
INSERT INTO `lab_reports` (`id`, `report_no`, `order_id`, `branch_id`, `patient_id`, `status`, `approved_by`, `approved_at`, `version`, `pdf_watermark`, `created_at`) VALUES ('5', 'REP-2026-00845', '5', '1', '5', 'draft', '1', '2026-10-10 18:31:34', '1', 'draft', '2026-10-09 18:31:34');
INSERT INTO `lab_reports` (`id`, `report_no`, `order_id`, `branch_id`, `patient_id`, `status`, `approved_by`, `approved_at`, `version`, `pdf_watermark`, `created_at`) VALUES ('6', 'REP-2026-00001', '5', '1', '5', 'approved', '1', '2026-10-11 11:08:36', '1', 'final', '2026-10-11 11:08:36');
INSERT INTO `lab_reports` (`id`, `report_no`, `order_id`, `branch_id`, `patient_id`, `status`, `approved_by`, `approved_at`, `version`, `pdf_watermark`, `created_at`) VALUES ('7', 'REP-2026-00002', '5', '1', '5', 'approved', '1', '2026-10-11 17:31:08', '1', 'final', '2026-10-11 17:31:08');
INSERT INTO `lab_reports` (`id`, `report_no`, `order_id`, `branch_id`, `patient_id`, `status`, `approved_by`, `approved_at`, `version`, `pdf_watermark`, `created_at`) VALUES ('8', 'REP-2026-00003', '8', '1', '6', 'approved', '1', '2026-10-11 18:33:02', '1', 'final', '2026-10-11 18:33:02');
INSERT INTO `lab_reports` (`id`, `report_no`, `order_id`, `branch_id`, `patient_id`, `status`, `approved_by`, `approved_at`, `version`, `pdf_watermark`, `created_at`) VALUES ('9', 'REP-2026-00004', '7', '1', '4', 'approved', '1', '2026-10-11 18:36:24', '1', 'final', '2026-10-11 18:36:24');

-- Table structure for table `lab_results`
DROP TABLE IF EXISTS `lab_results`;
CREATE TABLE `lab_results` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) unsigned NOT NULL,
  `order_item_id` bigint(20) unsigned NOT NULL,
  `test_id` bigint(20) unsigned NOT NULL,
  `result_value` varchar(255) DEFAULT NULL,
  `result_flag` enum('normal','high','low','critical') NOT NULL DEFAULT 'normal',
  `reference_range_text` varchar(150) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `entered_by` bigint(20) unsigned NOT NULL,
  `entered_at` datetime NOT NULL DEFAULT current_timestamp(),
  `verified_by` bigint(20) unsigned DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `status` enum('draft','verified','approved') NOT NULL DEFAULT 'draft',
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `order_item_id` (`order_item_id`),
  KEY `test_id` (`test_id`),
  KEY `entered_by` (`entered_by`),
  KEY `verified_by` (`verified_by`),
  CONSTRAINT `lab_results_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `diagnostic_orders` (`id`),
  CONSTRAINT `lab_results_ibfk_2` FOREIGN KEY (`order_item_id`) REFERENCES `diagnostic_order_items` (`id`),
  CONSTRAINT `lab_results_ibfk_3` FOREIGN KEY (`test_id`) REFERENCES `diagnostic_tests` (`id`),
  CONSTRAINT `lab_results_ibfk_4` FOREIGN KEY (`entered_by`) REFERENCES `users` (`id`),
  CONSTRAINT `lab_results_ibfk_5` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `lab_results`
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('1', '1', '1', '1', '126.5', 'high', '70.0 - 99.0 mg/dL', 'Fasting Blood Sugar elevated. Consistent with diabetic profile.', '1', '2026-10-05 18:31:34', '1', '2026-10-10 18:31:34', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('2', '1', '2', '3', '7.8', 'high', '< 5.7 % (Normal)', 'HbA1c indicates sub-optimal glycemic control over past 90 days.', '1', '2026-10-05 18:31:34', '1', '2026-10-10 18:31:34', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('3', '1', '3', '5', '242.0', 'high', '< 200.0 mg/dL', 'Total cholesterol mildly elevated. Serum clear.', '1', '2026-10-05 18:31:34', '1', '2026-10-10 18:31:34', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('4', '2', '4', '13', '2.45', 'normal', '0.35 - 4.94 uIU/mL', 'Euthyroid state confirmed.', '1', '2026-10-06 18:31:34', '1', '2026-10-10 18:31:34', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('5', '2', '5', '14', '1.18', 'normal', '0.70 - 1.48 ng/dL', 'Normal Free T4 levels.', '1', '2026-10-06 18:31:34', '1', '2026-10-10 18:31:34', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('6', '2', '6', '16', '34.2', 'normal', '30.0 - 100.0 ng/dL', 'Vitamin D level adequate.', '1', '2026-10-06 18:31:34', '1', '2026-10-10 18:31:34', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('7', '3', '7', '9', '14.2', 'normal', '13.0 - 17.0 g/dL', 'CBC parameters within physiological baseline.', '1', '2026-10-07 18:31:34', '1', '2026-10-10 18:31:34', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('8', '3', '8', '4', '1.05', 'normal', '0.7 - 1.3 mg/dL', 'Renal clearance normal.', '1', '2026-10-07 18:31:34', '1', '2026-10-10 18:31:34', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('9', '3', '9', '8', '141.0', 'normal', '136 - 145 mmol/L', 'Serum sodium balanced.', '1', '2026-10-07 18:31:34', '1', '2026-10-10 18:31:34', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('10', '4', '10', '22', '15-20 Pus Cells', 'high', '0 - 2 Pus Cells/HPF', 'Microscopy reveals pyuria with moderate epithelial cells.', '1', '2026-10-08 18:31:34', '1', '2026-10-10 18:31:34', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('11', '4', '11', '25', 'Escherichia coli >10^5 CFU/mL', 'high', 'No Growth', 'Sensitive to Nitrofurantoin, Amikacin, Meropenem. Resistant to Ciprofloxacin.', '1', '2026-10-08 18:31:34', '1', '2026-10-10 18:31:34', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('12', '5', '12', '1', '385.0', 'critical', '70.0 - 99.0 mg/dL', 'PANIC CRITICAL VALUE! Severe Hyperglycemia. Telephonic alert communicated to chamber.', '1', '2026-10-09 18:31:34', '1', '2026-10-11 17:31:08', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('13', '5', '13', '4', '2.85', 'high', '0.7 - 1.3 mg/dL', 'Elevated creatinine. Nephrology consult recommended.', '1', '2026-10-09 18:31:34', '1', '2026-10-11 17:31:08', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('14', '5', '14', '6', '9.4', 'high', '3.5 - 7.2 mg/dL', 'Hyperuricemia noted.', '1', '2026-10-09 18:31:34', '1', '2026-10-11 17:31:08', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('15', '6', '15', '30', 'MTB Detected (Medium), Rifampicin Resistance NOT Detected', 'high', 'Not Detected', 'Correlate clinically with chest X-ray findings and clinical history.', '1', '2026-10-11 17:23:12', NULL, NULL, 'draft');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('16', '7', '16', '30', 'MTB NOT Detected', 'normal', 'Not Detected', 'Negative for Mycobacterium tuberculosis DNA.', '1', '2026-10-11 17:23:12', '1', '2026-10-11 18:36:24', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('17', '8', '17', '28', 'NILM - Negative for Intraepithelial Lesion or Malignancy', 'normal', 'Normal / NILM', 'Satisfactory for evaluation. Endocervical component present.', '1', '2026-10-11 17:23:12', '1', '2026-10-11 18:33:02', 'approved');
INSERT INTO `lab_results` (`id`, `order_id`, `order_item_id`, `test_id`, `result_value`, `result_flag`, `reference_range_text`, `comments`, `entered_by`, `entered_at`, `verified_by`, `verified_at`, `status`) VALUES ('18', '5', '14', '6', '8.9 mg/dL', 'high', '3.4 - 7.0 mg/dL', 'Hyperuricemia noted. Re-check after dietary purine restriction.', '1', '2026-10-11 17:23:12', '1', '2026-10-11 17:31:08', 'approved');

-- Table structure for table `leave_requests`
DROP TABLE IF EXISTS `leave_requests`;
CREATE TABLE `leave_requests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint(20) unsigned NOT NULL,
  `leave_type` enum('casual','sick','annual') NOT NULL DEFAULT 'casual',
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `total_days` smallint(5) unsigned NOT NULL DEFAULT 1,
  `reason` varchar(255) NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `leave_requests_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `hr_employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `leave_requests`
INSERT INTO `leave_requests` (`id`, `employee_id`, `leave_type`, `start_date`, `end_date`, `total_days`, `reason`, `status`, `created_at`) VALUES ('1', '3', 'annual', '2026-10-25', '2026-10-28', '4', 'Annual family pilgrimage visit', 'approved', '2026-10-20 11:27:01');
INSERT INTO `leave_requests` (`id`, `employee_id`, `leave_type`, `start_date`, `end_date`, `total_days`, `reason`, `status`, `created_at`) VALUES ('2', '6', 'sick', '2026-10-18', '2026-10-19', '2', 'Acute viral fever with medical certificate', 'approved', '2026-10-20 11:27:01');
INSERT INTO `leave_requests` (`id`, `employee_id`, `leave_type`, `start_date`, `end_date`, `total_days`, `reason`, `status`, `created_at`) VALUES ('3', '8', 'casual', '2026-10-22', '2026-10-23', '2', 'Personal emergency work at native village', 'pending', '2026-10-20 11:27:02');
INSERT INTO `leave_requests` (`id`, `employee_id`, `leave_type`, `start_date`, `end_date`, `total_days`, `reason`, `status`, `created_at`) VALUES ('4', '10', 'casual', '2026-10-30', '2026-10-31', '2', 'Brother wedding ceremony', 'pending', '2026-10-20 11:27:02');

-- Table structure for table `login_logs`
DROP TABLE IF EXISTS `login_logs`;
CREATE TABLE `login_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `email_attempt` varchar(190) DEFAULT NULL,
  `successful` tinyint(1) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `occurred_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_login_email_time` (`email_attempt`,`occurred_at`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `login_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=199 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `login_logs`
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('19', '1', 'admin@cognovait.com', '0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 14:21:53');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('20', '1', 'admin@cognovait.com', '0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 14:21:56');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('21', '1', 'admin@cognovait.com', '0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 14:22:14');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('22', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 14:22:19');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('23', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 14:27:40');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('24', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-10 14:28:43');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('25', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-10 14:36:10');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('26', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-10 14:50:05');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('27', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 14:51:06');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('28', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 14:56:58');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('29', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-10 14:59:33');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('30', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-10 15:13:48');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('31', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-10 15:18:11');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('32', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 15:20:10');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('33', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-10 15:27:17');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('34', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 15:28:37');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('35', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 15:43:27');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('36', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 16:59:35');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('37', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 17:00:00');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('38', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 17:00:13');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('39', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 17:14:13');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('40', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-10 17:31:14');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('41', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-10 17:31:52');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('42', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 17:53:10');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('43', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-10 17:58:25');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('44', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 18:38:19');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('45', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 18:49:30');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('46', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-10 18:49:35');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('47', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-10 21:33:58');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('48', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-10 22:05:18');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('49', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-10 22:05:49');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('50', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-10 22:48:02');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('51', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 00:33:58');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('52', NULL, '', '0', '127.0.0.1', 'Python-urllib/3.13', '2026-10-11 00:51:57');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('53', '1', 'admin@cognovait.com', '0', '127.0.0.1', 'Python-urllib/3.13', '2026-10-11 00:55:24');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('54', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 00:57:07');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('55', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-11 00:59:15');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('56', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-11 01:38:03');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('57', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-11 01:40:24');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('58', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-11 01:47:43');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('59', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-11 01:50:50');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('60', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-11 02:32:28');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('61', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 02:32:36');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('62', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-11 02:37:55');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('63', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-11 02:50:28');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('64', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-11 02:50:49');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('65', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 10:50:01');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('66', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:24:49');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('67', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:43:39');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('68', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:43:47');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('69', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:43:54');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('70', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:44:02');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('71', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:44:10');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('72', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:44:27');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('73', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:56:42');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('74', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:56:50');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('75', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:56:54');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('76', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:56:57');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('77', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 14:57:02');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('78', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 17:19:43');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('79', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 18:31:41');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('80', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 18:42:46');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('81', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 22:10:42');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('82', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 22:36:36');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('83', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-11 22:40:29');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('84', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-12 01:34:48');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('85', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 14:19:34');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('86', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 16:06:42');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('87', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-15 20:37:14');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('88', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-15 22:25:21');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('89', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 00:08:05');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('90', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 00:35:49');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('91', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 00:39:09');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('92', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 00:41:01');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('93', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 00:42:26');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('94', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 01:06:11');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('95', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 01:07:18');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('96', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 01:13:38');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('97', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 01:14:15');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('98', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 01:39:03');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('99', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 01:43:16');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('100', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 02:29:08');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('101', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 02:31:28');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('102', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 02:49:22');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('103', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 02:50:41');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('104', '1', 'admin@cognovait.com', '1', 'CLI', '', '2026-10-16 02:59:58');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('105', '2', 'clinic@cognovait.com', '1', 'CLI', '', '2026-10-16 02:59:58');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('106', '3', 'lab@cognovait.com', '1', 'CLI', '', '2026-10-16 02:59:58');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('107', '4', 'doctor@cognovait.com', '1', 'CLI', '', '2026-10-16 02:59:59');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('108', '5', 'staff@cognovait.com', '1', 'CLI', '', '2026-10-16 02:59:59');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('109', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:02:14');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('110', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:02:25');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('111', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:04:44');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('112', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:04:50');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('113', '1', 'admin@cognovait.com', '1', 'CLI', '', '2026-10-16 03:06:29');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('114', '2', 'clinic@cognovait.com', '1', 'CLI', '', '2026-10-16 03:06:29');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('115', '3', 'lab@cognovait.com', '1', 'CLI', '', '2026-10-16 03:06:29');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('116', '4', 'doctor@cognovait.com', '1', 'CLI', '', '2026-10-16 03:06:30');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('117', '5', 'staff@cognovait.com', '1', 'CLI', '', '2026-10-16 03:06:30');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('118', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:09:29');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('119', '2', 'clinic@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:11:06');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('120', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 03:11:10');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('121', '2', 'clinic@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 03:11:11');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('122', '3', 'lab@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 03:11:11');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('123', '4', 'doctor@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 03:11:12');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('124', '5', 'staff@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 03:11:13');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('125', '5', 'staff@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:11:32');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('126', '4', 'doctor@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:12:21');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('127', '2', 'clinic@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:14:47');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('128', '3', 'lab@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:14:51');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('129', '2', 'clinic@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:17:12');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('130', '4', 'doctor@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 03:17:23');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('131', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 03:21:20');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('132', '2', 'clinic@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 03:21:21');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('133', '3', 'lab@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 03:21:22');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('134', '4', 'doctor@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 03:21:23');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('135', '5', 'staff@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 03:21:24');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('136', '2', 'clinic@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 19:29:44');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('137', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 19:29:49');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('138', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 22:04:12');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('139', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 22:19:44');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('140', '2', 'clinic@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 22:19:45');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('141', '3', 'lab@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 22:19:45');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('142', '4', 'doctor@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 22:19:46');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('143', '5', 'staff@cognovait.com', '1', '127.0.0.1', '', '2026-10-16 22:19:46');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('144', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-17 00:56:21');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('145', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-17 14:06:01');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('146', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-17 14:06:24');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('147', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 10:31:08');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('148', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 10:49:50');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('149', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 10:58:22');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('150', NULL, 'admin@lutfunnesa.com', '0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 11:07:27');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('151', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 11:10:02');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('152', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 11:12:56');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('153', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 11:24:02');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('154', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 11:42:44');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('155', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'node', '2026-10-20 12:03:44');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('156', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'node', '2026-10-20 12:03:58');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('157', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 12:23:32');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('158', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 12:30:30');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('159', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 12:31:16');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('160', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 12:57:44');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('161', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 13:08:22');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('162', NULL, '', '0', '127.0.0.1', 'Python-urllib/3.13', '2026-10-20 13:30:21');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('163', '1', 'admin@cognovait.com', '0', '127.0.0.1', 'Python-urllib/3.13', '2026-10-20 13:32:36');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('164', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Python-urllib/3.13', '2026-10-20 13:33:11');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('165', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 13:34:44');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('166', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 13:36:56');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('167', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 13:39:09');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('168', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 13:42:39');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('169', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 14:27:18');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('170', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 15:01:17');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('171', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 15:02:42');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('172', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 15:26:58');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('173', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 15:27:47');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('174', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 15:46:55');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('175', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 16:05:18');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('176', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 16:25:51');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('177', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 16:38:22');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('178', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 17:00:23');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('179', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36', '2026-10-20 17:01:04');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('180', '2', 'clinic@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 17:04:54');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('181', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 17:07:03');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('182', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 17:20:44');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('183', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 17:34:35');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('184', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 17:38:35');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('185', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 17:54:24');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('186', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 17:57:49');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('187', NULL, '', '0', '127.0.0.1', '', '2026-10-20 17:59:36');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('188', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 18:00:24');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('189', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-20 18:01:27');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('190', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-20 18:01:45');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('191', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-20 18:02:16');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('192', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-20 18:02:36');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('193', '1', 'admin@cognovait.com', '1', '127.0.0.1', '', '2026-10-20 18:03:00');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('194', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 18:03:45');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('195', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 18:04:33');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('196', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 18:06:24');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('197', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 18:12:26');
INSERT INTO `login_logs` (`id`, `user_id`, `email_attempt`, `successful`, `ip_address`, `user_agent`, `occurred_at`) VALUES ('198', '1', 'admin@cognovait.com', '1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-21 10:42:26');

-- Table structure for table `measurement_units`
DROP TABLE IF EXISTS `measurement_units`;
CREATE TABLE `measurement_units` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `medical_specializations`
DROP TABLE IF EXISTS `medical_specializations`;
CREATE TABLE `medical_specializations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `name` varchar(150) NOT NULL,
  `category` varchar(100) NOT NULL DEFAULT 'Clinical Medicine',
  `description` text DEFAULT NULL,
  `wing_location` varchar(150) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `medical_specializations`
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('1', 'SPEC-DIA', 'Diabetology & Metabolic Disorders', 'Clinical Medicine', 'Comprehensive management of Type 1 & 2 Diabetes, Diabetic Foot, HbA1c control and insulin titration.', 'Level 2, Diabetology Wing', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('2', 'SPEC-ENDO', 'Endocrinology & Hormonal Medicine', 'Clinical Medicine', 'Thyroid disorders, Pituitary disorders, PCOD/PCOS, Adrenal health and pediatric hormone issues.', 'Level 2, Endocrine Suite', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('3', 'SPEC-CARD', 'Cardiology & Cardiovascular Medicine', 'Clinical Medicine', 'Hypertension, Ischemic heart disease, Arrhythmias, ECG, Echocardiography & Color Doppler.', 'Level 1, Cardiac Care Desk', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('4', 'SPEC-PATH', 'Clinical Pathology & Laboratory Medicine', 'Diagnostic & LIS', 'Automated Biochemistry, Hematology, Coagulation, Microbiology, Histopathology and PCR Molecular testing.', 'Level 3, Central Automated Lab', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('5', 'SPEC-RAD', 'Digital Radiology & Medical Imaging', 'Diagnostic & LIS', 'Digital X-Ray, High-Resolution 4D Ultrasonography, CT Scan, Mammography and PACS DICOM archive.', 'Ground Floor, Radiology Wing', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('6', 'SPEC-NEPH', 'Nephrology & Renal Medicine', 'Clinical Medicine', 'Chronic Kidney Disease (CKD), Diabetic Nephropathy, Glomerulonephritis and Renal replacement care.', 'Level 2, Nephro OPD', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('7', 'SPEC-GAST', 'Gastroenterology & Hepatology', 'Clinical Medicine', 'Fatty liver disease, Hepatitis B/C, Peptic ulcer, GERD, Endoscopy and Colonoscopy diagnostics.', 'Level 1, GI Suite', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('8', 'SPEC-GENM', 'Internal & General Medicine', 'Clinical Medicine', 'Adult multi-system diseases, Fever of unknown origin, Infection control and chronic care.', 'Level 1, OPD Chambers', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('9', 'SPEC-OBGY', 'Obstetrics & Gynecology', 'Clinical Medicine', 'Gestational diabetes, Antenatal care, High-risk pregnancy, Menstrual health and USG screening.', 'Level 2, Women\'s Health Desk', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('10', 'SPEC-PED', 'Pediatrics & Child Health', 'Clinical Medicine', 'Childhood diabetes, Pediatric growth monitoring, Vaccinations and nutritional assessments.', 'Level 1, Pediatric Corner', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('11', 'SPEC-NEUR', 'Neurology & Brain Sciences', 'Clinical Medicine', 'Diabetic neuropathy, Stroke prevention, Migraine, Epilepsy and peripheral nerve diagnostics.', 'Level 2, Neuro OPD', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');
INSERT INTO `medical_specializations` (`id`, `code`, `name`, `category`, `description`, `wing_location`, `active`, `created_at`, `updated_at`) VALUES ('12', 'SPEC-ORTH', 'Orthopedics & Physical Medicine', 'Surgical & Daycare', 'Diabetic joint issues, Osteoporosis, Spine disorders, Arthritis and rehabilitation therapy.', 'Ground Floor, Ortho Desk', '1', '2026-10-11 15:48:06', '2026-10-11 15:48:06');

-- Table structure for table `methodologies`
DROP TABLE IF EXISTS `methodologies`;
CREATE TABLE `methodologies` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `microbiology_cultures`
DROP TABLE IF EXISTS `microbiology_cultures`;
CREATE TABLE `microbiology_cultures` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_item_id` bigint(20) unsigned NOT NULL,
  `sample_collection_id` bigint(20) unsigned NOT NULL,
  `specimen_quality` varchar(100) DEFAULT NULL,
  `gram_stain_findings` text DEFAULT NULL,
  `growth_status` enum('incubation','no_growth','growth_observed') NOT NULL DEFAULT 'incubation',
  `isolated_organism` varchar(180) DEFAULT NULL,
  `colony_count` varchar(80) DEFAULT NULL,
  `reported_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `order_item_id` (`order_item_id`),
  KEY `sample_collection_id` (`sample_collection_id`),
  KEY `reported_by` (`reported_by`),
  CONSTRAINT `microbiology_cultures_ibfk_1` FOREIGN KEY (`order_item_id`) REFERENCES `diagnostic_order_items` (`id`),
  CONSTRAINT `microbiology_cultures_ibfk_2` FOREIGN KEY (`sample_collection_id`) REFERENCES `sample_collections` (`id`),
  CONSTRAINT `microbiology_cultures_ibfk_3` FOREIGN KEY (`reported_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `microbiology_cultures`
INSERT INTO `microbiology_cultures` (`id`, `order_item_id`, `sample_collection_id`, `specimen_quality`, `gram_stain_findings`, `growth_status`, `isolated_organism`, `colony_count`, `reported_by`, `created_at`) VALUES ('1', '11', '11', 'Adequate Midstream Urine Specimen', 'Moderate Gram-negative bacilli observed with 15-20 Pus cells/HPF', 'growth_observed', 'Escherichia coli (Significant Growth)', '>10^5 CFU/mL', '1', '2026-10-11 17:23:12');
INSERT INTO `microbiology_cultures` (`id`, `order_item_id`, `sample_collection_id`, `specimen_quality`, `gram_stain_findings`, `growth_status`, `isolated_organism`, `colony_count`, `reported_by`, `created_at`) VALUES ('2', '15', '13', 'Early Morning Mucopurulent Sputum', 'Numerous Polymorphs, Gram-positive cocci in pairs, ZN Stain: AFB Positive (2+)', 'incubation', 'Mycobacterium tuberculosis complex (GeneXpert Detected, Rifampicin Resistance NOT Detected)', 'Moderate (GeneXpert Medium)', '1', '2026-10-11 17:23:12');
INSERT INTO `microbiology_cultures` (`id`, `order_item_id`, `sample_collection_id`, `specimen_quality`, `gram_stain_findings`, `growth_status`, `isolated_organism`, `colony_count`, `reported_by`, `created_at`) VALUES ('3', '16', '14', 'Clean Catch Midstream Urine', 'No bacteria or significant pus cells seen (<2 HPF)', 'no_growth', 'No bacterial growth after 48 hours of aerobic incubation at 37°C', '0 CFU/mL', '1', '2026-10-11 17:23:12');

-- Table structure for table `notification_logs`
DROP TABLE IF EXISTS `notification_logs`;
CREATE TABLE `notification_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `channel` enum('sms','email') NOT NULL DEFAULT 'sms',
  `template_key` varchar(80) NOT NULL,
  `recipient` varchar(190) NOT NULL,
  `language` enum('bn','en') NOT NULL DEFAULT 'bn',
  `content` text NOT NULL,
  `status` enum('queued','sent','failed') NOT NULL DEFAULT 'queued',
  `provider_response` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `notification_logs_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `notification_logs`
INSERT INTO `notification_logs` (`id`, `patient_id`, `channel`, `template_key`, `recipient`, `language`, `content`, `status`, `provider_response`, `created_at`, `sent_at`) VALUES ('1', '1', 'sms', 'report_ready', '01711-000001', 'bn', '??????????? ?????????? ???????: ????? ???????????? ??????? ???????? ??????? ?????? ??????? ???? ??????? ???? ????? ?????', 'sent', 'HTTP 200 OK - Sent via SMS Gateway', '2026-10-21 10:47:17', '2026-10-21 10:48:17');
INSERT INTO `notification_logs` (`id`, `patient_id`, `channel`, `template_key`, `recipient`, `language`, `content`, `status`, `provider_response`, `created_at`, `sent_at`) VALUES ('2', '2', 'sms', 'appointment_confirm', '01811-000002', 'bn', '????? ???????????????? ??????? ??????? ??? ??????? ???????????????? ??: APT-2026-0042, ????: ????? ?:???', 'sent', 'HTTP 200 OK - Sent via SMS Gateway', '2026-10-21 10:12:17', '2026-10-21 10:12:17');

-- Table structure for table `notification_reads`
DROP TABLE IF EXISTS `notification_reads`;
CREATE TABLE `notification_reads` (
  `user_id` bigint(20) unsigned NOT NULL,
  `notification_key` varchar(100) NOT NULL,
  `read_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`user_id`,`notification_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `number_sequences`
DROP TABLE IF EXISTS `number_sequences`;
CREATE TABLE `number_sequences` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `document_type` varchar(50) NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `prefix` varchar(25) NOT NULL,
  `padding` tinyint(3) unsigned NOT NULL DEFAULT 6,
  `reset_period` enum('never','year','month') NOT NULL DEFAULT 'year',
  `period_key` varchar(7) NOT NULL DEFAULT '',
  `next_value` bigint(20) unsigned NOT NULL DEFAULT 1,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_number_type_branch` (`document_type`,`branch_id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `number_sequences_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `number_sequences`
INSERT INTO `number_sequences` (`id`, `document_type`, `branch_id`, `prefix`, `padding`, `reset_period`, `period_key`, `next_value`, `active`) VALUES ('1', 'report', '1', 'REP-', '5', 'year', '2026', '5', '1');
INSERT INTO `number_sequences` (`id`, `document_type`, `branch_id`, `prefix`, `padding`, `reset_period`, `period_key`, `next_value`, `active`) VALUES ('2', 'order', '1', 'ORD-', '5', 'year', '2026', '11', '1');
INSERT INTO `number_sequences` (`id`, `document_type`, `branch_id`, `prefix`, `padding`, `reset_period`, `period_key`, `next_value`, `active`) VALUES ('3', 'invoice', '1', 'INV-', '5', 'year', '2026', '11', '1');
INSERT INTO `number_sequences` (`id`, `document_type`, `branch_id`, `prefix`, `padding`, `reset_period`, `period_key`, `next_value`, `active`) VALUES ('4', 'patient', '1', 'PAT-', '5', 'year', '2026', '7', '1');
INSERT INTO `number_sequences` (`id`, `document_type`, `branch_id`, `prefix`, `padding`, `reset_period`, `period_key`, `next_value`, `active`) VALUES ('5', 'receipt', '1', 'REC-', '5', 'year', '2026', '3', '1');
INSERT INTO `number_sequences` (`id`, `document_type`, `branch_id`, `prefix`, `padding`, `reset_period`, `period_key`, `next_value`, `active`) VALUES ('6', 'doctor', '1', 'DOC-', '3', 'never', '2026', '10', '1');
INSERT INTO `number_sequences` (`id`, `document_type`, `branch_id`, `prefix`, `padding`, `reset_period`, `period_key`, `next_value`, `active`) VALUES ('7', 'local_customer', '1', 'LOC-', '5', 'year', '2026', '16', '1');
INSERT INTO `number_sequences` (`id`, `document_type`, `branch_id`, `prefix`, `padding`, `reset_period`, `period_key`, `next_value`, `active`) VALUES ('8', 'online_customer', '1', 'ONL-', '5', 'year', '2026', '25', '1');
INSERT INTO `number_sequences` (`id`, `document_type`, `branch_id`, `prefix`, `padding`, `reset_period`, `period_key`, `next_value`, `active`) VALUES ('9', 'barcode', '1', 'BAR-', '5', 'year', '2026', '5', '1');
INSERT INTO `number_sequences` (`id`, `document_type`, `branch_id`, `prefix`, `padding`, `reset_period`, `period_key`, `next_value`, `active`) VALUES ('10', 'clinical_patient', '1', 'CLN-', '5', 'year', '2026', '2', '1');
INSERT INTO `number_sequences` (`id`, `document_type`, `branch_id`, `prefix`, `padding`, `reset_period`, `period_key`, `next_value`, `active`) VALUES ('12', 'doctor_prescribed', '1', 'DOC-', '5', 'year', '2026', '5', '1');

-- Table structure for table `organizations`
DROP TABLE IF EXISTS `organizations`;
CREATE TABLE `organizations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(180) NOT NULL,
  `short_name` varchar(80) NOT NULL,
  `facility_identifier` varchar(100) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `organizations`
INSERT INTO `organizations` (`id`, `name`, `short_name`, `facility_identifier`, `phone`, `email`, `address`, `active`, `created_at`, `updated_at`) VALUES ('1', 'Cognova Diagnostic Center', 'CDC', 'CDC-DHK', NULL, NULL, 'Dhaka, Bangladesh', '1', '2026-09-28 19:30:57', '2026-09-28 19:30:57');

-- Table structure for table `package_items`
DROP TABLE IF EXISTS `package_items`;
CREATE TABLE `package_items` (
  `package_id` bigint(20) unsigned NOT NULL,
  `test_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`package_id`,`test_id`),
  KEY `test_id` (`test_id`),
  CONSTRAINT `package_items_ibfk_1` FOREIGN KEY (`package_id`) REFERENCES `packages` (`id`),
  CONSTRAINT `package_items_ibfk_2` FOREIGN KEY (`test_id`) REFERENCES `diagnostic_tests` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `packages`
DROP TABLE IF EXISTS `packages`;
CREATE TABLE `packages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `name` varchar(180) NOT NULL,
  `price` decimal(15,2) NOT NULL DEFAULT 0.00,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `pacs_studies`
DROP TABLE IF EXISTS `pacs_studies`;
CREATE TABLE `pacs_studies` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `radiology_order_id` bigint(20) unsigned NOT NULL,
  `study_instance_uid` varchar(120) NOT NULL,
  `dicom_patient_id` varchar(80) NOT NULL,
  `modality` varchar(20) NOT NULL,
  `viewer_url` varchar(255) DEFAULT NULL,
  `status` enum('pending','archived','reconciled') NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `study_instance_uid` (`study_instance_uid`),
  KEY `radiology_order_id` (`radiology_order_id`),
  CONSTRAINT `pacs_studies_ibfk_1` FOREIGN KEY (`radiology_order_id`) REFERENCES `radiology_orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `pacs_studies`
INSERT INTO `pacs_studies` (`id`, `radiology_order_id`, `study_instance_uid`, `dicom_patient_id`, `modality`, `viewer_url`, `status`, `created_at`) VALUES ('1', '1', '1.2.840.113619.2.55.3.2819216.20261011.0001', 'MRN-2026-00101', 'xray', '/index.php?page=pacs_viewer&study_uid=1.2.840.113619.2.55.3.2819216.20261011.0001', 'archived', '2026-10-11 18:21:57');
INSERT INTO `pacs_studies` (`id`, `radiology_order_id`, `study_instance_uid`, `dicom_patient_id`, `modality`, `viewer_url`, `status`, `created_at`) VALUES ('2', '2', '1.2.840.113619.2.55.3.2819216.20261011.0002', 'MRN-2026-00102', 'usg', '/index.php?page=pacs_viewer&study_uid=1.2.840.113619.2.55.3.2819216.20261011.0002', 'archived', '2026-10-11 18:21:57');
INSERT INTO `pacs_studies` (`id`, `radiology_order_id`, `study_instance_uid`, `dicom_patient_id`, `modality`, `viewer_url`, `status`, `created_at`) VALUES ('3', '3', '1.2.840.113619.2.55.3.2819216.20261011.0003', 'MRN-2026-00103', 'ct', '/index.php?page=pacs_viewer&study_uid=1.2.840.113619.2.55.3.2819216.20261011.0003', 'archived', '2026-10-11 18:21:57');
INSERT INTO `pacs_studies` (`id`, `radiology_order_id`, `study_instance_uid`, `dicom_patient_id`, `modality`, `viewer_url`, `status`, `created_at`) VALUES ('4', '4', '1.2.840.113619.2.55.3.2819216.20261011.0004', 'MRN-2026-00104', 'mri', '/index.php?page=pacs_viewer&study_uid=1.2.840.113619.2.55.3.2819216.20261011.0004', 'archived', '2026-10-11 18:21:57');
INSERT INTO `pacs_studies` (`id`, `radiology_order_id`, `study_instance_uid`, `dicom_patient_id`, `modality`, `viewer_url`, `status`, `created_at`) VALUES ('5', '5', '1.2.840.113619.2.55.3.2819216.20261011.0005', 'MRN-2026-00105', 'ecg', '/index.php?page=pacs_viewer&study_uid=1.2.840.113619.2.55.3.2819216.20261011.0005', 'archived', '2026-10-11 18:21:57');

-- Table structure for table `pathology_accessions`
DROP TABLE IF EXISTS `pathology_accessions`;
CREATE TABLE `pathology_accessions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `accession_no` varchar(30) NOT NULL,
  `order_item_id` bigint(20) unsigned NOT NULL,
  `gross_description` text DEFAULT NULL,
  `microscopic_description` text DEFAULT NULL,
  `diagnosis` text DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `pathologist_id` bigint(20) unsigned DEFAULT NULL,
  `status` enum('accessioned','grossed','microscopy','approved') NOT NULL DEFAULT 'accessioned',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `accession_no` (`accession_no`),
  KEY `order_item_id` (`order_item_id`),
  KEY `pathologist_id` (`pathologist_id`),
  CONSTRAINT `pathology_accessions_ibfk_1` FOREIGN KEY (`order_item_id`) REFERENCES `diagnostic_order_items` (`id`),
  CONSTRAINT `pathology_accessions_ibfk_2` FOREIGN KEY (`pathologist_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `pathology_accessions`
INSERT INTO `pathology_accessions` (`id`, `accession_no`, `order_item_id`, `gross_description`, `microscopic_description`, `diagnosis`, `comments`, `pathologist_id`, `status`, `created_at`, `updated_at`) VALUES ('1', 'BIO-2026-0041', '17', 'Received single liquid-based cytology vial containing cervical brush specimen in 20mL PreservCyt fixative.', 'Smears show adequate cellularity consisting of superficial and intermediate squamous cells along with endocervical cells. No atypical squamous or glandular cells seen. Background shows lactobacilli with mild inflammation.', 'Negative for Intraepithelial Lesion or Malignancy (NILM), Bethesda System 2014. Mild nonspecific reactive cellular changes.', 'Routine follow-up screening recommended after 3 years.', '1', 'approved', '2026-10-11 17:23:12', '2026-10-11 17:23:12');
INSERT INTO `pathology_accessions` (`id`, `accession_no`, `order_item_id`, `gross_description`, `microscopic_description`, `diagnosis`, `comments`, `pathologist_id`, `status`, `created_at`, `updated_at`) VALUES ('2', 'BIO-2026-0042', '15', 'Received multiple mucosal tissue fragments together measuring 0.6 x 0.4 x 0.3 cm. Entire tissue submitted in cassette A1.', 'Sections show gastric antral mucosa exhibiting dense lymphoplasmacytic infiltration in the lamina propria with glandular atrophy and neutrophilic activity. Giemsa stain highlights Helicobacter pylori organisms on luminal surface.', 'Endoscopic Gastric Antral Biopsy: Chronic Active Gastritis with H. pylori colonization (Updated Sydney System).', 'Triple therapy eradication regimen advised under gastroenterologist supervision.', '1', 'microscopy', '2026-10-11 17:23:12', '2026-10-11 17:23:12');
INSERT INTO `pathology_accessions` (`id`, `accession_no`, `order_item_id`, `gross_description`, `microscopic_description`, `diagnosis`, `comments`, `pathologist_id`, `status`, `created_at`, `updated_at`) VALUES ('3', 'BIO-2026-0043', '16', 'Received a punch biopsy of skin measuring 4mm in diameter and 3mm in depth with formal orientation intact.', 'Processing in laboratory. Microtome sectioning and H&E staining in progress.', 'Histopathology evaluation in progress.', 'Special stain (PAS & Fite) requested.', '1', 'grossed', '2026-10-11 17:23:12', '2026-10-11 17:23:12');

-- Table structure for table `patient_allergies`
DROP TABLE IF EXISTS `patient_allergies`;
CREATE TABLE `patient_allergies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uhid` varchar(50) NOT NULL,
  `allergen_category` varchar(100) NOT NULL,
  `specific_allergen` varchar(150) NOT NULL,
  `reaction_severity` varchar(30) NOT NULL DEFAULT 'SEVERE',
  `reaction_notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_uhid` (`uhid`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `patient_allergies`
INSERT INTO `patient_allergies` (`id`, `uhid`, `allergen_category`, `specific_allergen`, `reaction_severity`, `reaction_notes`, `created_at`) VALUES ('1', 'UHID-10001', 'Penicillin', 'Amoxicillin / Penicillin V', 'ANAPHYLAXIS', 'History of severe facial edema and bronchospasm after Amoxicillin in 2024.', '2026-10-11 02:29:28');
INSERT INTO `patient_allergies` (`id`, `uhid`, `allergen_category`, `specific_allergen`, `reaction_severity`, `reaction_notes`, `created_at`) VALUES ('2', 'UHID-10002', 'NSAID', 'Aspirin / Ibuprofen', 'SEVERE', 'Urticaria and severe asthma exacerbation.', '2026-10-11 02:29:28');
INSERT INTO `patient_allergies` (`id`, `uhid`, `allergen_category`, `specific_allergen`, `reaction_severity`, `reaction_notes`, `created_at`) VALUES ('3', 'UHID-10003', 'Sulfa', 'Co-trimoxazole (Sulfamethoxazole)', 'MODERATE', 'Widespread skin rash and Stevens-Johnson warning.', '2026-10-11 02:29:28');

-- Table structure for table `patient_documents`
DROP TABLE IF EXISTS `patient_documents`;
CREATE TABLE `patient_documents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `doc_type` enum('prescription','lab_report','radiology_scan','discharge_summary','nid_insurance','other') DEFAULT 'other',
  `title` varchar(180) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_size` int(10) unsigned DEFAULT 0,
  `mime_type` varchar(80) DEFAULT 'application/pdf',
  `notes` text DEFAULT NULL,
  `uploaded_by` varchar(100) DEFAULT 'Reception Desk',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_patient_doc` (`patient_id`),
  KEY `idx_doc_type` (`doc_type`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `patient_documents`
INSERT INTO `patient_documents` (`id`, `patient_id`, `doc_type`, `title`, `file_path`, `file_size`, `mime_type`, `notes`, `uploaded_by`, `created_at`) VALUES ('1', '1', 'prescription', 'Diabetology Chamber Prescription (Prof. Dr. M. Rahman)', '/storage/docs/rx_nasir_2026.pdf', '458200', 'application/pdf', NULL, 'Dr. Chamber Desk', '2026-10-10 17:53:29');
INSERT INTO `patient_documents` (`id`, `patient_id`, `doc_type`, `title`, `file_path`, `file_size`, `mime_type`, `notes`, `uploaded_by`, `created_at`) VALUES ('2', '1', 'lab_report', 'HbA1c & Fasting Lipid Profile Automated Report', '/storage/docs/lab_nasir_hba1c.pdf', '612400', 'application/pdf', NULL, 'Pathology LIS Desk', '2026-10-10 17:53:29');
INSERT INTO `patient_documents` (`id`, `patient_id`, `doc_type`, `title`, `file_path`, `file_size`, `mime_type`, `notes`, `uploaded_by`, `created_at`) VALUES ('3', '2', 'lab_report', 'Thyroid Panel (TSH, FT3, FT4) Verified Report', '/storage/docs/lab_fatema_thyroid.pdf', '524000', 'application/pdf', NULL, 'Pathology LIS Desk', '2026-10-10 17:53:29');
INSERT INTO `patient_documents` (`id`, `patient_id`, `doc_type`, `title`, `file_path`, `file_size`, `mime_type`, `notes`, `uploaded_by`, `created_at`) VALUES ('4', '2', 'radiology_scan', 'High-Resolution Ultrasonography Whole Abdomen', '/storage/docs/usg_fatema_abdomen.jpg', '1240800', 'image/jpeg', NULL, 'Radiology Desk', '2026-10-10 17:53:29');
INSERT INTO `patient_documents` (`id`, `patient_id`, `doc_type`, `title`, `file_path`, `file_size`, `mime_type`, `notes`, `uploaded_by`, `created_at`) VALUES ('5', '3', 'radiology_scan', 'Digital Chest X-Ray P/A View with Radiologist Impression', '/storage/docs/xray_shahidul_chest.jpg', '1950000', 'image/jpeg', NULL, 'PACS Imaging Archive', '2026-10-10 17:53:29');
INSERT INTO `patient_documents` (`id`, `patient_id`, `doc_type`, `title`, `file_path`, `file_size`, `mime_type`, `notes`, `uploaded_by`, `created_at`) VALUES ('6', '4', 'nid_insurance', 'National ID & Corporate Healthcare Insurance Card', '/storage/docs/insurance_sultana.pdf', '312000', 'application/pdf', NULL, 'Front Desk Reception', '2026-10-10 17:53:29');
INSERT INTO `patient_documents` (`id`, `patient_id`, `doc_type`, `title`, `file_path`, `file_size`, `mime_type`, `notes`, `uploaded_by`, `created_at`) VALUES ('7', '6', 'lab_report', 'Comprehensive Diabetes & Metabolic Panel (HbA1c: 6.8%)', 'uploads/docs/ehr_hba1c_panel.pdf', '248500', 'application/pdf', 'Verified by Central Pathology Lab. Blood glucose under optimal glycemic control.', 'Central Pathology Wing', '2026-10-20 10:55:37');
INSERT INTO `patient_documents` (`id`, `patient_id`, `doc_type`, `title`, `file_path`, `file_size`, `mime_type`, `notes`, `uploaded_by`, `created_at`) VALUES ('8', '6', 'radiology_scan', 'Digital 12-Lead ECG & Rhythm Tracing Strip', 'uploads/docs/ehr_ecg_cardio.pdf', '482100', 'application/pdf', 'Normal sinus rhythm, HR 72 bpm, no ST-T wave segment abnormalities.', 'Cardiology Diagnostic Section', '2026-10-20 10:55:37');
INSERT INTO `patient_documents` (`id`, `patient_id`, `doc_type`, `title`, `file_path`, `file_size`, `mime_type`, `notes`, `uploaded_by`, `created_at`) VALUES ('9', '6', 'prescription', 'Consultant Prescription & Medication Plan - Prof. Dr. M. Rahman', 'uploads/docs/ehr_prescription_oct26.pdf', '195400', 'application/pdf', 'Prescribed Tab. Metformin 500mg, Tab. Rosuvastatin 10mg, lifestyle modifications.', 'Chamber Consultation Desk', '2026-10-20 10:55:37');
INSERT INTO `patient_documents` (`id`, `patient_id`, `doc_type`, `title`, `file_path`, `file_size`, `mime_type`, `notes`, `uploaded_by`, `created_at`) VALUES ('10', '6', 'radiology_scan', 'Chest Radiograph X-Ray P/A View High-Res Report', 'uploads/docs/ehr_chest_xray.pdf', '742000', 'application/pdf', 'Both lung fields clear. Bronchovascular markings normal. Cardio-thoracic ratio normal.', 'Radiology & Imaging Wing', '2026-10-20 10:55:37');
INSERT INTO `patient_documents` (`id`, `patient_id`, `doc_type`, `title`, `file_path`, `file_size`, `mime_type`, `notes`, `uploaded_by`, `created_at`) VALUES ('11', '6', 'nid_insurance', 'National Identity Card (NID) & Health Insurance Card Scan', 'uploads/docs/ehr_patient_nid.pdf', '312000', 'application/pdf', 'Verified biometric KYC documentation for corporate diagnostic coverage.', 'Patient Registration Desk', '2026-10-20 10:55:37');

-- Table structure for table `patient_feedback`
DROP TABLE IF EXISTS `patient_feedback`;
CREATE TABLE `patient_feedback` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `order_id` bigint(20) unsigned DEFAULT NULL,
  `category` enum('wait_time','phlebotomy','report','staff','other') NOT NULL DEFAULT 'staff',
  `rating` tinyint(3) unsigned NOT NULL DEFAULT 5,
  `comments` text DEFAULT NULL,
  `status` enum('received','under_review','resolved') NOT NULL DEFAULT 'received',
  `resolved_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  KEY `order_id` (`order_id`),
  KEY `resolved_by` (`resolved_by`),
  CONSTRAINT `patient_feedback_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`),
  CONSTRAINT `patient_feedback_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `diagnostic_orders` (`id`),
  CONSTRAINT `patient_feedback_ibfk_3` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `patient_feedback`
INSERT INTO `patient_feedback` (`id`, `patient_id`, `order_id`, `category`, `rating`, `comments`, `status`, `resolved_by`, `created_at`) VALUES ('1', '1', '1', 'wait_time', '5', 'Extremely prompt service! Digital token display system made the process very smooth.', 'resolved', '1', '2026-10-20 15:44:03');
INSERT INTO `patient_feedback` (`id`, `patient_id`, `order_id`, `category`, `rating`, `comments`, `status`, `resolved_by`, `created_at`) VALUES ('2', '2', '2', 'phlebotomy', '5', 'Phlebotomist was very gentle and professional. Painless vein needle draw for fasting blood sugar.', 'resolved', '1', '2026-10-20 15:44:03');
INSERT INTO `patient_feedback` (`id`, `patient_id`, `order_id`, `category`, `rating`, `comments`, `status`, `resolved_by`, `created_at`) VALUES ('3', '3', '3', 'report', '4', 'SMS alert arrived right on time with secure PDF report download link. Highly convenient.', 'resolved', '1', '2026-10-20 15:44:03');
INSERT INTO `patient_feedback` (`id`, `patient_id`, `order_id`, `category`, `rating`, `comments`, `status`, `resolved_by`, `created_at`) VALUES ('4', '4', '4', 'staff', '5', 'Reception desk staff were courteous and assisted elderly patient with wheelchair support.', 'resolved', '1', '2026-10-20 15:44:03');
INSERT INTO `patient_feedback` (`id`, `patient_id`, `order_id`, `category`, `rating`, `comments`, `status`, `resolved_by`, `created_at`) VALUES ('5', '5', '5', 'other', '4', 'Very clean and sanitized sample collection cubicles. Proper cold chain compliance observed.', 'received', '1', '2026-10-20 15:44:03');

-- Table structure for table `patient_merge_requests`
DROP TABLE IF EXISTS `patient_merge_requests`;
CREATE TABLE `patient_merge_requests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `primary_patient_id` bigint(20) unsigned NOT NULL,
  `duplicate_patient_id` bigint(20) unsigned NOT NULL,
  `requested_by` bigint(20) unsigned NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `approval_request_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `primary_patient_id` (`primary_patient_id`),
  KEY `duplicate_patient_id` (`duplicate_patient_id`),
  KEY `requested_by` (`requested_by`),
  KEY `approval_request_id` (`approval_request_id`),
  CONSTRAINT `patient_merge_requests_ibfk_1` FOREIGN KEY (`primary_patient_id`) REFERENCES `patients` (`id`),
  CONSTRAINT `patient_merge_requests_ibfk_2` FOREIGN KEY (`duplicate_patient_id`) REFERENCES `patients` (`id`),
  CONSTRAINT `patient_merge_requests_ibfk_3` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`),
  CONSTRAINT `patient_merge_requests_ibfk_4` FOREIGN KEY (`approval_request_id`) REFERENCES `approval_requests` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `patient_portal_accounts`
DROP TABLE IF EXISTS `patient_portal_accounts`;
CREATE TABLE `patient_portal_accounts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `mobile` varchar(25) NOT NULL,
  `otp_code` varchar(10) DEFAULT NULL,
  `otp_expires_at` datetime DEFAULT NULL,
  `auth_token` varchar(80) DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `patient_id` (`patient_id`),
  CONSTRAINT `patient_portal_accounts_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `patient_portal_accounts`
INSERT INTO `patient_portal_accounts` (`id`, `patient_id`, `mobile`, `otp_code`, `otp_expires_at`, `auth_token`, `last_login_at`, `created_at`) VALUES ('1', '1', '01711-000001', '123456', NULL, '0d3a575dd85faa836c67acb608445dec', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `patient_portal_accounts` (`id`, `patient_id`, `mobile`, `otp_code`, `otp_expires_at`, `auth_token`, `last_login_at`, `created_at`) VALUES ('2', '2', '01811-000002', '123456', NULL, 'c3c827ad956e5808dfdbfb460866e04b', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `patient_portal_accounts` (`id`, `patient_id`, `mobile`, `otp_code`, `otp_expires_at`, `auth_token`, `last_login_at`, `created_at`) VALUES ('3', '3', '01911-000003', '123456', NULL, '2010cfde59d1c4fd50480a78ae65b917', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `patient_portal_accounts` (`id`, `patient_id`, `mobile`, `otp_code`, `otp_expires_at`, `auth_token`, `last_login_at`, `created_at`) VALUES ('4', '4', '01611-000004', '123456', NULL, 'bd70792538cc9a6f591d8563eb999b05', '2026-10-10 17:53:29', '2026-10-10 17:53:29');
INSERT INTO `patient_portal_accounts` (`id`, `patient_id`, `mobile`, `otp_code`, `otp_expires_at`, `auth_token`, `last_login_at`, `created_at`) VALUES ('5', '5', '01511-000005', '123456', NULL, 'a031aa2add38f4a6d562ca84ad6bd5c3', '2026-10-10 17:53:29', '2026-10-10 17:53:29');

-- Table structure for table `patients`
DROP TABLE IF EXISTS `patients`;
CREATE TABLE `patients` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `mrn` varchar(30) NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `category` enum('doctor_prescribed','clinical_patient','local_customer','online_customer') NOT NULL DEFAULT 'doctor_prescribed',
  `name` varchar(150) NOT NULL,
  `gender` enum('male','female','other') NOT NULL DEFAULT 'male',
  `dob` date DEFAULT NULL,
  `blood_group` enum('A+','A-','B+','B-','AB+','AB-','O+','O-','unknown') NOT NULL DEFAULT 'unknown',
  `mobile` varchar(25) NOT NULL,
  `alternate_mobile` varchar(25) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `emergency_contact_name` varchar(150) DEFAULT NULL,
  `emergency_contact_phone` varchar(25) DEFAULT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `nid_passport` varchar(80) DEFAULT NULL,
  `corporate_client_id` bigint(20) unsigned DEFAULT NULL,
  `wallet_balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `loyalty_points` int(11) NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `mrn` (`mrn`),
  KEY `idx_patient_mobile` (`mobile`),
  KEY `branch_id` (`branch_id`),
  KEY `corporate_client_id` (`corporate_client_id`),
  CONSTRAINT `patients_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `patients_ibfk_2` FOREIGN KEY (`corporate_client_id`) REFERENCES `corporate_clients` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `patients`
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('1', 'DOC-2026-00001', '1', 'doctor_prescribed', 'Nasir Uddin', 'male', '1972-04-12', 'B+', '01711-000001', NULL, 'nasir.uddin@gmail.com', 'House 12, Road 5, Dhanmondi, Dhaka', NULL, NULL, 'Business', NULL, NULL, '750.00', '180', '1', '2026-10-10 17:53:29', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('2', 'DOC-2026-00002', '1', 'doctor_prescribed', 'Fatema Begum', 'female', '1978-08-25', 'O+', '01811-000002', NULL, 'fatema.begum@yahoo.com', 'Flat 4B, Green Road, Dhaka', NULL, NULL, 'Teacher', NULL, NULL, '750.00', '180', '1', '2026-10-10 17:53:29', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('3', 'DOC-2026-00003', '1', 'doctor_prescribed', 'Shahidul Islam', 'male', '1965-11-15', 'A+', '01911-000003', NULL, 'shahidul.islam@gmail.com', 'Plot 88, Sector 7, Uttara, Dhaka', NULL, NULL, 'Retired Govt Official', NULL, NULL, '750.00', '180', '1', '2026-10-10 17:53:29', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('4', 'CLN-2026-00004', '1', 'clinical_patient', 'Sultana Razia', 'female', '1985-02-19', 'AB+', '01611-000004', NULL, 'sultana.razia@hotmail.com', 'Road 11, Banani, Dhaka', NULL, NULL, 'Banker', NULL, NULL, '750.00', '180', '1', '2026-10-10 17:53:29', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('5', 'CLN-2026-00005', '1', 'clinical_patient', 'Anisur Rahman', 'male', '1990-06-30', 'O-', '01511-000005', NULL, 'anisur.rahman@gmail.com', 'Mirpur-10, Dhaka', NULL, NULL, 'Software Engineer', NULL, NULL, '750.00', '180', '1', '2026-10-10 17:53:29', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('6', 'LOC-2026-00006', '1', 'local_customer', 'JAHIDUL HASSAN RESHAD', 'male', '2006-06-07', 'B+', '01531150655', NULL, 'rokebul.islam088@gmail.com', 'Dhaka, Bangladesh', NULL, NULL, NULL, NULL, NULL, '500.00', '90', '1', '2026-10-11 15:56:28', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('7', 'LOC-2026-00007', '2', 'local_customer', 'Khandakar Rafiqul Islam', 'male', '1970-03-15', 'A+', '01712-345601', NULL, 'rafiq.uttara@gmail.com', 'Sector 4, Uttara, Dhaka', NULL, NULL, 'Engineer', NULL, NULL, '500.00', '90', '1', '2026-10-20 17:27:12', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('8', 'LOC-2026-00008', '2', 'local_customer', 'Shamima Nasreen', 'female', '1985-07-22', 'B+', '01819-345602', NULL, 'shamima.n@gmail.com', 'Sector 7, Uttara, Dhaka', NULL, NULL, 'Banker', NULL, NULL, '500.00', '90', '1', '2026-10-20 17:27:12', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('9', 'LOC-2026-00009', '2', 'local_customer', 'Tareq Mahmud', 'male', '1992-11-05', 'O+', '01911-345603', NULL, 'tareq.m@yahoo.com', 'Sector 11, Uttara, Dhaka', NULL, NULL, 'Corporate Executive', NULL, NULL, '500.00', '90', '1', '2026-10-20 17:27:12', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('10', 'ONL-2026-00010', '2', 'online_customer', 'Hosne Ara Begum', 'female', '1965-09-18', 'AB+', '01720-345604', NULL, 'hosneara@outlook.com', 'Sector 3, Uttara, Dhaka', NULL, NULL, 'Homemaker', NULL, NULL, '1250.00', '320', '1', '2026-10-20 17:27:12', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('11', 'ONL-2026-00011', '3', 'online_customer', 'Syed Ahsan Habib', 'male', '1968-05-12', 'B+', '01715-998801', NULL, 'ahsan.habib@gmail.com', 'Road 8A, Dhanmondi, Dhaka', NULL, NULL, 'Professor', NULL, NULL, '1250.00', '320', '1', '2026-10-20 17:27:12', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('12', 'ONL-2026-00012', '3', 'online_customer', 'Farzana Yasmin', 'female', '1988-12-30', 'O+', '01822-998802', NULL, 'farzana.y@gmail.com', 'Satmasjid Road, Dhanmondi, Dhaka', NULL, NULL, 'Architect', NULL, NULL, '1250.00', '320', '1', '2026-10-20 17:27:12', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('13', 'ONL-2026-00013', '3', 'online_customer', 'Kamrul Hassan', 'male', '1975-01-20', 'A+', '01923-998803', NULL, 'kamrul.h@yahoo.com', 'Road 27, Dhanmondi, Dhaka', NULL, NULL, 'Business', NULL, NULL, '1250.00', '320', '1', '2026-10-20 17:27:12', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('14', 'CLN-2026-00014', '1', 'clinical_patient', 'Engr. Mahfuzur Rahman', 'male', NULL, 'unknown', '+8801711223344', NULL, 'rokebul.islam088@gmail.com', '-House- 2A/5 -68/ Rainkhola Bazar Commer', NULL, NULL, NULL, NULL, NULL, '0.00', '0', '1', '2026-10-21 14:41:48', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('15', 'LOC-2026-00015', '1', 'local_customer', 'NUR NOBI', 'male', NULL, 'unknown', '01531150566', NULL, 'nurnobi88@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, '0.00', '100', '1', '2026-10-21 16:03:37', '2026-10-21 16:03:37');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('16', 'CLN-2026-00016', '1', 'clinical_patient', 'ROhim', 'male', '2001-02-02', 'AB+', '01827693729', NULL, 'rokebul.islam088@gmail.com', '-House- 2A,/Dhaka', NULL, NULL, NULL, '02322323354355', NULL, '0.00', '0', '1', '2026-10-21 16:16:14', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('17', 'CLN-2026-00017', '1', 'clinical_patient', 'ROhim', 'male', '2001-02-02', 'AB+', '01827693729', NULL, NULL, 'E block,07 no road, house 285/B, Bashundhara', NULL, NULL, NULL, '02322323354355', NULL, '0.00', '0', '1', '2026-10-21 16:17:06', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('18', 'CLN-2026-00018', '1', 'clinical_patient', 'kawsar', 'male', NULL, 'O+', '01970010098', NULL, NULL, 'E block,Bashundhara', NULL, NULL, NULL, NULL, NULL, '0.00', '0', '1', '2026-10-21 16:18:10', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('19', 'CLN-2026-00019', '1', 'clinical_patient', 'rakib', 'male', NULL, 'unknown', '01970010099', NULL, 'rokebul.islam088@gmail.com', 'Rahmotpur Colony ,Chandpur', NULL, NULL, NULL, NULL, NULL, '0.00', '0', '1', '2026-10-21 16:19:42', '2026-10-21 16:35:59');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('20', 'CLN-2026-00001', '1', 'clinical_patient', 'Mr. Testing Patient', 'male', NULL, 'unknown', '01799887766', NULL, NULL, 'House 44, Road 11, Banani, Dhaka', NULL, NULL, NULL, NULL, NULL, '0.00', '0', '1', '2026-10-21 18:03:17', '2026-10-21 18:03:17');
INSERT INTO `patients` (`id`, `mrn`, `branch_id`, `category`, `name`, `gender`, `dob`, `blood_group`, `mobile`, `alternate_mobile`, `email`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `occupation`, `nid_passport`, `corporate_client_id`, `wallet_balance`, `loyalty_points`, `active`, `created_at`, `updated_at`) VALUES ('22', 'DOC-2026-00004', '1', 'doctor_prescribed', 'Mrs. Selina Akhter', 'male', NULL, 'unknown', '01811223344', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.00', '0', '1', '2026-10-21 18:16:57', '2026-10-21 18:16:57');

-- Table structure for table `payment_methods`
DROP TABLE IF EXISTS `payment_methods`;
CREATE TABLE `payment_methods` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `kind` enum('cash','card','bank','mfs','online','other') NOT NULL DEFAULT 'other',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `payment_methods`
INSERT INTO `payment_methods` (`id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('1', 'CASH', 'Hand Cash Payment (Counter Desk)', 'cash', '1', '2026-10-11 16:11:00', '2026-10-11 16:11:00');
INSERT INTO `payment_methods` (`id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('2', 'SSLCOMMERZ', 'SSLCommerz Gateway (All Cards & Banks)', 'online', '1', '2026-10-11 16:11:00', '2026-10-11 16:11:00');
INSERT INTO `payment_methods` (`id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('3', 'BKASH', 'bKash Merchant Pay (App / USSD)', 'mfs', '1', '2026-10-11 16:11:00', '2026-10-11 16:11:00');
INSERT INTO `payment_methods` (`id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('4', 'NAGAD', 'Nagad Digital Payment', 'mfs', '1', '2026-10-11 16:11:00', '2026-10-11 16:11:00');
INSERT INTO `payment_methods` (`id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('5', 'ROCKET', 'DBBL Rocket MFS', 'mfs', '1', '2026-10-11 16:11:00', '2026-10-11 16:11:00');
INSERT INTO `payment_methods` (`id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('6', 'VISA_MC', 'Credit / Debit Card (Visa / Mastercard / Amex POS)', 'card', '1', '2026-10-11 16:11:00', '2026-10-11 16:11:00');
INSERT INTO `payment_methods` (`id`, `code`, `name`, `kind`, `active`, `created_at`, `updated_at`) VALUES ('7', 'NET_BANK', 'Internet Banking / IBFT Transfer', 'bank', '1', '2026-10-11 16:11:00', '2026-10-11 16:11:00');

-- Table structure for table `payments`
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `receipt_no` varchar(30) NOT NULL,
  `invoice_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `counter_id` bigint(20) unsigned DEFAULT NULL,
  `payment_method_id` bigint(20) unsigned NOT NULL,
  `amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `reference_no` varchar(100) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `received_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `receipt_no` (`receipt_no`),
  KEY `invoice_id` (`invoice_id`),
  KEY `branch_id` (`branch_id`),
  KEY `counter_id` (`counter_id`),
  KEY `payment_method_id` (`payment_method_id`),
  KEY `received_by` (`received_by`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`),
  CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`counter_id`) REFERENCES `counters` (`id`),
  CONSTRAINT `payments_ibfk_4` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`id`),
  CONSTRAINT `payments_ibfk_5` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `payments`
INSERT INTO `payments` (`id`, `receipt_no`, `invoice_id`, `branch_id`, `counter_id`, `payment_method_id`, `amount`, `reference_no`, `remarks`, `received_by`, `created_at`) VALUES ('1', 'REC-2026-00001', '8', '1', NULL, '2', '2500.00', 'TXN-1DC933D2', NULL, '1', '2026-10-11 16:20:09');
INSERT INTO `payments` (`id`, `receipt_no`, `invoice_id`, `branch_id`, `counter_id`, `payment_method_id`, `amount`, `reference_no`, `remarks`, `received_by`, `created_at`) VALUES ('2', 'REC-2026-00002', '7', '1', NULL, '2', '1000.00', 'TXN-9A1304E9', NULL, '1', '2026-10-11 17:14:04');

-- Table structure for table `payrolls`
DROP TABLE IF EXISTS `payrolls`;
CREATE TABLE `payrolls` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `payroll_period` varchar(30) NOT NULL,
  `employee_id` bigint(20) unsigned NOT NULL,
  `basic_salary` decimal(15,2) NOT NULL DEFAULT 0.00,
  `house_rent` decimal(15,2) NOT NULL DEFAULT 0.00,
  `medical_allowance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `allowances` decimal(15,2) NOT NULL DEFAULT 0.00,
  `provident_fund` decimal(15,2) NOT NULL DEFAULT 0.00,
  `tax_deduction` decimal(15,2) NOT NULL DEFAULT 0.00,
  `deductions` decimal(15,2) NOT NULL DEFAULT 0.00,
  `net_salary` decimal(15,2) NOT NULL DEFAULT 0.00,
  `payment_method` varchar(40) NOT NULL DEFAULT 'Bank Transfer',
  `transaction_ref` varchar(80) DEFAULT NULL,
  `status` enum('draft','approved','paid') NOT NULL DEFAULT 'draft',
  `paid_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `payrolls_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `hr_employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `payrolls`
INSERT INTO `payrolls` (`id`, `payroll_period`, `employee_id`, `basic_salary`, `house_rent`, `medical_allowance`, `allowances`, `provident_fund`, `tax_deduction`, `deductions`, `net_salary`, `payment_method`, `transaction_ref`, `status`, `paid_at`, `created_at`) VALUES ('1', 'October 2026', '1', '95000.00', '38000.00', '3000.00', '43500.00', '7600.00', '2500.00', '10100.00', '128400.00', 'Bank Transfer (City Bank)', 'SLP-202610-0001', 'paid', '2026-10-20 11:27:02', '2026-10-20 11:27:02');
INSERT INTO `payrolls` (`id`, `payroll_period`, `employee_id`, `basic_salary`, `house_rent`, `medical_allowance`, `allowances`, `provident_fund`, `tax_deduction`, `deductions`, `net_salary`, `payment_method`, `transaction_ref`, `status`, `paid_at`, `created_at`) VALUES ('2', 'October 2026', '2', '85000.00', '34000.00', '3000.00', '38000.00', '6800.00', '2500.00', '9300.00', '113700.00', 'Bank Transfer (City Bank)', 'SLP-202610-0002', 'paid', '2026-10-20 11:27:02', '2026-10-20 11:27:02');
INSERT INTO `payrolls` (`id`, `payroll_period`, `employee_id`, `basic_salary`, `house_rent`, `medical_allowance`, `allowances`, `provident_fund`, `tax_deduction`, `deductions`, `net_salary`, `payment_method`, `transaction_ref`, `status`, `paid_at`, `created_at`) VALUES ('3', 'October 2026', '3', '48000.00', '19200.00', '3000.00', '24700.00', '3840.00', '1000.00', '4840.00', '67860.00', 'Bank Transfer (City Bank)', 'SLP-202610-0003', 'paid', '2026-10-20 11:27:02', '2026-10-20 11:27:02');
INSERT INTO `payrolls` (`id`, `payroll_period`, `employee_id`, `basic_salary`, `house_rent`, `medical_allowance`, `allowances`, `provident_fund`, `tax_deduction`, `deductions`, `net_salary`, `payment_method`, `transaction_ref`, `status`, `paid_at`, `created_at`) VALUES ('4', 'October 2026', '4', '46000.00', '18400.00', '3000.00', '22400.00', '3680.00', '1000.00', '4680.00', '63720.00', 'Bank Transfer (City Bank)', 'SLP-202610-0004', 'paid', '2026-10-20 11:27:02', '2026-10-20 11:27:02');
INSERT INTO `payrolls` (`id`, `payroll_period`, `employee_id`, `basic_salary`, `house_rent`, `medical_allowance`, `allowances`, `provident_fund`, `tax_deduction`, `deductions`, `net_salary`, `payment_method`, `transaction_ref`, `status`, `paid_at`, `created_at`) VALUES ('5', 'October 2026', '5', '44000.00', '17600.00', '3000.00', '23100.00', '3520.00', '1000.00', '4520.00', '62580.00', 'Bank Transfer (City Bank)', 'SLP-202610-0005', 'paid', '2026-10-20 11:27:02', '2026-10-20 11:27:02');
INSERT INTO `payrolls` (`id`, `payroll_period`, `employee_id`, `basic_salary`, `house_rent`, `medical_allowance`, `allowances`, `provident_fund`, `tax_deduction`, `deductions`, `net_salary`, `payment_method`, `transaction_ref`, `status`, `paid_at`, `created_at`) VALUES ('6', 'October 2026', '6', '38000.00', '15200.00', '3000.00', '19200.00', '3040.00', '1000.00', '4040.00', '53160.00', 'Bank Transfer (City Bank)', 'SLP-202610-0006', 'paid', '2026-10-20 11:27:02', '2026-10-20 11:27:02');
INSERT INTO `payrolls` (`id`, `payroll_period`, `employee_id`, `basic_salary`, `house_rent`, `medical_allowance`, `allowances`, `provident_fund`, `tax_deduction`, `deductions`, `net_salary`, `payment_method`, `transaction_ref`, `status`, `paid_at`, `created_at`) VALUES ('7', 'October 2026', '7', '42000.00', '16800.00', '3000.00', '22300.00', '3360.00', '1000.00', '4360.00', '59940.00', 'Bank Transfer (City Bank)', 'SLP-202610-0007', 'paid', '2026-10-20 11:27:02', '2026-10-20 11:27:02');
INSERT INTO `payrolls` (`id`, `payroll_period`, `employee_id`, `basic_salary`, `house_rent`, `medical_allowance`, `allowances`, `provident_fund`, `tax_deduction`, `deductions`, `net_salary`, `payment_method`, `transaction_ref`, `status`, `paid_at`, `created_at`) VALUES ('8', 'October 2026', '8', '28000.00', '11200.00', '3000.00', '15200.00', '2240.00', '0.00', '2240.00', '40960.00', 'Bank Transfer (City Bank)', 'SLP-202610-0008', 'paid', '2026-10-20 11:27:02', '2026-10-20 11:27:02');
INSERT INTO `payrolls` (`id`, `payroll_period`, `employee_id`, `basic_salary`, `house_rent`, `medical_allowance`, `allowances`, `provident_fund`, `tax_deduction`, `deductions`, `net_salary`, `payment_method`, `transaction_ref`, `status`, `paid_at`, `created_at`) VALUES ('9', 'October 2026', '9', '30000.00', '12000.00', '3000.00', '17500.00', '2400.00', '0.00', '2400.00', '45100.00', 'Bank Transfer (City Bank)', 'SLP-202610-0009', 'paid', '2026-10-20 11:27:02', '2026-10-20 11:27:02');
INSERT INTO `payrolls` (`id`, `payroll_period`, `employee_id`, `basic_salary`, `house_rent`, `medical_allowance`, `allowances`, `provident_fund`, `tax_deduction`, `deductions`, `net_salary`, `payment_method`, `transaction_ref`, `status`, `paid_at`, `created_at`) VALUES ('10', 'October 2026', '10', '26000.00', '10400.00', '3000.00', '14400.00', '2080.00', '0.00', '2080.00', '38320.00', 'Bank Transfer (City Bank)', 'SLP-202610-0010', 'paid', '2026-10-20 11:27:02', '2026-10-20 11:27:02');

-- Table structure for table `permissions`
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(90) NOT NULL,
  `description` varchar(190) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `permissions`
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('1', 'dashboard.view', 'View Dashboard');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('2', 'masters.view', 'View Masters');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('3', 'masters.edit', 'Edit Masters');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('4', 'settings.manage', 'Manage Settings');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('5', 'users.manage', 'Manage Users');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('6', 'audit.view', 'View Audit Logs');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('7', 'approvals.request', 'Request Approval');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('8', 'approvals.decide', 'Approve or Reject Requests');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('9', 'sequences.manage', 'Manage Number Sequences');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('10', 'department.all', 'Access All Departments');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('11', 'patients.view', 'View Patients');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('12', 'patients.edit', 'Create and Edit Patients');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('13', 'appointments.manage', 'Manage Appointments');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('14', 'queue.manage', 'Manage Patient Queue');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('15', 'orders.view', 'View Orders');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('16', 'orders.create', 'Create Orders');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('17', 'reports.export', 'Export Reports');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('18', 'security.manage', 'Manage Security');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('19', 'integration.manage', 'Manage Integrations');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('20', 'intelligence.view', 'View Management Intelligence');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('21', 'pharmacy.view', 'View Global Medicine Catalog & Local Pharmacy Inventory');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('22', 'pharmacy.manage', 'Manage Pharmacy Items Mapping, Pricing & Reorder Levels');
INSERT INTO `permissions` (`id`, `code`, `description`) VALUES ('23', 'pharmacy.pos', 'Dispense Pharmacy Prescriptions & Process Counter Billing');

-- Table structure for table `pharmacy_3way_matching_logs`
DROP TABLE IF EXISTS `pharmacy_3way_matching_logs`;
CREATE TABLE `pharmacy_3way_matching_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `match_code` varchar(100) NOT NULL,
  `po_id` bigint(20) unsigned NOT NULL,
  `grn_id` bigint(20) unsigned DEFAULT NULL,
  `supplier_id` bigint(20) unsigned NOT NULL,
  `supplier_invoice_no` varchar(100) NOT NULL,
  `supplier_invoice_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `po_total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `price_variance_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `quantity_shortage_count` int(11) NOT NULL DEFAULT 0,
  `matching_status` varchar(50) NOT NULL DEFAULT 'MATCHED',
  `supervisor_approval` varchar(50) NOT NULL DEFAULT 'APPROVED',
  `audited_by` bigint(20) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `match_code` (`match_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `pharmacy_batches`
DROP TABLE IF EXISTS `pharmacy_batches`;
CREATE TABLE `pharmacy_batches` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pharmacy_item_id` bigint(20) unsigned NOT NULL,
  `batch_number` varchar(100) NOT NULL,
  `mfg_date` date DEFAULT NULL,
  `expiry_date` date NOT NULL,
  `purchase_rate` decimal(10,2) NOT NULL,
  `mrp` decimal(10,2) NOT NULL,
  `current_stock` decimal(10,2) NOT NULL DEFAULT 0.00,
  `cold_chain_verified` tinyint(1) DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `pharmacy_item_id` (`pharmacy_item_id`),
  KEY `idx_exp` (`expiry_date`),
  KEY `idx_batch` (`batch_number`),
  CONSTRAINT `pharmacy_batches_ibfk_1` FOREIGN KEY (`pharmacy_item_id`) REFERENCES `pharmacy_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `pharmacy_batches`
INSERT INTO `pharmacy_batches` (`id`, `pharmacy_item_id`, `batch_number`, `mfg_date`, `expiry_date`, `purchase_rate`, `mrp`, `current_stock`, `cold_chain_verified`, `created_at`) VALUES ('1', '1', 'BAT-POP-3554', '2026-01-01', '2028-12-31', '1.00', '1.20', '1000.00', '1', '2026-10-11 02:29:09');
INSERT INTO `pharmacy_batches` (`id`, `pharmacy_item_id`, `batch_number`, `mfg_date`, `expiry_date`, `purchase_rate`, `mrp`, `current_stock`, `cold_chain_verified`, `created_at`) VALUES ('2', '2', 'BAT-POP-8642', '2026-01-01', '2028-12-31', '2.10', '2.50', '800.00', '1', '2026-10-11 02:29:09');
INSERT INTO `pharmacy_batches` (`id`, `pharmacy_item_id`, `batch_number`, `mfg_date`, `expiry_date`, `purchase_rate`, `mrp`, `current_stock`, `cold_chain_verified`, `created_at`) VALUES ('3', '3', 'BAT-POP-9858', '2026-01-01', '2028-12-31', '1.00', '1.20', '900.00', '1', '2026-10-11 02:29:09');
INSERT INTO `pharmacy_batches` (`id`, `pharmacy_item_id`, `batch_number`, `mfg_date`, `expiry_date`, `purchase_rate`, `mrp`, `current_stock`, `cold_chain_verified`, `created_at`) VALUES ('4', '4', 'BAT-POP-1918', '2026-01-01', '2028-12-31', '5.10', '6.00', '600.00', '1', '2026-10-11 02:29:09');
INSERT INTO `pharmacy_batches` (`id`, `pharmacy_item_id`, `batch_number`, `mfg_date`, `expiry_date`, `purchase_rate`, `mrp`, `current_stock`, `cold_chain_verified`, `created_at`) VALUES ('5', '5', 'BAT-POP-5747', '2026-01-01', '2028-12-31', '6.00', '7.00', '750.00', '1', '2026-10-11 02:29:09');
INSERT INTO `pharmacy_batches` (`id`, `pharmacy_item_id`, `batch_number`, `mfg_date`, `expiry_date`, `purchase_rate`, `mrp`, `current_stock`, `cold_chain_verified`, `created_at`) VALUES ('6', '6', 'BAT-POP-3574', '2026-01-01', '2028-12-31', '12.50', '15.00', '400.00', '1', '2026-10-11 02:29:09');
INSERT INTO `pharmacy_batches` (`id`, `pharmacy_item_id`, `batch_number`, `mfg_date`, `expiry_date`, `purchase_rate`, `mrp`, `current_stock`, `cold_chain_verified`, `created_at`) VALUES ('7', '7', 'BAT-POP-6315', '2026-01-01', '2028-12-31', '6.00', '7.00', '500.00', '1', '2026-10-11 02:29:09');
INSERT INTO `pharmacy_batches` (`id`, `pharmacy_item_id`, `batch_number`, `mfg_date`, `expiry_date`, `purchase_rate`, `mrp`, `current_stock`, `cold_chain_verified`, `created_at`) VALUES ('8', '8', 'BAT-POP-8275', '2026-01-01', '2028-12-31', '5.00', '6.00', '300.00', '1', '2026-10-11 02:29:09');
INSERT INTO `pharmacy_batches` (`id`, `pharmacy_item_id`, `batch_number`, `mfg_date`, `expiry_date`, `purchase_rate`, `mrp`, `current_stock`, `cold_chain_verified`, `created_at`) VALUES ('9', '9', 'BAT-POP-8194', '2026-01-01', '2028-12-31', '13.50', '16.00', '450.00', '1', '2026-10-11 02:29:09');
INSERT INTO `pharmacy_batches` (`id`, `pharmacy_item_id`, `batch_number`, `mfg_date`, `expiry_date`, `purchase_rate`, `mrp`, `current_stock`, `cold_chain_verified`, `created_at`) VALUES ('10', '10', 'BAT-POP-1609', '2026-01-01', '2028-12-31', '2.50', '3.00', '650.00', '1', '2026-10-11 02:29:09');

-- Table structure for table `pharmacy_clinical_alerts`
DROP TABLE IF EXISTS `pharmacy_clinical_alerts`;
CREATE TABLE `pharmacy_clinical_alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uhid` varchar(50) DEFAULT NULL,
  `alert_type` varchar(50) NOT NULL,
  `severity` varchar(30) NOT NULL,
  `alert_title` varchar(255) NOT NULL,
  `alert_details` text NOT NULL,
  `action_taken` varchar(50) NOT NULL DEFAULT 'ALERTED',
  `override_reason` text DEFAULT NULL,
  `handled_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `pharmacy_cold_chain_logs`
DROP TABLE IF EXISTS `pharmacy_cold_chain_logs`;
CREATE TABLE `pharmacy_cold_chain_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `storage_unit` varchar(100) NOT NULL,
  `temperature` decimal(4,2) NOT NULL,
  `min_threshold` decimal(4,2) DEFAULT 2.00,
  `max_threshold` decimal(4,2) DEFAULT 8.00,
  `status` varchar(50) DEFAULT 'NORMAL',
  `logged_by` bigint(20) unsigned NOT NULL,
  `logged_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_unit` (`storage_unit`),
  KEY `idx_logged` (`logged_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `pharmacy_cold_chain_logs`
INSERT INTO `pharmacy_cold_chain_logs` (`id`, `storage_unit`, `temperature`, `min_threshold`, `max_threshold`, `status`, `logged_by`, `logged_at`) VALUES ('1', 'Insulin Cold-Bay Ref-01 (Main Pharmacy)', '4.20', '2.00', '8.00', 'NORMAL', '1', '2026-10-11 02:35:23');
INSERT INTO `pharmacy_cold_chain_logs` (`id`, `storage_unit`, `temperature`, `min_threshold`, `max_threshold`, `status`, `logged_by`, `logged_at`) VALUES ('2', 'Insulin Deep-Freeze Bay-02', '3.80', '2.00', '8.00', 'NORMAL', '1', '2026-10-11 02:35:23');
INSERT INTO `pharmacy_cold_chain_logs` (`id`, `storage_unit`, `temperature`, `min_threshold`, `max_threshold`, `status`, `logged_by`, `logged_at`) VALUES ('3', 'Vaccine & Biological Storage Bay-03', '4.50', '2.00', '8.00', 'NORMAL', '1', '2026-10-11 02:35:23');
INSERT INTO `pharmacy_cold_chain_logs` (`id`, `storage_unit`, `temperature`, `min_threshold`, `max_threshold`, `status`, `logged_by`, `logged_at`) VALUES ('4', 'Test Strip & Reagent Fridge Bay-04', '5.10', '2.00', '8.00', 'NORMAL', '1', '2026-10-11 02:35:23');

-- Table structure for table `pharmacy_concurrency_audits`
DROP TABLE IF EXISTS `pharmacy_concurrency_audits`;
CREATE TABLE `pharmacy_concurrency_audits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `test_sku` varchar(50) NOT NULL,
  `simulated_counters` int(11) NOT NULL DEFAULT 5,
  `attempted_qty` int(11) NOT NULL,
  `available_qty` int(11) NOT NULL,
  `result_status` varchar(50) NOT NULL,
  `isolation_level` varchar(50) NOT NULL DEFAULT 'REPEATABLE-READ FOR UPDATE',
  `audited_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `pharmacy_crash_cart_audits`
DROP TABLE IF EXISTS `pharmacy_crash_cart_audits`;
CREATE TABLE `pharmacy_crash_cart_audits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cart_location` varchar(100) NOT NULL,
  `seal_number` varchar(50) NOT NULL,
  `audited_by` varchar(100) NOT NULL,
  `checklist_status` varchar(30) NOT NULL DEFAULT 'PASSED',
  `missing_items` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `pharmacy_crash_cart_audits`
INSERT INTO `pharmacy_crash_cart_audits` (`id`, `cart_location`, `seal_number`, `audited_by`, `checklist_status`, `missing_items`, `created_at`) VALUES ('1', 'Emergency Room Bay-01', 'SEAL-ER-99412', 'Sr. Nurse Supervisor', 'PASSED', 'All 18 life-saving drugs verified intact. Expiry > 6 months.', '2026-10-11 02:29:29');
INSERT INTO `pharmacy_crash_cart_audits` (`id`, `cart_location`, `seal_number`, `audited_by`, `checklist_status`, `missing_items`, `created_at`) VALUES ('2', 'Daycare Ward Bay-02', 'SEAL-DC-88120', 'Floor Pharmacist', 'ATTENTION_REQUIRED', 'Atropine 0.6mg ampoule 1 unit low stock. Restocked immediately.', '2026-10-11 02:29:29');

-- Table structure for table `pharmacy_cycle_counts`
DROP TABLE IF EXISTS `pharmacy_cycle_counts`;
CREATE TABLE `pharmacy_cycle_counts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `count_date` date NOT NULL,
  `rack_location` varchar(100) NOT NULL,
  `pharmacy_item_id` int(11) NOT NULL,
  `item_name` varchar(150) NOT NULL,
  `system_expected_qty` decimal(10,2) NOT NULL,
  `physical_counted_qty` decimal(10,2) NOT NULL,
  `variance_qty` decimal(10,2) NOT NULL,
  `reconciled_by` varchar(100) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `pharmacy_cycle_counts`
INSERT INTO `pharmacy_cycle_counts` (`id`, `count_date`, `rack_location`, `pharmacy_item_id`, `item_name`, `system_expected_qty`, `physical_counted_qty`, `variance_qty`, `reconciled_by`, `notes`, `created_at`) VALUES ('1', '2026-10-11', '📍 Rack R-01 · Shelf S-02', '1', 'Napa 500mg Tablet', '250.00', '250.00', '0.00', 'Store Auditor', 'Perpetual shelf count verified zero variance.', '2026-10-11 02:29:29');
INSERT INTO `pharmacy_cycle_counts` (`id`, `count_date`, `rack_location`, `pharmacy_item_id`, `item_name`, `system_expected_qty`, `physical_counted_qty`, `variance_qty`, `reconciled_by`, `notes`, `created_at`) VALUES ('2', '2026-10-11', '📍 Rack R-02 · Shelf S-01', '2', 'Ace 500mg Tablet', '180.00', '178.00', '-2.00', 'Store Auditor', 'Physical variance of -2 Pcs reconciled under minor packaging loss.', '2026-10-11 02:29:29');

-- Table structure for table `pharmacy_digital_receipts`
DROP TABLE IF EXISTS `pharmacy_digital_receipts`;
CREATE TABLE `pharmacy_digital_receipts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_no` varchar(50) NOT NULL,
  `patient_mobile` varchar(20) NOT NULL,
  `receipt_token` varchar(100) NOT NULL,
  `qr_payload` text NOT NULL,
  `sent_whatsapp` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_no` (`invoice_no`),
  UNIQUE KEY `receipt_token` (`receipt_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `pharmacy_drug_interactions`
DROP TABLE IF EXISTS `pharmacy_drug_interactions`;
CREATE TABLE `pharmacy_drug_interactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `generic_a` varchar(150) NOT NULL,
  `generic_b` varchar(150) NOT NULL,
  `severity_level` varchar(30) NOT NULL DEFAULT 'SEVERE',
  `clinical_effect` text NOT NULL,
  `management_advice` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `pharmacy_drug_interactions`
INSERT INTO `pharmacy_drug_interactions` (`id`, `generic_a`, `generic_b`, `severity_level`, `clinical_effect`, `management_advice`, `created_at`) VALUES ('1', 'Warfarin', 'Aspirin', 'CONTRAINDICATED', 'Severe risk of major gastrointestinal hemorrhage and intracranial bleeding.', 'Avoid co-administration or monitor INR daily with dose reduction.', '2026-10-11 02:29:28');
INSERT INTO `pharmacy_drug_interactions` (`id`, `generic_a`, `generic_b`, `severity_level`, `clinical_effect`, `management_advice`, `created_at`) VALUES ('2', 'Ciprofloxacin', 'Antacid', 'SEVERE', 'Multivalent cations bind ciprofloxacin in gut, reducing absorption by up to 90%.', 'Administer ciprofloxacin at least 2 hours before or 6 hours after antacids.', '2026-10-11 02:29:28');
INSERT INTO `pharmacy_drug_interactions` (`id`, `generic_a`, `generic_b`, `severity_level`, `clinical_effect`, `management_advice`, `created_at`) VALUES ('3', 'Ketorolac', 'Ibuprofen', 'CONTRAINDICATED', 'Duplicate NSAID therapy causing acute gastric ulceration and renal toxicity.', 'Discontinue one NSAID immediately. Do not combine systemic NSAIDs.', '2026-10-11 02:29:28');
INSERT INTO `pharmacy_drug_interactions` (`id`, `generic_a`, `generic_b`, `severity_level`, `clinical_effect`, `management_advice`, `created_at`) VALUES ('4', 'Metformin', 'Iopamidol', 'CONTRAINDICATED', 'Radiocontrast induced nephropathy leading to severe Metformin-associated Lactic Acidosis (MALA).', 'Withhold Metformin 48h prior to and after contrast imaging until renal function re-evaluated.', '2026-10-11 02:29:28');
INSERT INTO `pharmacy_drug_interactions` (`id`, `generic_a`, `generic_b`, `severity_level`, `clinical_effect`, `management_advice`, `created_at`) VALUES ('5', 'Clopidogrel', 'Omeprazole', 'SEVERE', 'Omeprazole inhibits CYP2C19, reducing active clopidogrel metabolite and antiplatelet efficacy.', 'Switch PPI to Pantoprazole or Rabeprazole which have minimal CYP2C19 inhibition.', '2026-10-11 02:29:28');
INSERT INTO `pharmacy_drug_interactions` (`id`, `generic_a`, `generic_b`, `severity_level`, `clinical_effect`, `management_advice`, `created_at`) VALUES ('6', 'Azithromycin', 'Amiodarone', 'CONTRAINDICATED', 'Additive QT interval prolongation causing Torsades de Pointes fatal ventricular arrhythmia.', 'Avoid combination or perform daily baseline ECG monitoring.', '2026-10-11 02:29:28');

-- Table structure for table `pharmacy_grn`
DROP TABLE IF EXISTS `pharmacy_grn`;
CREATE TABLE `pharmacy_grn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `grn_no` varchar(100) NOT NULL,
  `po_id` bigint(20) unsigned DEFAULT NULL,
  `supplier_id` bigint(20) unsigned NOT NULL,
  `challan_no` varchar(100) DEFAULT NULL,
  `received_date` date NOT NULL,
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `received_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `grn_no` (`grn_no`),
  KEY `supplier_id` (`supplier_id`),
  KEY `idx_grn` (`grn_no`),
  CONSTRAINT `pharmacy_grn_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `pharmacy_suppliers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `pharmacy_hypercare_logs`
DROP TABLE IF EXISTS `pharmacy_hypercare_logs`;
CREATE TABLE `pharmacy_hypercare_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `log_date` date NOT NULL,
  `hypercare_day` int(11) NOT NULL DEFAULT 1,
  `active_counters` int(11) NOT NULL DEFAULT 1,
  `daily_sales_count` int(11) NOT NULL DEFAULT 0,
  `daily_sales_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `cash_variance_status` varchar(50) NOT NULL DEFAULT 'RECONCILED',
  `inventory_sync_status` varchar(50) NOT NULL DEFAULT 'HEALTHY',
  `auditor_name` varchar(100) NOT NULL DEFAULT 'System Auditor',
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `pharmacy_hypercare_logs`
INSERT INTO `pharmacy_hypercare_logs` (`id`, `log_date`, `hypercare_day`, `active_counters`, `daily_sales_count`, `daily_sales_total`, `cash_variance_status`, `inventory_sync_status`, `auditor_name`, `notes`, `created_at`) VALUES ('1', '2026-10-11', '1', '3', '42', '18450.00', 'VERIFIED_ZERO_VARIANCE', 'SYNCHRONIZED', 'Lead Auditor', 'Go-Live Day 1 Hypercare Initialized. 3 POS Counters online, zero inventory stock-out race conditions.', '2026-10-11 02:29:28');

-- Table structure for table `pharmacy_indents`
DROP TABLE IF EXISTS `pharmacy_indents`;
CREATE TABLE `pharmacy_indents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `indent_no` varchar(50) NOT NULL,
  `from_store` varchar(100) NOT NULL DEFAULT 'OPD Pharmacy',
  `to_store` varchar(100) NOT NULL DEFAULT 'Central Warehouse',
  `status` varchar(30) NOT NULL DEFAULT 'REQUESTED',
  `total_items` int(11) NOT NULL DEFAULT 0,
  `requested_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `indent_no` (`indent_no`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `pharmacy_indents`
INSERT INTO `pharmacy_indents` (`id`, `indent_no`, `from_store`, `to_store`, `status`, `total_items`, `requested_by`, `approved_by`, `notes`, `created_at`) VALUES ('1', 'IND-2026-001', 'Daycare Ward', 'Central Warehouse', 'DISPATCHED', '3', '1', NULL, 'Urgent restocking of IV Fluids & Emergency Injectables for Daycare Beds.', '2026-10-11 02:29:29');

-- Table structure for table `pharmacy_invoice_items`
DROP TABLE IF EXISTS `pharmacy_invoice_items`;
CREATE TABLE `pharmacy_invoice_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pharmacy_invoice_id` bigint(20) unsigned NOT NULL,
  `pharmacy_item_id` bigint(20) unsigned NOT NULL,
  `batch_id` bigint(20) unsigned DEFAULT NULL,
  `item_name` varchar(255) NOT NULL,
  `unit_type` varchar(50) NOT NULL DEFAULT 'Piece',
  `quantity` decimal(10,2) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pharmacy_invoice_id` (`pharmacy_invoice_id`),
  KEY `pharmacy_item_id` (`pharmacy_item_id`),
  CONSTRAINT `pharmacy_invoice_items_ibfk_1` FOREIGN KEY (`pharmacy_invoice_id`) REFERENCES `pharmacy_invoices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_invoice_items_ibfk_2` FOREIGN KEY (`pharmacy_item_id`) REFERENCES `pharmacy_items` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `pharmacy_invoices`
DROP TABLE IF EXISTS `pharmacy_invoices`;
CREATE TABLE `pharmacy_invoices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `invoice_no` varchar(100) NOT NULL,
  `patient_id` bigint(20) unsigned DEFAULT NULL,
  `patient_name` varchar(150) DEFAULT NULL,
  `patient_mobile` varchar(50) DEFAULT NULL,
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `vat_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `payable_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `paid_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `due_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `payment_method` varchar(50) DEFAULT 'CASH',
  `status` varchar(50) DEFAULT 'paid',
  `served_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_no` (`invoice_no`),
  KEY `idx_inv_no` (`invoice_no`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `pharmacy_items`
DROP TABLE IF EXISTS `pharmacy_items`;
CREATE TABLE `pharmacy_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `global_medicine_id` bigint(20) unsigned DEFAULT NULL,
  `sku_code` varchar(100) NOT NULL,
  `custom_name` varchar(255) NOT NULL,
  `strength` varchar(50) DEFAULT '500mg',
  `rack_number` varchar(20) DEFAULT 'R-01',
  `shelf_id` varchar(20) DEFAULT 'S-01',
  `bin_number` varchar(20) DEFAULT 'B-01',
  `rack_location` varchar(100) DEFAULT 'Rack A-01',
  `refrigerator_id` varchar(50) DEFAULT 'REF-ALPHA-01',
  `zone_tag` varchar(50) DEFAULT 'Zone-A (Cold-Chain 2-8°C)',
  `reorder_level` decimal(10,2) DEFAULT 20.00,
  `unit_type` varchar(50) DEFAULT 'Box',
  `strips_per_box` int(11) DEFAULT 10,
  `pieces_per_strip` int(11) DEFAULT 10,
  `purchase_price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `mrp` decimal(10,2) NOT NULL DEFAULT 0.00,
  `vat_percentage` decimal(5,2) DEFAULT 0.00,
  `cold_chain_required` tinyint(1) DEFAULT 0,
  `is_schedule_g` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `last_sold_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku_code` (`sku_code`),
  KEY `global_medicine_id` (`global_medicine_id`),
  KEY `idx_sku` (`sku_code`),
  KEY `idx_active` (`is_active`),
  CONSTRAINT `pharmacy_items_ibfk_1` FOREIGN KEY (`global_medicine_id`) REFERENCES `pharmacy_medicines_global` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `pharmacy_items`
INSERT INTO `pharmacy_items` (`id`, `global_medicine_id`, `sku_code`, `custom_name`, `strength`, `rack_number`, `shelf_id`, `bin_number`, `rack_location`, `refrigerator_id`, `zone_tag`, `reorder_level`, `unit_type`, `strips_per_box`, `pieces_per_strip`, `purchase_price`, `mrp`, `vat_percentage`, `cold_chain_required`, `is_schedule_g`, `is_active`, `last_sold_at`, `created_at`) VALUES ('1', NULL, 'SKU-MED-NAPA-500', 'Napa 500mg Tablet', '500mg', 'R-01', 'S-01', 'B-01', '📍 Rack R-01 · Shelf S-01 · Bin B-01', 'REF-ALPHA-01', 'Zone-A (Cold-Chain 2-8°C)', '50.00', 'Strip', '50', '10', '1.00', '1.20', '0.00', '0', '0', '1', NULL, '2026-10-11 02:29:09');
INSERT INTO `pharmacy_items` (`id`, `global_medicine_id`, `sku_code`, `custom_name`, `strength`, `rack_number`, `shelf_id`, `bin_number`, `rack_location`, `refrigerator_id`, `zone_tag`, `reorder_level`, `unit_type`, `strips_per_box`, `pieces_per_strip`, `purchase_price`, `mrp`, `vat_percentage`, `cold_chain_required`, `is_schedule_g`, `is_active`, `last_sold_at`, `created_at`) VALUES ('2', NULL, 'SKU-MED-NAPA-EXTRA', 'Napa Extra Tablet', '500mg', 'R-01', 'S-01', 'B-02', '📍 Rack R-01 · Shelf S-01 · Bin B-02', 'REF-ALPHA-01', 'Zone-A (Cold-Chain 2-8°C)', '50.00', 'Strip', '50', '10', '2.10', '2.50', '0.00', '0', '0', '1', NULL, '2026-10-11 02:29:09');
INSERT INTO `pharmacy_items` (`id`, `global_medicine_id`, `sku_code`, `custom_name`, `strength`, `rack_number`, `shelf_id`, `bin_number`, `rack_location`, `refrigerator_id`, `zone_tag`, `reorder_level`, `unit_type`, `strips_per_box`, `pieces_per_strip`, `purchase_price`, `mrp`, `vat_percentage`, `cold_chain_required`, `is_schedule_g`, `is_active`, `last_sold_at`, `created_at`) VALUES ('3', NULL, 'SKU-MED-ACE-500', 'Ace 500mg Tablet', '500mg', 'R-01', 'S-01', 'B-03', '📍 Rack R-01 · Shelf S-01 · Bin B-03', 'REF-ALPHA-01', 'Zone-A (Cold-Chain 2-8°C)', '50.00', 'Strip', '50', '10', '1.00', '1.20', '0.00', '0', '0', '1', NULL, '2026-10-11 02:29:09');
INSERT INTO `pharmacy_items` (`id`, `global_medicine_id`, `sku_code`, `custom_name`, `strength`, `rack_number`, `shelf_id`, `bin_number`, `rack_location`, `refrigerator_id`, `zone_tag`, `reorder_level`, `unit_type`, `strips_per_box`, `pieces_per_strip`, `purchase_price`, `mrp`, `vat_percentage`, `cold_chain_required`, `is_schedule_g`, `is_active`, `last_sold_at`, `created_at`) VALUES ('4', NULL, 'SKU-MED-SECLO-20', 'Seclo 20mg Capsule', '500mg', 'R-02', 'S-02', 'B-01', '📍 Rack R-02 · Shelf S-02 · Bin B-01', 'REF-ALPHA-01', 'Zone-A (Cold-Chain 2-8°C)', '50.00', 'Box', '6', '10', '5.10', '6.00', '0.00', '0', '0', '1', NULL, '2026-10-11 02:29:09');
INSERT INTO `pharmacy_items` (`id`, `global_medicine_id`, `sku_code`, `custom_name`, `strength`, `rack_number`, `shelf_id`, `bin_number`, `rack_location`, `refrigerator_id`, `zone_tag`, `reorder_level`, `unit_type`, `strips_per_box`, `pieces_per_strip`, `purchase_price`, `mrp`, `vat_percentage`, `cold_chain_required`, `is_schedule_g`, `is_active`, `last_sold_at`, `created_at`) VALUES ('5', NULL, 'SKU-MED-SERGEL-20', 'Sergel 20mg Capsule', '500mg', 'R-02', 'S-02', 'B-02', '📍 Rack R-02 · Shelf S-02 · Bin B-02', 'REF-ALPHA-01', 'Zone-A (Cold-Chain 2-8°C)', '50.00', 'Box', '5', '10', '6.00', '7.00', '0.00', '0', '0', '1', NULL, '2026-10-11 02:29:09');
INSERT INTO `pharmacy_items` (`id`, `global_medicine_id`, `sku_code`, `custom_name`, `strength`, `rack_number`, `shelf_id`, `bin_number`, `rack_location`, `refrigerator_id`, `zone_tag`, `reorder_level`, `unit_type`, `strips_per_box`, `pieces_per_strip`, `purchase_price`, `mrp`, `vat_percentage`, `cold_chain_required`, `is_schedule_g`, `is_active`, `last_sold_at`, `created_at`) VALUES ('6', NULL, 'SKU-MED-CIPROCIN-500', 'Ciprocin 500mg Tablet', '500mg', 'R-03', 'S-01', 'B-01', '📍 Rack R-03 · Shelf S-01 · Bin B-01', 'REF-ALPHA-01', 'Zone-A (Cold-Chain 2-8°C)', '50.00', 'Strip', '3', '10', '12.50', '15.00', '0.00', '0', '0', '1', NULL, '2026-10-11 02:29:09');
INSERT INTO `pharmacy_items` (`id`, `global_medicine_id`, `sku_code`, `custom_name`, `strength`, `rack_number`, `shelf_id`, `bin_number`, `rack_location`, `refrigerator_id`, `zone_tag`, `reorder_level`, `unit_type`, `strips_per_box`, `pieces_per_strip`, `purchase_price`, `mrp`, `vat_percentage`, `cold_chain_required`, `is_schedule_g`, `is_active`, `last_sold_at`, `created_at`) VALUES ('7', NULL, 'SKU-MED-MAXPRO-20', 'Maxpro 20mg Capsule', '500mg', 'R-02', 'S-03', 'B-01', '📍 Rack R-02 · Shelf S-03 · Bin B-01', 'REF-ALPHA-01', 'Zone-A (Cold-Chain 2-8°C)', '50.00', 'Box', '5', '10', '6.00', '7.00', '0.00', '0', '0', '1', NULL, '2026-10-11 02:29:09');
INSERT INTO `pharmacy_items` (`id`, `global_medicine_id`, `sku_code`, `custom_name`, `strength`, `rack_number`, `shelf_id`, `bin_number`, `rack_location`, `refrigerator_id`, `zone_tag`, `reorder_level`, `unit_type`, `strips_per_box`, `pieces_per_strip`, `purchase_price`, `mrp`, `vat_percentage`, `cold_chain_required`, `is_schedule_g`, `is_active`, `last_sold_at`, `created_at`) VALUES ('8', NULL, 'SKU-MED-RIVOTRIL-05', 'Rivotril 0.5mg Tablet (Schedule-G Narcotic)', '500mg', 'R-LOCK', 'S-SAFE', 'B-NARCOTIC', '🔒 Locked Narcotics Safe · Shelf S-SAFE · Bin B-NARCOTIC', 'REF-ALPHA-01', 'Zone-A (Cold-Chain 2-8°C)', '50.00', 'Strip', '5', '10', '5.00', '6.00', '0.00', '0', '1', '1', NULL, '2026-10-11 02:29:09');
INSERT INTO `pharmacy_items` (`id`, `global_medicine_id`, `sku_code`, `custom_name`, `strength`, `rack_number`, `shelf_id`, `bin_number`, `rack_location`, `refrigerator_id`, `zone_tag`, `reorder_level`, `unit_type`, `strips_per_box`, `pieces_per_strip`, `purchase_price`, `mrp`, `vat_percentage`, `cold_chain_required`, `is_schedule_g`, `is_active`, `last_sold_at`, `created_at`) VALUES ('9', NULL, 'SKU-MED-MONAS-10', 'Monas 10mg Tablet', '500mg', 'R-04', 'S-01', 'B-02', '📍 Rack R-04 · Shelf S-01 · Bin B-02', 'REF-ALPHA-01', 'Zone-A (Cold-Chain 2-8°C)', '50.00', 'Box', '3', '10', '13.50', '16.00', '0.00', '0', '0', '1', NULL, '2026-10-11 02:29:09');
INSERT INTO `pharmacy_items` (`id`, `global_medicine_id`, `sku_code`, `custom_name`, `strength`, `rack_number`, `shelf_id`, `bin_number`, `rack_location`, `refrigerator_id`, `zone_tag`, `reorder_level`, `unit_type`, `strips_per_box`, `pieces_per_strip`, `purchase_price`, `mrp`, `vat_percentage`, `cold_chain_required`, `is_schedule_g`, `is_active`, `last_sold_at`, `created_at`) VALUES ('10', NULL, 'SKU-MED-ALATROL-10', 'Alatrol 10mg Tablet', '500mg', 'R-01', 'S-03', 'B-04', '📍 Rack R-01 · Shelf S-03 · Bin B-04', 'REF-ALPHA-01', 'Zone-A (Cold-Chain 2-8°C)', '50.00', 'Strip', '10', '10', '2.50', '3.00', '0.00', '0', '0', '1', NULL, '2026-10-11 02:29:09');

-- Table structure for table `pharmacy_loyalty_points`
DROP TABLE IF EXISTS `pharmacy_loyalty_points`;
CREATE TABLE `pharmacy_loyalty_points` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_mobile` varchar(20) NOT NULL,
  `patient_name` varchar(150) NOT NULL,
  `total_points` int(11) NOT NULL DEFAULT 0,
  `points_redeemed` int(11) NOT NULL DEFAULT 0,
  `points_balance` int(11) NOT NULL DEFAULT 0,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `patient_mobile` (`patient_mobile`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `pharmacy_loyalty_points`
INSERT INTO `pharmacy_loyalty_points` (`id`, `patient_mobile`, `patient_name`, `total_points`, `points_redeemed`, `points_balance`, `updated_at`) VALUES ('1', '01711000001', 'Mr. Jahangir Alam', '450', '100', '350', '2026-10-11 02:29:29');
INSERT INTO `pharmacy_loyalty_points` (`id`, `patient_mobile`, `patient_name`, `total_points`, `points_redeemed`, `points_balance`, `updated_at`) VALUES ('2', '01819000002', 'Mrs. Rashida Begum', '280', '0', '280', '2026-10-11 02:29:29');

-- Table structure for table `pharmacy_medicines_global`
DROP TABLE IF EXISTS `pharmacy_medicines_global`;
CREATE TABLE `pharmacy_medicines_global` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `brand_name` varchar(255) NOT NULL,
  `generic_name` varchar(255) NOT NULL,
  `strength` varchar(100) DEFAULT NULL,
  `dosage_form` varchar(100) DEFAULT NULL,
  `manufacturer` varchar(255) NOT NULL,
  `country` varchar(100) DEFAULT 'Bangladesh',
  `dgda_dar_no` varchar(100) DEFAULT NULL,
  `therapeutic_class` varchar(255) DEFAULT NULL,
  `who_atc_code` varchar(50) DEFAULT NULL,
  `is_narcotic` tinyint(1) DEFAULT 0,
  `storage_temp` varchar(100) DEFAULT '2°C - 25°C',
  `indicative_mrp` decimal(10,2) DEFAULT 0.00,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_brand` (`brand_name`),
  KEY `idx_generic` (`generic_name`),
  KEY `idx_manufacturer` (`manufacturer`),
  KEY `idx_dar` (`dgda_dar_no`),
  KEY `idx_class` (`therapeutic_class`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `pharmacy_physical_migrations`
DROP TABLE IF EXISTS `pharmacy_physical_migrations`;
CREATE TABLE `pharmacy_physical_migrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `migration_code` varchar(50) NOT NULL,
  `imported_by` varchar(100) NOT NULL,
  `total_items_imported` int(11) NOT NULL DEFAULT 0,
  `total_valuation` decimal(14,2) NOT NULL DEFAULT 0.00,
  `status` varchar(30) NOT NULL DEFAULT 'COMPLETED',
  `remarks` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `migration_code` (`migration_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `pharmacy_po_items`
DROP TABLE IF EXISTS `pharmacy_po_items`;
CREATE TABLE `pharmacy_po_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `po_id` bigint(20) unsigned NOT NULL,
  `pharmacy_item_id` bigint(20) unsigned NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `po_id` (`po_id`),
  KEY `pharmacy_item_id` (`pharmacy_item_id`),
  CONSTRAINT `pharmacy_po_items_ibfk_1` FOREIGN KEY (`po_id`) REFERENCES `pharmacy_purchase_orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_po_items_ibfk_2` FOREIGN KEY (`pharmacy_item_id`) REFERENCES `pharmacy_items` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `pharmacy_prescription_items`
DROP TABLE IF EXISTS `pharmacy_prescription_items`;
CREATE TABLE `pharmacy_prescription_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `prescription_id` bigint(20) unsigned NOT NULL,
  `pharmacy_item_id` bigint(20) unsigned NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `dosage_instruction` varchar(150) NOT NULL,
  `duration_days` int(11) DEFAULT 7,
  `quantity` decimal(10,2) NOT NULL,
  `is_narcotic` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `prescription_id` (`prescription_id`),
  KEY `pharmacy_item_id` (`pharmacy_item_id`),
  CONSTRAINT `pharmacy_prescription_items_ibfk_1` FOREIGN KEY (`prescription_id`) REFERENCES `pharmacy_prescriptions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_prescription_items_ibfk_2` FOREIGN KEY (`pharmacy_item_id`) REFERENCES `pharmacy_items` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `pharmacy_prescription_items`
INSERT INTO `pharmacy_prescription_items` (`id`, `prescription_id`, `pharmacy_item_id`, `item_name`, `dosage_instruction`, `duration_days`, `quantity`, `is_narcotic`) VALUES ('1', '1', '1', 'Lantus SoloStar Pen 100 IU/ml', '10 units subcutaneously at bedtime', '30', '2.00', '0');
INSERT INTO `pharmacy_prescription_items` (`id`, `prescription_id`, `pharmacy_item_id`, `item_name`, `dosage_instruction`, `duration_days`, `quantity`, `is_narcotic`) VALUES ('2', '1', '2', 'Linaglip M 2.5/500 Tablet', '1 tablet twice daily after meals', '30', '60.00', '0');

-- Table structure for table `pharmacy_prescriptions`
DROP TABLE IF EXISTS `pharmacy_prescriptions`;
CREATE TABLE `pharmacy_prescriptions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `rx_no` varchar(100) NOT NULL,
  `patient_id` bigint(20) unsigned DEFAULT NULL,
  `patient_name` varchar(150) NOT NULL,
  `patient_uhid` varchar(50) NOT NULL,
  `doctor_name` varchar(150) NOT NULL,
  `doctor_reg_no` varchar(100) NOT NULL,
  `is_narcotic_restricted` tinyint(1) DEFAULT 0,
  `rx_file_path` varchar(255) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'unfulfilled',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `rx_no` (`rx_no`),
  KEY `idx_rx` (`rx_no`),
  KEY `idx_uhid` (`patient_uhid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `pharmacy_prescriptions`
INSERT INTO `pharmacy_prescriptions` (`id`, `rx_no`, `patient_id`, `patient_name`, `patient_uhid`, `doctor_name`, `doctor_reg_no`, `is_narcotic_restricted`, `rx_file_path`, `status`, `created_at`) VALUES ('1', 'RX-LUDC-2026-0081', NULL, 'Begum Rokeya', 'UHID-2026-10492', 'Prof. Dr. A.K. Azad (Endocrinologist)', 'A-29481', '0', NULL, 'unfulfilled', '2026-10-11 02:35:23');

-- Table structure for table `pharmacy_purchase_orders`
DROP TABLE IF EXISTS `pharmacy_purchase_orders`;
CREATE TABLE `pharmacy_purchase_orders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `po_no` varchar(100) NOT NULL,
  `supplier_id` bigint(20) unsigned NOT NULL,
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` varchar(50) DEFAULT 'issued',
  `created_by` bigint(20) unsigned NOT NULL,
  `approved_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `po_no` (`po_no`),
  KEY `supplier_id` (`supplier_id`),
  KEY `idx_po_no` (`po_no`),
  CONSTRAINT `pharmacy_purchase_orders_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `pharmacy_suppliers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `pharmacy_purchase_requisitions`
DROP TABLE IF EXISTS `pharmacy_purchase_requisitions`;
CREATE TABLE `pharmacy_purchase_requisitions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pr_no` varchar(100) NOT NULL,
  `supplier_id` bigint(20) unsigned NOT NULL,
  `pharmacy_item_id` bigint(20) unsigned NOT NULL,
  `current_stock` decimal(10,2) NOT NULL DEFAULT 0.00,
  `reorder_level` decimal(10,2) NOT NULL DEFAULT 20.00,
  `daily_sales_velocity` decimal(10,2) NOT NULL DEFAULT 0.00,
  `suggested_qty` decimal(10,2) NOT NULL DEFAULT 100.00,
  `status` varchar(50) NOT NULL DEFAULT 'draft',
  `requested_by` bigint(20) unsigned DEFAULT NULL,
  `approved_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `pr_no` (`pr_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `pharmacy_quarantine`
DROP TABLE IF EXISTS `pharmacy_quarantine`;
CREATE TABLE `pharmacy_quarantine` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_no` varchar(100) NOT NULL,
  `pharmacy_item_id` bigint(20) unsigned NOT NULL,
  `batch_id` bigint(20) unsigned DEFAULT NULL,
  `batch_number` varchar(100) DEFAULT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `reason` varchar(100) NOT NULL,
  `notes` text DEFAULT NULL,
  `status` varchar(50) DEFAULT 'pending',
  `requested_by` bigint(20) unsigned NOT NULL,
  `approved_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `ticket_no` (`ticket_no`),
  KEY `pharmacy_item_id` (`pharmacy_item_id`),
  KEY `idx_ticket` (`ticket_no`),
  CONSTRAINT `pharmacy_quarantine_ibfk_1` FOREIGN KEY (`pharmacy_item_id`) REFERENCES `pharmacy_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `pharmacy_refill_reminders`
DROP TABLE IF EXISTS `pharmacy_refill_reminders`;
CREATE TABLE `pharmacy_refill_reminders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_name` varchar(150) NOT NULL,
  `patient_mobile` varchar(50) NOT NULL,
  `patient_uhid` varchar(50) DEFAULT NULL,
  `chronic_condition` varchar(100) NOT NULL DEFAULT 'DIABETES',
  `medicine_name` varchar(255) NOT NULL,
  `last_refill_date` date NOT NULL,
  `next_refill_due_date` date NOT NULL,
  `sms_status` varchar(50) NOT NULL DEFAULT 'PENDING',
  `sent_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `pharmacy_returns`
DROP TABLE IF EXISTS `pharmacy_returns`;
CREATE TABLE `pharmacy_returns` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `return_no` varchar(100) NOT NULL,
  `invoice_id` bigint(20) unsigned NOT NULL,
  `invoice_no` varchar(100) NOT NULL,
  `patient_name` varchar(150) NOT NULL,
  `refund_amount` decimal(10,2) NOT NULL,
  `credit_note_no` varchar(100) NOT NULL,
  `reason` text DEFAULT NULL,
  `processed_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `return_no` (`return_no`),
  KEY `invoice_id` (`invoice_id`),
  KEY `idx_ret` (`return_no`),
  CONSTRAINT `pharmacy_returns_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `pharmacy_invoices` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `pharmacy_rtv_notes`
DROP TABLE IF EXISTS `pharmacy_rtv_notes`;
CREATE TABLE `pharmacy_rtv_notes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `rtv_no` varchar(100) NOT NULL,
  `quarantine_id` bigint(20) unsigned NOT NULL,
  `supplier_id` bigint(20) unsigned NOT NULL,
  `pharmacy_item_id` bigint(20) unsigned NOT NULL,
  `batch_number` varchar(100) NOT NULL,
  `quantity` decimal(10,2) NOT NULL DEFAULT 0.00,
  `unit_cost` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_debit_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `note_type` varchar(50) NOT NULL DEFAULT 'DEBIT_NOTE',
  `reason` varchar(150) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'ISSUED',
  `issued_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `rtv_no` (`rtv_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `pharmacy_scheduleg_logs`
DROP TABLE IF EXISTS `pharmacy_scheduleg_logs`;
CREATE TABLE `pharmacy_scheduleg_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `invoice_id` bigint(20) unsigned DEFAULT NULL,
  `invoice_no` varchar(100) NOT NULL,
  `patient_name` varchar(150) NOT NULL,
  `patient_mobile` varchar(50) DEFAULT NULL,
  `doctor_name` varchar(150) NOT NULL,
  `doctor_bmdc_no` varchar(100) NOT NULL,
  `rx_no` varchar(100) DEFAULT NULL,
  `pharmacy_item_id` bigint(20) unsigned NOT NULL,
  `medicine_name` varchar(255) NOT NULL,
  `quantity_dispensed` decimal(10,2) NOT NULL DEFAULT 1.00,
  `unit_type` varchar(50) NOT NULL DEFAULT 'Pcs',
  `dispensed_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `pharmacy_supplier_payments`
DROP TABLE IF EXISTS `pharmacy_supplier_payments`;
CREATE TABLE `pharmacy_supplier_payments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `voucher_no` varchar(100) NOT NULL,
  `supplier_id` bigint(20) unsigned NOT NULL,
  `payment_date` date NOT NULL,
  `amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `payment_method` varchar(50) NOT NULL DEFAULT 'BANK_TRANSFER',
  `reference_no` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `voucher_no` (`voucher_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `pharmacy_suppliers`
DROP TABLE IF EXISTS `pharmacy_suppliers`;
CREATE TABLE `pharmacy_suppliers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `supplier_code` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `contact_person` varchar(150) DEFAULT NULL,
  `phone` varchar(50) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `drug_license_no` varchar(100) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `supplier_code` (`supplier_code`),
  KEY `idx_code` (`supplier_code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `pharmacy_suppliers`
INSERT INTO `pharmacy_suppliers` (`id`, `supplier_code`, `name`, `contact_person`, `phone`, `email`, `address`, `drug_license_no`, `status`, `created_at`) VALUES ('1', 'SUP-SQ-001', 'Square Pharmaceuticals Ltd', 'Md. Harun-ur-Rashid', '01711002233', 'info@squarepharma.com.bd', 'Square Centre, 48 Mohakhali C/A, Dhaka-1212', 'DL-DHAKA-10293', 'active', '2026-10-11 02:35:23');
INSERT INTO `pharmacy_suppliers` (`id`, `supplier_code`, `name`, `contact_person`, `phone`, `email`, `address`, `drug_license_no`, `status`, `created_at`) VALUES ('2', 'SUP-IN-002', 'Incepta Pharmaceuticals Ltd', 'Shahidul Islam', '01819223344', 'sales@inceptapharma.com', '40 Shahid Tajuddin Ahmed Sarani, Tejgaon, Dhaka', 'DL-DHAKA-10882', 'active', '2026-10-11 02:35:23');
INSERT INTO `pharmacy_suppliers` (`id`, `supplier_code`, `name`, `contact_person`, `phone`, `email`, `address`, `drug_license_no`, `status`, `created_at`) VALUES ('3', 'SUP-NV-003', 'Novo Nordisk Bangladesh (Cold-Chain)', 'Tanvir Ahmed', '01911445566', 'coldchain@novonordisk.bd', 'Gulshan 1, Dhaka-1212', 'DL-DHAKA-11200', 'active', '2026-10-11 02:35:23');
INSERT INTO `pharmacy_suppliers` (`id`, `supplier_code`, `name`, `contact_person`, `phone`, `email`, `address`, `drug_license_no`, `status`, `created_at`) VALUES ('4', 'SUP-SA-004', 'Sanofi Bangladesh Ltd', 'Dr. Farhana Rahman', '01730998877', 'orders@sanofi.com.bd', '623 Begum Rokeya Sarani, Dhaka', 'DL-DHAKA-10544', 'active', '2026-10-11 02:35:23');

-- Table structure for table `pharmacy_vendor_ttr`
DROP TABLE IF EXISTS `pharmacy_vendor_ttr`;
CREATE TABLE `pharmacy_vendor_ttr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_name` varchar(150) NOT NULL,
  `quarter_period` varchar(50) NOT NULL,
  `target_sales_amount` decimal(14,2) NOT NULL,
  `achieved_sales_amount` decimal(14,2) NOT NULL,
  `rebate_percentage` decimal(5,2) NOT NULL DEFAULT 3.00,
  `estimated_rebate_amount` decimal(12,2) NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'ON_TRACK',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `pharmacy_vendor_ttr`
INSERT INTO `pharmacy_vendor_ttr` (`id`, `supplier_name`, `quarter_period`, `target_sales_amount`, `achieved_sales_amount`, `rebate_percentage`, `estimated_rebate_amount`, `status`, `created_at`) VALUES ('1', 'Square Pharmaceuticals PLC', 'Q3 2026 (Jul - Sep)', '500000.00', '420000.00', '3.50', '14700.00', 'ON_TRACK', '2026-10-11 02:29:29');
INSERT INTO `pharmacy_vendor_ttr` (`id`, `supplier_name`, `quarter_period`, `target_sales_amount`, `achieved_sales_amount`, `rebate_percentage`, `estimated_rebate_amount`, `status`, `created_at`) VALUES ('2', 'Beximco Pharmaceuticals Ltd', 'Q3 2026 (Jul - Sep)', '350000.00', '365000.00', '4.00', '14600.00', 'TARGET_ACHIEVED', '2026-10-11 02:29:29');
INSERT INTO `pharmacy_vendor_ttr` (`id`, `supplier_name`, `quarter_period`, `target_sales_amount`, `achieved_sales_amount`, `rebate_percentage`, `estimated_rebate_amount`, `status`, `created_at`) VALUES ('3', 'Incepta Pharmaceuticals Ltd', 'Q3 2026 (Jul - Sep)', '300000.00', '210000.00', '3.00', '6300.00', 'ACTION_REQUIRED', '2026-10-11 02:29:29');

-- Table structure for table `pharmacy_void_logs`
DROP TABLE IF EXISTS `pharmacy_void_logs`;
CREATE TABLE `pharmacy_void_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_no` varchar(50) NOT NULL,
  `patient_name` varchar(150) NOT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `void_reason` varchar(255) NOT NULL,
  `supervisor_otp` varchar(20) NOT NULL,
  `voided_by` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `pharmacy_void_logs`
INSERT INTO `pharmacy_void_logs` (`id`, `invoice_no`, `patient_name`, `total_amount`, `void_reason`, `supervisor_otp`, `voided_by`, `created_at`) VALUES ('1', 'INV-PHARM-20260930-1012', 'Mr. Jahangir Alam', '850.00', 'Customer changed dosage prescription before payment', 'OTP-9941', 'Shift Supervisor', '2026-10-11 02:29:29');

-- Table structure for table `purchase_orders`
DROP TABLE IF EXISTS `purchase_orders`;
CREATE TABLE `purchase_orders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `po_no` varchar(30) NOT NULL,
  `supplier_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `total_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `status` enum('issued','received','cancelled') NOT NULL DEFAULT 'issued',
  `created_by` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `po_date` date DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `payment_status` enum('unpaid','partial','paid') DEFAULT 'unpaid',
  `tds_amount` decimal(15,2) DEFAULT 0.00,
  `vds_amount` decimal(15,2) DEFAULT 0.00,
  PRIMARY KEY (`id`),
  UNIQUE KEY `po_no` (`po_no`),
  KEY `supplier_id` (`supplier_id`),
  KEY `branch_id` (`branch_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `purchase_orders_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `purchase_orders_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `purchase_orders_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `purchase_orders`
INSERT INTO `purchase_orders` (`id`, `po_no`, `supplier_id`, `branch_id`, `total_amount`, `status`, `created_by`, `created_at`, `po_date`, `delivery_date`, `notes`, `payment_status`, `tds_amount`, `vds_amount`) VALUES ('1', 'PO-2026-001', '1', '1', '145000.00', 'received', '1', '2026-10-20 14:54:04', '2026-10-15', '2026-10-25', 'Monthly automated biochemistry reagent pack (Cobas C311)', 'paid', '7250.00', '10875.00');
INSERT INTO `purchase_orders` (`id`, `po_no`, `supplier_id`, `branch_id`, `total_amount`, `status`, `created_by`, `created_at`, `po_date`, `delivery_date`, `notes`, `payment_status`, `tds_amount`, `vds_amount`) VALUES ('2', 'PO-2026-002', '2', '1', '98000.00', 'received', '1', '2026-10-20 14:54:04', '2026-10-15', '2026-10-25', 'Sysmex XN-550 hematology diluent, lyse and sheath reagent kits', 'partial', '4900.00', '7350.00');
INSERT INTO `purchase_orders` (`id`, `po_no`, `supplier_id`, `branch_id`, `total_amount`, `status`, `created_by`, `created_at`, `po_date`, `delivery_date`, `notes`, `payment_status`, `tds_amount`, `vds_amount`) VALUES ('3', 'PO-2026-003', '3', '1', '220000.00', 'issued', '1', '2026-10-20 14:54:04', '2026-10-15', '2026-10-25', 'X-Ray cassette digital sensor replacement & contrast media supply', 'unpaid', '11000.00', '16500.00');
INSERT INTO `purchase_orders` (`id`, `po_no`, `supplier_id`, `branch_id`, `total_amount`, `status`, `created_by`, `created_at`, `po_date`, `delivery_date`, `notes`, `payment_status`, `tds_amount`, `vds_amount`) VALUES ('4', 'PO-2026-004', '4', '1', '45000.00', 'received', '1', '2026-10-20 14:54:05', '2026-10-15', '2026-10-25', 'Bio-Rad Lyphochek international immunoassay control kits (Level 1,2,3)', 'paid', '2250.00', '3375.00');
INSERT INTO `purchase_orders` (`id`, `po_no`, `supplier_id`, `branch_id`, `total_amount`, `status`, `created_by`, `created_at`, `po_date`, `delivery_date`, `notes`, `payment_status`, `tds_amount`, `vds_amount`) VALUES ('5', 'PO-2026-005', '5', '1', '65000.00', 'issued', '1', '2026-10-20 14:54:05', '2026-10-15', '2026-10-25', 'BD Vacutainer blood collection tubes (EDTA, Gel, Fluoride) 5000 pcs', 'unpaid', '3250.00', '4875.00');

-- Table structure for table `purchase_requisitions`
DROP TABLE IF EXISTS `purchase_requisitions`;
CREATE TABLE `purchase_requisitions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `req_no` varchar(30) NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `requested_by` bigint(20) unsigned NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `req_no` (`req_no`),
  KEY `branch_id` (`branch_id`),
  KEY `department_id` (`department_id`),
  KEY `requested_by` (`requested_by`),
  CONSTRAINT `purchase_requisitions_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `purchase_requisitions_ibfk_2` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `purchase_requisitions_ibfk_3` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `quality_controls`
DROP TABLE IF EXISTS `quality_controls`;
CREATE TABLE `quality_controls` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `section_name` varchar(100) NOT NULL,
  `test_id` bigint(20) unsigned DEFAULT NULL,
  `qc_level` enum('level_1','level_2','level_3') NOT NULL DEFAULT 'level_1',
  `target_value` decimal(10,4) NOT NULL DEFAULT 0.0000,
  `observed_value` decimal(10,4) NOT NULL DEFAULT 0.0000,
  `status` enum('passed','out_of_control') NOT NULL DEFAULT 'passed',
  `logged_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `test_id` (`test_id`),
  CONSTRAINT `quality_controls_ibfk_1` FOREIGN KEY (`test_id`) REFERENCES `diagnostic_tests` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `quality_controls`
INSERT INTO `quality_controls` (`id`, `section_name`, `test_id`, `qc_level`, `target_value`, `observed_value`, `status`, `logged_at`) VALUES ('1', 'Biochemistry', '1', 'level_1', '100.0000', '100.8000', 'passed', '2026-10-21 10:12:17');
INSERT INTO `quality_controls` (`id`, `section_name`, `test_id`, `qc_level`, `target_value`, `observed_value`, `status`, `logged_at`) VALUES ('2', 'Biochemistry', '1', 'level_2', '250.0000', '252.4000', 'passed', '2026-10-21 09:12:17');
INSERT INTO `quality_controls` (`id`, `section_name`, `test_id`, `qc_level`, `target_value`, `observed_value`, `status`, `logged_at`) VALUES ('3', 'Biochemistry', '3', 'level_1', '5.8000', '5.7600', 'passed', '2026-10-21 08:12:17');
INSERT INTO `quality_controls` (`id`, `section_name`, `test_id`, `qc_level`, `target_value`, `observed_value`, `status`, `logged_at`) VALUES ('4', 'Hematology', '9', 'level_1', '14.5000', '14.4200', 'passed', '2026-10-21 07:12:17');
INSERT INTO `quality_controls` (`id`, `section_name`, `test_id`, `qc_level`, `target_value`, `observed_value`, `status`, `logged_at`) VALUES ('5', 'Hematology', '9', 'level_2', '8.2000', '8.1800', 'passed', '2026-10-21 06:12:17');
INSERT INTO `quality_controls` (`id`, `section_name`, `test_id`, `qc_level`, `target_value`, `observed_value`, `status`, `logged_at`) VALUES ('6', 'Immunology', '4', 'level_1', '2.4500', '2.4800', 'passed', '2026-10-21 05:12:17');
INSERT INTO `quality_controls` (`id`, `section_name`, `test_id`, `qc_level`, `target_value`, `observed_value`, `status`, `logged_at`) VALUES ('7', 'Biochemistry', '8', 'level_3', '3.2000', '3.8200', 'out_of_control', '2026-10-21 03:12:17');
INSERT INTO `quality_controls` (`id`, `section_name`, `test_id`, `qc_level`, `target_value`, `observed_value`, `status`, `logged_at`) VALUES ('8', 'Microbiology', NULL, 'level_1', '99.5000', '99.2000', 'passed', '2026-10-20 23:12:17');
INSERT INTO `quality_controls` (`id`, `section_name`, `test_id`, `qc_level`, `target_value`, `observed_value`, `status`, `logged_at`) VALUES ('9', 'Biochemistry', '4', 'level_1', '1.0500', '1.0400', 'passed', '2026-10-20 11:12:17');
INSERT INTO `quality_controls` (`id`, `section_name`, `test_id`, `qc_level`, `target_value`, `observed_value`, `status`, `logged_at`) VALUES ('10', 'Hematology', '9', 'level_3', '4.1000', '4.0800', 'passed', '2026-10-20 13:12:17');

-- Table structure for table `queue_tokens`
DROP TABLE IF EXISTS `queue_tokens`;
CREATE TABLE `queue_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `token_no` varchar(30) NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `service_area` enum('registration','billing','sample_collection','doctor_chamber','imaging') NOT NULL,
  `counter_id` bigint(20) unsigned DEFAULT NULL,
  `patient_id` bigint(20) unsigned DEFAULT NULL,
  `order_id` bigint(20) unsigned DEFAULT NULL,
  `appointment_id` bigint(20) unsigned DEFAULT NULL,
  `priority` enum('normal','urgent','senior_vip') NOT NULL DEFAULT 'normal',
  `status` enum('waiting','called','serving','completed','skipped') NOT NULL DEFAULT 'waiting',
  `called_at` datetime DEFAULT NULL,
  `served_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `branch_id` (`branch_id`),
  KEY `counter_id` (`counter_id`),
  KEY `patient_id` (`patient_id`),
  KEY `order_id` (`order_id`),
  KEY `appointment_id` (`appointment_id`),
  CONSTRAINT `queue_tokens_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `queue_tokens_ibfk_2` FOREIGN KEY (`counter_id`) REFERENCES `counters` (`id`),
  CONSTRAINT `queue_tokens_ibfk_3` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`),
  CONSTRAINT `queue_tokens_ibfk_4` FOREIGN KEY (`order_id`) REFERENCES `diagnostic_orders` (`id`),
  CONSTRAINT `queue_tokens_ibfk_5` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `queue_tokens`
INSERT INTO `queue_tokens` (`id`, `token_no`, `branch_id`, `service_area`, `counter_id`, `patient_id`, `order_id`, `appointment_id`, `priority`, `status`, `called_at`, `served_at`, `completed_at`, `created_at`) VALUES ('1', 'DOC-001', '1', 'doctor_chamber', NULL, '3', NULL, '1', 'normal', 'waiting', NULL, NULL, NULL, '2026-10-11 12:23:20');
INSERT INTO `queue_tokens` (`id`, `token_no`, `branch_id`, `service_area`, `counter_id`, `patient_id`, `order_id`, `appointment_id`, `priority`, `status`, `called_at`, `served_at`, `completed_at`, `created_at`) VALUES ('2', 'BIL-001', '1', 'billing', '6', '5', '6', NULL, 'normal', 'called', '2026-10-11 15:42:41', NULL, NULL, '2026-10-11 15:12:51');
INSERT INTO `queue_tokens` (`id`, `token_no`, `branch_id`, `service_area`, `counter_id`, `patient_id`, `order_id`, `appointment_id`, `priority`, `status`, `called_at`, `served_at`, `completed_at`, `created_at`) VALUES ('3', 'BIL-002', '1', 'billing', '6', '4', '7', NULL, 'normal', 'called', '2026-10-11 15:42:55', NULL, NULL, '2026-10-11 15:42:21');
INSERT INTO `queue_tokens` (`id`, `token_no`, `branch_id`, `service_area`, `counter_id`, `patient_id`, `order_id`, `appointment_id`, `priority`, `status`, `called_at`, `served_at`, `completed_at`, `created_at`) VALUES ('4', 'BIL-003', '1', 'billing', NULL, '6', '8', NULL, 'normal', 'waiting', NULL, NULL, NULL, '2026-10-11 15:57:30');
INSERT INTO `queue_tokens` (`id`, `token_no`, `branch_id`, `service_area`, `counter_id`, `patient_id`, `order_id`, `appointment_id`, `priority`, `status`, `called_at`, `served_at`, `completed_at`, `created_at`) VALUES ('5', 'SPL-001', '1', 'sample_collection', NULL, '1', '1', NULL, 'normal', 'waiting', NULL, NULL, NULL, '2026-10-11 16:20:09');
INSERT INTO `queue_tokens` (`id`, `token_no`, `branch_id`, `service_area`, `counter_id`, `patient_id`, `order_id`, `appointment_id`, `priority`, `status`, `called_at`, `served_at`, `completed_at`, `created_at`) VALUES ('6', 'SPL-002', '1', 'sample_collection', NULL, '6', '8', NULL, 'normal', 'waiting', NULL, NULL, NULL, '2026-10-11 17:14:04');
INSERT INTO `queue_tokens` (`id`, `token_no`, `branch_id`, `service_area`, `counter_id`, `patient_id`, `order_id`, `appointment_id`, `priority`, `status`, `called_at`, `served_at`, `completed_at`, `created_at`) VALUES ('7', 'BIL-001', '1', 'billing', '6', '6', '13', NULL, 'normal', 'called', '2026-10-20 13:23:59', NULL, NULL, '2026-10-20 13:23:49');
INSERT INTO `queue_tokens` (`id`, `token_no`, `branch_id`, `service_area`, `counter_id`, `patient_id`, `order_id`, `appointment_id`, `priority`, `status`, `called_at`, `served_at`, `completed_at`, `created_at`) VALUES ('8', 'BIL-001', '1', 'billing', NULL, '1', '19', NULL, 'normal', 'waiting', NULL, NULL, NULL, '2026-10-21 12:24:28');
INSERT INTO `queue_tokens` (`id`, `token_no`, `branch_id`, `service_area`, `counter_id`, `patient_id`, `order_id`, `appointment_id`, `priority`, `status`, `called_at`, `served_at`, `completed_at`, `created_at`) VALUES ('9', 'DOC-001', '1', 'doctor_chamber', NULL, '6', NULL, '13', 'normal', 'waiting', NULL, NULL, NULL, '2026-10-21 14:25:01');
INSERT INTO `queue_tokens` (`id`, `token_no`, `branch_id`, `service_area`, `counter_id`, `patient_id`, `order_id`, `appointment_id`, `priority`, `status`, `called_at`, `served_at`, `completed_at`, `created_at`) VALUES ('10', 'BIL-002', '1', 'billing', NULL, '14', '20', NULL, 'normal', 'waiting', NULL, NULL, NULL, '2026-10-21 14:46:41');
INSERT INTO `queue_tokens` (`id`, `token_no`, `branch_id`, `service_area`, `counter_id`, `patient_id`, `order_id`, `appointment_id`, `priority`, `status`, `called_at`, `served_at`, `completed_at`, `created_at`) VALUES ('11', 'DOC-002', '1', 'doctor_chamber', NULL, '22', NULL, NULL, 'normal', 'waiting', NULL, NULL, NULL, '2026-10-21 18:16:57');

-- Table structure for table `radiology_orders`
DROP TABLE IF EXISTS `radiology_orders`;
CREATE TABLE `radiology_orders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `accession_no` varchar(30) NOT NULL,
  `order_id` bigint(20) unsigned NOT NULL,
  `order_item_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `modality` enum('xray','usg','ct','mri','mammography','ecg') NOT NULL DEFAULT 'xray',
  `room_id` bigint(20) unsigned DEFAULT NULL,
  `technician_id` bigint(20) unsigned DEFAULT NULL,
  `radiologist_id` bigint(20) unsigned DEFAULT NULL,
  `status` enum('scheduled','arrived','in_progress','completed','reported') NOT NULL DEFAULT 'scheduled',
  `critical_finding` tinyint(1) NOT NULL DEFAULT 0,
  `clinical_history` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `accession_no` (`accession_no`),
  KEY `order_id` (`order_id`),
  KEY `order_item_id` (`order_item_id`),
  KEY `branch_id` (`branch_id`),
  KEY `room_id` (`room_id`),
  KEY `technician_id` (`technician_id`),
  KEY `radiologist_id` (`radiologist_id`),
  CONSTRAINT `radiology_orders_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `diagnostic_orders` (`id`),
  CONSTRAINT `radiology_orders_ibfk_2` FOREIGN KEY (`order_item_id`) REFERENCES `diagnostic_order_items` (`id`),
  CONSTRAINT `radiology_orders_ibfk_3` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `radiology_orders_ibfk_4` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`),
  CONSTRAINT `radiology_orders_ibfk_5` FOREIGN KEY (`technician_id`) REFERENCES `users` (`id`),
  CONSTRAINT `radiology_orders_ibfk_6` FOREIGN KEY (`radiologist_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `radiology_orders`
INSERT INTO `radiology_orders` (`id`, `accession_no`, `order_id`, `order_item_id`, `branch_id`, `modality`, `room_id`, `technician_id`, `radiologist_id`, `status`, `critical_finding`, `clinical_history`, `created_at`, `updated_at`) VALUES ('1', 'RAD-2026-0001', '1', '1', '1', 'xray', '1', '1', '1', 'reported', '0', 'Chronic cough for 3 weeks, low grade fever, evaluate for pulmonary pathology (P/A View).', '2026-10-11 18:21:57', '2026-10-11 18:21:57');
INSERT INTO `radiology_orders` (`id`, `accession_no`, `order_id`, `order_item_id`, `branch_id`, `modality`, `room_id`, `technician_id`, `radiologist_id`, `status`, `critical_finding`, `clinical_history`, `created_at`, `updated_at`) VALUES ('2', 'RAD-2026-0002', '2', '4', '1', 'usg', '2', '1', '1', 'reported', '0', 'Right hypochondriac dull ache and dyspepsia. Routine ultrasound screening.', '2026-10-11 18:21:57', '2026-10-11 18:21:57');
INSERT INTO `radiology_orders` (`id`, `accession_no`, `order_id`, `order_item_id`, `branch_id`, `modality`, `room_id`, `technician_id`, `radiologist_id`, `status`, `critical_finding`, `clinical_history`, `created_at`, `updated_at`) VALUES ('3', 'RAD-2026-0003', '3', '7', '1', 'ct', '3', '1', NULL, 'completed', '0', 'Subacute chest pain and shortness of breath on exertion. Contrast HRCT Thorax.', '2026-10-11 18:21:57', '2026-10-11 18:21:57');
INSERT INTO `radiology_orders` (`id`, `accession_no`, `order_id`, `order_item_id`, `branch_id`, `modality`, `room_id`, `technician_id`, `radiologist_id`, `status`, `critical_finding`, `clinical_history`, `created_at`, `updated_at`) VALUES ('4', 'RAD-2026-0004', '4', '10', '1', 'mri', '4', '1', NULL, 'arrived', '0', 'Persistent vertigo and migraine with aura. MRI Brain protocol with diffusion sequences.', '2026-10-11 18:21:57', '2026-10-11 18:21:57');
INSERT INTO `radiology_orders` (`id`, `accession_no`, `order_id`, `order_item_id`, `branch_id`, `modality`, `room_id`, `technician_id`, `radiologist_id`, `status`, `critical_finding`, `clinical_history`, `created_at`, `updated_at`) VALUES ('5', 'RAD-2026-0005', '5', '12', '1', 'ecg', '5', '1', '1', 'reported', '0', 'Cardiovascular risk evaluation and pre-procedural 12-lead ECG screening.', '2026-10-11 18:21:57', '2026-10-11 18:21:57');

-- Table structure for table `radiology_reports`
DROP TABLE IF EXISTS `radiology_reports`;
CREATE TABLE `radiology_reports` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `report_no` varchar(30) NOT NULL,
  `radiology_order_id` bigint(20) unsigned NOT NULL,
  `radiologist_id` bigint(20) unsigned NOT NULL,
  `template_id` bigint(20) unsigned DEFAULT NULL,
  `findings` text NOT NULL,
  `impression` text NOT NULL,
  `critical_finding_flag` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('draft','reviewed','finalized','amended') NOT NULL DEFAULT 'draft',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_no` (`report_no`),
  KEY `radiology_order_id` (`radiology_order_id`),
  KEY `radiologist_id` (`radiologist_id`),
  KEY `template_id` (`template_id`),
  CONSTRAINT `radiology_reports_ibfk_1` FOREIGN KEY (`radiology_order_id`) REFERENCES `radiology_orders` (`id`),
  CONSTRAINT `radiology_reports_ibfk_2` FOREIGN KEY (`radiologist_id`) REFERENCES `users` (`id`),
  CONSTRAINT `radiology_reports_ibfk_3` FOREIGN KEY (`template_id`) REFERENCES `radiology_templates` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `radiology_reports`
INSERT INTO `radiology_reports` (`id`, `report_no`, `radiology_order_id`, `radiologist_id`, `template_id`, `findings`, `impression`, `critical_finding_flag`, `status`, `created_at`, `updated_at`) VALUES ('1', 'RAD-RPT-0001', '1', '1', '1', 'CHEST DIGITAL RADIOGRAPHY (PA VIEW):\nLung fields are well aerated and completely clear of any active parenchymal consolidation, cavitation or infiltrative lesion. Costophrenic and cardiophrenic sulci are sharp. Normal cardiac size with cardiothoracic ratio < 0.50. Bony thorax and soft tissue contours are intact and symmetric.', 'Normal digital chest radiograph (PA View). No active tuberculosis or pulmonary lesion identified.', '0', 'finalized', '2026-10-11 18:21:57', '2026-10-11 18:21:57');
INSERT INTO `radiology_reports` (`id`, `report_no`, `radiology_order_id`, `radiologist_id`, `template_id`, `findings`, `impression`, `critical_finding_flag`, `status`, `created_at`, `updated_at`) VALUES ('2', 'RAD-RPT-0002', '2', '1', '2', 'ULTRASOUND OF WHOLE ABDOMEN & PELVIS:\nLiver is normal in size (13.1 cm) with regular margins and homogeneous parenchymal echotexture. No focal hepatic mass or intrahepatic biliary duct dilatation. Gallbladder is well distended, lumen is clear without cholelithiasis or wall thickening. Both kidneys exhibit normal bipolar length and cortical thickness. Spleen and pancreas are normal.', 'Normal whole abdominal sonogram. No cholelithiasis or nephrolithiasis detected.', '0', 'finalized', '2026-10-11 18:21:57', '2026-10-11 18:21:57');
INSERT INTO `radiology_reports` (`id`, `report_no`, `radiology_order_id`, `radiologist_id`, `template_id`, `findings`, `impression`, `critical_finding_flag`, `status`, `created_at`, `updated_at`) VALUES ('3', 'RAD-RPT-0005', '5', '1', NULL, '12-LEAD RESTING ELECTROCARDIOGRAM:\n- Rhythm: Normal sinus rhythm\n- Heart Rate: 74 bpm\n- PR interval: 156 ms, QRS duration: 84 ms, QTc: 412 ms\n- Normal axis (+60°)\n- No pathological Q waves, ST elevation or T-wave inversion noted across limb and precordial leads.', 'Normal resting 12-lead Electrocardiogram (ECG).', '0', 'finalized', '2026-10-11 18:21:57', '2026-10-11 18:21:57');

-- Table structure for table `radiology_templates`
DROP TABLE IF EXISTS `radiology_templates`;
CREATE TABLE `radiology_templates` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `name` varchar(180) NOT NULL,
  `modality` enum('xray','usg','ct','mri','mammography','ecg') NOT NULL DEFAULT 'xray',
  `body_part` varchar(100) DEFAULT NULL,
  `template_text` text NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `radiology_templates`
INSERT INTO `radiology_templates` (`id`, `code`, `name`, `modality`, `body_part`, `template_text`, `active`, `created_at`) VALUES ('1', 'TPL-CXR', 'Chest X-Ray (PA View) Normal Macro', 'xray', 'Chest', 'CHEST X-RAY PA VIEW:\n- Trachea is central in position.\n- Both lung fields are clear with normal vascular markings.\n- Costophrenic and cardiophrenic angles are sharp and clear.\n- Cardiac silhouette and mediastinal contours are within normal anatomical limits.\n- Diaphragmatic domes are normal in contour.\n- Visualized bony thorax and soft tissue structures appear unremarkable.\n\nIMPRESSION: Normal Chest Radiograph. No active cardiopulmonary lesion.', '1', '2026-10-11 18:21:57');
INSERT INTO `radiology_templates` (`id`, `code`, `name`, `modality`, `body_part`, `template_text`, `active`, `created_at`) VALUES ('2', 'TPL-USG-WA', 'Ultrasonography of Whole Abdomen Normal Macro', 'usg', 'Whole Abdomen', 'ULTRASONOGRAPHY OF WHOLE ABDOMEN:\n- Liver: Normal in size (13.2 cm), homogenous echotexture. No focal lesion or intrahepatic biliary radicle dilatation.\n- Gallbladder: Well distended with normal wall thickness. No calculus or sludge seen.\n- Common Bile Duct (CBD) and Portal Vein: Normal in caliber.\n- Pancreas & Spleen: Normal in size, contour and parenchymal echo pattern.\n- Both Kidneys: Normal size and cortical thickness. Normal corticomedullary differentiation. No calculus or hydronephrosis.\n- Urinary Bladder: Normal lumen, no mass or calculus.\n- Prostate/Pelvic Organs: Normal in appearance.\n\nIMPRESSION: Normal findings on Whole Abdominal Sonogram.', '1', '2026-10-11 18:21:57');
INSERT INTO `radiology_templates` (`id`, `code`, `name`, `modality`, `body_part`, `template_text`, `active`, `created_at`) VALUES ('3', 'TPL-CT-CHEST', 'High Resolution CT (HRCT) Chest Protocol', 'ct', 'Chest', 'HRCT OF CHEST (NON-CONTRAST):\n- Tracheobronchial tree is patent down to segmental bronchi.\n- Both lungs reveal normal parenchymal attenuation. No ground-glass opacities, consolidation, or interstitial septal thickening.\n- No pulmonary nodule or mass lesion detected.\n- Mediastinal and hilar lymph nodes are not enlarged.\n- Pleural spaces are clear without effusion or thickening.\n\nIMPRESSION: Normal HRCT Thorax study.', '1', '2026-10-11 18:21:57');
INSERT INTO `radiology_templates` (`id`, `code`, `name`, `modality`, `body_part`, `template_text`, `active`, `created_at`) VALUES ('4', 'TPL-MRI-BRAIN', 'MRI Brain & Cervical Spine Protocol', 'mri', 'Brain', 'MRI OF BRAIN (T1, T2, FLAIR, DWI, ADC, SWI):\n- Brain parenchyma displays normal signal intensities. No acute infarct, intracranial hemorrhage, or space-occupying lesion.\n- Ventricular system, basal cisterns and cortical sulci are within normal limits for age.\n- Midline structures are undisturbed.\n- Bilateral cerebellopontine angles and internal auditory canals appear normal.\n\nIMPRESSION: Normal MRI scan of the brain.', '1', '2026-10-11 18:21:57');

-- Table structure for table `reason_codes`
DROP TABLE IF EXISTS `reason_codes`;
CREATE TABLE `reason_codes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `category` enum('discount','refund','correction','cancellation','other') NOT NULL DEFAULT 'other',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `referral_settlements`
DROP TABLE IF EXISTS `referral_settlements`;
CREATE TABLE `referral_settlements` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `settlement_no` varchar(30) NOT NULL,
  `doctor_id` bigint(20) unsigned NOT NULL,
  `period_month` tinyint(3) unsigned NOT NULL,
  `period_year` smallint(5) unsigned NOT NULL,
  `total_referred_volume` decimal(15,2) NOT NULL DEFAULT 0.00,
  `commission_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `status` enum('draft','approved','paid') NOT NULL DEFAULT 'draft',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `settlement_no` (`settlement_no`),
  KEY `doctor_id` (`doctor_id`),
  CONSTRAINT `referral_settlements_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `referrers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `referrer_profiles`
DROP TABLE IF EXISTS `referrer_profiles`;
CREATE TABLE `referrer_profiles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `referrer_id` bigint(20) unsigned NOT NULL,
  `specialty` varchar(120) DEFAULT NULL,
  `organization_name` varchar(180) DEFAULT NULL,
  `territory_zone` varchar(100) DEFAULT NULL,
  `relationship_manager_id` bigint(20) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `referrer_id` (`referrer_id`),
  KEY `relationship_manager_id` (`relationship_manager_id`),
  CONSTRAINT `referrer_profiles_ibfk_1` FOREIGN KEY (`referrer_id`) REFERENCES `referrers` (`id`),
  CONSTRAINT `referrer_profiles_ibfk_2` FOREIGN KEY (`relationship_manager_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `referrer_visits`
DROP TABLE IF EXISTS `referrer_visits`;
CREATE TABLE `referrer_visits` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `referrer_id` bigint(20) unsigned NOT NULL,
  `visited_by` bigint(20) unsigned NOT NULL,
  `visit_date` date NOT NULL,
  `discussion_notes` text NOT NULL,
  `follow_up_action` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `referrer_id` (`referrer_id`),
  KEY `visited_by` (`visited_by`),
  CONSTRAINT `referrer_visits_ibfk_1` FOREIGN KEY (`referrer_id`) REFERENCES `referrers` (`id`),
  CONSTRAINT `referrer_visits_ibfk_2` FOREIGN KEY (`visited_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `referrer_visits`
INSERT INTO `referrer_visits` (`id`, `referrer_id`, `visited_by`, `visit_date`, `discussion_notes`, `follow_up_action`, `created_at`) VALUES ('1', '1', '1', '2026-10-18', 'Visited Prof. Dr. M. Rahman at Chamber. Shared updated Endocrinology and HbA1c test panel brochures. Requested fast-track reporting for diabetic patients.', 'Deliver customized test requisition pads next Monday.', '2026-10-20 15:19:14');
INSERT INTO `referrer_visits` (`id`, `referrer_id`, `visited_by`, `visit_date`, `discussion_notes`, `follow_up_action`, `created_at`) VALUES ('2', '2', '1', '2026-10-15', 'Met Dr. Farhana Ahmed at clinic. Reviewed high-resolution 4D Obstetric USG report quality. Highly satisfied with turnaround time.', 'Invite to upcoming Clinical CME seminar on Fetal Medicine.', '2026-10-20 15:19:14');
INSERT INTO `referrer_visits` (`id`, `referrer_id`, `visited_by`, `visit_date`, `discussion_notes`, `follow_up_action`, `created_at`) VALUES ('3', '3', '1', '2026-10-12', 'Discussed Cardiology lipid panel profiling and automated Cardiac Troponin-I testing. Doctor committed additional referral volume.', 'Send digital portal login access for instant online report view.', '2026-10-20 15:19:14');
INSERT INTO `referrer_visits` (`id`, `referrer_id`, `visited_by`, `visit_date`, `discussion_notes`, `follow_up_action`, `created_at`) VALUES ('4', '4', '1', '2026-10-10', 'Consultation with Dhaka Care Clinic Administration. Signed corporate referral MoA with dedicated sample collection desk facility.', 'Setup automated daily sample courier pick-up at 11:00 AM.', '2026-10-20 15:19:14');

-- Table structure for table `referrers`
DROP TABLE IF EXISTS `referrers`;
CREATE TABLE `referrers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `mobile` varchar(25) DEFAULT NULL,
  `type` enum('doctor','organization','other') NOT NULL DEFAULT 'doctor',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `referrers`
INSERT INTO `referrers` (`id`, `code`, `name`, `mobile`, `type`, `active`, `created_at`, `updated_at`) VALUES ('1', 'REF-001', 'Prof. Dr. M. Rahman', '01711-223344', 'doctor', '1', '2026-10-20 13:12:43', '2026-10-20 13:12:43');
INSERT INTO `referrers` (`id`, `code`, `name`, `mobile`, `type`, `active`, `created_at`, `updated_at`) VALUES ('2', 'REF-002', 'Dr. Farhana Ahmed', '01819-334455', 'doctor', '1', '2026-10-20 13:12:43', '2026-10-20 13:12:43');
INSERT INTO `referrers` (`id`, `code`, `name`, `mobile`, `type`, `active`, `created_at`, `updated_at`) VALUES ('3', 'REF-003', 'Dr. Tanvir Hossain', '01912-445566', 'doctor', '1', '2026-10-20 13:12:43', '2026-10-20 13:12:43');
INSERT INTO `referrers` (`id`, `code`, `name`, `mobile`, `type`, `active`, `created_at`, `updated_at`) VALUES ('4', 'REF-004', 'Dhaka Care Clinic & OPD Referral', '01611-667788', 'organization', '1', '2026-10-20 13:12:43', '2026-10-20 13:12:43');

-- Table structure for table `refunds`
DROP TABLE IF EXISTS `refunds`;
CREATE TABLE `refunds` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `refund_no` varchar(30) NOT NULL,
  `invoice_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `reason` varchar(255) NOT NULL,
  `refunded_by` bigint(20) unsigned NOT NULL,
  `approval_request_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `refund_no` (`refund_no`),
  KEY `invoice_id` (`invoice_id`),
  KEY `branch_id` (`branch_id`),
  KEY `refunded_by` (`refunded_by`),
  KEY `approval_request_id` (`approval_request_id`),
  CONSTRAINT `refunds_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`),
  CONSTRAINT `refunds_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `refunds_ibfk_3` FOREIGN KEY (`refunded_by`) REFERENCES `users` (`id`),
  CONSTRAINT `refunds_ibfk_4` FOREIGN KEY (`approval_request_id`) REFERENCES `approval_requests` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `report_catalog_views`
DROP TABLE IF EXISTS `report_catalog_views`;
CREATE TABLE `report_catalog_views` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `report_key` varchar(60) NOT NULL,
  `title` varchar(150) NOT NULL,
  `report_group` enum('front_desk','billing','lab','radiology','corporate','referral','inventory','procurement','finance','hr','quality','audit') NOT NULL,
  `description` text DEFAULT NULL,
  `query_definition` text NOT NULL,
  `export_formats` varchar(50) NOT NULL DEFAULT 'PDF,Excel,CSV',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_key` (`report_key`)
) ENGINE=InnoDB AUTO_INCREMENT=1135 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `report_catalog_views`
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('1', 'rpt_exec_daily_mtd_ytd', 'Executive Revenue & Patient Volume Summary (Daily/MTD/YTD)', 'front_desk', 'Real-time & historic revenue, patient counts, average bill amounts, and collection breakdown.', 'SELECT DATE(created_at) AS invoice_date, COUNT(DISTINCT patient_id) AS patients, SUM(total_amount) AS total_rev, SUM(paid_amount) AS paid, SUM(due_amount) AS dues FROM invoices GROUP BY DATE(created_at)', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('2', 'rpt_daily_billing_summary', 'Daily Front Desk & Cash Collection Summary', 'billing', 'Detailed list of daily patient bills, discounts, payments, dues, and payment modes.', 'SELECT invoice_no, patient_id, DATE(created_at) AS invoice_date, total_amount, discount_amount, paid_amount, due_amount, status FROM invoices', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('3', 'rpt_fd_cashier_closing', 'Cashier Shift Collection & Closing Variance Log', 'billing', 'Cashier shift opening float, physical cash counts, digital payments, and closing variances.', 'SELECT cs.id AS shift_id, u.name AS cashier, cs.opening_float, cs.declared_cash, cs.variance, cs.status FROM cashier_shifts cs JOIN users u ON u.id=cs.cashier_id', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('4', 'rpt_lab_tat_performance', 'Laboratory Turnaround Time (TAT) & Worklist Analytics', 'lab', 'Tracks sample collection to verification processing time, department worklist aging, and SLA compliance.', 'SELECT doi.id, o.order_no, doi.item_name AS test_name, doi.status FROM diagnostic_order_items doi JOIN diagnostic_orders o ON o.id=doi.order_id', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('5', 'rpt_lis_critical_values', 'LIS Critical Values & Panic Result Alert Log', 'lab', 'Log of panic test results, doctor notification timestamps, and acknowledgment records.', 'SELECT order_item_id, critical_parameter, critical_value, notified_to, status FROM critical_alert_logs', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('6', 'rpt_rad_reporting_tat', 'Radiology Modality Bookings, PACS & Reporting TAT', 'radiology', 'Modality utilization, radiologist workload, PACS reconciliation, and critical imaging finding logs.', 'SELECT accession_no, modality, clinical_history, status FROM radiology_orders', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('7', 'rpt_corporate_receivables_aging', 'Corporate Credit Billing Aging & Contract Expiry Statement', 'corporate', 'Outstanding corporate credit invoices categorized by 30/60/90+ days aging and contract expiry alerts.', 'SELECT ci.invoice_no, cc.name AS company_name, ci.billing_period, ci.total_amount, ci.due_amount, ci.status FROM corporate_invoices ci JOIN corporate_clients cc ON cc.id=ci.corporate_client_id', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('8', 'rpt_referrer_commission_ledger', 'Doctor & Referrer Monthly Commission & Contribution Ledger', 'referral', 'Comprehensive statement of doctor referral claims, net contribution, payouts, TDS deductions, and balances.', 'SELECT rd.name AS doctor_name, rd.specialty FROM doctors rd', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('9', 'rpt_inventory_expiry_risk', 'Reagent & Consumable FEFO Expiry Risk & Reorder Report', 'inventory', 'Items approaching expiration within 30/60/90 days, minimum stock reorders, and stock valuation.', 'SELECT ii.name AS item_name, ii.code AS item_code, ib.batch_no, ib.quantity_on_hand, ib.expiry_date FROM inventory_batches ib JOIN inventory_items ii ON ii.id=ib.item_id', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('10', 'rpt_proc_po_grn_pending', 'Procurement PO, GRN 3-Way Matching & Supplier Performance', 'procurement', 'Purchase requisitions, pending POs, GRN inspection logs, and purchase price variance.', 'SELECT po.po_no, s.name AS supplier_name, po.total_amount, po.status FROM purchase_orders po JOIN suppliers s ON s.id=po.supplier_id', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('11', 'rpt_financial_trial_balance', 'General Ledger Trial Balance, P&L & Balance Sheet', 'finance', 'Double-entry trial balance ledger showing debit and credit sums, general ledger, and P&L snapshots.', 'SELECT account_code, name AS account_name, account_type FROM chart_of_accounts', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('12', 'rpt_hr_attendance_payroll', 'Staff Monthly Attendance, Overtime & Payroll Register', 'hr', 'Staff working days, leave counts, overtime hours, gross salaries, deductions, and net payouts.', 'SELECT p.id, e.employee_code, e.name AS full_name, p.payroll_period, p.basic_salary, p.deductions, p.net_salary, p.status FROM payrolls p JOIN hr_employees e ON e.id=p.employee_id', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('13', 'rpt_quality_capa_sop', 'Quality Control (QC), CAPA Aging & Compliance Calendar', 'quality', 'Westgard QC runs, open CAPA tickets, controlled SOP reviews, and DGHS/BAERA license renewals.', 'SELECT doc_no, title, category, version, status, effective_date FROM controlled_documents', 'PDF,Excel,CSV', '2026-09-28 19:31:52');
INSERT INTO `report_catalog_views` (`id`, `report_key`, `title`, `report_group`, `description`, `query_definition`, `export_formats`, `created_at`) VALUES ('14', 'rpt_audit_trail_log', 'System Security & Immutable Data Audit Log', 'audit', 'Audit log of all sensitive updates, patient record views, result overrides, and deletions.', 'SELECT action, entity_type AS table_name, entity_id AS record_id, occurred_at FROM audit_logs', 'PDF,Excel,CSV', '2026-09-28 19:31:52');

-- Table structure for table `report_deliveries`
DROP TABLE IF EXISTS `report_deliveries`;
CREATE TABLE `report_deliveries` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) unsigned NOT NULL,
  `report_type` enum('lab','radiology') NOT NULL DEFAULT 'lab',
  `report_id` bigint(20) unsigned NOT NULL,
  `action_type` enum('print','reprint','email','portal_publish') NOT NULL DEFAULT 'print',
  `acted_by` bigint(20) unsigned NOT NULL,
  `acted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `recipient_email` varchar(190) DEFAULT NULL,
  `qr_verification_hash` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `acted_by` (`acted_by`),
  CONSTRAINT `report_deliveries_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `diagnostic_orders` (`id`),
  CONSTRAINT `report_deliveries_ibfk_2` FOREIGN KEY (`acted_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `report_deliveries`
INSERT INTO `report_deliveries` (`id`, `order_id`, `report_type`, `report_id`, `action_type`, `acted_by`, `acted_at`, `recipient_email`, `qr_verification_hash`) VALUES ('1', '1', 'lab', '1', 'print', '1', '2026-10-10 18:31:34', NULL, 'c3240adb2e69833d1e38ea14035bfc5a73530be0eb6604f752684891f66964de');
INSERT INTO `report_deliveries` (`id`, `order_id`, `report_type`, `report_id`, `action_type`, `acted_by`, `acted_at`, `recipient_email`, `qr_verification_hash`) VALUES ('2', '2', 'lab', '2', 'print', '1', '2026-10-10 18:31:34', NULL, '361d988533db6544c40ff7fdc5d8dabeda59a225bd01f5d601ebe9139d2aa6d0');
INSERT INTO `report_deliveries` (`id`, `order_id`, `report_type`, `report_id`, `action_type`, `acted_by`, `acted_at`, `recipient_email`, `qr_verification_hash`) VALUES ('3', '3', 'lab', '3', 'print', '1', '2026-10-10 18:31:34', NULL, 'b98e675e310a50645023a60394ca2b3e414dcbd471a155647ed18cdc2057d04d');
INSERT INTO `report_deliveries` (`id`, `order_id`, `report_type`, `report_id`, `action_type`, `acted_by`, `acted_at`, `recipient_email`, `qr_verification_hash`) VALUES ('4', '4', 'lab', '4', 'print', '1', '2026-10-10 18:31:34', NULL, '369c61e31f32c485f9b652c741758a662fbfe1c92eff9418e08cfec0615e3c46');

-- Table structure for table `report_templates`
DROP TABLE IF EXISTS `report_templates`;
CREATE TABLE `report_templates` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `template_kind` enum('lab','radiology','other') NOT NULL DEFAULT 'lab',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `role_permissions`
DROP TABLE IF EXISTS `role_permissions`;
CREATE TABLE `role_permissions` (
  `role_id` bigint(20) unsigned NOT NULL,
  `permission_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `role_permissions`
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '1');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '2');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '3');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '4');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '5');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '6');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '7');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '8');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '9');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '10');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '11');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '12');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '13');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '14');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '16');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '17');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '18');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '19');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '20');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '21');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '22');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('1', '23');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '1');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '10');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '11');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '12');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '13');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '14');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '16');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '17');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '20');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '21');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('3', '23');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('4', '1');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('4', '10');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('4', '11');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('4', '14');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('4', '15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('4', '16');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('4', '17');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('4', '20');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('5', '1');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('5', '10');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('5', '11');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('5', '12');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('5', '13');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('5', '14');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('5', '15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('5', '16');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('5', '17');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('5', '23');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('6', '1');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('6', '10');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('6', '11');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('6', '15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('6', '17');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('6', '21');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('6', '22');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('6', '23');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('7', '1');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('7', '10');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('7', '15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('7', '17');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('7', '20');
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES ('7', '21');

-- Table structure for table `roles`
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `roles`
INSERT INTO `roles` (`id`, `code`, `name`, `active`) VALUES ('1', 'super_admin', 'System Administrator', '1');
INSERT INTO `roles` (`id`, `code`, `name`, `active`) VALUES ('3', 'doctor', 'Specialist Doctor & Radiologist', '1');
INSERT INTO `roles` (`id`, `code`, `name`, `active`) VALUES ('4', 'lab_tech', 'Lab Technologist & Pathologist', '1');
INSERT INTO `roles` (`id`, `code`, `name`, `active`) VALUES ('5', 'cashier', 'Receptionist & Billing Cashier', '1');
INSERT INTO `roles` (`id`, `code`, `name`, `active`) VALUES ('6', 'pharmacist', 'Pharmacist & Dispensing Manager', '1');
INSERT INTO `roles` (`id`, `code`, `name`, `active`) VALUES ('7', 'accounts', 'Accounts & Financial Controller', '1');

-- Table structure for table `rooms`
DROP TABLE IF EXISTS `rooms`;
CREATE TABLE `rooms` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `service_unit_id` bigint(20) unsigned DEFAULT NULL,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_room` (`branch_id`,`code`),
  KEY `service_unit_id` (`service_unit_id`),
  CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `rooms_ibfk_2` FOREIGN KEY (`service_unit_id`) REFERENCES `service_units` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `rooms`
INSERT INTO `rooms` (`id`, `branch_id`, `service_unit_id`, `code`, `name`, `active`, `created_at`, `updated_at`) VALUES ('1', '1', NULL, 'RAD-XR1', 'Digital X-Ray Suite (Room 101)', '1', '2026-10-11 18:21:44', '2026-10-11 18:21:44');
INSERT INTO `rooms` (`id`, `branch_id`, `service_unit_id`, `code`, `name`, `active`, `created_at`, `updated_at`) VALUES ('2', '1', NULL, 'RAD-USG1', '4D Ultrasonography Room (Room 102)', '1', '2026-10-11 18:21:44', '2026-10-11 18:21:44');
INSERT INTO `rooms` (`id`, `branch_id`, `service_unit_id`, `code`, `name`, `active`, `created_at`, `updated_at`) VALUES ('3', '1', NULL, 'RAD-CT1', '128-Slice CT Scan Suite (Room 103)', '1', '2026-10-11 18:21:44', '2026-10-11 18:21:44');
INSERT INTO `rooms` (`id`, `branch_id`, `service_unit_id`, `code`, `name`, `active`, `created_at`, `updated_at`) VALUES ('4', '1', NULL, 'RAD-MRI1', '1.5T Silent MRI Suite (Room 104)', '1', '2026-10-11 18:21:44', '2026-10-11 18:21:44');
INSERT INTO `rooms` (`id`, `branch_id`, `service_unit_id`, `code`, `name`, `active`, `created_at`, `updated_at`) VALUES ('5', '1', NULL, 'RAD-ECG1', 'ECG & Echo Cardiology Lab (Room 105)', '1', '2026-10-11 18:21:44', '2026-10-11 18:21:44');

-- Table structure for table `sample_collections`
DROP TABLE IF EXISTS `sample_collections`;
CREATE TABLE `sample_collections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `barcode` varchar(40) NOT NULL,
  `order_id` bigint(20) unsigned NOT NULL,
  `order_item_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `sample_type_id` bigint(20) unsigned DEFAULT NULL,
  `container_id` bigint(20) unsigned DEFAULT NULL,
  `status` enum('pending','collected','recollected','rejected') NOT NULL DEFAULT 'pending',
  `collected_by` bigint(20) unsigned DEFAULT NULL,
  `collected_at` datetime DEFAULT NULL,
  `rejection_reason` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `barcode` (`barcode`),
  KEY `order_id` (`order_id`),
  KEY `order_item_id` (`order_item_id`),
  KEY `branch_id` (`branch_id`),
  KEY `sample_type_id` (`sample_type_id`),
  KEY `container_id` (`container_id`),
  KEY `collected_by` (`collected_by`),
  CONSTRAINT `sample_collections_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `diagnostic_orders` (`id`),
  CONSTRAINT `sample_collections_ibfk_2` FOREIGN KEY (`order_item_id`) REFERENCES `diagnostic_order_items` (`id`),
  CONSTRAINT `sample_collections_ibfk_3` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `sample_collections_ibfk_4` FOREIGN KEY (`sample_type_id`) REFERENCES `sample_types` (`id`),
  CONSTRAINT `sample_collections_ibfk_5` FOREIGN KEY (`container_id`) REFERENCES `containers` (`id`),
  CONSTRAINT `sample_collections_ibfk_6` FOREIGN KEY (`collected_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `sample_collections`
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('1', 'BAR-261010-1256', '1', '1', '1', NULL, NULL, 'collected', '1', '2026-10-05 18:31:34', NULL, '2026-10-05 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('2', 'BAR-261010-1545', '1', '2', '1', NULL, NULL, 'collected', '1', '2026-10-05 18:31:34', NULL, '2026-10-05 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('3', 'BAR-261010-4843', '1', '3', '1', NULL, NULL, 'collected', '1', '2026-10-05 18:31:34', NULL, '2026-10-05 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('4', 'BAR-261010-9670', '2', '4', '1', NULL, NULL, 'collected', '1', '2026-10-06 18:31:34', NULL, '2026-10-06 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('5', 'BAR-261010-6612', '2', '5', '1', NULL, NULL, 'collected', '1', '2026-10-06 18:31:34', NULL, '2026-10-06 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('6', 'BAR-261010-8567', '2', '6', '1', NULL, NULL, 'collected', '1', '2026-10-06 18:31:34', NULL, '2026-10-06 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('7', 'BAR-261010-5400', '3', '7', '1', NULL, NULL, 'collected', '1', '2026-10-07 18:31:34', NULL, '2026-10-07 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('8', 'BAR-261010-5495', '3', '8', '1', NULL, NULL, 'collected', '1', '2026-10-07 18:31:34', NULL, '2026-10-07 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('9', 'BAR-261010-3421', '3', '9', '1', NULL, NULL, 'collected', '1', '2026-10-07 18:31:34', NULL, '2026-10-07 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('10', 'BAR-261010-5264', '4', '10', '1', NULL, NULL, 'collected', '1', '2026-10-08 18:31:34', NULL, '2026-10-08 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('11', 'BAR-261010-7899', '4', '11', '1', NULL, NULL, 'collected', '1', '2026-10-08 18:31:34', NULL, '2026-10-08 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('12', 'BAR-261010-1044', '5', '12', '1', NULL, NULL, 'collected', '1', '2026-10-09 18:31:34', NULL, '2026-10-09 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('13', 'BAR-261010-6583', '5', '13', '1', NULL, NULL, 'collected', '1', '2026-10-09 18:31:34', NULL, '2026-10-09 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('14', 'BAR-261010-7775', '5', '14', '1', NULL, NULL, 'collected', '1', '2026-10-09 18:31:34', NULL, '2026-10-09 18:31:34');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('15', 'BAR-261011-8812', '6', '15', '1', NULL, NULL, 'collected', '1', '2026-10-11 17:23:12', NULL, '2026-10-11 17:23:12');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('16', 'BAR-261011-8813', '7', '16', '1', NULL, NULL, 'collected', '1', '2026-10-11 17:23:12', NULL, '2026-10-11 17:23:12');
INSERT INTO `sample_collections` (`id`, `barcode`, `order_id`, `order_item_id`, `branch_id`, `sample_type_id`, `container_id`, `status`, `collected_by`, `collected_at`, `rejection_reason`, `created_at`) VALUES ('17', 'BAR-261011-8814', '8', '17', '1', NULL, NULL, 'collected', '1', '2026-10-11 17:23:12', NULL, '2026-10-11 17:23:12');

-- Table structure for table `sample_types`
DROP TABLE IF EXISTS `sample_types`;
CREATE TABLE `sample_types` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `schema_migrations`
DROP TABLE IF EXISTS `schema_migrations`;
CREATE TABLE `schema_migrations` (
  `version` varchar(100) NOT NULL,
  `applied_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `schema_migrations`
INSERT INTO `schema_migrations` (`version`, `applied_at`) VALUES ('diagnostic_erp', '2026-09-28 19:22:33');

-- Table structure for table `security_backup_logs`
DROP TABLE IF EXISTS `security_backup_logs`;
CREATE TABLE `security_backup_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `backup_no` varchar(40) NOT NULL,
  `backup_type` enum('full_db','schema_only','audit_export') NOT NULL DEFAULT 'full_db',
  `file_path` varchar(255) NOT NULL,
  `file_hash_sha256` varchar(64) NOT NULL,
  `file_size_bytes` bigint(20) unsigned NOT NULL DEFAULT 0,
  `status` enum('completed','failed','verified') NOT NULL DEFAULT 'completed',
  `triggered_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `backup_no` (`backup_no`),
  KEY `triggered_by` (`triggered_by`),
  CONSTRAINT `security_backup_logs_ibfk_1` FOREIGN KEY (`triggered_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `service_units`
DROP TABLE IF EXISTS `service_units`;
CREATE TABLE `service_units` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_service_unit` (`branch_id`,`code`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `service_units_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `service_units_ibfk_2` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `suppliers`
DROP TABLE IF EXISTS `suppliers`;
CREATE TABLE `suppliers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(180) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `category` varchar(100) DEFAULT 'Reagents & Kits',
  `trade_license` varchar(100) DEFAULT NULL,
  `tin_bin` varchar(100) DEFAULT NULL,
  `payment_terms` varchar(50) DEFAULT 'Net 30 Days',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `suppliers`
INSERT INTO `suppliers` (`id`, `code`, `name`, `phone`, `email`, `active`, `created_at`, `updated_at`, `category`, `trade_license`, `tin_bin`, `payment_terms`) VALUES ('1', 'SUPP-001', 'Roche Diagnostics Bangladesh Ltd', '02-9887766', 'orders.bd@roche.com', '1', '2026-10-20 13:11:16', '2026-10-20 14:54:04', 'Biochemistry & Immunology Reagents', 'TL-DHK-48201', 'BIN-002914820-0101', 'Net 30 Days');
INSERT INTO `suppliers` (`id`, `code`, `name`, `phone`, `email`, `active`, `created_at`, `updated_at`, `category`, `trade_license`, `tin_bin`, `payment_terms`) VALUES ('2', 'SUPP-002', 'Sysmex Healthcare BD Ltd', '02-9112233', 'sales@sysmex.com.bd', '1', '2026-10-20 13:11:16', '2026-10-20 14:54:04', 'Hematology & Coagulation Analyzers', 'TL-DHK-59218', 'BIN-003819204-0102', 'Net 30 Days');
INSERT INTO `suppliers` (`id`, `code`, `name`, `phone`, `email`, `active`, `created_at`, `updated_at`, `category`, `trade_license`, `tin_bin`, `payment_terms`) VALUES ('3', 'SUPP-003', 'Siemens Healthineers Bangladesh', '02-8877665', 'contact@siemens-healthineers.com', '1', '2026-10-20 13:11:16', '2026-10-20 14:54:04', 'Radiology & Imaging Systems', 'TL-DHK-39102', 'BIN-001928374-0103', 'Net 30 Days');
INSERT INTO `suppliers` (`id`, `code`, `name`, `phone`, `email`, `active`, `created_at`, `updated_at`, `category`, `trade_license`, `tin_bin`, `payment_terms`) VALUES ('4', 'SUPP-004', 'Bio-Rad Laboratories EQAS & Controls', '02-7766554', 'eqas@bio-rad.com', '1', '2026-10-20 13:11:16', '2026-10-20 14:54:04', 'Quality Control & EQAS Calibrators', 'TL-DHK-67192', 'BIN-004819283-0104', 'Net 30 Days');
INSERT INTO `suppliers` (`id`, `code`, `name`, `phone`, `email`, `active`, `created_at`, `updated_at`, `category`, `trade_license`, `tin_bin`, `payment_terms`) VALUES ('5', 'SUPP-005', 'Beximco Pharmaceuticals Ltd (Distribution)', '02-5544332', 'pharma.dist@beximco.net', '1', '2026-10-20 13:11:16', '2026-10-20 14:54:04', 'Clinical Consumables & PPE Supplies', 'TL-DHK-18293', 'BIN-005918273-0105', 'Net 30 Days');

-- Table structure for table `tax_rules`
DROP TABLE IF EXISTS `tax_rules`;
CREATE TABLE `tax_rules` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(25) NOT NULL,
  `name` varchar(150) NOT NULL,
  `rate_percent` decimal(7,4) NOT NULL DEFAULT 0.0000,
  `effective_from` date NOT NULL,
  `effective_to` date DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `test_categories`
DROP TABLE IF EXISTS `test_categories`;
CREATE TABLE `test_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `name` varchar(150) NOT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `default_sample_type` varchar(100) DEFAULT 'Blood / Serum',
  `tat_hours` int(11) DEFAULT 4,
  `description` text DEFAULT NULL,
  `icon` varchar(50) DEFAULT 'flask',
  `display_order` int(11) DEFAULT 0,
  `active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `test_categories`
INSERT INTO `test_categories` (`id`, `code`, `name`, `department_id`, `default_sample_type`, `tat_hours`, `description`, `icon`, `display_order`, `active`, `created_at`, `updated_at`) VALUES ('1', 'CAT-BIO', 'Biochemistry & Metabolic Chemistry', '3', 'Serum / Plasma (Red/Yellow Top)', '2', 'Comprehensive automated biochemistry: Blood Glucose, HbA1c, Renal Function Tests (Creatinine, Urea), Liver Function Tests (SGPT, SGOT, Bilirubin), Electrolytes & Lipid Profile.', 'vial', '1', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `test_categories` (`id`, `code`, `name`, `department_id`, `default_sample_type`, `tat_hours`, `description`, `icon`, `display_order`, `active`, `created_at`, `updated_at`) VALUES ('2', 'CAT-HEM', 'Hematology & Complete Hemogram', '3', 'Whole Blood (EDTA Purple Top)', '1', '5-Part differential automated CBC, ESR, Peripheral Blood Film (PBF), Coagulation profile (PT/INR, APTT), Hemoglobin Electrophoresis.', 'microscope', '2', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `test_categories` (`id`, `code`, `name`, `department_id`, `default_sample_type`, `tat_hours`, `description`, `icon`, `display_order`, `active`, `created_at`, `updated_at`) VALUES ('3', 'CAT-END', 'Endocrinology & Diabetic Hormones', '3', 'Serum (Red Top / Gel Separator)', '4', 'Chemiluminescence Immunoassay (CLIA): Thyroid panel (FT3, FT4, TSH), Fasting Insulin, C-Peptide, Vitamin D3, Vitamin B12, Cortisol.', 'dna', '3', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `test_categories` (`id`, `code`, `name`, `department_id`, `default_sample_type`, `tat_hours`, `description`, `icon`, `display_order`, `active`, `created_at`, `updated_at`) VALUES ('4', 'CAT-IMM', 'Immunology & Infectious Serology', '3', 'Serum (Red Top)', '3', 'Serological markers: HBsAg, Anti-HCV, HIV 1&2, VDRL, Dengue NS1/IgG/IgM, Widal test, Febrile antigens, CRP & RA factor.', 'shield-virus', '4', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `test_categories` (`id`, `code`, `name`, `department_id`, `default_sample_type`, `tat_hours`, `description`, `icon`, `display_order`, `active`, `created_at`, `updated_at`) VALUES ('5', 'CAT-CLIN', 'Clinical Pathology & Routine Analysis', '3', 'Fresh Random Urine / Stool Container', '1', 'Automated urine routine & microscopy (Urine R/M/E), Stool routine & occult blood test (OBT), Semen analysis, Sputum examination.', 'vials', '5', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `test_categories` (`id`, `code`, `name`, `department_id`, `default_sample_type`, `tat_hours`, `description`, `icon`, `display_order`, `active`, `created_at`, `updated_at`) VALUES ('6', 'CAT-MIC', 'Microbiology & Antibiogram Sensitivity', '3', 'Sterile Swab / Urine / Sputum', '48', 'Bacterial & fungal culture, colony morphology, automated Gram staining, antibiotic susceptibility testing (AST / Kirby-Bauer & MIC).', 'bacterium', '6', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `test_categories` (`id`, `code`, `name`, `department_id`, `default_sample_type`, `tat_hours`, `description`, `icon`, `display_order`, `active`, `created_at`, `updated_at`) VALUES ('7', 'CAT-HIST', 'Histopathology & Cytopathology', '3', 'Tissue Biopsy in 10% Formalin / FNAC', '72', 'Gross tissue dissection, paraffin embedding, H&E staining, FNAC, Pap smear, cervical cytology, cancer margin reporting.', 'disease', '7', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');
INSERT INTO `test_categories` (`id`, `code`, `name`, `department_id`, `default_sample_type`, `tat_hours`, `description`, `icon`, `display_order`, `active`, `created_at`, `updated_at`) VALUES ('8', 'CAT-MOL', 'Molecular Biology & Real-Time PCR', '3', 'EDTA Plasma / Viral Transport Medium (VTM)', '24', 'Quantitative viral load: HBV DNA PCR, HCV RNA PCR, HPV genotyping, HLA-B27, GeneXpert MTB/RIF.', 'atom', '8', '1', '2026-10-10 18:31:12', '2026-10-10 18:31:12');

-- Table structure for table `test_panel_items`
DROP TABLE IF EXISTS `test_panel_items`;
CREATE TABLE `test_panel_items` (
  `panel_id` bigint(20) unsigned NOT NULL,
  `test_id` bigint(20) unsigned NOT NULL,
  `sort_order` smallint(5) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`panel_id`,`test_id`),
  KEY `test_id` (`test_id`),
  CONSTRAINT `test_panel_items_ibfk_1` FOREIGN KEY (`panel_id`) REFERENCES `test_panels` (`id`),
  CONSTRAINT `test_panel_items_ibfk_2` FOREIGN KEY (`test_id`) REFERENCES `diagnostic_tests` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `test_panels`
DROP TABLE IF EXISTS `test_panels`;
CREATE TABLE `test_panels` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `name` varchar(180) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `test_reference_ranges`
DROP TABLE IF EXISTS `test_reference_ranges`;
CREATE TABLE `test_reference_ranges` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `test_id` bigint(20) unsigned NOT NULL,
  `sex` enum('any','female','male') NOT NULL DEFAULT 'any',
  `min_age_days` int(10) unsigned DEFAULT NULL,
  `max_age_days` int(10) unsigned DEFAULT NULL,
  `low_value` decimal(16,5) DEFAULT NULL,
  `high_value` decimal(16,5) DEFAULT NULL,
  `critical_low` decimal(16,5) DEFAULT NULL,
  `critical_high` decimal(16,5) DEFAULT NULL,
  `display_text` varchar(255) DEFAULT NULL,
  `method_id` bigint(20) unsigned DEFAULT NULL,
  `effective_from` date NOT NULL,
  `effective_to` date DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `test_id` (`test_id`),
  KEY `method_id` (`method_id`),
  CONSTRAINT `test_reference_ranges_ibfk_1` FOREIGN KEY (`test_id`) REFERENCES `diagnostic_tests` (`id`),
  CONSTRAINT `test_reference_ranges_ibfk_2` FOREIGN KEY (`method_id`) REFERENCES `methodologies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `user_branches`
DROP TABLE IF EXISTS `user_branches`;
CREATE TABLE `user_branches` (
  `user_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`branch_id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `user_branches_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_branches_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `user_branches`
INSERT INTO `user_branches` (`user_id`, `branch_id`) VALUES ('1', '1');
INSERT INTO `user_branches` (`user_id`, `branch_id`) VALUES ('2', '1');
INSERT INTO `user_branches` (`user_id`, `branch_id`) VALUES ('3', '1');
INSERT INTO `user_branches` (`user_id`, `branch_id`) VALUES ('4', '1');
INSERT INTO `user_branches` (`user_id`, `branch_id`) VALUES ('5', '1');

-- Table structure for table `user_departments`
DROP TABLE IF EXISTS `user_departments`;
CREATE TABLE `user_departments` (
  `user_id` bigint(20) unsigned NOT NULL,
  `department_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`department_id`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `user_departments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_departments_ibfk_2` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Table structure for table `user_roles`
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles` (
  `user_id` bigint(20) unsigned NOT NULL,
  `role_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `user_roles`
INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES ('1', '1');
INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES ('2', '5');
INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES ('3', '4');
INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES ('4', '3');
INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES ('5', '6');

-- Table structure for table `users`
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `password_changed_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table `users`
INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `active`, `password_changed_at`, `last_login_at`, `created_at`, `updated_at`) VALUES ('1', 'System Administrator', 'admin@cognovait.com', '$2y$10$uCdOhB0.uvD9vLAMV7fy/.nQnq0yAi94wg9KLJYr03x7UtlDyovhq', '1', '2026-09-28 19:30:57', '2026-10-21 10:42:26', '2026-09-28 19:30:57', '2026-10-21 10:42:26');
INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `active`, `password_changed_at`, `last_login_at`, `created_at`, `updated_at`) VALUES ('2', 'Clinic Receptionist Desk', 'clinic@cognovait.com', '$2y$10$Dh5pWjPIiWbO76iFh2AWl.N5vneb0NDd0m9L7VUU11rYDrPja7wXe', '1', NULL, '2026-10-20 17:04:54', '2026-10-16 02:59:34', '2026-10-20 17:04:54');
INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `active`, `password_changed_at`, `last_login_at`, `created_at`, `updated_at`) VALUES ('3', 'Lab Technologist Desk', 'lab@cognovait.com', '$2y$10$Dh5pWjPIiWbO76iFh2AWl.N5vneb0NDd0m9L7VUU11rYDrPja7wXe', '1', NULL, '2026-10-16 22:19:45', '2026-10-16 02:59:34', '2026-10-16 22:19:45');
INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `active`, `password_changed_at`, `last_login_at`, `created_at`, `updated_at`) VALUES ('4', 'Specialist Doctor Consultant', 'doctor@cognovait.com', '$2y$10$Dh5pWjPIiWbO76iFh2AWl.N5vneb0NDd0m9L7VUU11rYDrPja7wXe', '1', NULL, '2026-10-16 22:19:46', '2026-10-16 02:59:34', '2026-10-16 22:19:46');
INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `active`, `password_changed_at`, `last_login_at`, `created_at`, `updated_at`) VALUES ('5', 'Pharmacy & Center Staff', 'staff@cognovait.com', '$2y$10$Dh5pWjPIiWbO76iFh2AWl.N5vneb0NDd0m9L7VUU11rYDrPja7wXe', '1', NULL, '2026-10-16 22:19:46', '2026-10-16 02:59:34', '2026-10-16 22:19:46');

-- Table structure for table `website_appointments`
DROP TABLE IF EXISTS `website_appointments`;
CREATE TABLE `website_appointments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_name` varchar(255) NOT NULL,
  `patient_phone` varchar(50) NOT NULL,
  `patient_email` varchar(255) DEFAULT NULL,
  `department_name` varchar(255) DEFAULT NULL,
  `doctor_name` varchar(255) DEFAULT NULL,
  `preferred_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `website_doctors`
DROP TABLE IF EXISTS `website_doctors`;
CREATE TABLE `website_doctors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `qualification` varchar(255) NOT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `department` varchar(255) DEFAULT 'General Medicine',
  `image_url` text DEFAULT NULL,
  `experience` varchar(100) DEFAULT '10+ Years',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `website_gallery`
DROP TABLE IF EXISTS `website_gallery`;
CREATE TABLE `website_gallery` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `category` varchar(100) DEFAULT 'Facility',
  `image_url` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `website_messages`
DROP TABLE IF EXISTS `website_messages`;
CREATE TABLE `website_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_name` varchar(255) NOT NULL,
  `sender_email` varchar(255) NOT NULL,
  `sender_phone` varchar(50) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `website_services`
DROP TABLE IF EXISTS `website_services`;
CREATE TABLE `website_services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `icon_class` varchar(100) DEFAULT 'fa-solid fa-stethoscope',
  `description` text DEFAULT NULL,
  `category` varchar(100) DEFAULT 'General Healthcare',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `website_settings`
DROP TABLE IF EXISTS `website_settings`;
CREATE TABLE `website_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_title` varchar(255) DEFAULT NULL,
  `tagline` varchar(255) DEFAULT NULL,
  `hotline` varchar(50) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `hero_title` text DEFAULT NULL,
  `hero_subtitle` text DEFAULT NULL,
  `hero_bg_image` text DEFAULT NULL,
  `hero_cta1_text` varchar(255) DEFAULT NULL,
  `hero_cta1_link` varchar(255) DEFAULT NULL,
  `hero_cta2_text` varchar(255) DEFAULT NULL,
  `hero_cta2_link` varchar(255) DEFAULT NULL,
  `primary_color` varchar(50) DEFAULT NULL,
  `secondary_color` varchar(50) DEFAULT NULL,
  `button_color` varchar(50) DEFAULT NULL,
  `fb_link` varchar(255) DEFAULT NULL,
  `linkedin_link` varchar(255) DEFAULT NULL,
  `youtube_link` varchar(255) DEFAULT NULL,
  `instagram_link` varchar(255) DEFAULT NULL,
  `about_title` varchar(255) DEFAULT NULL,
  `about_text` text DEFAULT NULL,
  `chairman_message` text DEFAULT NULL,
  `md_message` text DEFAULT NULL,
  `logo_url` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `website_settings_history`
DROP TABLE IF EXISTS `website_settings_history`;
CREATE TABLE `website_settings_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `settings_json` text NOT NULL,
  `saved_by` varchar(100) DEFAULT 'System Admin',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS=1;
COMMIT;
