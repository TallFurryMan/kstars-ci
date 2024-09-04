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
        zlib1g-dev:i386 libsecret-1-dev:i386 linux-libc-dev-i386-cross \
        libcurl4-openssl-dev:i386 libwxgtk3.0-dev:i386 wx-common:i386 wx3.0-i18n:i386
RUN apt-get -y --no-install-recommends install \
        libeigen3-dev:i386 libcfitsio-dev:i386 libnova-dev:i386 libgsl-dev:i386 libraw-dev:i386 wcslib-dev:i386 \
        libindi-dev:i386 xplanet xplanet-images

RUN apt-get remove -y --purge --auto-remove cmake && \
    apt-get -y update && apt-get -y --no-install-recommends install software-properties-common lsb-release && \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" && \
    apt-get -y update && apt-get -y install kitware-archive-keyring && rm /etc/apt/trusted.gpg.d/kitware.gpg && \
    apt-get -y update && apt-get -y --no-install-recommends install cmake

RUN useradd -m jenkins
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
