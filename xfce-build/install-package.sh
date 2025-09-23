#!/usr/bin/env bash

set -e
set -x

export PREFIX=/usr/ # local/xfce
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export CFLAGS="-s -O2 -mtune=generic -march=x86-64-v3 -pipe" # -pipe
export CXXFLAGS="-s -O2 -mtune=generic -march=x86-64-v3 -pipe"

mkdir -p /tmp/jarvice-desktop-master/sources/xfce/src/
cd /tmp/jarvice-desktop-master/sources/xfce/src/
rm -rf /tmp/jarvice-desktop-master/sources/xfce/src/*

package="$1"
version="$2"

latestVersion=$(
    curl -L --silent https://archive.xfce.org/src/xfce/${package}/${version}/ | \
    grep -- "href=\"${package}-${version}" | \
    tr '-' ' ' | \
    sort -k7n -k6M -k5n | \
    tail -n1 | \
    tr ' ' '-' | \
    tr '>' ' ' | \
    tr '<' ' ' | \
    awk '{print $2}'
)
downloadURL="https://archive.xfce.org/src/xfce/${package}/${version}/${latestVersion}"
curl -L "$downloadURL" | tar xj --strip-components=1 --no-same-owner
mkdir -p /tmp/build-config/
if [[ -f ./meson.build ]]; then
    echo "Using meson build"
    OPTIONS="--prefix=$PREFIX --buildtype=debugoptimized"
    if [[ $package == "xfdesktop" ]]; then
        OPTIONS+=" -Dtests=false -Dx11=enabled -Dwayland=enabled"
    elif [[ $package == "xfce4-panel" ]]; then
        OPTIONS+=" -Dx11=enabled -Dwayland=enabled -Dintrospection=false"
    fi
    # meson setup --prefix=$PREFIX --buildtype=release -Dexamples=false -Ddocs=false -Dtests=false build 2>&1 | tee /tmp/build-config/$package.log
    meson setup $OPTIONS build 2>&1 | tee /tmp/build-config/$package.log
    meson compile -C build
    meson install -C build
else
    echo "Using config build"
    ./configure --prefix=$PREFIX --enable-x11 --enable-wayland 2>&1 | tee /tmp/build-config/$package.log
    make
    make install
fi
rm -rf /tmp/jarvice-desktop-master/sources/xfce/src/*
