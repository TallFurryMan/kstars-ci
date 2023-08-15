FROM ubuntu:18.04

RUN dpkg --add-architecture i386
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        gcc-multilib g++-multilib
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        cmake extra-cmake-modules
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        git dpkg-dev default-jre ccache gettext
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        zlib1g-dev:i386 libsecret-1-dev:i386 linux-libc-dev-i386-cross libcurl4-openssl-dev:i386
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        libeigen3-dev:i386 libcfitsio-dev:i386 libnova-dev:i386 libgsl-dev:i386 libraw-dev:i386 wcslib-dev:i386 libev-dev:i386 \
        libusb-1.0.0-dev:i386 libgsl-dev:i386 libjpeg-dev:i386 libtiff-dev:i386 libfftw3-dev:i386 libftdi1-dev:i386
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        libavcodec-dev:i386 libavdevice-dev:i386 libavformat-dev:i386 libavutil-dev:i386 libswscale-dev:i386
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        libgphoto2-dev:i386

RUN apt-get -y update && apt-get -y --no-install-recommends install wget apt sudo
RUN sed -i 's|^%sudo.*$|%sudo ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/make|' /etc/sudoers
RUN useradd -m jenkins --groups sudo
RUN /usr/sbin/update-ccache-symlinks

RUN apt-get remove -y --purge --auto-remove cmake && \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" && \
    apt-get -y update && apt-get -y install kitware-archive-keyring && rm /etc/apt/trusted.gpg.d/kitware.gpg && \
    apt-get -y update && apt-get -y --no-install-recommends install cmake

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
