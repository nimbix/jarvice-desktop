#!/usr/bin/env bash

set -e

ARCH=$(arch)
BRANCH=master

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
  --verbose)
    export VERBOSE=true
    shift
    shift
    ;;
  --reduce-image-size)
    export RIS=true
    shift
    shift
    ;;
  *)
    break
    ;;
  esac
done

if [ "$VERBOSE" = true ]; then
  echo -e "\e[1;33mINFO : Enabling verbosity\e[0m"
  sleep 1
  set -x
fi

echo -e "\e[1;34m     _  _   _____   _____ ___ ___   ___  ___ ___ _  _______ ___  ___ "
echo -e "\e[1;34m  _ | |/_\\ | _ \\ \\ / /_ _/ __| __| |   \\| __/ __| |/ /_   _/ _ \\| _ \\"
echo -e "\e[1;34m | || / _ \\|   /\\ V / | | (__| _|  | |) | _|\\__ \\ ' <  | || (_) |  _/"
echo -e "\e[1;34m  \\__/_/ \\_\\_|_\\ \\_/ |___\\___|___| |___/|___|___/_|\\_\\ |_| \\___/|_|  "                                                                
sleep 3

# Base OS
function setup_base_os() {

echo
echo -e "\e[1;33m ###############################################\e[0m"
echo -e "\e[1;33m #                SETUP BASE OS                #\e[0m"
echo -e "\e[1;33m ###############################################\e[0m"
echo
sleep 1

  # Core packages
  PKGS="curl zip unzip sudo"
  # Source current environment
  source /etc/os-release

  if [[ "$ID_LIKE" == *"rhel"* ]]; then # EL based system
    if [ "$RIS" = true ]; then
      export RIS="--nobest"
    fi
    if [[ "${VERSION_ID:0:1}" == "7" ]] || [[ "${VERSION_ID:0:1}" == "8" ]]; then # Supported EL version
      echo -e "\e[1;33mINFO : RHEL derivated detected\e[0m"
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
      if [[ "${VERSION_ID:0:1}" == "7" ]]; then
        yum -y install $PKGS
      elif [[ "${VERSION_ID:0:1}" == "8" ]]; then 
        dnf -y install $PKGS $RIS
      fi

      # EL 8 images have locals natively manually removed !!
      # We need to force reinstall packages to ensure files are present to build locals.
      if [[ "${VERSION_ID:0:1}" == "8" ]]; then
        dnf -y install glibc-langpack-en glibc-common glibc-locale-source gzip
        dnf -y reinstall glibc-langpack-en glibc-common glibc-locale-source gzip
      fi
      # Set locale
      localedef -i en_US -f UTF-8 en_US.UTF-8

      echo '# leave empty' >/etc/fstab
    else
      echo -e "\e[1;31mERROR: unknown or unsupported image operating system."
      echo -e "Please report to documentation to know supported Linux versions."
      echo -e "Exiting...\e[0m"
      exit 1
    fi

  elif [[ "$ID" == *"ubuntu"* ]]; then # Ubuntu based system
    if [ "$RIS" = true ]; then
      export RIS="--no-install-recommends"
    fi
    if [[ "$VERSION_ID" == "18.04" ]] || [[ "$VERSION_ID" == "20.04" ]] || [[ "$VERSION_ID" == "22.04" ]]; then # Supported versions
      echo -e "\e[1;33mINFO : Ubuntu derivated detected\e[0m"

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
      # If requested by user, update system
      [ -z "$SKIP_OS_PKG_UPDATE" ] && apt-get -y upgrade
      # Install packages
      apt-get -y install $PKGS $RIS

      locale-gen en_US.UTF-8
      update-locale LANG=en_US.UTF-8
    else
      echo -e "\e[1;31mERROR: unknown or unsupported image operating system."
      echo -e "Please report to documentation to know supported Linux versions."
      echo -e "Exiting...\e[0m"
      exit 1
    fi

  else
    echo -e "\e[1;31mERROR: unknown or unsupported image operating system."
    echo -e "Please report to documentation to know supported Linux versions."
    echo -e "Exiting...\e[0m"
    exit 1
  fi
}

# Nimbix JARVICE emulation
function setup_jarvice_emulation() {

  echo
  echo -e "\e[1;33m ###############################################\e[0m"
  echo -e "\e[1;33m #            SETUP JARVICE EMULATION          #\e[0m"
  echo -e "\e[1;33m ###############################################\e[0m"
  echo
  sleep 1

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

  echo
  echo -e "\e[1;33m ###############################################\e[0m"
  echo -e "\e[1;33m #             SETUP NIMBIX DESKTOP            #\e[0m"
  echo -e "\e[1;33m ###############################################\e[0m"
  echo
  sleep 1

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
    /usr/local/lib/nimbix_desktop/install-tiger.sh
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

  echo
  echo -e "\e[1;33m ###############################################\e[0m"
  echo -e "\e[1;33m #                 CLEANING UP                 #\e[0m"
  echo -e "\e[1;33m ###############################################\e[0m"
  echo
  sleep 1

  if [[ "$ID_LIKE" == *"rhel"* ]]; then # EL based system
    yum clean all
  elif [[ "$ID" == *"ubuntu"* ]]; then # Ubuntu based system
    apt-get clean
  fi
  rm -rf /tmp/jarvice-desktop-$BRANCH
}

function tune_nimbix_desktop() {

  echo
  echo -e "\e[1;33m ###############################################\e[0m"
  echo -e "\e[1;33m #                TUNING DESKTOP               #\e[0m"
  echo -e "\e[1;33m ###############################################\e[0m"
  echo
  sleep 1

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

  # Ensure no screensaver lock possible
  rm -f /etc/xdg/autostart/xfce4-screensaver.desktop
  rm -f /etc/xdg/autostart/xscreensaver.desktop
  rm -f /etc/xdg/autostart/light-locker.desktop

  rm -f /usr/bin/xfce4-screensaver
  echo -e '#!/bin/sh\nexit 0' > /usr/bin/xfce4-screensaver

}

function makecert() {
    cat <<EOF >/usr/local/etc/cert.pem
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDEmb/moNBZguGD
5dFZwQd6mzKNNzPchYLaGs2PX67Gd/RaOmWgxoOyahTUWs6cir2Y3BHTQmDynAgL
8ZkGTI2YupAptsHyTU9Vu2/XS0HiTiGhYgHLqNmbAhp74k+gt3LOUOiSyKNkIHlD
rNCosdDxa1Tf+HeGhtzBY/4gEu08kExREjQvDUGZgaeIIvMhvHNc+MrNJBhdvd8y
HWB/EWDasWwQt/HSDJeqQTXThRxwx5BLAN4V0qtTY0wlsEpVWLsAuTARVIy7umpr
44Swg9lXJ/ZXim1yvk81Bu05Vai9oPZqh6nO72Q48n03n/DEhITR9nGTIk05fqOi
nOQH/0vPAgMBAAECggEADXaZ9ak9m2OjHe03EPZvFK5cH9+P5aIe++CqAw+CYIUG
bsdg/kmZ6zXoh0JQs9esdDNd5SG+kd6tjmPVHuFPMQ5VoQWq8nTo4e4cEppMwLqp
Auw7Qz8k58CVH7a3zUHC0u4nfyXOSqUOqNvEzkifDmlTPqM9TDEgHP5EAN5K8MKy
PR5lvrMASvYy4z1qQlYDe0H+QC8osno7sCdgOEdfE0SBFO3/kZaDnsSDoItUk+et
VrUVPaLXhuCJnwRhb1WZOlStf54K1Qsg5+Q0YBEGatIETadvxw6HQ3sOjWpKlqvU
CQSdLhaQAZ4EiY0jgzVCptFh1tXIIphGNKzf7h+HwQKBgQDhaAPXF+pYnfiyssLY
CdP73xKnU9aSFF3a199XJuvnqpsb8p3LQyJyO/vR6hK2GhKaMvcwZyZyPilHfaCA
1ng2/aIeELxqjXDjBVFuXijf3/EnFucy81/rkPoDu6xHfIG92p5awR1QIQr3s3N6
S7PeUHGK4EUGGkj0BqSAYzx+ywKBgQDfSNlEKG8soqMW+d1ISLg4ci2yLigOLdQH
aSBalySY+vLteA0d6WB+kdtitfD3fp78kxu01BZAvhB2w44qBnYowCEeiNWZGzze
YxW4/LbIa1Mm4uCF4KnHdkkICbTJstaCqsw045/9uRnSqQpn2YMyXbIKR6Ye8Y22
K/6D3zOijQKBgQDHxcxBgmyshbW5iz2tA2jhvl9l9aQia/KS1uiW8WP7OvWl222G
jMWmwQr6jJ5wzsLV732tZH5qmjUzq1/pUCvTcQ+R3ftf5GO8kSYOz10irfOpVV8r
hQ/qU9+CF38lDHBgt7XJcYZtUhvKVT1vklCkJF+9We9S7VDjFlANieY/6QKBgGYp
jM90uLlxiLGgjbDfJPsesu3N1KH4MgVaAmWwthwQ5knlHgtLls0Sq5CUsrZrBw+F
t62bRLtGu327qDZuUm3+yqiP7ztojQcryuqjJna5NIicUiKvUr9izbORzVhkLWYI
A/tHExMiOEB8+7fce/z1hdrSQZ3y4+YwZvmrjJKZAoGBANGjKCNFsIe6Vwcc3Wvy
1F75iWhKnTLhZx7sgkaLznge0a5OcifgsaXbsNC/eAU+ZNILMeH5BCZeQbqYgn2q
ezsp24wobcUk94Oy1ugu5PnG7cbcPrv9JU0II0rn3UQLQbh46nTfb0SFx1TuiK+J
6RNTNU7wG1vYbpFkdGLctxbm
-----END PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIDczCCAlugAwIBAgIUHvzUm4fHsf///sfAN+a+3x0qAkUwDQYJKoZIhvcNAQEL
BQAwSDELMAkGA1UEBhMCVVMxDjAMBgNVBAgMBVRleGFzMQ8wDQYDVQQHDAZEYWxs
YXMxDDAKBgNVBAoMA3dlYjEKMAgGA1UEAwwBeDAgFw0yMjA2MTQxOTM5NThaGA8y
MTIyMDUyMTE5Mzk1OFowSDELMAkGA1UEBhMCVVMxDjAMBgNVBAgMBVRleGFzMQ8w
DQYDVQQHDAZEYWxsYXMxDDAKBgNVBAoMA3dlYjEKMAgGA1UEAwwBeDCCASIwDQYJ
KoZIhvcNAQEBBQADggEPADCCAQoCggEBAMSZv+ag0FmC4YPl0VnBB3qbMo03M9yF
gtoazY9frsZ39Fo6ZaDGg7JqFNRazpyKvZjcEdNCYPKcCAvxmQZMjZi6kCm2wfJN
T1W7b9dLQeJOIaFiAcuo2ZsCGnviT6C3cs5Q6JLIo2QgeUOs0Kix0PFrVN/4d4aG
3MFj/iAS7TyQTFESNC8NQZmBp4gi8yG8c1z4ys0kGF293zIdYH8RYNqxbBC38dIM
l6pBNdOFHHDHkEsA3hXSq1NjTCWwSlVYuwC5MBFUjLu6amvjhLCD2Vcn9leKbXK+
TzUG7TlVqL2g9mqHqc7vZDjyfTef8MSEhNH2cZMiTTl+o6Kc5Af/S88CAwEAAaNT
MFEwHQYDVR0OBBYEFGYRkqh7TG/czVwDjAq943PaKwQMMB8GA1UdIwQYMBaAFGYR
kqh7TG/czVwDjAq943PaKwQMMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQEL
BQADggEBAIUZkrlLPDNKM0mNcewCTf5i/4J6Qw5f4GXybJJH1VPe5JIdbSvYycKk
dKf21RYHVYXnrB5Z4RvI0P6+gWd/TWC2U5eCznSnlpJaLJu0UGrtepilW/DQQ0GK
D7rZJ2m9gUfgP8QO8TiAdZ53pR36MpA3IXhjCV69OwmNsFYp3ExjmE3ONjuNKDzd
YIiHxNaO6sCvoQeWO/c5at3iMojn/LRvPw/8VDNHUrwRMGAN3Z3niacldflpc4fe
Abk9AMaErBBZqaqKyDWGzrdEqZ7+rAS94nL/jT6caa564qFqyxdnnB16CXvSz0So
cNmG8pCV9HVJ+d4hah4DydeJrjfugLo=
-----END CERTIFICATE-----
EOF
}

setup_base_os
setup_jarvice_emulation
setup_nimbix_desktop
tune_nimbix_desktop
makecert
cleanup

exit 0
