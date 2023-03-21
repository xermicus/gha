#!/bin/bash
set -e

# Source: https://jvns.ca/blog/2021/01/22/day-44--got-some-vms-to-start-in-firecracker/

IMG_ID=$(docker build -q .)
CONTAINER_ID=$(docker run -td $IMG_ID /bin/bash)
MOUNTDIR=mnt
IMAGE=ubuntu.ext4
mount $IMAGE $MOUNTDIR
qemu-img create -f raw $IMAGE 800M
mkfs.ext4 $IMAGE
docker cp $CONTAINER_ID:/ $MOUNTDIR

