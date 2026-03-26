#!/usr/bin/env bash
set -euo pipefail

echo "=== Fix common reasons Filebeat shows 0 documents ==="
echo "1. Log directory not traversable by user 'filebeat'"
echo "2. Filebeat started before log files had content"
echo "3. Stale harvester state in the registry"
echo

echo "=== Permissions on /var/log/apache2 ==="
# Path may not exist if the apache2 package was never installed (ZIP lab VMs often skip it).
sudo mkdir -p /var/log/apache2
sudo chmod 0755 /var/log/apache2
if [[ -f /var/log/apache2/access.log ]]; then sudo chmod 0644 /var/log/apache2/access.log; fi
if [[ -f /var/log/apache2/error.log ]]; then sudo chmod 0644 /var/log/apache2/error.log; fi
sudo ls -la /var/log/apache2/

if id filebeat >/dev/null 2>&1; then
  sudo usermod -aG adm filebeat || true
fi

echo "=== Log line counts (should be > 0) ==="
wc -l /var/log/apache2/access.log /var/log/apache2/error.log 2>/dev/null || {
  echo "Missing log files. Run: bash ingest/01_fetch_sample_logs.sh"
  exit 1
}

echo "=== Reset Filebeat registry (forces re-read of log files) ==="
sudo systemctl stop filebeat
sudo rm -rf /var/lib/filebeat/registry/*
sudo systemctl start filebeat

echo "=== Wait for first bulk flush (up to ~90s) ==="
for i in $(seq 1 18); do
  COUNT_JSON="$(curl -fsS "http://127.0.0.1:9200/filebeat-*/_count" 2>/dev/null || echo '{"count":0}')"
  DOC_COUNT="$(printf "%s" "${COUNT_JSON}" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("count", 0))')"
  echo "  attempt ${i}: filebeat docs = ${DOC_COUNT}"
  if [[ "${DOC_COUNT}" -gt 0 ]]; then
    echo "OK - events are landing in Elasticsearch."
    exit 0
  fi
  sleep 5
done

echo
echo "Still 0 documents. Check Filebeat errors:"
echo "  sudo journalctl -u filebeat -n 80 --no-pager"
echo "  sudo filebeat test config -e"
echo "  sudo filebeat export modules apache | head -40"
exit 1
