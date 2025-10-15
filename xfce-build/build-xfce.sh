#!/usr/bin/env bash

set -x
set -e

# Get what version of xfce to install
XFCE_VERSION=${1:-4.20}

# Install needed dependencies
dnf install -y epel-release
crb enable

dnf group install -y "Development Tools"

dnf install -y \
    bzip2 \
    cmake \
    colord-devel \
    dbus-glib \
    glib2-devel \
    gobject-introspection-devel \
    gspell-devel \
    gstreamer1-devel \
    gtk-doc \
    gtk3-devel \
    gtksourceview4-devel \
    ImageMagick-devel \
    libdbusmenu-devel \
    libdisplay-info-devel \
    libepoxy-devel \
    libexif-devel \
    libgsf-devel \
    libgtop2-devel \
    libgudev-devel \
    libinput-devel \
    libnotify-devel \
    libopenraw-devel \
    libSM-devel \
    libwnck3-devel \
    libyaml-devel \
    ninja-build \
    perl \
    poppler-devel \
    vala \
    vte291-devel \
    wayland-protocols-devel

python3 -m pip install meson

packages="\
xfce4-dev-tools \
libxfce4util \
xfconf \
libxfce4ui \
garcon \
exo \
libxfce4windowing \
xfce4-panel \
thunar \
xfce4-settings \
xfce4-session \
xfdesktop \
xfwm4 \
xfce4-appfinder \
tumbler \
thunar-volman"

for p in $packages; do
    $(dirname $0)/install-package.sh $p $XFCE_VERSION
done

apps="\
mousepad-0.6.5 \
xfce4-terminal-1.1.3 \
ristretto-0.13.4"
for app in $apps; do
    $(dirname $0)/install-app.sh $(echo $app | rev | sed 's,-, ,' | rev)
done
