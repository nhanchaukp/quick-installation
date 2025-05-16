# quick-installation
Quick installtion scripts for devops.

## Node Exporter Installation Guide

This document explains how to install and run Prometheus Node Exporter on Linux systems using a one-line installer script. The script automatically detects your CPU architecture, downloads the correct binary, creates a dedicated user, sets up a systemd service, and starts the exporter.

**Default install (v1.9.1)**

```bash
curl -sSL https://raw.githubusercontent.com/nhanchaukp/quick-installation/refs/heads/main/install_node_exporter.sh | bash
```

**Custom version**

```bash
VERSION=1.9.0
curl -sSL https://raw.githubusercontent.com/nhanchaukp/quick-installation/refs/heads/main/install_node_exporter.sh | bash
```
