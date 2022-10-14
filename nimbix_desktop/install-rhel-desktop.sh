#!/bin/bash -ex

ARCH=$(arch)
source /etc/os-release

## Adding a safe download backup since SourceForge goes offline frequently
VGL64VER=2.6.5
VGL64="https://storage.googleapis.com/app_archive/virtualgl/VirtualGL-${VGL64VER}.x86_64.rpm"
VGL32="https://storage.googleapis.com/app_archive/virtualgl/VirtualGL-${VGL64VER}.i386.rpm"

dirname=$(dirname "$0")

# Required packages, varies depending of version id
if [[ "${VERSION_ID:0:1}" == "7" ]]; then
    yum -y groupinstall Xfce
    yum -y install perl wget xauth pygtk2 gnome-icon-theme  \
       xorg-x11-fonts-Type1 xorg-x11-fonts-misc xorg-x11-fonts-75dpi xorg-x11-fonts-100dpi \
       xorg-x11-fonts-ISO8859-1-100dpi xorg-x11-fonts-ISO8859-1-75dpi \
       xkeyboard-config xorg-x11-apps xcb-util xcb-util-keysyms xorg-x11-utils \
       net-tools glx-utils ImageMagick-devel firefox \
       ristretto xterm numpy python36-numpy python36-gobject python-pip
elif [[ "${VERSION_ID:0:1}" == "8" ]]; then
    dnf -y groupinstall Xfce --nobest
    dnf -y install perl wget xauth pygtk2 adwaita-icon-theme  \
       xorg-x11-fonts-Type1 xorg-x11-fonts-misc xorg-x11-fonts-75dpi xorg-x11-fonts-100dpi \
       xorg-x11-fonts-ISO8859-1-100dpi xorg-x11-fonts-ISO8859-1-75dpi \
       xkeyboard-config xterm xcb-util xcb-util-keysyms xorg-x11-utils \
       net-tools glx-utils ImageMagick-devel firefox \
       ristretto xterm python3-numpy python3-gobject python3-pip $RIS
    # Remove power manager to prevent pannel plugin crash at startup
    dnf -y remove xfce4-power-manager
fi

if [ "$ARCH" != "x86_64" ]; then
    echo "non-x86_64 has no VirtualGL"
else
    cd /tmp
    wget --content-disposition "$VGL64"
    wget --content-disposition "$VGL32"
    yum -y install VirtualGL*.rpm || yum -y update VirtualGL*.rpm
    rm -f VirtualGL*.rpm
fi

yum clean all

pip3 install --no-cache-dir Wand

[ -f /etc/xdg/autostart/xfce-polkit.desktop ] && \
    rm -f /etc/xdg/autostart/xfce-polkit.desktop

. $dirname/postinstall-desktop.sh
