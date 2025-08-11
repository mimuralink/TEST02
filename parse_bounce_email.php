<?php
// Parse bounce e-mail and optionally store details into PostgreSQL
// Usage: php parse_bounce_email.php FILE [DSN]

if ($argc < 2) {
    fwrite(STDERR, "Usage: php parse_bounce_email.php FILE [DSN]\n");
    exit(1);
}

$file = $argv[1];
$dsn  = $argv[2] ?? null;
$raw  = file_get_contents($file);

// Split headers and body
list($headerText, $body) = preg_split("/\r?\n\r?\n/", $raw, 2);
$headers = [];
$current = null;
foreach (preg_split("/\r?\n/", $headerText) as $line) {
    if ($line === '') {
        continue;
    }
    if (preg_match('/^\s+/', $line) && $current !== null) {
        // Continuation line
        $headers[$current] .= ' ' . trim($line);
    } else {
        $parts = explode(':', $line, 2);
        if (count($parts) === 2) {
            $current = trim($parts[0]);
            $headers[$current] = trim($parts[1]);
        }
    }
}

$subject = $headers['Subject'] ?? '';

$errorCode = null;
if (preg_match('/Status:\s*([245]\.[0-9]\.[0-9])/', $raw, $m)) {
    $errorCode = $m[1];
} elseif (preg_match('/Diagnostic-Code:\s*[^;]+;\s*([0-9]{3}\s[0-9.]+)/', $raw, $m)) {
    $errorCode = $m[1];
}

$info = [
    'subject' => $subject,
    'headers' => $headers,
    'body' => $body,
    'error_code' => $errorCode,
];

if ($dsn) {
    $pdo = new PDO($dsn);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->exec('CREATE TABLE IF NOT EXISTS bounces (
        id SERIAL PRIMARY KEY,
        subject TEXT,
        headers JSON,
        body TEXT,
        error_code TEXT
    )');
    $stmt = $pdo->prepare('INSERT INTO bounces (subject, headers, body, error_code) VALUES (:subject, :headers, :body, :error_code)');
    $stmt->execute([
        ':subject' => $info['subject'],
        ':headers' => json_encode($info['headers']),
        ':body' => $info['body'],
        ':error_code' => $info['error_code']
    ]);
    echo "Stored bounce information in PostgreSQL.\n";
} else {
    echo json_encode($info, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . PHP_EOL;
}

