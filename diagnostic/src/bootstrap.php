<?php
declare(strict_types=1);

spl_autoload_register(static function (string $class): void {
    $prefix = 'Diagnostic\\';
    if (str_starts_with($class, $prefix)) {
        $path = __DIR__ . '/' . str_replace('\\', '/', substr($class, strlen($prefix))) . '.php';
        if (is_file($path)) require $path;
    }
});

$vendorAutoload = dirname(__DIR__) . '/vendor/autoload.php';
if (is_file($vendorAutoload)) {
    require_once $vendorAutoload;
}

function env_value(string $name, string $default = ''): string
{
    // Check $_ENV and $_SERVER first (Vercel Serverless environment)
    if (isset($_ENV[$name]) && $_ENV[$name] !== '') return (string) $_ENV[$name];
    if (isset($_SERVER[$name]) && $_SERVER[$name] !== '') return (string) $_SERVER[$name];
    $val = getenv($name);
    if ($val !== false && $val !== '') return (string) $val;

    static $values = null;
    if ($values === null) {
        $values = [];
        $file = dirname(__DIR__) . '/.env';
        if (is_file($file)) {
            foreach (file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [] as $line) {
                if (str_starts_with(trim($line), '#') || !str_contains($line, '=')) continue;
                [$key, $value] = explode('=', $line, 2);
                $values[trim($key)] = trim(trim($value), "\"'");
            }
        }
    }
    return (string) ($values[$name] ?? $default);
}

date_default_timezone_set(env_value('APP_TIMEZONE', 'Asia/Dhaka'));

function app_base_path(): string
{
    static $base = null;
    if ($base !== null) return $base;
    
    // Auto-detect script subdirectory (works seamlessly under XAMPP htdocs subfolders or php -S)
    if (!empty($_SERVER['SCRIPT_NAME'])) {
        $dir = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME']));
        if ($dir !== '/' && $dir !== '.') {
            $base = rtrim($dir, '/');
            return $base;
        }
    }
    
    $path = (string) (parse_url(env_value('APP_URL', ''), PHP_URL_PATH) ?? '');
    $path = '/' . trim($path, '/');
    $base = $path === '/' ? '' : rtrim($path, '/');
    return $base;
}

function app_path(string $path = ''): string
{
    $base = app_base_path();
    $path = ltrim($path, '/');
    return $base . '/' . $path;
}

function app_request_path(): string
{
    $path = (string) (parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?? '/');
    $base = app_base_path();
    if ($base !== '' && ($path === $base || str_starts_with($path, $base . '/'))) {
        $path = substr($path, strlen($base)) ?: '/';
    }
    return '/' . ltrim($path, '/');
}

function rewrite_app_urls(string $html): string
{
    $base = app_base_path();
    if ($base === '') return $html;
    return (string) preg_replace_callback(
        '/\\b(href|src|action)="\\/(?!\\/)([^"]*)"/i',
        static fn(array $m): string => $m[1] . '="' . $base . '/' . $m[2] . '"',
        $html
    );
}

function request_is_https(): bool
{
    $forwarded = strtolower(trim((string) ($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '')));
    if ($forwarded !== '') return explode(',', $forwarded)[0] === 'https';
    if (!empty($_SERVER['HTTPS']) && strtolower((string) $_SERVER['HTTPS']) !== 'off') return true;
    return strtolower((string) (parse_url(env_value('APP_URL', ''), PHP_URL_SCHEME) ?? '')) === 'https';
}

function db(): PDO
{
    static $db = null;
    if ($db instanceof PDO) return $db;
    $host = env_value('DB_HOST', 'gateway01.ap-northeast-1.prod.aws.tidbcloud.com');
    $port = env_value('DB_PORT', '4000');
    $dbname = env_value('DB_NAME', 'test');
    $user = env_value('DB_USER', '2j1q3whjJpQMVWL.root');
    $pass = env_value('DB_PASSWORD', 'hRVF0vucg24bv3wt');
    $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', $host, $port, $dbname);
    
    $connect = function($u, $p) use ($dsn, $host) {
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];

        // Cloud MySQL / TiDB / Aiven SSL requirement
        if ($host !== '127.0.0.1' && $host !== 'localhost') {
            $options[PDO::MYSQL_ATTR_SSL_CA] = true;
            $options[PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT] = false;
        }

        return new PDO($dsn, $u, $p, $options);
    };

    try {
        $db = $connect($user, $pass);
    } catch (PDOException $e) {
        // Auto-heal: If MySQL is not running (error 2002) on Windows and XAMPP exists, auto-start mysqld
        if (str_contains($e->getMessage(), '2002') && PHP_OS_FAMILY === 'Windows') {
            $xamppMysqld = 'C:/xampp/mysql/bin/mysqld.exe';
            $xamppIni = 'C:/xampp/mysql/bin/my.ini';
            if (file_exists($xamppMysqld)) {
                // Launch mysqld standalone daemon
                pclose(popen('start "" /B "C:\\xampp\\mysql\\bin\\mysqld.exe" --defaults-file="' . str_replace('/', '\\', $xamppIni) . '" --standalone', 'r'));
                // Retry connecting up to 6 times (up to 3 seconds)
                for ($i = 0; $i < 6; $i++) {
                    usleep(500000);
                    try {
                        $db = $connect($user, $pass);
                        break;
                    } catch (PDOException $retryEx) {
                        if ($user !== 'root') {
                            try {
                                $db = $connect('root', '');
                                break;
                            } catch (PDOException $r2) {}
                        }
                    }
                }
            }
        }

        if (!($db instanceof PDO)) {
            if ($user !== 'root') {
                try {
                    $db = $connect('root', '');
                } catch (PDOException $rootEx) {
                    throw $e;
                }
            } else {
                throw $e;
            }
        }
    }
    $db->exec("SET time_zone = '+06:00'");
    return $db;
}

function e(mixed $value): string { return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }

function csrf_token(): string
{
    if (!isset($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32));
    return $_SESSION['csrf'];
}

function require_csrf(): void
{
    $given = $_POST['_csrf'] ?? $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    if (!is_string($given) || !hash_equals(csrf_token(), $given)) {
        http_response_code(419);
        throw new RuntimeException('Form expired. Refresh and try again.');
    }
}

function redirect(string $route): never
{
    $base = app_base_path();
    $location = ($base !== '' && ($route === $base || str_starts_with($route, $base . '/')))
        ? $route
        : app_path($route);
    header('Location: ' . $location, true, 303);
    exit;
}

function flash(string $kind, string $message): void { $_SESSION['flash'] = [$kind, $message]; }

function input(string $key, int $max = 255): string { return mb_substr(trim((string) ($_POST[$key] ?? '')), 0, $max); }

function audit(PDO $db, string $entity, string $entityId, string $action, ?array $before, ?array $after, ?int $branchId = null, ?string $reason = null): void
{
    $stmt = $db->prepare('INSERT INTO audit_logs(actor_id,branch_id,entity_type,entity_id,action,before_json,after_json,reason,ip_address) VALUES(?,?,?,?,?,?,?,?,?)');
    $stmt->execute([$_SESSION['user_id'] ?? null, $branchId, $entity, $entityId, $action,
        $before === null ? null : json_encode($before, JSON_THROW_ON_ERROR),
        $after === null ? null : json_encode($after, JSON_THROW_ON_ERROR), $reason, $_SERVER['REMOTE_ADDR'] ?? 'CLI']);
}
