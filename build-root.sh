#!/bin/bash
set -e

# Source: https://jvns.ca/blog/2021/01/22/day-44--got-some-vms-to-start-in-firecracker/

IMG_ID=$(sudo docker build  --build-arg TOKEN=$1 --build-arg ROOTPW=$2 --build-arg RUNNERNAME=cyrill-microvm -q .)
CONTAINER_ID=$(sudo docker run -td $IMG_ID /bin/bash true)
MOUNTDIR=/tmp/mnt
IMAGE=ubuntu.ext4
IMAGESIZE=16384M

mkdir -p $MOUNTDIR
qemu-img create -f raw $IMAGE $IMAGESIZE
mkfs.ext4 $IMAGE
sudo mount $IMAGE $MOUNTDIR
sudo docker cp -a $CONTAINER_ID:/ $MOUNTDIR
sudo umount $MOUNTDIR

