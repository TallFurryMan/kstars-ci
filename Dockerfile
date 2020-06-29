FROM ubuntu:18.04

RUN dpkg --add-architecture i386
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y --no-install-recommends install \
        gcc-multilib g++-multilib
RUN apt-get -y --no-install-recommends install \
        cmake extra-cmake-modules
RUN apt-get -y --no-install-recommends install \
        git dpkg-dev default-jre ccache gettext breeze-icon-theme
RUN apt-get -y --no-install-recommends install \
        zlib1g-dev:i386 libsecret-1-dev:i386
RUN apt-get -y install \
        qtdeclarative5-dev:i386 libqt5svg5-dev:i386 libqt5websockets5-dev:i386 qt5keychain-dev:i386
RUN apt-get -y install \
        libkf5plotting-dev:i386 libkf5xmlgui-dev:i386 libkf5newstuff-dev:i386 \
        libkf5notifications-dev:i386 libkf5crash-dev:i386 libkf5notifyconfig-dev:i386 \
        kio-dev:i386 kinit-dev:i386 kdoctools-dev:i386
RUN apt-get -y --no-install-recommends install \
        libeigen3-dev:i386 libcfitsio-dev:i386 libnova-dev:i386 libgsl-dev:i386 libraw-dev:i386 wcslib-dev:i386 \
        libindi-dev:i386 xplanet xplanet-images
RUN apt-get -y --no-install-recommends install \
        libkf5config-bin:i386

RUN useradd -m jenkins
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN echo "export PATH=/usr/lib/ccache:$PATH" >> /etc/profile
RUN date | tee /home/jenkins/built_on
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
