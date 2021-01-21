FROM ubuntu:20.04

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y --no-install-recommends install \
        gcc-multilib g++-multilib
RUN apt-get -y --no-install-recommends install \
        cmake extra-cmake-modules
RUN apt-get -y --no-install-recommends install \
        git dpkg-dev default-jre ccache gettext
RUN apt-get -y --no-install-recommends install \
        zlib1g-dev libsecret-1-dev libcurl4-openssl-dev
RUN apt-get -y --no-install-recommends install \
        libeigen3-dev libcfitsio-dev libnova-dev libgsl-dev libraw-dev wcslib-dev \
        libusb-1.0.0-dev libgsl-dev libjpeg-dev libtiff-dev libfftw3-dev libftdi1-dev
RUN apt-get -y --no-install-recommends install \
        libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev libswscale-dev
RUN apt-get -y --no-install-recommends install \
        libgphoto2-dev

RUN apt-get -y --no-install-recommends install wget apt sudo
RUN sed -i 's|^%sudo.*$|%sudo ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/make|' /etc/sudoers
RUN useradd -m jenkins --groups sudo
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
