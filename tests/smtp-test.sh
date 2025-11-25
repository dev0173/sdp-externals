#!/usr/bin/env bash
set -euo pipefail

# Config
SMTP_HOST="localhost"
SMTP_PORT="1025"

FROM_ADDR="sender@example.com"
TO_ADDR="recipient@example.com"

ATTACHMENT_FILE="${1:-./email-attachment.txt}"   # pass a path as first arg or it will default

if [[ ! -f "$ATTACHMENT_FILE" ]]; then
  echo "Attachment file '$ATTACHMENT_FILE' not found."
  exit 1
fi

send_plain_text_email() {
  {
    # SMTP envelope and headers
    printf 'HELO localhost\r\n'
    printf 'MAIL FROM:<%s>\r\n' "$FROM_ADDR"
    printf 'RCPT TO:<%s>\r\n' "$TO_ADDR"
    printf 'DATA\r\n'

    printf 'From: <%s>\r\n' "$FROM_ADDR"
    printf 'To: <%s>\r\n' "$TO_ADDR"
    printf 'Subject: Plain text test email\r\n'
    printf '\r\n'

    # Text body
    printf 'Hello,\r\n\r\nThis is a simple plain text email.\r\n\r\nRegards,\r\nSMTP Test Script\r\n'
    printf '.\r\n'
    printf 'QUIT\r\n'
  } | nc "$SMTP_HOST" "$SMTP_PORT" 

}

send_email_with_attachment() {
  local boundary="====BOUNDARY_$$.$RANDOM===="
  local filename
  filename="$(basename "$ATTACHMENT_FILE")"

  {
    # SMTP envelope and headers
    printf 'HELO localhost\r\n'
    printf 'MAIL FROM:<%s>\r\n' "$FROM_ADDR"
    printf 'RCPT TO:<%s>\r\n' "$TO_ADDR"
    printf 'DATA\r\n'

    printf 'From: <%s>\r\n' "$FROM_ADDR"
    printf 'To: <%s>\r\n' "$TO_ADDR"
    printf 'Subject: Test email with attachment\r\n'
    printf 'MIME-Version: 1.0\r\n'
    printf 'Content-Type: multipart/mixed; boundary="%s"\r\n' "$boundary"
    printf '\r\n'

    # Text part
    printf '%s\r\n' "--$boundary"
    printf 'Content-Type: text/plain; charset="utf-8"\r\n'
    printf 'Content-Transfer-Encoding: 7bit\r\n'
    printf '\r\n'
    printf 'Hello,\r\n'
    printf '\r\n'
    printf 'This is a test email that includes a small attachment.\r\n'
    printf '\r\n'
    printf 'Regards,\r\n'
    printf 'SMTP Test Script\r\n'
    printf '\r\n'

    # Attachment part
    printf '%s\r\n' "--$boundary"
    printf 'Content-Type: application/octet-stream; name="%s"\r\n' "$filename"
    printf 'Content-Transfer-Encoding: base64\r\n'
    printf 'Content-Disposition: attachment; filename="%s"\r\n' "$filename"
    printf '\r\n'
    
    # Ensure base64 lines end with \r\n to be proper SMTP CRLF
    base64 -i "$ATTACHMENT_FILE" | sed 's/$/\r/'
    printf '\r\n'

    # Closing boundary and end of DATA
    printf '%s--\r\n' "--$boundary"
    printf '.\r\n'
    printf 'QUIT\r\n'
  } | nc "$SMTP_HOST" "$SMTP_PORT"
}


echo "Sending plain text email..."
send_plain_text_email
echo "Done."

echo "Sending email with attachment: $ATTACHMENT_FILE"
send_email_with_attachment
echo "Done."
