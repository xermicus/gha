Scripts for running GHA runners in ephemeral firecracker micro VMs. Ephemeral VMs are preferable because there is no cleanup to be done after a job run, hence there is also no risk of accidentially leaking data between job runs.

# How it works

- The VM image is built from an ordinary docker file
- After each job run, the VM simply reboots, which will halt it's execution
- `systemd` will take care of restarting VMs immediatly, boot time is less than one second
- Because VMs disk drive is a `tmpfs` residing entirely in RAM, no state is persistet between runs. Alternatively, e.g. if not enough memory is available on the VM host, this could also be made a COW which is thrown away after each run instead, with minor changes.
- Isolation from the host is done with `jailer`.
- One VM host can run multiple microVMs at the same time. However each runner needs it's own GHA runner token.

# Requirements

- `docker`
- `qemu-img`
- squashfs-tools
- `sudo`
- Unpriviledged user for jailer

# Setup briefly

1. Download the latest runner package: `curl -O -L https://github.com/actions/runner/releases/download/v2.303.0/actions-runner-linux-x64-2.303.0.tar.gz`
2. Obtain a firecracker supported kernel (5.10) and save it as `vmlinux.bin`
3. Build the root filesystem: `./build-root.sh token root_passwd runner-name-X && vm rootfs.img rootfsX.img` (replace X with a number)
4. Repeat the previous step for as many runners you want
5. Enable the systemd service

# Issues
These would be nice to fix for good but I ENOTIME:
- Netfilter (NFT) doesn't work for some reason, but docker needs it -> switched to legacy iptables (ugly)
- Network configuration is an ugly hack
- DNS inside VM only works via TCP
- Uses the undocummented `--once` flag with the GHA runner binary but it is apparently depricated and removed in the future. I'm not sure how else we can make this work, since `--ephemeral` will delete the runnner after one job and a new token needs to be obtained somehow? The GHA docs don't loose a word to this problem.

