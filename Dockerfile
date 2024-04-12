FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# Install misc utilities and add toolkit user
ENV LANG=en_US.UTF-8
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y \
        build-essential \
        openmpi-bin openmpi-common libopenmpi-dev \
        openssh-client openssh-server \
        ca-certificates \
        supervisor \
        locales \
        && \
    # locale-gen
    sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen && \
    locale-gen && \
    # users
    useradd -m -u 13011 -s /bin/bash toolkit && \
    passwd -d toolkit && \
    useradd -m -u 13011 -s /bin/bash --non-unique console && \
    passwd -d console && \
    useradd -m -u 13011 -s /bin/bash --non-unique _toolchain && \
    passwd -d _toolchain && \
    useradd -m -u 13011 -s /bin/bash --non-unique coder && \
    passwd -d coder && \
    chown -R toolkit:toolkit /run /etc/shadow /etc/profile /tmp && \
    # Clean up
    apt autoremove --purge && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo ssh >> /etc/securetty && \
    rm -f /etc/legal /etc/motd

USER root
EXPOSE 2222
EXPOSE 6000
EXPOSE 8088
COPY --chown=13011:13011 --from=registry.console.elementai.com/shared.image/sshd:base /tk /tk
RUN chmod 0600 /tk/etc/ssh/ssh_host_rsa_key
COPY --chown=13011:13011 ./supervisord.conf /tk/etc/supervisord.conf

USER toolkit
COPY --chown=13011:13011 . /app
WORKDIR /app
RUN make MPI=1 MPI_HOME=/usr/lib/x86_64-linux-gnu/openmpi all
