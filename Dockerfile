FROM ubuntu:24.04

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        gcc-multilib g++-multilib
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        cmake extra-cmake-modules
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        git dpkg-dev default-jre ccache gettext breeze-icon-theme
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        zlib1g-dev libsecret-1-dev
RUN apt-get -y update && apt-get -y install \
        qtdeclarative5-dev libqt5svg5-dev libqt5websockets5-dev
RUN apt-get -y update && apt-get -y install \
        libkf5plotting-dev libkf5xmlgui-dev libkf5newstuff-dev \
        libkf5notifications-dev libkf5crash-dev libkf5notifyconfig-dev \
        libkf5kio-dev kinit-dev libkf5doctools-dev libkf5config-bin
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        libeigen3-dev libcfitsio-dev libnova-dev libgsl-dev libraw-dev wcslib-dev \
        xplanet xplanet-images
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        qtmultimedia5-dev qtpositioning5-dev \
        libqt5sql5-sqlite libkf5guiaddons-dev libkf5i18n-dev \
        phonon4qt5-backend-vlc qt5keychain-dev \
        libqt5datavisualization5-dev qml-module-qtquick-controls
        
RUN apt-get -y update && apt-get -y --no-install-recommends install wget apt sudo
RUN echo 'jenkins ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/dpkg' > /etc/sudoers.d/50-jenkins
RUN useradd -m jenkins --groups sudo
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN sudo /usr/bin/dpkg --version
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
