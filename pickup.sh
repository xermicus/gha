#!/bin/bash

# Silence some errors
export XDG_RUNTIME_DIR=/run/user/$(id -u)
echo -n "runner" | sudo -S mkdir $XDG_RUNTIME_DIR
echo -n "runner" | sudo -S chmod 700 $XDG_RUNTIME_DIR
echo -n "runner" | sudo -S chown $(id -un):$(id -gn) $XDG_RUNTIME_DIR
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
dbus-daemon --session --address=$DBUS_SESSION_BUS_ADDRESS --nofork --nopidfile --syslog-only &

# Do it
/home/runner/run.sh --once

# Reboot will kill the VM
echo -n "runner" | sudo -S reboot
