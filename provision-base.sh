#!/bin/bash
source /vagrant/lib.sh

# Prevent apt-get from asking questions
echo 'Defaults env_keep += "DEBIAN_FRONTEND"' >/etc/sudoers.d/env_keep_apt
chmod 440 /etc/sudoers.d/env_keep_apt
export DEBIAN_FRONTEND=noninteractive

echo "Updating the package index cache..."
sudo apt-get -qq update

echo "Expanding the root partition..."
sudo apt-get -qq install --no-install-recommends parted >/dev/null
partition_device="$(findmnt -no SOURCE /)"
partition_number="$(echo "$partition_device" | perl -ne '/(\d+)$/ && print $1')"
disk_device="$(echo "$partition_device" | perl -ne '/(.+?)\d+$/ && print $1')"
gdisk "$disk_device" <<EOF
v
w
Y
Y
EOF
parted ---pretend-input-tty "$disk_device" <<EOF
resizepart $partition_number 100%
yes
EOF
resize2fs "$partition_device"


# Install vim
sudo apt-get -qq install --no-install-recommends vim >/dev/null
cat >/etc/vim/vimrc.local <<"EOF"
syntax on
set background=dark
set esckeys
set ruler
set laststatus=2
set nobackup
EOF


# Configure the shell
cat >/etc/profile.d/login.sh <<"EOF"
[[ "$-" != *i* ]] && return
export EDITOR=vim
export PAGER=less
alias l="ls -lF --color"
alias ll="l -a"
alias h="history 25"
alias j="jobs -l"
EOF

cat >/etc/inputrc <<"EOF"
set input-meta on
set output-meta on
set show-all-if-ambiguous on
set completion-ignore-case on
"\e[A": history-search-backward
"\e[B": history-search-forward
"\eOD": backward-word
"\eOC": forward-word
EOF

cat >~/.bash_history <<"EOF"
EOF

# Configure the vagrant user home
su vagrant -c bash <<"EOF-VAGRANT"
set -euxo pipefail

cat >~/.bash_history <<"EOF"
EOF
EOF-VAGRANT

# Install and configure Git
sudo apt-get -qq install git-core >/dev/null
su vagrant -c bash <<"EOF"
set -eux
git config --global push.default simple
git config --global core.autocrlf false
EOF

# Install qemu
sudo apt-get -qq install qemu-system-x86 >/dev/null
