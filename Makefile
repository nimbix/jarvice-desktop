
OLD_PODMAN_IMAGE_RHEL_8=$(shell podman images | grep rhel-8 | awk '{print $$3}')
OLD_PODMAN_IMAGE_RHEL_9=$(shell podman images | grep rhel-9 | awk '{print $$3}')

OLD_PODMAN_IMAGE_UBUNTU_1804=$(shell podman images | grep ubuntu-18.04 | awk '{print $$3}')
OLD_PODMAN_IMAGE_UBUNTU_2004=$(shell podman images | grep ubuntu-20.04 | awk '{print $$3}')
OLD_PODMAN_IMAGE_UBUNTU_2204=$(shell podman images | grep ubuntu-22.04 | awk '{print $$3}')
OLD_PODMAN_IMAGE_UBUNTU_2404=$(shell podman images | grep ubuntu-24.04 | awk '{print $$3}')

all-fixes: all-rhel-fixes all-ubuntu-fixes

all-rhel-fixes: fix-rhel-8 fix-rhel-9

all-ubuntu-fixes: fix-ubuntu-20 fix-ubuntu-22 fix-ubuntu-24

fix-rhel-8: update-zip
	if [ ! -z "$(OLD_PODMAN_IMAGE_RHEL_8)" ]; then podman rmi --force $(OLD_PODMAN_IMAGE_RHEL_8); fi
	podman build --pull --rm -f "Dockerfile.fix-rhel" -t "jarvice-desktop-fix:rhel-8" --build-arg RHEL_VER=8 "."

fix-rhel-9: update-zip
	if [ ! -z "$(OLD_PODMAN_IMAGE_RHEL_9)" ]; then podman rmi --force $(OLD_PODMAN_IMAGE_RHEL_9); fi
	podman build --pull --rm -f "Dockerfile.fix-rhel" -t "jarvice-desktop-fix:rhel-9" --build-arg RHEL_VER=9 "."

fix-ubuntu-20: update-zip
	if [ ! -z "$(OLD_PODMAN_IMAGE_UBUNTU_2004)" ]; then podman rmi --force $(OLD_PODMAN_IMAGE_UBUNTU_2004); fi
	podman build --pull --rm -f "Dockerfile.fix-ubuntu" -t "jarvice-desktop-fix:ubuntu-20.04" --build-arg UBUNTU_VER=20.04 "."

fix-ubuntu-22: update-zip
	if [ ! -z "$(OLD_PODMAN_IMAGE_UBUNTU_2204)" ]; then podman rmi --force $(OLD_PODMAN_IMAGE_UBUNTU_2204); fi
	podman build --pull --rm -f "Dockerfile.fix-ubuntu" -t "jarvice-desktop-fix:ubuntu-22.04" --build-arg UBUNTU_VER=22.04 "."

fix-ubuntu-24: update-zip
	if [ ! -z "$(OLD_PODMAN_IMAGE_UBUNTU_2404)" ]; then podman rmi --force $(OLD_PODMAN_IMAGE_UBUNTU_2404); fi
	podman build --pull --rm -f "Dockerfile.fix-ubuntu" -t "jarvice-desktop-fix:ubuntu-24.04" --build-arg UBUNTU_VER=24.04 "."

update-zip:
	zip -r nimbix.zip etc nimbix_desktop tools install-nimbix.sh portal-screenshot.png README.md setup-nimbix.sh
