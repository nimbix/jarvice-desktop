#!/bin/bash

TURBOVNC_VERSION=3.3
ARCH=$(arch)
set -e

source /etc/os-release

if [[ "$ARCH" == "x86_64" ]]; then
    DEB_ARCH="amd64"
    RPM_ARCH="x86_64"
elif [[ "$ARCH" == "aarch64" ]]; then
    DEB_ARCH="arm64"
    RPM_ARCH="aarch64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

BASE_URL="https://github.com/TurboVNC/turbovnc/releases/download/${TURBOVNC_VERSION}"

if [[ "${ID_LIKE:-}" == *"rhel"* ]]; then
    RPM_URL="${BASE_URL}/turbovnc-${TURBOVNC_VERSION}.${RPM_ARCH}.rpm"
    wget -O /tmp/turbovnc.rpm "$RPM_URL"
    dnf install -y /tmp/turbovnc.rpm
    rm -f /tmp/turbovnc.rpm
elif [[ "${ID:-}" == *"ubuntu"* ]]; then
    DEB_URL="${BASE_URL}/turbovnc_${TURBOVNC_VERSION}_${DEB_ARCH}.deb"
    wget -O /tmp/turbovnc.deb "$DEB_URL"
    dpkg -i /tmp/turbovnc.deb
    rm -f /tmp/turbovnc.deb
else
    echo "Unsupported OS: ID=${ID:-unknown} ID_LIKE=${ID_LIKE:-unknown}"
    exit 1
fi

# Add TurboVNC to system PATH
echo 'export PATH="/opt/TurboVNC/bin:$PATH"' > /etc/profile.d/turbovnc.sh
chmod +x /etc/profile.d/turbovnc.sh
