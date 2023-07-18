#!/bin/bash -ex

ARCH=$(arch)
source /etc/os-release

dirname=$(dirname $0)

export DEBIAN_FRONTEND=noninteractive
apt-get -y update

PKGS="wget gnome-icon-theme software-properties-common \
        humanity-icon-theme tango-icon-theme xfce4 xfce4-terminal \
        fonts-freefont-ttf xfonts-base xfonts-100dpi xfonts-75dpi x11-apps \
        xfonts-scalable xauth ristretto mesa-utils init-system-helpers \
        libxcb1 libxcb-keysyms1 libxcb-util1 librtmp1 python3-numpy \
        gir1.2-gtk-3.0 libxv1 libglu1-mesa"
if [ "$VERSION_ID" == "20.04" ] || [ "$VERSION_ID" == "18.04" ]; then
    PKGS+=" firefox"
fi
if [ "$VERSION_ID" == "22.04" ]; then
    PKGS+=" libxtst6"
fi

apt-get -y install $PKGS $RIS
apt-get -y remove light-locker

if [ "$VERSION_ID" == "22.04" ]; then
    snap remove firefox
    add-apt-repository ppa:mozillateam/ppa
    mkdir -p /etc/apt/preferences.d
    cat << EOF > /etc/apt/preferences.d/mozillateamppa
Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1

Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 200
EOF
    mkdir -p /etc/apt/apt.conf.d/
    cat << EOF > /etc/apt/apt.conf.d/51unattended-upgrades-firefox
Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";
EOF
    apt-get update && apt-get install firefox -y

fi

PY2=$(python -V 2>&1 |grep "^Python 2" || true)
if [[ -n "$PY2" ]]; then
    # this clobbers py3 only, so do it only if we have py2
    apt-get -y install python-pip libmagickwand-dev python-gtk2 python-gnome2 python-numpy $RIS
    # Wand is used for screenshots
    pip install Wand
fi

apt-get clean

. $dirname/postinstall-desktop.sh
