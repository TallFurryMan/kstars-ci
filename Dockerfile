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
        zlib1g-dev:i386 libsecret-1-dev:i386 linux-libc-dev-i386-cross libcurl-dev:i386
RUN apt-get -y --no-install-recommends install \
        libeigen3-dev:i386 libcfitsio-dev:i386 libnova-dev:i386 libgsl-dev:i386 libraw-dev:i386 wcslib-dev:i386 \
        libindi-dev:i386 xplanet xplanet-images

RUN useradd -m jenkins
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
