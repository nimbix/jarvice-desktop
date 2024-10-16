#!/bin/bash -ex

# shellcheck disable=SC2034
ARCH=$(arch)
source /etc/os-release

dirname=$(dirname "$0")

# Required packages, varies depending of version id
if [[ "8 9" =~ ${VERSION_ID:0:1} ]]; then
    dnf install 'dnf-command(config-manager)' -y
    dnf install dnf-plugins-core -y
    if [[ "${VERSION_ID:0:1}" == "8" ]]; then
        dnf config-manager --set-enabled powertools
        dnf install -y xorg-x11-apps pygtk2
    elif [[ "${VERSION_ID:0:1}" == "9" ]]; then
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
fi

dnf clean all

pip3 install --no-cache-dir Wand

[ -f /etc/xdg/autostart/xfce-polkit.desktop ] && \
    rm -f /etc/xdg/autostart/xfce-polkit.desktop

. $dirname/postinstall-desktop.sh
