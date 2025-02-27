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
    # Install the cached tarball
    tar -C / -xzf  /usr/local/lib/nimbix_desktop/tigervnc-$VERSION.$ARCH.tar.gz --strip-components=1

    # Fix newer installs that put binary in /usr/libexec
#    if [[ -x /usr/libexec/vncserver ]]; then
#      ln -sf /usr/libexec/vncserver /usr/bin/vncserver
#    fi

fi

cp /usr/local/lib/nimbix_desktop/help-tiger.html /etc/NAE/help.html
