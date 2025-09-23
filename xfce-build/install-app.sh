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

git clone -b "$package-$version" --recursive --depth=1 https://gitlab.xfce.org/apps/$package.git
cd $package
mkdir -p /tmp/build-config
./autogen.sh 2>&1 | tee /tmp/build-config/$package.log
make install
cd /tmp/jarvice-desktop-master/sources/xfce/src/
rm -rf $package
