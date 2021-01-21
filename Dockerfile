FROM ubuntu:20.04

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y --no-install-recommends install \
        gcc-multilib g++-multilib
RUN apt-get -y --no-install-recommends install \
        cmake extra-cmake-modules
RUN apt-get -y --no-install-recommends install \
        git dpkg-dev default-jre ccache gettext breeze-icon-theme
RUN apt-get -y --no-install-recommends install \
        zlib1g-dev libsecret-1-dev
RUN apt-get -y install \
        qtdeclarative5-dev libqt5svg5-dev libqt5websockets5-dev
RUN apt-get -y install \
        libkf5plotting-dev libkf5xmlgui-dev libkf5newstuff-dev \
        libkf5notifications-dev libkf5crash-dev libkf5notifyconfig-dev \
        kio-dev kinit-dev kdoctools-dev libkf5config-bin
RUN apt-get -y --no-install-recommends install \
        libeigen3-dev libcfitsio-dev libnova-dev libgsl-dev libraw-dev wcslib-dev \
        xplanet xplanet-images

RUN apt-get -y --no-install-recommends install wget apt sudo
RUN sed -i 's|^%sudo.*$|%sudo ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/dpkg|' /etc/sudoers
RUN useradd -m jenkins --groups sudo
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
