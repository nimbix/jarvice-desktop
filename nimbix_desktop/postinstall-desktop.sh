#!/usr/bin/env bash

SKEL_CONFIGS=$(cd $dirname/skel.config && find . -type f)
for i in $SKEL_CONFIGS; do
    mkdir -p $(dirname /etc/skel/.config/$i)
    cp -f $dirname/skel.config/$i /etc/skel/.config/$i
    chmod u+w /etc/skel/.config/$i
done

# Add new logout functionality
cat > /tmp/.logout.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=logout-nimbix
Comment=stops vnc
Exec=/usr/local/bin/nimbix-logout
OnlyShowIn=XFCE;
RunHook=1
StartupNotify=false
Terminal=false
Hidden=false
EOF

# Set the logout button to stop the Xvnc prog
cat > /usr/local/bin/nimbix-logout <<EOF
#!/usr/bin/env bash
kill \$(pidof Xvnc)
EOF
chmod +x /usr/local/bin/nimbix-logout

# Copy in the config files to set Firefox as default
mkdir -p /etc/skel/.config/xfce4
cp -f $dirname/helpers.rc /etc/skel/.config/xfce4
cp -f $dirname/mimeapps.list /etc/skel/.config
rm -f /usr/local/bin/nimbix_desktop
ln -sf $dirname/nimbix_desktop /usr/local/bin/nimbix_desktop
rm -f /usr/local/bin/xfce4-session-logout
ln -sf $dirname/xfce4-session-logout /usr/local/bin/xfce4-session-logout


# VirtualGL is now provided by platform; link in the binaries that will
# be deployed if VGL is available
for i in vglclient vglconfig vglconnect vglgenkey vgllogin vglrun; do
    ln -sf /opt/VirtualGL/bin/$i /usr/bin/$i
done

# create empty libs that are world-writable so that init can replace with
# VGL libraries as non-root
for i in libdlfaker.so libgefaker.so libvglfaker-nodl.so libvglfaker-opencl.so libvglfaker.so; do
    for j in lib lib32 lib64; do
        [ -d /usr/$j ] && (touch /usr/$j/$i && chmod 0777 /usr/$j/$i) || true
    done
done

mkdir -p /etc/NAE
if [ ! -e /etc/NAE/url.txt ]; then
    echo 'https://%PUBLICADDR%:5902/vnc.html?password=%NIMBIXPASSWD%&autoconnect=true&reconnect=true' >/etc/NAE/url.txt
fi
