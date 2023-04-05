#!/bin/bash
set -e

if [[ $# = 0 ]] ;
then
	echo "Usage: run.sh UPLINK_DEV DATA_DIR BASE_DIR VM_NO"
	exit 1
fi

# Clean state
rm -rf $3

# Enable ip forwarding
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
#iptables -t nat -D POSTROUTING -o $1 -j MASQUERADE || true
#iptables -D FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT || true
iptables -t nat -A POSTROUTING -o $1 -j MASQUERADE
iptables -I FORWARD 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
	
for n in $(seq 1 $4);
do
	TAP_DEV="tap$n"
	TAP_IP="172.16.$n.1"
	MASK_SHORT="/30"
	BASE_DIR=$3/$n/root
	DATA_DIR=$2
	
	# Setup network interface
	ip link del "$TAP_DEV" 2> /dev/null || true
	ip tuntap add dev "$TAP_DEV" mode tap
	ip addr add "${TAP_IP}${MASK_SHORT}" dev "$TAP_DEV"
	ip link set dev "$TAP_DEV" up
	
	# Set up microVM internet access
	#iptables -D FORWARD -i $TAP_DEV -o $1 -j ACCEPT || true
	iptables -I FORWARD 1 -i $TAP_DEV -o $1 -j ACCEPT

	mkdir -p $BASE_DIR
	cp $DATA_DIR/rootfs$n.img $BASE_DIR/rootfs.img
	cp $DATA_DIR/config.json $DATA_DIR/vmlinux.bin $BASE_DIR/
	sed -i "s/00:02/0${n}:02/g" $BASE_DIR/config.json
	sed -i "s/tap0/tap${n}/g" $BASE_DIR/config.json
	chown -R jailer:jailer $BASE_DIR

	$2/microvm.sh $BASE_DIR $n &
done

