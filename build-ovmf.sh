#!/bin/bash
export WORKSPACE=$HOME/edk2
source $WORKSPACE/edksetup.sh
set -euxo pipefail

cd $WORKSPACE

# Build
NUM_CPUS=$((`getconf _NPROCESSORS_ONLN` + 2))
build \
    -p OvmfPkg/OvmfPkgX64.dsc \
    -a X64 \
    -t GCC5 \
    -b DEBUG \
    -n $NUM_CPUS \
    -D SECURE_BOOT_ENABLE=TRUE \
    -D SMM_REQUIRE=TRUE \
    -D TPM_ENABLE=TRUE \
    -D TPM_CONFIG_ENABLE=TRUE \
    -D NETWORK_TLS_ENABLE=TRUE \
    --pcd gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVendor=L"rgl" \
    --pcd gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVersionString=L"rgl uefi firmware" \
    --pcd gEfiMdePkgTokenSpaceGuid.PcdDebugPrintErrorLevel=0x8000004F

# Copy to the host.
# NB we also copy the Shell.efi file because its easier to use it
#    as a boot option. e.g. to add it as the last boot option to
#    reboot the system when all the other options have failed.
mkdir -p /vagrant/tmp
cp Build/OvmfX64/DEBUG_GCC5/FV/OVMF*.fd /vagrant/tmp/
cp Build/OvmfX64/DEBUG_GCC5/X64/Shell.efi /vagrant/tmp/
cp Build/OvmfX64/DEBUG_GCC5/X64/UiApp.efi /vagrant/tmp/
ls -laF /vagrant/tmp/{OVMF*.fd,Shell.efi,UiApp.efi}
