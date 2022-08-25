#!/usr/bin/env bash
set -x
. /etc/JARVICE/vglinfo.sh
if [ ! -x /usr/bin/vglrun ]; then
    export VGL_DISPLAY=""
fi

cd

rm -rf .vnc
mkdir -p .vnc
cat <<EOF >.vnc/xstartup
#!/bin/sh
if [ ! -z "$VGL_DISPLAY" ]; then
        VGL_DISPLAY=$VGL_DISPLAY; export VGL_DISPLAY
        VGL_READBACK=sync; export VGL_READBACK
        vglclient &
fi
xsetroot -solid "#000050"
xhost +
EOF
chmod +x .vnc/xstartup

if [ -d /etc/X11/fontpath.d ]; then
    FP="-fp catalogue:/etc/X11/fontpath.d,built-ins"
fi

# Start the VNC server
RET=1 && (vnclicense -check >/dev/null 2>&1) && RET=$?

    # Install Tiger from local tarball or package
    /usr/local/lib/nimbix_desktop/install-tiger.sh
    export PATH=/opt/JARVICE/tigervnc/usr/bin/:$PATH
    export LD_LIBRARY_PATH=/opt/JARVICE/tigervnc/usr/lib64:$LD_LIBRARY_PATH
#    mkdir /tmp/.X11-unix
#    chmod -R 777 /tmp/.X11-unix
    # Start the Tiger server
    /opt/JARVICE/tigervnc/usr/bin/vncserver -geometry "$VNC_GEOMETRY" \
        -rfbauth /etc/JARVICE/vncpasswd \
        -dpi 100 \
        -SecurityTypes=VeNCrypt,TLSVnc,VncAuth :1

export DISPLAY=:1
export LANG=en_US.UTF-8 # XXX
export TERM=xterm
export VGL_READBACK=sync

# Start noVNC daemon
NOVNC_PATH=/usr/local/JARVICE/tools/noVNC
pushd "$NOVNC_PATH"
(utils/launch.sh --cert /etc/JARVICE/cert.pem --listen 5902 --vnc localhost:5901 | tee /tmp/novnc.log &) #2>&1 &)
echo "$NOVNC_PATH" | tee /etc/.novnc-stable
popd

# Create links to the vault mounted at /data
ln -sf /data .
mkdir -p Desktop
ln -sf /data Desktop
sleep 2

if [ -z "$VGL_DISPLAY" ]; then
    exec "$@"
else
    exec vglrun -d $VGL_DISPLAY "$@"
fi
