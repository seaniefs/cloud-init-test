kvm -no-reboot -m 4096 \
    -drive file=./image.img,format=raw,cache=none,if=virtio

