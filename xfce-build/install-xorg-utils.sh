#!/usr/bin/env bash

set -e
set +x

mkdir -p cd /tmp/jarvice-desktop-master/sources/xorg
cd /tmp/jarvice-desktop-master/sources/xorg

# Deps
dnf install -y libXmu-devel ninja-build openssl-devel cmake xorg-x11-util-macros

git clone https://gitlab.freedesktop.org/xorg/util/modular.git util/modular
sed -i "/cd \$DIR/a \        mkdir -p ./m4" ./util/modular/build.sh

# Build list of apps to build
export PREFIX=/usr/
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig
export ACLOCAL="aclocal -I $PREFIX/share/aclocal"
export LD_LIBRARY_PATH=$PREFIX/lib
export PATH=$PREFIX/bin:$PATH
export CFLAGS="-s -O2 -mtune=generic -march=x86-64-v3 -pipe" # -pipe
export CXXFLAGS="-s -O2 -mtune=generic -march=x86-64-v3 -pipe"

cat << EOF > buildFiles.txt
app/xset
app/iceauth
EOF

# ./util/modular/build.sh -L | grep -E "app/|util/|lib/|data/|font/|keyboard|xserver" > buildFiles.txt
# ./util/modular/build.sh -L | grep -E "app/|util/" > buildFiles.txt
./util/modular/build.sh --clone --modfile ./buildFiles.txt $PREFIX
