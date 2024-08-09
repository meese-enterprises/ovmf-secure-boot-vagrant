# About

This is a [Vagrant](https://www.vagrantup.com/) environment for setting up the [OVMF UEFI EDK2](https://github.com/tianocore/edk2) environment to play with [UEFI Secure Boot](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface#SECURE-BOOT) using [sbctl (Secure Boot key manager)](https://github.com/Foxboron/sbctl).

## Usage

Install the [base box](https://github.com/meese-enterprises/ubuntu-vagrant).

Start the environment:

```shell
time vagrant up --provider=libvirt --no-destroy-on-error --no-tty
cd tmp
bash ./run.sh
```

Verify that the platform is in Setup Mode:

```shell
sbctl status
```

It must output:

```shell
Installed:    ✗ sbctl is not installed
Setup Mode:   ✗ Enabled
Secure Boot:  ✗ Disabled
Vendor Keys:  none
```

Create our own Platform Key (PK), Key Exchange Key (KEK), and Code Signing CAs:

```shell
sbctl create-keys
```

It should something alike:

```shell
Created Owner UUID 5c839e31-20eb-42a6-906b-824ab404e0dd
Creating secure boot keys...✓
Secure boot keys created!
```

In more detail, all of these files should have been created:

```shell
$ find -type f /usr/share/secureboot/keys
/usr/share/secureboot/keys/KEK/KEK.key
/usr/share/secureboot/keys/KEK/KEK.pem
/usr/share/secureboot/keys/PK/PK.key
/usr/share/secureboot/keys/PK/PK.pem
/usr/share/secureboot/keys/db/db.key
/usr/share/secureboot/keys/db/db.pem
```

Enroll the keys with the firmware:

```shell
# NB this should be equivalent of using sbkeysync to write the EFI variables as:
  # sbkeysync --pk --verbose --keystore /usr/share/secureboot/keys
# see https://github.com/Foxboron/sbctl/blob/fda4f2c1efd801cd04fb52923afcdb34baa42369/keys.go#L114-L115
sbctl enroll-keys --yes-this-might-brick-my-machine
```

It should display something like:

```shell
Enrolling keys to EFI variables...✓
Enrolled keys to the EFI variables!
```

Verify that the platform is now out of Setup Mode:

```shell
sbctl status
```

It should output something like:

```shell
Installed:    ✓ sbctl is installed
Owner GUID:   88f1e363-3f8e-4f73-9a86-57a2dcb1a285
Setup Mode:   ✓ Disabled
Secure Boot:  ✗ Disabled
Vendor Keys:  none
```

Sign the Linux EFI application:

```shell
sbctl sign /boot/efi/linux
```

It should output something alike:

```shell
✓ Signed /boot/efi/linux
```

Analyze the Linux EFI application:

```shell
efianalyze signed-image /boot/efi/linux
```

It should output something like:

```shell
Data Directory Header:
	Virtual Address: 0xa1e8a0
	Size in bytes: 2192
Certificate Type: WIN_CERT_TYPE_PKCS_SIGNED_DATA
	Issuer Name: CN=Database Key,C=Database Key
	Serial Number: 48816627373166678216378579258444048592
```

Reboot the system:

```shell
umount /boot/efi
shutdown -r
```

After boot, verify that the platform is now in Secure Boot mode:

```shell
sbctl status
```

It must output:

```shell
Installed:    ✓ sbctl is installed
Owner GUID:   88f1e363-3f8e-4f73-9a86-57a2dcb1a285
Setup Mode:   ✓ Disabled
Secure Boot:  ✓ Enabled
Vendor Keys:  none
```

Test loading a kernel module:

```shell
insmod /modules/configs.ko
```

It must not return any output nor error.

And that's much how you test drive Secure Boot in OVMF.

## QEMU VM device tree

You can see all the QEMU devices status by running the following command in another shell:

```shell
cd tmp
echo info qtree | ./qmp-shell -H ./test/amd64.socket
```

## References

* [Unified Extensible Firmware Interface (UEFI)](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface).
* [UEFI Forum](http://www.uefi.org/).
* [EDK II (aka edk2): UEFI Reference Implementation ](https://github.com/tianocore/edk2).
* [EDK II `bcfg boot dump` source code](https://github.com/tianocore/edk2/blob/976d0353a6ce48149039849b52bb67527be5b580/ShellPkg/Library/UefiShellBcfgCommandLib/UefiShellBcfgCommandLib.c#L1301).
* [UefiToolsPkg](https://github.com/andreiw/UefiToolsPkg) set of UEFI tools.
  * These are useful on their own and as C source based UEFI application examples.
* [sbctl (Secure Boot key manager)](https://github.com/Foxboron/sbctl).
