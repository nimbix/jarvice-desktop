#!/usr/bin/env bash

set -e
set -x

export PREFIX=/usr/ # local/xfce
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export CFLAGS="-s -O2 -mtune=generic -march=x86-64-v3 -pipe"
export CXXFLAGS="-s -O2 -mtune=generic -march=x86-64-v3 -pipe"

## MOVE TO DEPS SCRIPT
dnf group install -y "Development Tools"
dnf install -y perl bzip2 glib2-devel gtk3-devel cmake wayland-protocols-devel gobject-introspection-devel vala ninja-build
python3 -m pip install meson

mkdir -p /tmp/jarvice-desktop-master/sources/xfce/src/
cd /tmp/jarvice-desktop-master/sources/xfce/src/

curl -L https://github.com/wmww/gtk-layer-shell/archive/refs/tags/v0.9.2.tar.gz | tar xz --strip-components=1 --no-same-owner

mkdir -p /tmp/build-config/
meson setup --prefix=$PREFIX --buildtype=release -Dexamples=false -Ddocs=false -Dtests=false build 2>&1 | tee /tmp/build-config/$(basename ${0::-3}).log
meson compile -C build
meson install -C build

rm -rf /tmp/jarvice-desktop-master/sources/xfce/src/*
