FROM ubuntu:20.04

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        gcc-multilib g++-multilib
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        cmake extra-cmake-modules
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        git dpkg-dev default-jre ccache gettext breeze-icon-theme
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        zlib1g-dev libsecret-1-dev \
        libcurl4-openssl-dev libwxgtk3.0-gtk3-dev wx-common wx3.0-i18n
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        libeigen3-dev libcfitsio-dev libnova-dev libgsl-dev libraw-dev wcslib-dev \
        libindi-dev xplanet xplanet-images

RUN useradd -m jenkins
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
