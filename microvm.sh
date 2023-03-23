#!/bin/bash
set -e

if [[ $# = 0 ]] ;
then
	exit 1
fi
BASE_DIR=$1/$2/root
DATA_DIR=/root/firecracker

mkdir -p $BASE_DIR
cp $DATA_DIR/rootfs$2.img $BASE_DIR/rootfs.img
cp $DATA_DIR/config.json $DATA_DIR/vmlinux.bin $BASE_DIR/
ADDR_NO=$(($2 + 1))
sed -i "s/00:02/00:0${ADDR_NO}/g" $BASE_DIR/config.json
chown -R jailer:jailer $BASE_DIR

while :
do
	rm -rf $BASE_DIR/dev || true
	rm -rf $BASE_DIR/run || true
	jailer --id $2 --uid 1000 --gid 1000 --exec-file /usr/bin/firecracker -- --config-file config.json --no-api
done
