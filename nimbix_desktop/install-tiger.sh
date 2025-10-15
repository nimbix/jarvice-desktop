#!/bin/bash

VERSION=1.10.1
ARCH=$(arch)
set -e
set -x

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
fi

cp /usr/local/lib/nimbix_desktop/help-tiger.html /etc/NAE/help.html
