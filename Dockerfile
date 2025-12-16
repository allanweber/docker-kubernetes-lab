FROM ubuntu:22.04

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    systemd \
    systemd-sysv \
    openssh-server \
    sudo \
    iproute2 \
    net-tools \
    vim \
    curl \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Disable unnecessary systemd services
RUN systemctl mask \
    dev-hugepages.mount \
    sys-fs-fuse-connections.mount \
    systemd-remount-fs.service \
    systemd-logind.service \
    getty.target

# SSH setup
RUN mkdir -p /var/run/sshd

# Admin user
RUN useradd -m admin && \
    echo "admin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/admin

# SSH key-only login
RUN mkdir -p /home/admin/.ssh && \
    chmod 700 /home/admin/.ssh

COPY vm_lab_key.pub /home/admin/.ssh/authorized_keys

RUN chmod 600 /home/admin/.ssh/authorized_keys && \
    chown -R admin:admin /home/admin/.ssh

# Harden SSH
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

EXPOSE 22

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
