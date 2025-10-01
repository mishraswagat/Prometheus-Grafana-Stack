# 🚀 Monitoring Stack: Prometheus + Grafana + Node # Exporter
https://img.shields.io/badge/Docker-Enabled-blue?style=for-the-badge&logo=docker
https://img.shields.io/badge/Prometheus-Monitoring-orange?style=for-the-badge&logo=prometheus
https://img.shields.io/badge/Grafana-Visualization-red?style=for-the-badge&logo=grafana
https://img.shields.io/badge/Ubuntu-24.04-orange?style=for-the-badge&logo=ubuntu

A complete, production-ready monitoring solution containerized with Docker, featuring Prometheus for metrics collection, Grafana for visualization, and Node Exporter for system metrics.\

 
## 🎯 Overview
This project provides a comprehensive monitoring stack that combines:

📊 Prometheus - Powerful metrics collection and time-series database
📈 Grafana - Advanced visualization and dashboarding platform
💻 Node Exporter - Comprehensive system/hardware metrics exporter

## ✨ Key Features
🐳 Multi-stage Docker build for optimal image size
💾 Persistent storage for configurations and data
🔄 Easy updates and maintenance
🛡 Production-ready architecture
📦 All-in-one solution with minimal setup

## 🏗 Architecture


## 📋 Prerequisites

System Requirements
OS: Ubuntu 24.04 (or compatible Linux distribution)

Docker: Installed and running

Permissions: sudo privileges

Ports: 3000, 9090, 9100 available

## Verify Prerequisites

```bash
# Check Docker installation
docker --version

# Check sudo privileges
sudo whoami

# Check port availability
sudo netstat -tulpn | grep -E ':(3000|9090|9100)'
```

## 🚀 Quick Start

### 1. Clone and Setup

```bash
# Create directory structure
sudo mkdir -p /opt/prometheus/{config,data}
sudo mkdir -p /opt/grafana/{config,data}
sudo chmod -R 755 /opt/prometheus /opt/grafana
```

### 2. Create Configuration Files
Prometheus Config (/opt/prometheus/config/prometheus.yml):
```bash
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: "Node_Exporter"
    static_configs:
      - targets: ['localhost:9100']
```
**Prometheus Configuration Details**
 - The prometheus.yml file is structured to:
 - Scrape every 15 seconds for near real-time monitoring
 - Monitor Prometheus itself for self-monitoring
 - Collect system metrics from Node Exporter

Grafana Config (/opt/grafana/config/grafana.ini):
```bash
[server]
http_port = 3000
;domain = localhost
```
**Grafana Configuration**
 - Port 3000 for web access
 - Default admin credentials (change in production)
 - Persistent data storage for dashboards and settings
 
### 3. Build and Run
```bash
docker build -t monitor-stack .
```

```bash
docker run -d \
  -p 9090:9090 \
  -p 3000:3000 \
  --network host \
  -v /opt/prometheus/config/prometheus.yml:/opt/prometheus/prometheus.yml \
  -v /opt/prometheus/data:/opt/prometheus/data \
  -v /opt/grafana/config/grafana.ini:/opt/grafana/conf/grafana.ini \
  -v /opt/grafana/data:/opt/grafana/data \
  --name monitor-stack \
  monitor-stack
```

### 4. Install Node Exporter
```bash
#!/bin/bash

echo "📥 Installing Node Exporter..."

# Download node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz

# Extract
tar -xvf node_exporter-1.9.1.linux-amd64.tar.gz

# Create system user
sudo useradd -rs /bin/false nodeusr

# Move binary to system location
sudo mv node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/

# Create systemd service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Cleanup
rm -rf node_exporter-1.9.1.linux-amd64*

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

echo "✅ Node Exporter installed and started!"
echo "📊 Metrics available at: http://localhost:9100/metrics"
```

## Build & Run

```bash
docker build -t monitor-stack .
```

```bash
docker run -d \
  -p 9090:9090 \
  -p 3000:3000 \
  --network host \
  -v /opt/prometheus/config/prometheus.yml:/opt/prometheus/prometheus.yml \
  -v /opt/prometheus/data:/opt/prometheus/data \
  -v /opt/grafana/config/grafana.ini:/opt/grafana/conf/grafana.ini \
  -v /opt/grafana/data:/opt/grafana/data \
  --name monitor-stack \
  monitor-stack
```

## 🎯 Access Services
🔍 Prometheus - http://localhost:9090
📈 Grafana - http://localhost:3000
💻 Node Exporter - http://localhost:9100/metrics

## 📊 Grafana Setup Guide

### 1. Initial Login
 - 🌐 Open http://localhost:3000 in your browser
 - 👤 Use credentials: admin/admin
 - 🔐 Change password when prompted
 
### 2. Add Prometheus Data Source
 - Navigate to Configuration → Data Sources
 - Click "Add data source"
 - Select "Prometheus"
 - Configure:
 - URL: http://localhost:9090
 - Access: Server (default)
 - Click "Save & Test"

### 3. Import Dashboards
 - Open Dashboard and click on Import
 - Provide ID as 1860 for 'Node Exporter Dashboard"


## Container Management
```bash
# Stop the stack
docker stop monitor-stack

# Start the stack
docker start monitor-stack

# Restart the stack
docker restart monitor-stack

# View logs
docker logs monitor-stack

# Follow logs in real-time
docker logs -f monitor-stack

# Remove container (data preserved in volumes)
docker rm -f monitor-stack
```

## Node Exporter Management
```bash
# Check status
sudo systemctl status node_exporter

# Restart service
sudo systemctl restart node_exporter

# Enable auto-start
sudo systemctl enable node_exporter

# View logs
sudo journalctl -u node_exporter -f
```
## Data Management
```bash
# Backup Prometheus data
sudo tar -czf prometheus_backup.tar.gz /opt/prometheus/data

# Backup Grafana data
sudo tar -czf grafana_backup.tar.gz /opt/grafana/data

# Restore from backup
sudo tar -xzf prometheus_backup.tar.gz -C /
sudo tar -xzf grafana_backup.tar.gz -C /
```
## 🐳 Multi-Stage Docker Build
 - Why: Separates build tools from runtime environment
 - Benefit: 60% smaller image size

## 💾 Volume Mounts
 - Configuration: Runtime modifications without rebuild
 - Data: Persistence across container updates
 - Backup: Easy backup/restore procedures
 
## 🌐 Host Network Mode
 - Why: Simplifies Prometheus → Node Exporter communication
 - Benefit: No complex Docker networking setup

## ⚡ Tini Init System
 - Purpose: Proper signal handling for graceful shutdown
 - Benefit: Prevents zombie processes, clean termination

## 🔄 Update Instructions

Updating Versions: 
To update component versions, modify the Dockerfile:
```bash
ENV PROM_VERSION=3.6.0  # Change to new version
ENV GRAF_VERSION=12.2.0 # Change to new version
```

