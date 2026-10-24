# Lutfunnesa Diagnostic Center & Hospital ERP Management System

Enterprise-grade Hospital, Diagnostic Center, and Pharmacy Management ERP platform built with PHP 8.2+ and MySQL.

---

## 🌟 Key Features & Modules

1. **Front Desk & Appointments Desk:**
   - Multi-specialty Doctor Chamber Scheduling & Instant OPD Token Generation.
   - Doctor Consultation Fee auto-population with custom discount approvals and cash memo generation.
   - Walk-in, Website, and Phone appointment tracking.

2. **Home Sample Specimen Collection POS:**
   - Patient auto-registration with segregated categories (`Doctor Prescribed`, `Clinical Patient`, `Local Customer`).
   - Diagnostic test selection with real-time price calculation, cold-chain logistics travel fee, and discount approval tracking.
   - Multi-channel instant payment receipt & Phlebotomy dispatch voucher generation with mPDF.

3. **Laboratory Information System (LIS) & Diagnostics:**
   - Complete Pathology, Biochemistry, Hematology, Microbiology, and Radiology worklists.
   - Barcode accession tracking, critical value alerts, two-step pathologist authorization, and digital reports.

4. **Pharmacy POS & Chamber Integration:**
   - Counter pharmacy sales, inventory batch management, FEFO/FIFO dispatch, and direct chamber prescription queue.

5. **Financial Accounting & Commission Settlement:**
   - Double-entry Chart of Accounts, Cashier shifts, Journal vouchers, Trial Balance, Income Statement, and Balance Sheet.
   - Doctor & Referrer commission calculation, referral profile management, and settlement logs.

6. **Public Hospital Website & Patient Portal:**
   - Responsive multi-page hospital portal (`/hospital-website/` or `/index.php?page=website`).
   - Online appointment requests, doctor directory, service catalog, and OTP-based patient report verification.

---

## 🚀 Local Installation & Setup

1. **Prerequisites:**
   - PHP 8.2 or higher
   - MySQL 8.0+ or MariaDB 10.6+
   - Composer (optional, for mPDF dependency)

2. **Database Setup:**
   - Create a MySQL database (e.g. `tigersof_diagnostic`).
   - Import the complete schema & seed data from [`diagnostic/database/tigersof_diagnostic.sql`](diagnostic/database/tigersof_diagnostic.sql).

3. **Environment Configuration:**
   - In `diagnostic/`, copy `.env.example` to `.env`:
     ```env
     APP_ENV=local
     APP_DEBUG=1
     APP_URL=http://localhost:8000
     DB_HOST=127.0.0.1
     DB_PORT=3306
     DB_NAME=tigersof_diagnostic
     DB_USER=root
     DB_PASSWORD=
     ```

4. **Run Locally:**
   ```bash
   cd diagnostic
   php -S 127.0.0.1:8000 -t public public/router.php
   ```
   Open `http://127.0.0.1:8000` in your web browser.

---

## ☁️ Deploying to Vercel

This repository is pre-configured with `vercel.json` and a serverless entry point at `api/index.php`.

### Steps:
1. **Push this repository to GitHub:**
   ```bash
   git branch -M main
   git push -u origin main
   ```
2. **Import to Vercel:**
   - Go to [vercel.com/new](https://vercel.com/new) and import `Rokibul-Islam-Robi/Lutfunnesa-Diagonistic-Center-`.
   - Framework Preset: **Other**.
   - Root Directory: `./` (leave default).
3. **Set Environment Variables in Vercel:**
   In your Vercel Project Settings > **Environment Variables**, provide your cloud MySQL credentials (e.g. from Aiven, PlanetScale, Railway, or Supabase):
   - `DB_HOST` = `<your-cloud-db-host>`
   - `DB_PORT` = `3306`
   - `DB_NAME` = `<your-cloud-db-name>`
   - `DB_USER` = `<your-cloud-db-username>`
   - `DB_PASSWORD` = `<your-cloud-db-password>`
   - `APP_ENV` = `production`
   - `APP_DEBUG` = `0`
4. **Deploy:** Click **Deploy**. Vercel will build the serverless functions and serve both the ERP system and public assets seamlessly!
