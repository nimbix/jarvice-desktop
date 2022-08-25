SKEL_CONFIGS=$(cd $dirname/skel.config && find . -type f)
for i in $SKEL_CONFIGS; do
    mkdir -p $(dirname /etc/skel/.config/$i)
    cp -f $dirname/skel.config/$i /etc/skel/.config/$i
    chmod u+w /etc/skel/.config/$i
done

# Copy in the config files to set Firefox as default
cp -f $dirname/helpers.rc /etc/skel/.config/xfce4
cp -f $dirname/mimeapps.list /etc/skel/.config

rm -f /usr/local/bin/nimbix_desktop
ln -sf $dirname/nimbix_desktop /usr/local/bin/nimbix_desktop
rm -f /usr/local/bin/xfce4-session-logout
ln -sf $dirname/xfce4-session-logout /usr/local/bin/xfce4-session-logout

mkdir -p /etc/NAE
if [ ! -e /etc/NAE/url.txt ]; then
    echo 'https://%PUBLICADDR%:5902/vnc.html?password=%NIMBIXPASSWD%&autoconnect=true&reconnect=true' >/etc/NAE/url.txt
fi
