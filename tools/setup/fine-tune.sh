#!/usr/bin/env bash

source /etc/os-release

# Fix the app menu
if [[ "$ID_LIKE" == *"rhel"* ]]; then # EL based system
    if [[ "${VERSION_ID:0:1}" == "7" ]]; then
        /usr/local/JARVICE/tools/setup/rhel/7/fine-tune-rhel-7.sh
    elif [[ "${VERSION_ID:0:1}" == "8" || "${VERSION_ID:0:1}" == "9" ]]; then
        /usr/local/JARVICE/tools/setup/rhel/8/fine-tune-rhel-8.sh
    fi
elif [[ "$ID" == *"ubuntu"* ]]; then # Ubuntu based system
    if [[ "$VERSION_ID" == "18.04" ]]; then
        /usr/local/JARVICE/tools/setup/ubuntu/18.04/fine-tune-ubuntu-18.04.sh
    elif [[ "$VERSION_ID" == "20.04" ]]; then
        /usr/local/JARVICE/tools/setup/ubuntu/20.04/fine-tune-ubuntu-20.04.sh
    elif [[ "$VERSION_ID" == "22.04" ||  "$VERSION_ID" == "24.04" ]]; then
        /usr/local/JARVICE/tools/setup/ubuntu/22.04/fine-tune-ubuntu-22.04.sh
    fi
fi

# Fix the panel
/usr/local/JARVICE/tools/setup/panel.sh

# Fix the background
/usr/local/JARVICE/tools/setup/desktop.sh
