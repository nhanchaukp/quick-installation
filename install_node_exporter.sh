#!/usr/bin/env bash
set -euo pipefail

# 1. Require root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root." >&2
  exit 1
fi

# 2. Use provided VERSION or default
VERSION="${VERSION:-1.9.1}"

# 3. Detect architecture
ARCH_RAW=$(uname -m)
case "${ARCH_RAW}" in
  x86_64)   ARCH=amd64 ;;
  aarch64)  ARCH=arm64 ;;
  arm64)    ARCH=arm64 ;;
  armv7l)   ARCH=armv7 ;;
  *) echo "Unsupported architecture: ${ARCH_RAW}" >&2; exit 1 ;;
esac

INSTALL_DIR="/opt/node_exporter"
BIN_PATH="/usr/local/bin/node_exporter"
SERVICE_PATH="/etc/systemd/system/node_exporter.service"

echo "Installing Node Exporter v${VERSION} for ${ARCH}..."

# 4. Download and unpack
cd /opt
TARBALL="node_exporter-${VERSION}.linux-${ARCH}.tar.gz"
URL="https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/${TARBALL}"

wget -q "${URL}"
tar -xzf "${TARBALL}"
mv "node_exporter-${VERSION}.linux-${ARCH}" node_exporter

# 5. Create user if needed
if ! id node_exporter &>/dev/null; then
  useradd --no-create-home --shell /bin/false node_exporter
fi

# 6. Install binary
cp "${INSTALL_DIR}/node_exporter" "${BIN_PATH}"
chown node_exporter:node_exporter "${BIN_PATH}"

# 7. Create systemd unit
cat > "${SERVICE_PATH}" <<EOF
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

echo "Service file created at ${SERVICE_PATH}"

# 8. Reload systemd and start service
systemctl daemon-reload
systemctl enable --now node_exporter

# 9. Verify status
echo
echo "Checking node_exporter service status..."
if systemctl is-active --quiet node_exporter; then
  echo "node_exporter v${VERSION} (${ARCH}) is running."
  systemctl status node_exporter --no-pager
else
  echo "node_exporter failed to start. Check logs with: journalctl -u node_exporter" >&2
  exit 1
fi
