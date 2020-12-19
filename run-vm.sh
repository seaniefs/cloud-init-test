kvm -no-reboot -m 4096 \
    -smp cpus=1,maxcpus=2,cores=2 \
    -drive file=./image.img,format=raw,cache=none,if=virtio

