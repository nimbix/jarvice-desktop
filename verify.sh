#!/usr/bin/env bash

DIST=${1:-rhel}
shift
VER=${1:-8}
shift
PROG="${*}"
TUNE_DESKTOP=true

# Get latest image
IMAGE=$(docker images | grep "$DIST"-"$VER" | head -n1 | awk '{print $1 ":" $2}')
if [[ -z $IMAGE ]]; then
    echo "ERROR: $DIST-$VER image not found..."
    exit 1
fi
echo "Starting: $IMAGE"
sudo modprobe vgem
# -v /dev/dri:/dev/dri:Z
docker run -it --gpus=all --rm --shm-size=16g -p 5902:5902 -v $PWD:/mydata:z --device=/dev/dri --entrypoint=bash "$IMAGE" -ec "
    useradd --shell /bin/bash nimbix

    usermod -a -G video nimbix
    usermod -a -G render nimbix
    mkdir -p /dev/dri
    # mknod /dev/dri/card0 c 226 0
    # mknod /dev/dri/renderD128 c 226 128
    chmod -R 777 /dev/dri

    cp /mydata/tools/setup/panel.sh /usr/local/JARVICE/tools/setup/panel.sh
    cp /mydata/tools/setup/fine-tune.sh /usr/local/JARVICE/tools/setup/fine-tune.sh
    cp /mydata/tools/setup/desktop.sh /usr/local/JARVICE/tools/setup/desktop.sh
    cp /mydata/nimbix_desktop/mimeapps.list /etc/skel/.config/mimeapps.list

    mkdir -p /home/nimbix/
    mkdir -p /data
    mkdir -p /etc/JARVICE
    echo 127.0.0.1 > /etc/JARVICE/cores
    echo 127.0.0.1 >> /etc/JARVICE/cores
    echo 127.0.0.1 > /etc/JARVICE/nodes
    echo JOB_NAME=Local_Testing >> /etc/JARVICE/jobinfo.sh
    echo VGL_DISPLAY=:1 >> /etc/JARVICE/vglinfo.sh
    chown -R nimbix:nimbix /home/nimbix
    chown -R nimbix:nimbix /data
    chown -R nimbix:nimbix /etc/JARVICE
    if [ $TUNE_DESKTOP == false ]; then
        sed -i 's/tune_desktop=true/tune_desktop=false/' /usr/local/bin/nimbix_desktop
    fi

    mkdir -p /usr/share/glvnd/egl_vendor.d
    # echo { >> /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    # echo \"file_format_version\" : \"1.0.0\", >> /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    # echo \"ICD\": {>> /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    # echo \"library_path\" : \"libEGL_nvidia.so.0\">> /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    # echo } >> /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    # echo } >> /usr/share/glvnd/egl_vendor.d/10_nvidia.json

    echo \"{\" >> /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    echo \"  \"file_format_version\" : \"1.0.0\",\" >> /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    echo \"  \"ICD\": {\" >> /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    echo \"    \"library_path\" : \"libEGL_nvidia.so.0\"\" >> /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    echo \"  }\" >> /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    echo \"}\" >> /usr/share/glvnd/egl_vendor.d/10_nvidia.json

    # cat /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    # exit 0

    su nimbix -c '
        cd \$HOME
        wget "https://as2.ftcdn.net/v2/jpg/01/04/78/75/1000_F_104787586_63vz1PkylLEfSfZ08dqTnqJqlqdq0eXx.jpg"
        # export LIBGL_DEBUG=verbose
        /usr/local/bin/nimbix_desktop $PROG
    '
"
