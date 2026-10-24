<?php
declare(strict_types=1);

// Vercel Serverless Entrypoint for Lutfunnesa Diagnostic ERP & Hospital Portal

// Adjust server request URI for Vercel routing
if (!isset($_SERVER['SCRIPT_NAME']) || empty($_SERVER['SCRIPT_NAME'])) {
    $_SERVER['SCRIPT_NAME'] = '/index.php';
}

chdir(__DIR__ . '/../diagnostic/public');
require __DIR__ . '/../diagnostic/public/index.php';
