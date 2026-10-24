<?php
// One-click Auto Migration & Import endpoint for Vercel + TiDB Cloud
require_once dirname(__DIR__) . '/src/bootstrap.php';

header('Content-Type: text/html; charset=utf-8');
echo '<html><body style="font-family:sans-serif;padding:30px;background:#f8fafc;color:#0f172a;">';
echo '<h2>⚙️ TiDB Cloud Database Initializer & Importer</h2>';

try {
    $db = db();
    echo '<p style="color:#059669;font-weight:700;">✓ Successfully connected to Cloud Database!</p>';

    $sqlFile = dirname(__DIR__) . '/database/tigersof_diagnostic.sql';
    if (!file_exists($sqlFile)) {
        die('<p style="color:#dc2626;">Error: SQL file not found at ' . htmlspecialchars($sqlFile) . '</p></body></html>');
    }

    echo '<p>Reading SQL file (' . number_format(filesize($sqlFile) / 1024, 2) . ' KB)...</p>';
    $sql = file_get_contents($sqlFile);

    // Disable foreign key checks for clean import
    $db->exec("SET FOREIGN_KEY_CHECKS=0;");

    // Execute multi-query import
    $db->exec($sql);

    $db->exec("SET FOREIGN_KEY_CHECKS=1;");

    $tables = $db->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    $tableCount = count($tables);

    echo '<div style="background:#ecfdf5;border:2px solid #10b981;border-radius:8px;padding:20px;margin-top:20px;">';
    echo '<h3 style="color:#047857;margin:0 0 10px 0;">🎉 All ' . $tableCount . ' Tables & Initial Data Successfully Imported!</h3>';
    echo '<p style="margin:0 0 15px 0;">Your cloud database now has complete users, roles, tests, doctors, patients, and ERP configurations.</p>';
    echo '<a href="/index.php?page=login" style="display:inline-block;background:#0c928c;color:#ffffff;text-decoration:none;padding:12px 24px;border-radius:6px;font-weight:700;">➔ Proceed to Login</a>';
    echo '</div>';

} catch (Throwable $e) {
    echo '<div style="background:#fef2f2;border:2px solid #ef4444;border-radius:8px;padding:20px;margin-top:20px;">';
    echo '<h3 style="color:#991b1b;margin:0 0 10px 0;">❌ Import Failed</h3>';
    echo '<pre style="color:#b91c1c;white-space:pre-wrap;">' . htmlspecialchars($e->getMessage()) . '</pre>';
    echo '</div>';
}

echo '</body></html>';
