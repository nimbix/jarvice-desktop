#!/usr/bin/env bash

source /etc/os-release

# Install our own VirtualGL
if [[ "$ID_LIKE" == *"rhel"* ]]; then # EL based systems, tested for rocky 8, 9, and 10, alma 10
    dnf install -y epel-release
    crb enable
    dnf install -y \
        cmake \
        libEGL-devel \
        libGL-devel \
        libGLU-devel \
        libxcb-devel \
        libXext-devel \
        libXtst-devel \
        libXv-devel \
        libX11-devel \
        nasm \
        ocl-icd-devel \
        wget \
        xcb-util-keysyms-devel
    dnf group install -y "Development Tools"
    # dnf install -y libjpeg-turbo-devel turbojpeg-devel
elif [[ "$ID" == *"ubuntu"* ]]; then # Ubuntu based system, tested with 20.04, 22.04, 24.04, and 26.04
    export DEBIAN_FRONTEND=noninteractive
    apt update
    apt-get -y install \
        build-essential \
        cmake \
        libxcb-glx0-dev \
        libxv-dev \
        libxtst-dev \
        libx11-xcb-dev \
        libxcb-keysyms1-dev \
        libegl1-mesa-dev \
        libglu1-mesa-dev \
        nasm \
        ocl-icd-opencl-dev \
        wget
        # libturbojpeg0-dev
fi

cd /opt
wget "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.1.4.1/libjpeg-turbo-3.1.4.1.tar.gz"
tar xf libjpeg-turbo-3.1.4.1.tar.gz
rm -rf libjpeg-turbo-3.1.4.1.tar.gz
mkdir libjpeg-turbo-3.1.4.1/BUILD
cd libjpeg-turbo-3.1.4.1/BUILD
cmake -DENABLE_STATIC=OFF -DCMAKE_INSTALL_PREFIX=/opt/libjpeg-turbo-JARVICE ..
make -j
make install
for i in /opt/libjpeg-turbo-JARVICE/lib64/*.so.*; do
    ln -sf $i /usr/lib64/$(basename $i)
done

for i in /opt/libjpeg-turbo-JARVICE/include/*.h; do
    ln -sf $i /usr/include/$(basename $i)
done

# Build VirtualGL
cd /opt
wget "https://github.com/VirtualGL/virtualgl/releases/download/3.1.4/VirtualGL-3.1.4.tar.gz"
tar xf VirtualGL-3.1.4.tar.gz
rm -rf VirtualGL-3.1.4.tar.gz
mkdir VirtualGL-3.1.4/BUILD
cd VirtualGL-3.1.4/BUILD
# cmake -DVGL_BUILDSTATIC=OFF -DCMAKE_INSTALL_PREFIX=/opt/VirtualGL-JARVICE -DTJPEG_LIBRARY=/opt/libjpeg-turbo/lib64/libturbojpeg.so ..
# -DCMAKE_BUILD_TYPE=Release \
cmake \
    -DCMAKE_C_FLAGS="-O3 -march=x86-64 -mtune=generic -fno-plt" \
    -DCMAKE_CXX_FLAGS="-O3 -march=x86-64 -mtune=generic -fno-plt" \
    -DVGL_BUILDSTATIC=OFF \
    -DCMAKE_INSTALL_PREFIX=/opt/VirtualGL-JARVICE \
    ..
make -j
make install
