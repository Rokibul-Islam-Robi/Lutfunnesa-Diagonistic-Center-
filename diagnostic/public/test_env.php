<?php
declare(strict_types=1);

// Debug endpoint to inspect actual environment variables loaded in Vercel
header('Content-Type: text/html; charset=utf-8');
echo '<html><body style="font-family:monospace;padding:20px;background:#0f172a;color:#f8fafc;">';
echo '<h2>Vercel Runtime Environment Inspector</h2>';

$keys = ['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD', 'APP_ENV', 'APP_DEBUG'];
echo '<table border="1" cellpadding="8" style="border-collapse:collapse;border-color:#334155;width:100%;max-width:700px;">';
echo '<tr style="background:#1e293b;"><th>Variable Key</th><th>Status in $_ENV</th><th>Status in $_SERVER</th><th>getenv() value</th></tr>';

foreach ($keys as $k) {
    $inEnv = isset($_ENV[$k]) ? 'SET (Length: ' . strlen((string)$_ENV[$k]) . ')' : '<span style="color:#ef4444;">NOT SET</span>';
    $inServer = isset($_SERVER[$k]) ? 'SET (Length: ' . strlen((string)$_SERVER[$k]) . ')' : '<span style="color:#ef4444;">NOT SET</span>';
    $val = getenv($k);
    $getEnvVal = ($val !== false) ? 'SET (Val: ' . ($k === 'DB_PASSWORD' ? '***' : htmlspecialchars((string)$val)) . ')' : '<span style="color:#ef4444;">FALSE</span>';
    echo "<tr><td><strong>$k</strong></td><td>$inEnv</td><td>$inServer</td><td>$getEnvVal</td></tr>";
}
echo '</table>';

// Test DB Connection live
require_once dirname(__DIR__) . '/src/bootstrap.php';
echo '<br><h3>Testing Connection with db()...</h3>';
try {
    $db = db();
    echo '<p style="color:#10b981;font-weight:bold;">✓ Database Connection Successful!</p>';
} catch (Throwable $e) {
    echo '<p style="color:#ef4444;font-weight:bold;">✗ Connection Error: ' . htmlspecialchars($e->getMessage()) . '</p>';
}

echo '</body></html>';
