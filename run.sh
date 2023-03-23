#!/bin/bash
set -e

if [[ $# = 0 ]] ;
then
	echo "Usage: run.sh UPLINK_DEV DATA_DIR BASE_DIR VM_NO"
	exit 1
fi

# Network setup is idempotent

TAP_DEV="tap0"
TAP_IP="172.16.0.1"
MASK_SHORT="/28"

# Setup network interface
ip link del "$TAP_DEV" 2> /dev/null || true
ip tuntap add dev "$TAP_DEV" mode tap
ip addr add "${TAP_IP}${MASK_SHORT}" dev "$TAP_DEV"
ip link set dev "$TAP_DEV" up

# Enable ip forwarding
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

# Set up microVM internet access
iptables -t nat -D POSTROUTING -o $1 -j MASQUERADE || true
iptables -D FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT || true
iptables -D FORWARD -i tap0 -o $1 -j ACCEPT || true
iptables -t nat -A POSTROUTING -o $1 -j MASQUERADE
iptables -I FORWARD 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -I FORWARD 1 -i tap0 -o $1 -j ACCEPT

# Clean state
rm -rf $3

for n in $(seq 1 $4);
do
	$3/microvm.sh $2 $3 $n &
done

