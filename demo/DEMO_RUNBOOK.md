# Assignment 03 Demo Runbook (In-Class)

Use this exact flow during demonstration to cover all grading points quickly.

## 1) Show services are installed and running

Run these commands on VM terminal:

```bash
systemctl is-active elasticsearch logstash kibana filebeat
```

Expected: all show `active`.

## 2) Show Elasticsearch and Kibana are reachable

```bash
curl -s http://127.0.0.1:9200
curl -s http://127.0.0.1:5601/api/status
```

In browser:

- `http://<VM-IP>:5601`

## 3) Explain your configuration

Show and explain these files:

- `/etc/elasticsearch/elasticsearch.yml`
- `/etc/kibana/kibana.yml`
- `/etc/logstash/conf.d/apache.conf`
- `/etc/filebeat/filebeat.yml`
- `/etc/filebeat/modules.d/apache.yml`

Focus on:

- Single-node setup
- Elasticsearch/Kibana connection
- Apache access + error log paths

## 4) Show ingestion evidence

```bash
curl -s "http://127.0.0.1:9200/_cat/indices/filebeat*?v"
curl -s "http://127.0.0.1:9200/filebeat-*/_count"
```

Expected:

- At least one `filebeat-*` index
- Count greater than 0

## 5) Show Kibana data and visuals

In Kibana:

1. Discover -> confirm Apache log documents are visible.
2. Dashboards -> search `Filebeat Apache` and open access/error dashboard.
3. Show at least one visualization and one filtered query.

## 6) Screenshot compliance reminders

Every screenshot in your report must include:

- VM name
- student number
- current date/time
