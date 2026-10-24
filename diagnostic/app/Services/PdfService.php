<?php
declare(strict_types=1);

namespace App\Services;

/**
 * Proxy / Bridge to \Diagnostic\PdfService
 * Maintains compatibility with standard app/Services namespace
 */
class PdfService extends \Diagnostic\PdfService
{
}
