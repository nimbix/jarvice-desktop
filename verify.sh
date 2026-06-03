#!/usr/bin/env bash

DIST=${1:-rhel}
shift
VER=${1:-8}
shift
PROG="${*}"

TUNE_DESKTOP=true

# Get latest image
IMAGE=$(docker images --format table | grep "$DIST"-"$VER" | head -n1 | awk '{print $1 ":" $2}')
if [[ -z $IMAGE ]]; then
    echo "ERROR: $DIST-$VER image not found..."
    exit 1
fi
echo "Starting: $IMAGE"
docker run -it --rm --shm-size=16g -p 5903:5902 -v $PWD:/mydata:Z --entrypoint=bash "$IMAGE" -ec "
    cp /mydata/tools/setup/panel.sh /usr/local/JARVICE/tools/setup/panel.sh
    cp /mydata/tools/setup/fine-tune.sh /usr/local/JARVICE/tools/setup/fine-tune.sh
    cp /mydata/tools/setup/desktop.sh /usr/local/JARVICE/tools/setup/desktop.sh
    cp /mydata/nimbix_desktop/mimeapps.list /etc/skel/.config/mimeapps.list
    cp /mydata/nimbix_desktop/nimbix_desktop /usr/local/lib/nimbix_desktop/nimbix_desktop
    cp /mydata/tools/bin/vncstart.sh /usr/local/JARVICE/tools/bin/vncstart.sh

    useradd --shell /bin/bash nimbix
    mkdir -p /home/nimbix/
    mkdir -p /data
    mkdir -p /etc/JARVICE
    chown -R nimbix:nimbix /home/nimbix
    chown -R nimbix:nimbix /data
    chown -R nimbix:nimbix /etc/JARVICE
    echo 127.0.0.1 > /etc/JARVICE/cores
    echo 127.0.0.1 >> /etc/JARVICE/cores
    echo 127.0.0.1 > /etc/JARVICE/nodes
    echo JOB_NAME=Local_Testing >> /etc/JARVICE/jobinfo.sh
    echo JARVICE_GRAPHICS_DEBUG=true >> /data/.jarvice-debug-options.sh
    if [ $TUNE_DESKTOP == false ]; then
        sed -i 's/tune_desktop=true/tune_desktop=false/' /usr/local/bin/nimbix_desktop
    fi
    su nimbix -c '
        cd \$HOME
        /usr/local/bin/nimbix_desktop $PROG
    '
"
