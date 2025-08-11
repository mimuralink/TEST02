import argparse
import json
import os
import re
from email import policy
from email.parser import BytesParser
from typing import Dict, Optional

def parse_bounce(raw_bytes: bytes) -> Dict[str, Optional[str]]:
    """Parse a raw bounce e-mail and return relevant information."""
    msg = BytesParser(policy=policy.default).parsebytes(raw_bytes)
    headers = dict(msg.items())
    subject = msg.get('subject', '')

    # Extract plain text body
    if msg.is_multipart():
        parts = [part.get_payload(decode=True) or b'' for part in msg.walk()
                 if part.get_content_type() == 'text/plain']
        body = b"\n".join(parts).decode(errors='ignore')
    else:
        body = msg.get_payload(decode=True).decode(errors='ignore')

    # Look for standard DSN fields
    error_code = None
    patterns = [
        re.compile(r"Status:\s*([245]\.[0-9]\.[0-9])"),
        re.compile(r"Diagnostic-Code:\s*[^;]+;\s*([0-9]{3}\s[0-9.]+)")
    ]
    for pat in patterns:
        match = pat.search(raw_bytes.decode(errors='ignore'))
        if match:
            error_code = match.group(1)
            break

    return {
        'subject': subject,
        'headers': headers,
        'body': body,
        'error_code': error_code,
    }


def store_in_postgres(dsn: str, info: Dict[str, Optional[str]]) -> None:
    """Store parsed bounce information into PostgreSQL."""
    import psycopg2  # Lazy import so script works without dependency when not storing

    conn = psycopg2.connect(dsn)
    cur = conn.cursor()
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS bounces (
            id SERIAL PRIMARY KEY,
            subject TEXT,
            headers JSONB,
            body TEXT,
            error_code TEXT
        )
        """
    )
    cur.execute(
        "INSERT INTO bounces (subject, headers, body, error_code) VALUES (%s, %s, %s, %s)",
        (
            info['subject'],
            json.dumps(info['headers']),
            info['body'],
            info['error_code'],
        ),
    )
    conn.commit()
    cur.close()
    conn.close()


def main() -> None:
    parser = argparse.ArgumentParser(description='Parse bounce e-mail and store in PostgreSQL')
    parser.add_argument('file', help='Path to bounce e-mail file')
    parser.add_argument('--dsn', help='PostgreSQL DSN e.g. "dbname=test user=postgres"')
    args = parser.parse_args()

    with open(args.file, 'rb') as f:
        raw = f.read()

    info = parse_bounce(raw)

    if args.dsn:
        store_in_postgres(args.dsn, info)
        print('Stored bounce information in PostgreSQL.')
    else:
        print(json.dumps(info, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
