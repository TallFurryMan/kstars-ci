FROM ubuntu:18.04

RUN dpkg --add-architecture i386
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y --no-install-recommends install \
        gcc-multilib g++-multilib
RUN apt-get -y --no-install-recommends install \
        autotools-dev autoconf
RUN apt-get -y --no-install-recommends install \
        git dpkg-dev default-jre ccache gettext breeze-icon-theme
RUN apt-get -y --no-install-recommends install \
        zlib1g-dev:i386 libsecret-1-dev:i386 linux-libc-dev-i386-cross \
        libcurl4-openssl-dev:i386

RUN useradd -m jenkins
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
