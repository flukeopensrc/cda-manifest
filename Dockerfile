FROM ubuntu:18.04

# Suppresses prompt for timezone
ENV DEBIAN_FRONTEND=noninteractive

# Yocto dependencies
RUN apt-get update
RUN apt-get -y install gawk make wget tar bzip2 gzip python3 unzip perl patch \
    diffutils diffstat git cpp gcc texinfo chrpath \
    ccache socat \
    python3-pexpect findutils file cpio python python3-pip \
    python3-jinja2 xterm bash

# Unable to locate packages
# gcc-c++  glibc-devel perl-Data-Dumper perl-Text-ParseWords perl-Thread-Queue perl-bignum
# which xz SDL-devel python3-GitPython

# Yocto build fails, if the Linux system does not configure a UTF8-capable locale.
RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ENV TERM="xterm-color"
ARG USER_ID=999
ARG GROUP_ID=999
ARG USER=docker
ARG PWD=docker
ARG HOME="/home/$USER"

RUN groupadd -g $GROUP_ID $USER && \
    useradd -g $GROUP_ID -m -s /bin/bash -u $USER_ID $USER

# RUN --mount=type=bind,target=$PWD,rw
# RUN --mount=type=bind,target=$HOME/.ssh,from=ubuntu

# Switch user to you
USER $USER
# start the ssh-agent && and prompt for ssh passphrase
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

