FROM ubuntu:18.04

RUN dpkg --add-architecture armhf
RUN apt-get -y update ; apt-get -y upgrade
RUN apt-get -y --no-install-recommends install \
        gcc-multilib g++-multilib
RUN apt-get -y --no-install-recommends install \
        cmake extra-cmake-modules
RUN apt-get -y --no-install-recommends install \
        git dpkg-dev default-jre ccache gettext breeze-icon-theme
RUN apt-get -y --no-install-recommends install \
        zlib1g-dev:armhf libsecret-1-dev:armhf
RUN apt-get -y install \
        qtdeclarative5-dev:armhf libqt5svg5-dev:armhf libqt5websockets5-dev:armhf
RUN apt-get -y install \
        libkf5plotting-dev:armhf libkf5xmlgui-dev:armhf libkf5newstuff-dev:armhf \
        libkf5notifications-dev:armhf libkf5crash-dev:armhf libkf5notifyconfig-dev:armhf \
        kio-dev:i386 kinit-dev:armhf kdoctools-dev:armhf
RUN apt-get -y --no-install-recommends install \
        libeigen3-dev:armhf libcfitsio-dev:armhf libnova-dev:armhf libgsl-dev:armhf libraw-dev:armhf wcslib-dev:armhf \
        libindi-dev:armhf xplanet xplanet-images
RUN apt-get -y --no-install-recommends install \
        libkf5config-bin:armhf

RUN useradd -m jenkins
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
