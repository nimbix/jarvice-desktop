#!/bin/sh
/usr/sbin/groupadd -g 505 nimbix
/usr/sbin/useradd -u 505 -g 505 -m -s /bin/bash nimbix
cat <<EOF >/etc/sudoers.d/00-nimbix
Defaults: nimbix !requiretty
Defaults: root !requiretty
nimbix ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/00-nimbix

# for standalone use, password is nimbixnimbix
# useful to unlock screensaver
/usr/sbin/usermod -p '$6$uU7dvN0Z6Z298lJP$q2KsLdY1ZdYHbFFn2aZrrSXP0o1Mfa34447F89HG9cLc.llR7mrElIhXPp/WrYv/GfRKQYcd3ta/7l.WOn.0S/' nimbix

# Create bashrc if not exist
if [ ! -f /home/nimbix/.bashrc ]
then
cat << EOF > /home/nimbix/.bashrc
export CLICOLOR=1
export LANG="en_US.UTF-8"

alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

alias ls="ls --color=auto"
alias ll="ls -alh"

export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
EOF
fi

# Ensure a PS1 is set if bashrc already exist
cat /home/nimbix/.bashrc | grep PS1 || echo 'export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/nimbix/.bashrc
