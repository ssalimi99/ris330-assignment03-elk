#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  echo "Run as a regular user with sudo privileges, not as root."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Install prerequisites ==="
sudo apt-get update
sudo apt-get install -y apt-transport-https curl gnupg

echo "=== Add Elastic 7.x repository ==="
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch \
  | sudo gpg --dearmor -o /usr/share/keyrings/elastic-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/elastic-archive-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/elastic-7.x.list >/dev/null

echo "=== Install ELK components ==="
sudo apt-get update
sudo apt-get install -y elasticsearch logstash kibana filebeat

echo "=== Apply provided configuration files ==="
sudo cp "${ROOT_DIR}/configs/elasticsearch.yml" /etc/elasticsearch/elasticsearch.yml
sudo cp "${ROOT_DIR}/configs/kibana.yml" /etc/kibana/kibana.yml
sudo cp "${ROOT_DIR}/configs/logstash-apache.conf" /etc/logstash/conf.d/apache.conf
sudo cp "${ROOT_DIR}/configs/filebeat.yml" /etc/filebeat/filebeat.yml

echo "=== Enable services ==="
for service in elasticsearch logstash kibana filebeat; do
  sudo systemctl enable "${service}"
done

echo "=== Start services ==="
sudo systemctl restart elasticsearch
sleep 15
sudo systemctl restart logstash
sudo systemctl restart kibana
sudo systemctl restart filebeat

echo "=== Verify service status ==="
for service in elasticsearch logstash kibana filebeat; do
  if sudo systemctl is-active --quiet "${service}"; then
    echo "${service}: active"
  else
    echo "${service}: not active"
    sudo systemctl status "${service}" --no-pager
    exit 2
  fi
done

echo "=== Verify local endpoints ==="
curl -fsS http://127.0.0.1:9200 >/dev/null && echo "Elasticsearch endpoint: OK"
curl -fsS http://127.0.0.1:5601/api/status >/dev/null && echo "Kibana endpoint: OK"

echo "ELK 7.x installation and baseline configuration completed."
