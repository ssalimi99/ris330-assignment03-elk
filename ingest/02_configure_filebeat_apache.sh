#!/usr/bin/env bash
set -euo pipefail

echo "=== Ensure Elasticsearch and Kibana are reachable ==="
curl -fsS http://127.0.0.1:9200 >/dev/null
curl -fsS http://127.0.0.1:5601/api/status >/dev/null

echo "=== Enable Apache module ==="
sudo filebeat modules enable apache

echo "=== Configure Apache module paths ==="
sudo tee /etc/filebeat/modules.d/apache.yml >/dev/null <<'EOF'
- module: apache
  access:
    enabled: true
    var.paths: ["/var/log/apache2/access.log*"]

  error:
    enabled: true
    var.paths: ["/var/log/apache2/error.log*"]
EOF

echo "=== Validate and setup Filebeat assets ==="
sudo filebeat test config -e
sudo filebeat setup -e

echo "=== Ensure Filebeat can read Apache logs (Ubuntu default perms) ==="
sudo chmod 0755 /var/log/apache2
if [[ -f /var/log/apache2/access.log ]]; then sudo chmod 0644 /var/log/apache2/access.log; fi
if [[ -f /var/log/apache2/error.log ]]; then sudo chmod 0644 /var/log/apache2/error.log; fi
if id filebeat >/dev/null 2>&1; then
  sudo usermod -aG adm filebeat || true
fi

echo "=== Restart Filebeat ==="
sudo systemctl restart filebeat
sudo systemctl is-active --quiet filebeat && echo "filebeat: active"

echo "Filebeat Apache module is configured."
