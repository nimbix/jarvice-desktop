
OLD_DOCKER_IMAGE_RHEL_8=$(shell docker images | grep rhel-8 | awk '{print $$3}')
OLD_DOCKER_IMAGE_RHEL_9=$(shell docker images | grep rhel-9 | awk '{print $$3}')
OLD_DOCKER_IMAGE_RHEL_10=$(shell docker images | grep rhel-10 | awk '{print $$3}')

OLD_DOCKER_IMAGE_UBUNTU_1804=$(shell docker images | grep ubuntu-18.04 | awk '{print $$3}')
OLD_DOCKER_IMAGE_UBUNTU_2004=$(shell docker images | grep ubuntu-20.04 | awk '{print $$3}')
OLD_DOCKER_IMAGE_UBUNTU_2204=$(shell docker images | grep ubuntu-22.04 | awk '{print $$3}')
OLD_DOCKER_IMAGE_UBUNTU_2404=$(shell docker images | grep ubuntu-24.04 | awk '{print $$3}')

all-fixes: all-rhel-fixes all-ubuntu-fixes

all-rhel-fixes: fix-rhel-8 fix-rhel-9 fix-rhel-10

all-ubuntu-fixes: fix-ubuntu-20 fix-ubuntu-22 fix-ubuntu-24

fix-rhel-8: update-zip
	if [ ! -z "$(OLD_DOCKER_IMAGE_RHEL_8)" ]; then docker rmi --force $(OLD_DOCKER_IMAGE_RHEL_8); fi
	docker build --pull --rm -f "Dockerfile.fix-rhel" -t "jarvice-desktop-fix:rhel-8" --build-arg RHEL_VER=8 "."

fix-rhel-9: update-zip
	if [ ! -z "$(OLD_DOCKER_IMAGE_RHEL_9)" ]; then docker rmi --force $(OLD_DOCKER_IMAGE_RHEL_9); fi
	docker build --pull --rm -f "Dockerfile.fix-rhel" -t "jarvice-desktop-fix:rhel-9" --build-arg RHEL_VER=9 "."

fix-rhel-10: update-zip
	if [ ! -z "$(OLD_DOCKER_IMAGE_RHEL_10)" ]; then docker rmi --force $(OLD_DOCKER_IMAGE_RHEL_10); fi
	docker build --pull --rm -f "Dockerfile.fix-rhel" -t "jarvice-desktop-fix:rhel-10" --build-arg RHEL_VER=10 "."

fix-ubuntu-20: update-zip
	if [ ! -z "$(OLD_DOCKER_IMAGE_UBUNTU_2004)" ]; then docker rmi --force $(OLD_DOCKER_IMAGE_UBUNTU_2004); fi
	docker build --pull --rm -f "Dockerfile.fix-ubuntu" -t "jarvice-desktop-fix:ubuntu-20.04" --build-arg UBUNTU_VER=20.04 "."

fix-ubuntu-22: update-zip
	if [ ! -z "$(OLD_DOCKER_IMAGE_UBUNTU_2204)" ]; then docker rmi --force $(OLD_DOCKER_IMAGE_UBUNTU_2204); fi
	docker build --pull --rm -f "Dockerfile.fix-ubuntu" -t "jarvice-desktop-fix:ubuntu-22.04" --build-arg UBUNTU_VER=22.04 "."

fix-ubuntu-24: update-zip
	if [ ! -z "$(OLD_DOCKER_IMAGE_UBUNTU_2404)" ]; then docker rmi --force $(OLD_DOCKER_IMAGE_UBUNTU_2404); fi
	docker build --pull --rm -f "Dockerfile.fix-ubuntu" -t "jarvice-desktop-fix:ubuntu-24.04" --build-arg UBUNTU_VER=24.04 "."

update-zip:
	zip -r nimbix.zip etc nimbix_desktop tools install-nimbix.sh portal-screenshot.png README.md setup-nimbix.sh xfce-build
