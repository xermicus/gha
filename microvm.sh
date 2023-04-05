#!/bin/bash

if [[ $# = 0 ]] ;
then
	echo "Usage: microvm.sh BASE_DIR VM_NO"
	exit 1
fi

while :
do
	rm -rf $1/dev $1/run || true
	jailer --id $2 --uid 1000 --gid 1000 --exec-file /usr/bin/firecracker -- --config-file config.json --no-api
done
