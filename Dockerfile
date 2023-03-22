# Derivate of https://github.com/weaveworks/ignite/blob/main/images/ubuntu/Dockerfile
FROM ubuntu:latest
ARG TOKEN
ARG RUNNERNAME
ARG ROOTPW

# udev is needed for booting a "real" VM, setting up the ttyS0 console properly
# kmod is needed for modprobing modules
# systemd is needed for running as PID 1 as /sbin/init
# ca-certificates, gnupg, lsb-release are needed for docker
RUN apt update && apt install -y \
		curl \
		dbus \
		kmod \
		iproute2 \
		iputils-ping \
		net-tools \
		openssh-server \
		rng-tools \
		ca-certificates \
		gnupg \
		lsb-release \
		systemd \
		sudo \
		bash \
		udev

# Install and enable docker
RUN mkdir -m 0755 -p /etc/apt/keyrings && \
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
	apt update && \
	apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
	apt clean && \
	rm -rf /var/lib/apt/lists/* && \
	systemctl enable docker

# Create the following files, but unset them
RUN echo "" > /etc/machine-id && echo "" > /var/lib/dbus/machine-id

# This container image doesn't have locales installed. Disable forwarding the
# user locale env variables or we get warnings such as:
#  bash: warning: setlocale: LC_ALL: cannot change locale
RUN sed -i -e 's/^AcceptEnv LANG LC_\*$/#AcceptEnv LANG LC_*/' /etc/ssh/sshd_config

# Set the root password for logging in through the VM's ttyS0 console
RUN echo "root:$ROOTPW" | chpasswd

# Add GHA runner service
COPY ./runner.service /etc/systemd/system/runner.service
RUN systemctl enable runner.service

# Install GHA runner
RUN groupadd user && \
	useradd -r -m -d /home/runner -s /bin/bash -g user -G sudo -u 1001 runner && \
	echo "runner:runner" | chpasswd
USER runner
WORKDIR /home/runner/
COPY ./post-hook.sh .
ADD ./actions-runner-linux-x64-2.303.0.tar.gz .
RUN ./config.sh --url https://github.com/hyperledger/solang --unattended --token $TOKEN --ephemeral --name $RUNNERNAME --disableupdate --labels ubuntu-latest --replace

