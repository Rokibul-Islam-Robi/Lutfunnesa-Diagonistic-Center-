<?php
declare(strict_types=1);

namespace Diagnostic;

use PDO;
use RuntimeException;

class WebsiteCMS
{
    public static function ensureTables(PDO $db): void
    {
        try {
            $db->exec("CREATE TABLE IF NOT EXISTS website_settings (
                id INT AUTO_INCREMENT PRIMARY KEY,
                site_title VARCHAR(255) NULL,
                tagline VARCHAR(255) NULL,
                hotline VARCHAR(50) NULL,
                phone VARCHAR(50) NULL,
                email VARCHAR(255) NULL,
                address TEXT NULL,
                hero_title TEXT NULL,
                hero_subtitle TEXT NULL,
                hero_bg_image TEXT NULL,
                hero_cta1_text VARCHAR(255) NULL,
                hero_cta1_link VARCHAR(255) NULL,
                hero_cta2_text VARCHAR(255) NULL,
                hero_cta2_link VARCHAR(255) NULL,
                primary_color VARCHAR(50) NULL,
                secondary_color VARCHAR(50) NULL,
                button_color VARCHAR(50) NULL,
                fb_link VARCHAR(255) NULL,
                linkedin_link VARCHAR(255) NULL,
                youtube_link VARCHAR(255) NULL,
                instagram_link VARCHAR(255) NULL,
                about_title VARCHAR(255) NULL,
                about_text TEXT NULL,
                chairman_message TEXT NULL,
                md_message TEXT NULL,
                logo_url TEXT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )");
            $db->exec("CREATE TABLE IF NOT EXISTS website_settings_history (
                id INT AUTO_INCREMENT PRIMARY KEY,
                settings_json TEXT NOT NULL,
                saved_by VARCHAR(100) DEFAULT 'System Admin',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )");
            $db->exec("CREATE TABLE IF NOT EXISTS website_doctors (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                qualification VARCHAR(255) NOT NULL,
                designation VARCHAR(255) NULL,
                department VARCHAR(255) DEFAULT 'General Medicine',
                image_url TEXT NULL,
                experience VARCHAR(100) DEFAULT '10+ Years',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )");
            $db->exec("CREATE TABLE IF NOT EXISTS website_services (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                icon_class VARCHAR(100) DEFAULT 'fa-solid fa-stethoscope',
                description TEXT NULL,
                category VARCHAR(100) DEFAULT 'General Healthcare',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )");
            $db->exec("CREATE TABLE IF NOT EXISTS website_gallery (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                category VARCHAR(100) DEFAULT 'Facility',
                image_url TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )");
            $db->exec("CREATE TABLE IF NOT EXISTS website_appointments (
                id INT AUTO_INCREMENT PRIMARY KEY,
                patient_name VARCHAR(255) NOT NULL,
                patient_phone VARCHAR(50) NOT NULL,
                patient_email VARCHAR(255) NULL,
                department_name VARCHAR(255) NULL,
                doctor_name VARCHAR(255) NULL,
                preferred_date DATE NULL,
                notes TEXT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )");
            $db->exec("CREATE TABLE IF NOT EXISTS website_messages (
                id INT AUTO_INCREMENT PRIMARY KEY,
                sender_name VARCHAR(255) NOT NULL,
                sender_email VARCHAR(255) NOT NULL,
                sender_phone VARCHAR(50) NULL,
                subject VARCHAR(255) NULL,
                message TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )");
        } catch (\Throwable $e) {}
    }

    public static function getSettings(PDO $db): array
    {
        self::ensureTables($db);
        $settings = false;
        try {
            $stmt = $db->query("SELECT * FROM website_settings ORDER BY id ASC LIMIT 1");
            $settings = $stmt->fetch();
        } catch (\Throwable $e) {}

        if (!$settings) {
            return [
                'site_title' => 'Lutfunnesa Diabetes & Diagnostic Center',
                'tagline' => 'Modern Diabetes, Diagnostic & Multi-Speciality Hospital Care',
                'hotline' => '10666',
                'phone' => '+880 9611-000111',
                'email' => 'info@lutfunnesadiagnostic.com',
                'address' => 'Station Road, Farmgate, Dhaka-1215',
                'hero_title' => 'ADVANCED DIABETES & DIAGNOSTIC CARE FOR EVERY FAMILY',
                'hero_subtitle' => 'Experienced specialists, modern laboratory technology and compassionate nursing — all under one roof, open 24 hours a day.',
                'hero_bg_image' => 'https://bdspecializedhospital.com/storage/app/public/media/1613276934.jpg',
                'hero_cta1_text' => 'BOOK AN APPOINTMENT',
                'hero_cta1_link' => '#appointment',
                'hero_cta2_text' => 'FIND A DOCTOR',
                'hero_cta2_link' => 'doctors.html',
                'primary_color' => '#059669',
                'secondary_color' => '#0f172a',
                'button_color' => '#059669',
                'fb_link' => 'https://facebook.com',
                'linkedin_link' => 'https://linkedin.com',
                'youtube_link' => 'https://youtube.com',
                'instagram_link' => 'https://instagram.com',
                'about_title' => 'WELCOME TO LUTFUNNESA CENTER',
                'about_text' => 'Lutfunnesa Diabetes & Diagnostic Center offers world-class diagnostic pathology, digital radiology, diabetology, and specialist consultation with 24/7 emergency care.',
                'chairman_message' => 'Our mission is to provide accessible, high-precision healthcare and compassionate diagnostic support to every family.',
                'md_message' => 'We are committed to continuous technology optimization, quality patient outcomes, and clinical excellence.',
                'logo_url' => 'assets/img/logo.png'
            ];
        }
        if (empty($settings['logo_url'])) {
            $settings['logo_url'] = 'assets/img/logo.png';
        }
        return $settings;
    }

    public static function handleImageUpload(?array $file, string $base64Data = '', string $fallback = ''): string
    {
        if ($file && isset($file['tmp_name']) && is_uploaded_file($file['tmp_name']) && $file['error'] === UPLOAD_ERR_OK) {
            $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
            if (!in_array($ext, ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'], true)) {
                $ext = 'jpg';
            }
            $filename = 'cms_' . time() . '_' . mt_rand(1000, 9999) . '.' . $ext;
            $uploadDir = dirname(__DIR__) . '/public/website/assets/uploads/';
            if (!is_dir($uploadDir)) {
                @mkdir($uploadDir, 0777, true);
            }
            $targetPath = $uploadDir . $filename;
            if (move_uploaded_file($file['tmp_name'], $targetPath)) {
                return 'assets/uploads/' . $filename;
            }
        }
        if (!empty($base64Data) && str_starts_with($base64Data, 'data:image/')) {
            $parts = explode(',', $base64Data);
            if (count($parts) === 2) {
                $data = base64_decode($parts[1]);
                if ($data !== false) {
                    $filename = 'cms_b64_' . time() . '_' . mt_rand(1000, 9999) . '.png';
                    $uploadDir = dirname(__DIR__) . '/public/website/assets/uploads/';
                    if (!is_dir($uploadDir)) {
                        @mkdir($uploadDir, 0777, true);
                    }
                    if (file_put_contents($uploadDir . $filename, $data) !== false) {
                        return 'assets/uploads/' . $filename;
                    }
                }
            }
        }
        return $fallback;
    }

    public static function exportStaticCmsJson(PDO $db): void
    {
        try {
            $payload = [
                'settings' => self::getSettings($db),
                'doctors' => self::getDoctors($db),
                'services' => self::getServices($db),
                'gallery' => self::getGallery($db)
            ];
            $json = json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
            $dir = dirname(__DIR__) . '/public/website/assets';
            if (!is_dir($dir)) {
                @mkdir($dir, 0777, true);
            }
            @file_put_contents($dir . '/cms_data.json', $json);
        } catch (\Throwable $e) {}
    }

    public static function backupSettingsSnapshot(PDO $db, string $savedBy = 'System Admin'): void
    {
        self::ensureTables($db);
        try {
            $current = self::getSettings($db);
            $json = json_encode($current, JSON_UNESCAPED_UNICODE);
            $db->prepare("INSERT INTO website_settings_history (settings_json, saved_by) VALUES (?, ?)")
                ->execute([$json, $savedBy]);
        } catch (\Throwable $e) {}
    }

    public static function updateSettingsInternal(PDO $db, array $data): void
    {
        $stmt = $db->prepare("UPDATE website_settings SET 
            site_title = ?, tagline = ?, hotline = ?, phone = ?, email = ?, address = ?,
            hero_title = ?, hero_subtitle = ?, hero_bg_image = ?,
            hero_cta1_text = ?, hero_cta1_link = ?, hero_cta2_text = ?, hero_cta2_link = ?,
            primary_color = ?, secondary_color = ?, button_color = ?,
            fb_link = ?, linkedin_link = ?, youtube_link = ?, instagram_link = ?,
            about_title = ?, about_text = ?, chairman_message = ?, md_message = ?,
            logo_url = ?
            WHERE id = 1");

        $stmt->execute([
            $data['site_title'] ?? 'Lutfunnesa Diabetes & Diagnostic Center',
            $data['tagline'] ?? 'Modern Diabetes, Diagnostic & Multi-Speciality Hospital Care',
            $data['hotline'] ?? '10666',
            $data['phone'] ?? '+880 9611-000111',
            $data['email'] ?? 'info@lutfunnesadiagnostic.com',
            $data['address'] ?? 'Station Road, Farmgate, Dhaka-1215',
            $data['hero_title'] ?? 'ADVANCED DIABETES & DIAGNOSTIC CARE FOR EVERY FAMILY',
            $data['hero_subtitle'] ?? 'Experienced specialists, modern laboratory technology and compassionate nursing — all under one roof, open 24 hours a day.',
            $data['hero_bg_image'] ?? 'assets/img/logo.png',
            $data['hero_cta1_text'] ?? 'BOOK AN APPOINTMENT',
            $data['hero_cta1_link'] ?? '#appointment',
            $data['hero_cta2_text'] ?? 'FIND A DOCTOR',
            $data['hero_cta2_link'] ?? 'doctors.html',
            $data['primary_color'] ?? '#059669',
            $data['secondary_color'] ?? '#0f172a',
            $data['button_color'] ?? '#059669',
            $data['fb_link'] ?? 'https://facebook.com',
            $data['linkedin_link'] ?? 'https://linkedin.com',
            $data['youtube_link'] ?? 'https://youtube.com',
            $data['instagram_link'] ?? 'https://instagram.com',
            $data['about_title'] ?? 'WELCOME TO LUTFUNNESA CENTER',
            $data['about_text'] ?? 'Lutfunnesa Diabetes & Diagnostic Center offers world-class diagnostic pathology, digital radiology, diabetology, and specialist consultation with 24/7 emergency care.',
            $data['chairman_message'] ?? 'Our mission is to provide accessible, high-precision healthcare and compassionate diagnostic support to every family.',
            $data['md_message'] ?? 'We are committed to continuous technology optimization, quality patient outcomes, and clinical excellence.',
            $data['logo_url'] ?? 'assets/img/logo.png'
        ]);
    }

    public static function updateSettings(PDO $db, array $data, ?array $files = null): void
    {
        self::backupSettingsSnapshot($db, 'Admin Update Snapshot');
        $current = self::getSettings($db);

        $title = trim((string)($data['site_title'] ?? $current['site_title']));
        $tagline = trim((string)($data['tagline'] ?? $current['tagline']));
        $hotline = trim((string)($data['hotline'] ?? $current['hotline']));
        $phone = trim((string)($data['phone'] ?? $current['phone']));
        $email = trim((string)($data['email'] ?? $current['email']));
        $address = trim((string)($data['address'] ?? $current['address']));

        $heroTitle = trim((string)($data['hero_title'] ?? $current['hero_title']));
        $heroSubtitle = trim((string)($data['hero_subtitle'] ?? $current['hero_subtitle']));
        
        $uploadedHeroBg = self::handleImageUpload($files['hero_bg_file'] ?? null, (string)($data['hero_bg_b64'] ?? ''), (string)($data['hero_bg_image'] ?? $current['hero_bg_image']));
        $heroBgImage = !empty($uploadedHeroBg) ? $uploadedHeroBg : $current['hero_bg_image'];

        $uploadedLogo = self::handleImageUpload($files['logo_file'] ?? null, (string)($data['logo_b64'] ?? ''), (string)($data['logo_url'] ?? $current['logo_url']));
        $logoUrl = !empty($uploadedLogo) ? $uploadedLogo : ($current['logo_url'] ?: 'assets/img/logo.png');

        $heroCta1Text = trim((string)($data['hero_cta1_text'] ?? $current['hero_cta1_text']));
        $heroCta1Link = trim((string)($data['hero_cta1_link'] ?? $current['hero_cta1_link']));
        $heroCta2Text = trim((string)($data['hero_cta2_text'] ?? $current['hero_cta2_text']));
        $heroCta2Link = trim((string)($data['hero_cta2_link'] ?? $current['hero_cta2_link']));

        $primaryColor = trim((string)($data['primary_color'] ?? $current['primary_color']));
        $secondaryColor = trim((string)($data['secondary_color'] ?? $current['secondary_color']));
        $buttonColor = trim((string)($data['button_color'] ?? $current['button_color']));

        $fbLink = trim((string)($data['fb_link'] ?? $current['fb_link']));
        $linkedinLink = trim((string)($data['linkedin_link'] ?? $current['linkedin_link']));
        $youtubeLink = trim((string)($data['youtube_link'] ?? $current['youtube_link']));
        $instagramLink = trim((string)($data['instagram_link'] ?? $current['instagram_link']));

        $aboutTitle = trim((string)($data['about_title'] ?? $current['about_title']));
        $aboutText = trim((string)($data['about_text'] ?? $current['about_text']));
        $chairmanMessage = trim((string)($data['chairman_message'] ?? $current['chairman_message']));
        $mdMessage = trim((string)($data['md_message'] ?? $current['md_message']));

        self::updateSettingsInternal($db, [
            'site_title' => $title,
            'tagline' => $tagline,
            'hotline' => $hotline,
            'phone' => $phone,
            'email' => $email,
            'address' => $address,
            'hero_title' => $heroTitle,
            'hero_subtitle' => $heroSubtitle,
            'hero_bg_image' => $heroBgImage,
            'hero_cta1_text' => $heroCta1Text,
            'hero_cta1_link' => $heroCta1Link,
            'hero_cta2_text' => $heroCta2Text,
            'hero_cta2_link' => $heroCta2Link,
            'primary_color' => $primaryColor,
            'secondary_color' => $secondaryColor,
            'button_color' => $buttonColor,
            'fb_link' => $fbLink,
            'linkedin_link' => $linkedinLink,
            'youtube_link' => $youtubeLink,
            'instagram_link' => $instagramLink,
            'about_title' => $aboutTitle,
            'about_text' => $aboutText,
            'chairman_message' => $chairmanMessage,
            'md_message' => $mdMessage,
            'logo_url' => $logoUrl
        ]);

        self::exportStaticCmsJson($db);
    }

    public static function restorePreviousBackup(PDO $db): bool
    {
        self::ensureTables($db);
        try {
            $stmt = $db->query("SELECT * FROM website_settings_history ORDER BY id DESC LIMIT 1");
            $row = $stmt->fetch();
            if (!$row || empty($row['settings_json'])) {
                return false;
            }
            $data = json_decode((string)$row['settings_json'], true);
            if (!is_array($data)) {
                return false;
            }
            self::updateSettingsInternal($db, $data);
            $db->prepare("DELETE FROM website_settings_history WHERE id = ?")->execute([$row['id']]);
            self::exportStaticCmsJson($db);
            return true;
        } catch (\Throwable $e) {
            return false;
        }
    }

    public static function resetToDefaults(PDO $db): void
    {
        self::backupSettingsSnapshot($db, 'Reset Default Backup');
        $defaults = [
            'site_title' => 'Lutfunnesa Diabetes & Diagnostic Center',
            'tagline' => 'Modern Diabetes, Diagnostic & Multi-Speciality Hospital Care',
            'hotline' => '10666',
            'phone' => '+880 9611-000111',
            'email' => 'info@lutfunnesadiagnostic.com',
            'address' => 'Station Road, Farmgate, Dhaka-1215',
            'hero_title' => 'ADVANCED DIABETES & DIAGNOSTIC CARE FOR EVERY FAMILY',
            'hero_subtitle' => 'Experienced specialists, modern laboratory technology and compassionate nursing — all under one roof, open 24 hours a day.',
            'hero_bg_image' => 'assets/img/logo.png',
            'hero_cta1_text' => 'BOOK AN APPOINTMENT',
            'hero_cta1_link' => '#appointment',
            'hero_cta2_text' => 'FIND A DOCTOR',
            'hero_cta2_link' => 'doctors.html',
            'primary_color' => '#059669',
            'secondary_color' => '#0f172a',
            'button_color' => '#059669',
            'fb_link' => 'https://facebook.com',
            'linkedin_link' => 'https://linkedin.com',
            'youtube_link' => 'https://youtube.com',
            'instagram_link' => 'https://instagram.com',
            'about_title' => 'WELCOME TO LUTFUNNESA CENTER',
            'about_text' => 'Lutfunnesa Diabetes & Diagnostic Center offers world-class diagnostic pathology, digital radiology, diabetology, and specialist consultation with 24/7 emergency care.',
            'chairman_message' => 'Our mission is to provide accessible, high-precision healthcare and compassionate diagnostic support to every family.',
            'md_message' => 'We are committed to continuous technology optimization, quality patient outcomes, and clinical excellence.',
            'logo_url' => 'assets/img/logo.png'
        ];
        self::updateSettingsInternal($db, $defaults);
        self::exportStaticCmsJson($db);
    }

    public static function getDoctors(PDO $db): array
    {
        return $db->query("SELECT * FROM website_doctors ORDER BY id DESC")->fetchAll();
    }

    public static function addDoctor(PDO $db, array $data, ?array $files = null): int
    {
        $name = trim((string)($data['name'] ?? ''));
        $qualification = trim((string)($data['qualification'] ?? ''));
        $designation = trim((string)($data['designation'] ?? ''));
        $department = trim((string)($data['department'] ?? 'General Medicine'));
        
        $uploadedImg = self::handleImageUpload($files['image_file'] ?? null, (string)($data['image_b64'] ?? ''), (string)($data['image_url'] ?? 'https://bdspecializedhospital.com/UI/FrontEnd/img/doctor/1.jpg'));
        $imageUrl = !empty($uploadedImg) ? $uploadedImg : 'https://bdspecializedhospital.com/UI/FrontEnd/img/doctor/1.jpg';
        
        $experience = trim((string)($data['experience'] ?? '10+ Years'));

        if ($name === '' || $qualification === '') {
            throw new RuntimeException('Doctor Name and Qualification are required.');
        }

        $stmt = $db->prepare("INSERT INTO website_doctors (name, qualification, designation, department, image_url, experience) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->execute([$name, $qualification, $designation, $department, $imageUrl, $experience]);
        $id = (int)$db->lastInsertId();
        self::exportStaticCmsJson($db);
        return $id;
    }

    public static function deleteDoctor(PDO $db, int $id): void
    {
        $db->prepare("DELETE FROM website_doctors WHERE id = ?")->execute([$id]);
        self::exportStaticCmsJson($db);
    }

    public static function getServices(PDO $db): array
    {
        return $db->query("SELECT * FROM website_services ORDER BY id DESC")->fetchAll();
    }

    public static function addService(PDO $db, array $data): int
    {
        $title = trim((string)($data['title'] ?? ''));
        $iconClass = trim((string)($data['icon_class'] ?? 'fa-solid fa-stethoscope'));
        $description = trim((string)($data['description'] ?? ''));
        $category = trim((string)($data['category'] ?? 'General Healthcare'));

        if ($title === '') {
            throw new RuntimeException('Service Title is required.');
        }

        $stmt = $db->prepare("INSERT INTO website_services (title, icon_class, description, category) VALUES (?, ?, ?, ?)");
        $stmt->execute([$title, $iconClass, $description, $category]);
        $id = (int)$db->lastInsertId();
        self::exportStaticCmsJson($db);
        return $id;
    }

    public static function deleteService(PDO $db, int $id): void
    {
        $db->prepare("DELETE FROM website_services WHERE id = ?")->execute([$id]);
        self::exportStaticCmsJson($db);
    }

    public static function getGallery(PDO $db): array
    {
        return $db->query("SELECT * FROM website_gallery ORDER BY id DESC")->fetchAll();
    }

    public static function addGalleryItem(PDO $db, array $data, ?array $files = null): int
    {
        $title = trim((string)($data['title'] ?? 'Hospital Facility'));
        $category = trim((string)($data['category'] ?? 'Hospital Premises'));
        
        $uploadedImg = self::handleImageUpload($files['image_file'] ?? null, (string)($data['image_b64'] ?? ''), (string)($data['image_url'] ?? 'https://bdspecializedhospital.com/UI/FrontEnd/img/gallery/1.jpg'));
        $imageUrl = !empty($uploadedImg) ? $uploadedImg : 'https://bdspecializedhospital.com/UI/FrontEnd/img/gallery/1.jpg';

        $stmt = $db->prepare("INSERT INTO website_gallery (title, category, image_url) VALUES (?, ?, ?)");
        $stmt->execute([$title, $category, $imageUrl]);
        $id = (int)$db->lastInsertId();
        self::exportStaticCmsJson($db);
        return $id;
    }

    public static function deleteGalleryItem(PDO $db, int $id): void
    {
        $db->prepare("DELETE FROM website_gallery WHERE id = ?")->execute([$id]);
        self::exportStaticCmsJson($db);
    }

    public static function submitAppointment(PDO $db, array $data): int
    {
        $name = trim((string)($data['patient_name'] ?? ''));
        $phone = trim((string)($data['patient_phone'] ?? ''));
        $email = trim((string)($data['patient_email'] ?? ''));
        $dept = trim((string)($data['department_name'] ?? 'General Medicine'));
        $doctor = trim((string)($data['doctor_name'] ?? 'Duty Specialist Doctor'));
        $date = !empty($data['preferred_date']) ? $data['preferred_date'] : date('Y-m-d', strtotime('+1 day'));
        $notes = trim((string)($data['notes'] ?? 'Online Website Booking Request'));

        if ($name === '' || $phone === '') {
            throw new RuntimeException('Patient Name and Phone Number are required.');
        }

        $stmt = $db->prepare("INSERT INTO website_appointments (patient_name, patient_phone, patient_email, department_name, doctor_name, preferred_date, notes) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$name, $phone, $email, $dept, $doctor, $date, $notes]);
        $appId = (int)$db->lastInsertId();

        try {
            $db->prepare("INSERT INTO appointments (branch_id, patient_id, appointment_type, appointment_date, time_slot, doctor_id, status, notes) VALUES (1, 1, 'consultation', ?, '10:00:00', 1, 'scheduled', ?)")
                ->execute([$date, "Online Booking Request #{$appId} - Patient: {$name} ({$phone})"]);
        } catch (\Throwable $e) {}

        return $appId;
    }

    public static function submitContactMessage(PDO $db, array $data): int
    {
        $name = trim((string)($data['sender_name'] ?? ''));
        $email = trim((string)($data['sender_email'] ?? ''));
        $phone = trim((string)($data['sender_phone'] ?? ''));
        $subject = trim((string)($data['subject'] ?? 'Website Inquiry'));
        $msg = trim((string)($data['message'] ?? ''));

        if ($name === '' || $email === '' || $msg === '') {
            throw new RuntimeException('Name, Email and Message are required.');
        }

        $stmt = $db->prepare("INSERT INTO website_messages (sender_name, sender_email, sender_phone, subject, message) VALUES (?, ?, ?, ?, ?)");
        $stmt->execute([$name, $email, $phone, $subject, $msg]);
        return (int)$db->lastInsertId();
    }

    public static function listAppointments(PDO $db): array
    {
        return $db->query("SELECT * FROM website_appointments ORDER BY id DESC LIMIT 50")->fetchAll();
    }

    public static function listMessages(PDO $db): array
    {
        return $db->query("SELECT * FROM website_messages ORDER BY id DESC LIMIT 50")->fetchAll();
    }
}
