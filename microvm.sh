#!/bin/bash
set -e

if [[ $# = 0 ]] ;
then
	echo "Usage: microvm.sh DATA_DIR BASE_DIR VM_NO"
	exit 1
fi
BASE_DIR=$2/$3/root
DATA_DIR=$1

mkdir -p $BASE_DIR
cp $DATA_DIR/rootfs$3.img $BASE_DIR/rootfs.img
cp $DATA_DIR/config.json $DATA_DIR/vmlinux.bin $BASE_DIR/
sed -i "s/00:02/0${3}:02/g" $BASE_DIR/config.json
sed -i "s/tap0/tap${3}/g" $BASE_DIR/config.json
chown -R jailer:jailer $BASE_DIR

while :
do
	rm -rf $BASE_DIR/dev || true
	rm -rf $BASE_DIR/run || true
	jailer --id $3 --uid 1000 --gid 1000 --exec-file /usr/bin/firecracker -- --config-file config.json --no-api
done
