#!/bin/bash
set -e

# Source: https://jvns.ca/blog/2021/01/22/day-44--got-some-vms-to-start-in-firecracker/

# Download some GHA runner and kernel
# curl -o actions-runner-linux-x64-2.303.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.303.0/actions-runner-linux-x64-2.303.0.tar.gz
# wget https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/${ARCH}/kernels/vmlinux.bin


IMG_ID=$(sudo docker build  --build-arg TOKEN=$1 --build-arg ROOTPW=$2 --build-arg RUNNERNAME=$3 -q .)
CONTAINER_ID=$(sudo docker run -td $IMG_ID /bin/bash true)
MOUNTDIR=/tmp/mnt/$3
IMAGE=ubuntu$3.ext4
IMAGESIZE=16384M

mkdir -p $MOUNTDIR
qemu-img create -f raw $IMAGE $IMAGESIZE
mkfs.ext4 $IMAGE
sudo mount $IMAGE $MOUNTDIR

# docker cp -a is apparently broken
# https://github.com/moby/moby/issues/41727
sudo docker cp $CONTAINER_ID:/ - | sudo tar xf /dev/stdin -C $MOUNTDIR
sudo cp ./resolv.conf $MOUNTDIR/etc/resolv.conf

# squashfs
sudo mkdir -p $MOUNTDIR/overlay/root $MOUNTDIR/overlay/work $MOUNTDIR/mnt $MOUNTDIR/rom
sudo cp overlay-init $MOUNTDIR/sbin/overlay-init
sudo mksquashfs $MOUNTDIR $3.img -noappend

sudo umount $MOUNTDIR

