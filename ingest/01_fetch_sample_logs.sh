#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="/tmp/ris330-apache-samples"
ACCESS_URL="https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/apache_logs/apache_logs"
ERROR_HTML_URL="https://www.ossec.net/docs/log_samples/apache/apache.html"

mkdir -p "${WORK_DIR}"

echo "=== Download Apache access log sample ==="
curl -fsSL "${ACCESS_URL}" -o "${WORK_DIR}/access.log"

echo "=== Download Apache error log sample page ==="
curl -fsSL "${ERROR_HTML_URL}" -o "${WORK_DIR}/apache_samples.html"

echo "=== Extract Apache error log lines ==="
python3 - <<'PY'
import re
from html import unescape
from pathlib import Path

html_path = Path("/tmp/ris330-apache-samples/apache_samples.html")
out_path = Path("/tmp/ris330-apache-samples/error.log")
html = html_path.read_text(errors="ignore")

match = re.search(r'id="apache-error-log".*?<pre>(.*?)</pre>', html, re.S)
if not match:
    raise SystemExit("Could not find Apache error-log section in source page.")

block = match.group(1)
lines = [unescape(x) for x in re.findall(r'<span class="go">(.*?)</span>', block, re.S)]

if not lines:
    raise SystemExit("Could not extract error-log lines from source page.")

out_path.write_text("\n".join(lines) + "\n")
print(f"Extracted {len(lines)} error log lines to {out_path}")
PY

echo "=== Place logs into Apache default paths for Filebeat module ==="
sudo mkdir -p /var/log/apache2
# Ubuntu often uses drwxr-x--- root:adm here; the filebeat user must be able to
# traverse this directory or it will harvest zero lines (index stays empty).
sudo chmod 0755 /var/log/apache2
sudo cp "${WORK_DIR}/access.log" /var/log/apache2/access.log
sudo cp "${WORK_DIR}/error.log" /var/log/apache2/error.log
sudo chmod 0644 /var/log/apache2/access.log /var/log/apache2/error.log

# Official packages run Filebeat as user "filebeat"; adm membership is the usual fix.
if id filebeat >/dev/null 2>&1; then
  sudo usermod -aG adm filebeat || true
fi

echo "Access log lines: $(wc -l < "${WORK_DIR}/access.log")"
echo "Error log lines : $(wc -l < "${WORK_DIR}/error.log")"
echo "Logs are ready at /var/log/apache2/access.log and /var/log/apache2/error.log"

if systemctl is-active --quiet filebeat 2>/dev/null; then
  echo "=== Restart Filebeat so harvesters pick up log paths (important) ==="
  sudo systemctl restart filebeat
fi
