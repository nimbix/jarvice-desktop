#!/usr/bin/env bash

set -e
set -x

ARCH=$(arch)
BRANCH=jar5582

while [ $# -gt 0 ]; do
  case $1 in
  --skip-os-pkg-update)
    export SKIP_OS_PKG_UPDATE=1
    shift
    ;;
  --jarvice-desktop-branch)
    BRANCH=$2
    shift
    shift
    ;;
  *)
    break
    ;;
  esac
done

# Base OS
function setup_base_os() {

  # Core packages
  PKGS="curl zip unzip sudo"
  # Source current environment
  source /etc/os-release

  if [[ "$ID_LIKE" == *"rhel"* ]]; then # EL based system
    if [[ "${VERSION_ID:0:1}" == "7" ]] || [[ "${VERSION_ID:0:1}" == "8" ]]; then # Supported EL version
      #if [[ "${VERSION_ID:0:1}" == "8" ]]; then 
      #  ln -s /usr/bin/dnf /usr/bin/yum
      #fi
      # install EPEL first, successive packages live there
      yum install wget -y
      if [[ "${VERSION_ID:0:1}" == "7" ]]; then
        wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
        yum -y install epel-release-latest-7.noarch.rpm
      elif [[ "${VERSION_ID:0:1}" == "8" ]]; then 
        wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
        dnf -y install epel-release-latest-8.noarch.rpm
      fi

      # Packages to support MPI and basic container operation
      PKGS+=" passwd xz tar file openssh-server openssh-clients python3"
      PKGS+=" which sshpass mailcap initscripts"

      # If requested by user, update system
      [ -z "$SKIP_OS_PKG_UPDATE" ] && yum -y update
      # Install packages
      yum -y install $PKGS $OPTS

      # EL 8 images have locals natively manually removed !!
      # We need to force reinstall packages to ensure files are present to build locals.
      if [[ "${VERSION_ID:0:1}" == "8" ]]; then
        dnf -y install glibc-langpack-en glibc-common glibc-locale-source gzip
        dnf -y reinstall glibc-langpack-en glibc-common glibc-locale-source gzip
        OPTS="--nobest"
      fi
      # Set locale
      localedef -i en_US -f UTF-8 en_US.UTF-8

      echo '# leave empty' >/etc/fstab
    else
      echo "ERROR: unknown or unsupported image operating system."
      echo "Please report to documentation to know supported Linux versions."
      echo "Exiting..."
      exit 1
    fi

  elif [[ "$ID" == *"ubuntu"* ]]; then # Ubuntu based system
    if [[ "$VERSION_ID" == "18.04" ]] || [[ "$VERSION_ID" == "20.04" ]] || [[ "$VERSION_ID" == "22.04" ]]; then # Supported versions

      # Prevent interactive packages locks
      export DEBIAN_FRONTEND=noninteractive

      PKGS+=" kmod xz-utils vim openssh-server libpam-systemd iputils-ping python3"
      PKGS+=" iptables build-essential byacc flex git cmake"
      PKGS+=" screen grep locales locales-all net-tools lsb-release"
      PKGS+=" openssh-client sshpass ca-certificates"
      if [ "$VERSION_ID" == "20.04" ]; then
        PKGS+=" python-is-python3"
      fi

      # Update cache
      apt-get -y update
      # Install packages
      apt-get -y install $PKGS --no-install-recommends

      locale-gen en_US.UTF-8
      update-locale LANG=en_US.UTF-8
    else
      echo "ERROR: unknown or unsupported image operating system."
      echo "Please report to documentation to know supported Linux versions."
      echo "Exiting..."
      exit 1
    fi

  else
    echo "ERROR: unknown or unsupported image operating system."
    echo "Please report to documentation to know supported Linux versions."
    echo "Exiting..."
    exit 1
  fi
}

# Nimbix JARVICE emulation
function setup_jarvice_emulation() {
  cd /tmp
  curl https://codeload.github.com/nimbix/jarvice-desktop/zip/$BRANCH \
    >/tmp/nimbix.zip
  unzip nimbix.zip
  rm -f nimbix.zip
  /tmp/jarvice-desktop-$BRANCH/setup-nimbix.sh

  # Redundant directory copies, use a soft link, favor the /usr/local/ but
  #  J2 depends on this so allow the full copies for now
  mkdir -p /usr/lib/JARVICE
  cp -a /tmp/jarvice-desktop-$BRANCH/tools /usr/lib/JARVICE
  mkdir -p /usr/local/JARVICE
  cp -a /tmp/jarvice-desktop-$BRANCH/tools /usr/local/JARVICE
  #    ln -sf /usr/local/JARVICE /usr/lib/JARVICE
  cat <<'EOF' | tee /etc/profile.d/jarvice-tools.sh >/dev/null
JARVICE_TOOLS="/usr/local/JARVICE/tools"
JARVICE_TOOLS_BIN="$JARVICE_TOOLS/bin"
PATH="$PATH:$JARVICE_TOOLS_BIN"
export JARVICE_TOOLS JARVICE_TOOLS_BIN PATH
EOF

  cd /tmp
  mkdir -p /etc/JARVICE
  cp -a /tmp/jarvice-desktop-"$BRANCH"/etc/* /etc/JARVICE
  chmod 755 /etc/JARVICE
  mkdir -m 0755 /data
  chown nimbix:nimbix /data
}

function setup_nimbix_desktop() {

  mkdir -p /usr/local/lib/nimbix_desktop

  # Copy in the VNC server installers and the XFCE files
  source /etc/os-release

  if [[ "$ID_LIKE" == *"rhel"* ]]; then # EL based system
    files="install-rhel-desktop.sh"
  elif [[ "$ID" == *"ubuntu"* ]]; then # Ubuntu based system
    files="install-ubuntu-desktop.sh"
  fi
  files+=" prep-tiger.sh install-tiger.sh help-tiger.html postinstall-desktop.sh"
  files+=" nimbix_desktop url.txt xfce4-session-logout share skel.config mimeapps.list helpers.rc"

  # Pull the files from the install bolus
  for i in $files; do
    cp -a /tmp/jarvice-desktop-"$BRANCH"/nimbix_desktop/"$i" \
      /usr/local/lib/nimbix_desktop
  done

  # Setup the desktop files
  if [[ "$ID_LIKE" == *"rhel"* ]]; then # EL based system
    /usr/local/lib/nimbix_desktop/install-rhel-desktop.sh
  elif [[ "$ID" == *"ubuntu"* ]]; then # Ubuntu based system
    /usr/local/lib/nimbix_desktop/install-ubuntu-desktop.sh
  fi

  if [[ $ARCH == x86_64 ]]; then
    /usr/local/lib/nimbix_desktop/prep-tiger.sh
    cp /usr/local/lib/nimbix_desktop/help-tiger.html /etc/NAE/help.html
  fi

  # clean up older copies, make a link for all apps to find nimbix_desktop
  rm -f /usr/lib/JARVICE/tools/nimbix_desktop
  ln -sf /usr/local/lib/nimbix_desktop/ /usr/lib/JARVICE/tools/nimbix_desktop

  # recreate nimbix user home to get the right skeleton files
  /bin/rm -rf /home/nimbix
  /sbin/mkhomedir_helper nimbix

  # Add a marker file for using a local, updated noVNC install
  echo /usr/local/JARVICE/tools/noVNC | tee /etc/.novnc-stable
  chmod 777 /etc/.novnc-stable
}

function cleanup() {
  if [[ "$ID_LIKE" == *"rhel"* ]]; then # EL based system
    yum clean all
  elif [[ "$ID" == *"ubuntu"* ]]; then # Ubuntu based system
    apt-get clean
  fi
  rm -rf /tmp/jarvice-desktop-$BRANCH
}

function tune_nimbix_desktop() {

# Hack XFCE wallpapers, to replace them with Nimbix's one
for filename in /usr/share/backgrounds/xfce/*.png; do
    [ -e "$filename" ] || continue
    rm -f $filename
    cp /usr/local/lib/nimbix_desktop/share/backgrounds/Nimix_Desktop.png $filename
done
for filename in /usr/share/backgrounds/xfce/*.jpg; do
    [ -e "$filename" ] || continue
    rm -f $filename
    cp /usr/local/lib/nimbix_desktop/share/backgrounds/Nimix_Desktop.jpg $filename
done
}

setup_base_os
setup_jarvice_emulation
setup_nimbix_desktop
tune_nimbix_desktop
cleanup

exit 0
