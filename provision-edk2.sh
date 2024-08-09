#!/bin/bash
source /vagrant/lib.sh

# install the dependencies.
sudo apt-get -qq install -y \
    acpica-tools python3-distutils uuid-dev \
    build-essential nasm dos2unix \
    >/dev/null

echo "Symlinking python to python3..."
sudo ln -s /usr/bin/python{3,}

# Build the base edk2 tools
su vagrant -c bash <<"EOF"
set -euxo pipefail

# Clone the edk2 repo
git clone https://github.com/tianocore/edk2.git edk2
cd edk2
git checkout edk2-stable202405
git submodule update --init --recursive

# Build the base edk2 tools
time make -C BaseTools
EOF
