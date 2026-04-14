#!/bin/bash

VERSION=1.10.1
ARCH=$(arch)
set -x

# if [[ -f /etc/redhat-release ]]; then
#     dnf -y install tigervnc-server tigervnc
# else
#     # tar -C / -xzf  /usr/local/lib/nimbix_desktop/tigervnc-$VERSION.$ARCH.tar.gz --strip-components=1
#     # This does not work for ubuntu 22.04 or 24.04
#     apt-get -y update
#     apt-get -y install tigervnc-standalone-server
# fi

if [ "$ARCH" != "x86_64" ]; then
    #build_and_install_tiger
    if [[ -f /etc/redhat-release ]]; then
        dnf -y install tigervnc-server
    else
        apt-get -y update
        apt-get -y install tigervnc-standalone-server
    fi
else
    # Install newer version of novnc
    rm -rf /usr/local/JARVICE/tools/noVNC/*
    cd /usr/local/JARVICE/tools/noVNC
    curl -L https://github.com/novnc/noVNC/archive/refs/tags/v1.6.0.tar.gz | tar xz --strip-components=1 --no-same-owner
    cd utils
    mkdir websockify
    cd websockify
    curl -L https://github.com/novnc/websockify/archive/refs/tags/v0.13.0.tar.gz | tar xz --strip-components=1 --no-same-owner

    # Install the cached tarball
    # tar -C / -xzf  /usr/local/lib/nimbix_desktop/tigervnc-$VERSION.$ARCH.tar.gz --strip-components=1
    # cp -rf /usr/local/lib/nimbix_desktop/tigervnc-1.16.2.x86_64/* /.
    # rm -rf /usr/local/lib/nimbix_desktop/tigervnc-1.16.2.x86_64
    dnf install -y /usr/local/lib/nimbix_desktop/tigervnc-server-minimal-1.16.2-1.el8.x86_64.rpm
    dnf install -y /usr/local/lib/nimbix_desktop/tigervnc-server-1.16.2-1.el8.x86_64.rpm

    # Fix newer installs that put binary in /usr/libexec
#    if [[ -x /usr/libexec/vncserver ]]; then
#      ln -sf /usr/libexec/vncserver /usr/bin/vncserver
#    fi

fi

cp /usr/local/lib/nimbix_desktop/help-tiger.html /etc/NAE/help.html
