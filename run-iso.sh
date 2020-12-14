sudo usermod -a -G kvm $USER
rm ./image.img
truncate -s 40G ./image.img

kvm -no-reboot -m 2048 \
    -drive file=./image.img,format=raw,cache=none,if=virtio \
    -cdrom ./ubuntu-20.04.1-live-server-amd64-autoinstall.iso

