#!/bin/bash

VERSION=1.10.1
ARCH=$(arch)

# update links as needed
#TIGERVNC="https://bintray.com/tigervnc/stable/download_file?file_path=tigervnc-$VERSION.$ARCH.tar.gz"
TIGERVNC="https://storage.googleapis.com/app_archive/tigervnc/tigervnc-$VERSION.$ARCH.tar.gz"
TIGERVNC="https://sourceforge.net/projects/tigervnc/files/stable/1.16.2/tigervnc-1.16.2.x86_64.tar.gz/download"

# Grab tarballs on x86_64, install in place to an location that needs pathing
cd /usr/local/lib/nimbix_desktop
# wget --content-disposition "$TIGERVNC"
# curl -L "https://sourceforge.net/projects/tigervnc/files/stable/1.16.2/tigervnc-1.16.2.x86_64.tar.gz" | tar xz
curl -L -o tigervnc-server-minimal-1.16.2-1.el8.x86_64.rpm https://sourceforge.net/projects/tigervnc/files/stable/1.16.2/el8/RPMS/x86_64/tigervnc-server-minimal-1.16.2-1.el8.x86_64.rpm/download
curl -L -o tigervnc-server-1.16.2-1.el8.x86_64.rpm https://sourceforge.net/projects/tigervnc/files/stable/1.16.2/el8/RPMS/x86_64/tigervnc-server-1.16.2-1.el8.x86_64.rpm/download
