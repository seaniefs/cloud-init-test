# Usage

Run: `make-iso.sh` to download the Ubuntu 20.04.1 and then generate the autoinstall iso if you want to use the iso on real hardware/VirtualBox etc.



__Testing on KVM__

Run: `make-iso.sh kvm` to download the Ubuntu 20.04.1 and then generate the autoinstall iso for use/testing on KVM

Run: `run-iso.sh` to run the iso in KVM which runs the autoinstall iso onto a virtual hard disk

Run: `run-vm.sh` to run the virtual hard disk image in KVM; you will be prompted to enter a username, fullname and password.  Once install has completed, power down and re-start.

See: https://ubuntu.com/server/docs/install/autoinstall

https://www.golinuxcloud.com/read-user-input-during-boot-stage-linux/
