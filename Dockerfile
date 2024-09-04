FROM ubuntu:22.04

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        gcc-multilib g++-multilib
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        git dpkg-dev default-jre ccache gettext breeze-icon-theme
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        zlib1g-dev libsecret-1-dev \
        libcurl4-openssl-dev libwxgtk3.0-gtk3-dev wx-common wx3.0-i18n
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        libeigen3-dev libcfitsio-dev libnova-dev libgsl-dev libraw-dev wcslib-dev \
        xplanet xplanet-images libopencv-dev

RUN apt-get -y update && apt-get -y --no-install-recommends install wget apt sudo
RUN sed -i 's|^%sudo.*$|%sudo ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/dpkg|' /etc/sudoers
RUN useradd -m jenkins --groups sudo
RUN /usr/sbin/update-ccache-symlinks

RUN apt-get -y update && apt-get -y --no-install-recommends install software-properties-common lsb-release && \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" && \
    apt-get -y update && apt-get -y install kitware-archive-keyring && rm /etc/apt/trusted.gpg.d/kitware.gpg && \
    apt-get -y update && apt-get -y --no-install-recommends install cmake extra-cmake-modules

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
