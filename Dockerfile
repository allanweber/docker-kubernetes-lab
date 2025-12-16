FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    iputils-ping \
    net-tools \
    curl \
    vim \
    systemd \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

# Create admin user
RUN useradd -m admin && echo "admin:admin" | chpasswd && adduser admin sudo

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]