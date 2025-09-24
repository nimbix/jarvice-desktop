#!/bin/bash -ex

# shellcheck disable=SC2034
ARCH=$(arch)
source /etc/os-release

# VERSION_ID can now be greater than 9. Need to be smarter...
VERSION_ID=$(echo $VERSION_ID | tr '.' ' ' | awk '{print $1}')

dirname=$(dirname "$0")

# Required packages, varies depending of version id
if [[ "8 9" =~ ${VERSION_ID} ]]; then
    dnf install 'dnf-command(config-manager)' -y
    dnf install dnf-plugins-core -y
    if [[ "${VERSION_ID}" == "8" ]]; then
        dnf config-manager --set-enabled powertools
        dnf install -y xorg-x11-apps pygtk2
    elif [[ "${VERSION_ID}" == "9" ]]; then
        dnf config-manager --set-enabled crb
        dnf install dbus-x11 xwd -y
    fi
    dnf -y groupinstall Xfce --nobest
    dnf -y install perl wget xauth adwaita-icon-theme  \
        xorg-x11-fonts-Type1 xorg-x11-fonts-misc xorg-x11-fonts-75dpi xorg-x11-fonts-100dpi \
        xorg-x11-fonts-ISO8859-1-100dpi xorg-x11-fonts-ISO8859-1-75dpi \
        xkeyboard-config xterm xcb-util xcb-util-keysyms xorg-x11-utils \
        net-tools glx-utils ImageMagick-devel firefox \
        ristretto xterm python3-numpy python3-gobject python3-pip libGLU bzip2 $RIS
    # Remove power manager to prevent pannel plugin crash at startup
    dnf -y remove xfce4-power-manager
else
    # Rocky 10...
    echo "========== BETA Rocky 10 =========="
    dnf install 'dnf-command(config-manager)' -y
    dnf install dnf-plugins-core -y
    dnf install -y python3-pip

    dnf install -y \
        firefox \
        python3-numpy \
        python3-gobject \
        net-tools \
        glx-utils \
        dbus-x11 \
        btop htop \
        vulkan-loader \
        libxkbcommon-x11

    dnf install -y \
        perl wget xauth adwaita-icon-theme xorg-x11-*  \
        xorg-x11-fonts-Type1 xorg-x11-fonts-misc xorg-x11-fonts-75dpi xorg-x11-fonts-100dpi \
        xorg-x11-fonts-ISO8859-1-100dpi xorg-x11-fonts-ISO8859-1-75dpi \
        xkeyboard-config xterm xcb-util xcb-util-keysyms \
        net-tools glx-utils ImageMagick-devel firefox \
        xterm python3-numpy python3-gobject python3-pip libGLU bzip2

    # Should just call a specific rhel 10 builder here...
    cd /tmp/jarvice-desktop-*/xfce-build
    ./install-gtk-layer-shell.sh
    ./install-xorg-utils.sh
    ./build-xfce.sh
fi

dnf clean all

pip3 install --no-cache-dir Wand

[ -f /etc/xdg/autostart/xfce-polkit.desktop ] && \
    rm -f /etc/xdg/autostart/xfce-polkit.desktop

. $dirname/postinstall-desktop.sh
