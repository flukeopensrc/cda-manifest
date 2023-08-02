FROM ubuntu:20.04

# Give us a nice color shell
ENV TERM="xterm-color"

# Variables that we will use to setup our image/container
# These value are arbitrary and should be replaced when calling docker build.
ARG USER_ID=999
ARG GROUP_ID=999
ARG USER=docker
ARG PWD=docker

ARG HOME="/home/$USER"

# Create our group and user so we can login as ourself. Useful for ssh.
RUN groupadd -g $GROUP_ID $USER && \
    useradd -g $GROUP_ID -m -s /bin/bash -d $HOME -u $USER_ID $USER

# Suppresses prompt for timezone
ENV DEBIAN_FRONTEND=noninteractive

# Yocto dependencies
RUN apt-get update
RUN apt-get -y upgrade

# This was copied from yocto documentation for zeus
RUN apt-get -y install gawk make wget tar bzip2 gzip python3 unzip perl patch \
    diffutils diffstat git cpp gcc texinfo chrpath \
    ccache socat \
    python3-pexpect findutils file cpio python python3-pip \
    python3-jinja2 xterm bash

# Unable to locate packages. Documentation from yocto might have been incorrect or just never
# corrected.
# These were likely packaged with other packages
# gcc-c++  glibc-devel perl-Data-Dumper perl-Text-ParseWords perl-Thread-Queue perl-bignum
# which xz SDL-devel python3-GitPython

# Other stuff that might be helpful
RUN apt-get -y install vim curl ca-certificates

# Clean up old package data that's no longer needed.
RUN apt autoremove -y

# Yocto build fails, if the Linux system does not configure a UTF8-capable locale.
RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# We get SSL issue if we don't include Zscaler certificates DUH....
COPY ZscalerRootCertificate-2048-SHA256.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Switch user to you
USER $USER

# start the ssh-agent && and prompt for ssh passphrase
# Run this whenever we call bash so don't forget.
RUN echo '\n\
ssh_start_agent() {\n\
    if [ ! -S "${HOME}/.ssh/ssh_auth_sock_${HOSTNAME}" ]; then\n\
        echo "Running ssh-agent from .bashrc"\n\
        eval "$(ssh-agent)"\n\
        ln -sf "$SSH_AUTH_SOCK" "${HOME}/ssh_auth_sock_${HOSTNAME}"\n\
    fi\n\
    export SSH_AUTH_SOCK="${HOME}/ssh_auth_sock_${HOSTNAME}"\n\
    ssh-add -l > /dev/null || ssh-add\n\
}\n\
ssh_start_agent\n' >> ${HOME}/.bashrc

WORKDIR $PWD
CMD sleep infinity

