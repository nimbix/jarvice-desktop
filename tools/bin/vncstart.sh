#!/usr/bin/env bash
set -x
[ -f /etc/JARVICE/vglinfo.sh ] && . /etc/JARVICE/vglinfo.sh || true
if [ ! -x /usr/bin/vglrun ]; then
    export VGL_DISPLAY=""
fi
VNC_GEOMETRY=${VNC_GEOMETRY:-1600x900}

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

# parameterization permitted from container caller
# assumes runtime endpoint will translate port in URL (from 5902 for example)
DISPLAY=${JARVICE_VNC_DISPLAY:1}
let VNCPORT=5900+$DISPLAY
PORTNUM=${JARVICE_NOVNC_PORT:5902}

# Start the Tiger server
vncserver -geometry "$VNC_GEOMETRY" \
    -rfbauth /etc/JARVICE/vncpasswd \
    -dpi 100 \
    -SecurityTypes=VeNCrypt,TLSVnc,VncAuth :${DISPLAY}

export DISPLAY=:${DISPLAY}
export LANG=en_US.UTF-8 # XXX
export TERM=xterm
export VGL_READBACK=sync

# Start noVNC daemon
NOVNC_PATH=/usr/local/JARVICE/tools/noVNC
pushd "$NOVNC_PATH"
(utils/launch.sh --listen ${PORTNUM} --vnc localhost:${VNCPORT} | tee /tmp/novnc.log &) #2>&1 &)
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
