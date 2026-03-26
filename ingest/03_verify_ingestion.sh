#!/usr/bin/env bash
set -euo pipefail

echo "=== Wait for Filebeat to publish (first events can take 30–90s) ==="
sleep 45

echo "=== Filebeat indices ==="
curl -fsS "http://127.0.0.1:9200/_cat/indices/filebeat*?v"

echo "=== Count ingested documents ==="
COUNT_JSON="$(curl -fsS "http://127.0.0.1:9200/filebeat-*/_count")"
DOC_COUNT="$(printf "%s" "${COUNT_JSON}" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("count", 0))')"
echo "Ingested filebeat docs: ${DOC_COUNT}"

if [[ "${DOC_COUNT}" -le 0 ]]; then
  echo "No documents found yet."
  echo "Common fix on Ubuntu: the filebeat user cannot read files under /var/log/apache2 (directory was 750)."
  echo "Run: bash ingest/04_fix_zero_documents.sh"
  echo "Then re-run this script, or check: sudo journalctl -u filebeat -n 60 --no-pager"
  exit 2
fi

echo "=== Verify Apache dashboard objects in Kibana ==="
KIBANA_RESULT="$(curl -fsS -H "kbn-xsrf: true" \
  "http://127.0.0.1:5601/api/saved_objects/_find?type=dashboard&search=Apache&search_fields=title")"

FOUND_DASHES="$(printf "%s" "${KIBANA_RESULT}" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("total", 0))')"

echo "Kibana dashboards matching 'Apache': ${FOUND_DASHES}"
echo "Open Kibana -> Dashboards and search for: Filebeat Apache"

echo "Verification complete."
