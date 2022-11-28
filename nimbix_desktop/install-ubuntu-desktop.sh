#!/bin/bash -ex

ARCH=$(arch)
source /etc/os-release

dirname=$(dirname $0)

export DEBIAN_FRONTEND=noninteractive
apt-get -y update

PKGS="wget gnome-icon-theme software-properties-common \
        humanity-icon-theme tango-icon-theme xfce4 xfce4-terminal \
        fonts-freefont-ttf xfonts-base xfonts-100dpi xfonts-75dpi x11-apps \
        xfonts-scalable xauth firefox ristretto mesa-utils init-system-helpers \
        libxcb1 libxcb-keysyms1 libxcb-util1 librtmp1 python3-numpy \
        gir1.2-gtk-3.0 libxv1 libglu1-mesa"
if [ "$VERSION_ID" == "22.04" ]; then
    PKGS+=" libxtst6"
fi

apt-get -y install $PKGS $RIS
apt-get -y remove light-locker

PY2=$(python -V 2>&1 |grep "^Python 2" || true)
if [[ -n "$PY2" ]]; then
    # this clobbers py3 only, so do it only if we have py2
    apt-get -y install python-pip libmagickwand-dev python-gtk2 python-gnome2 python-numpy $RIS
    # Wand is used for screenshots
    pip install Wand
fi

apt-get clean

. $dirname/postinstall-desktop.sh
