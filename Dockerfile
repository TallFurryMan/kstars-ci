FROM ubuntu:18.04

RUN dpkg --add-architecture armhf
RUN arch=$(dpkg --print-architecture) && \
    sed -i \
        -e "s|^deb http://archive\(.*\)/ubuntu/\(.*\)$|deb [arch=$arch] http://archive\1/ubuntu/\2\ndeb [arch=armhf] http://ports\1/ubuntu-ports/\2|" \
        -e "s|^deb http://security\(.*\)/ubuntu/\(.*\)$|deb [arch=$arch] http://security\1/ubuntu/\2|" \
        /etc/apt/sources.list
RUN apt-get -y update && apt-get -y upgrade
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
RUN apt-get -y install libkf5plotting-dev:armhf
RUN apt-get -y install libkf5xmlgui-dev
RUN apt-get -y install libkf5newstuff-dev:armhf
RUN apt-get -y install libkf5notifications-dev:armhf
RUN apt-get -y install libkf5crash-dev:armhf
RUN apt-get -y install libkf5notifyconfig-dev:armhf
RUN apt-get -y install kio-dev:armhf
RUN apt-get -y install kinit-dev:armhf
RUN apt-get -y install kdoctools-dev
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
