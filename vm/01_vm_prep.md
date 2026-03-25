# VM Preparation and Version Decision

## Target VM baseline

- OS: Ubuntu Server 22.04 LTS (or compatible Debian-based Linux)
- CPU: minimum 2 vCPU
- RAM: minimum 8 GB
- Disk: minimum 40 GB free
- Network: outbound internet access for package download

## Selected stack version

- **ELK version selected: 7.x**
- Reason:
  - Assignment accepts either approach.
  - 7.x avoids the default TLS/auth bootstrap complexity of 8.x.
  - Better fit for a fast single-node demo in class.

## Ports used

- Elasticsearch: `9200`
- Logstash Beats input: `5044`
- Kibana: `5601`

## Pre-flight commands (run on VM)

```bash
hostnamectl
lscpu | sed -n '1,12p'
free -h
df -h /
ip -br a
```

Capture these outputs in screenshots if your instructor asks for setup evidence.
