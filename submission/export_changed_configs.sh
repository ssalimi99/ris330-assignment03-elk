#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-$PWD/submission/config_export}"
mkdir -p "${OUT_DIR}"

echo "Exporting changed config files to: ${OUT_DIR}"

sudo cp /etc/elasticsearch/elasticsearch.yml "${OUT_DIR}/elasticsearch.yml"
sudo cp /etc/kibana/kibana.yml "${OUT_DIR}/kibana.yml"
sudo cp /etc/logstash/conf.d/apache.conf "${OUT_DIR}/apache.conf"
sudo cp /etc/filebeat/filebeat.yml "${OUT_DIR}/filebeat.yml"
sudo cp /etc/filebeat/modules.d/apache.yml "${OUT_DIR}/apache.yml"

sudo chown "$(id -u)":"$(id -g)" "${OUT_DIR}"/*

echo "Done. Attach files from ${OUT_DIR} with your report upload."
