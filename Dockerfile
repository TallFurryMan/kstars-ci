FROM ubuntu:20.04

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y --no-install-recommends install \
        gcc-multilib g++-multilib
RUN apt-get -y --no-install-recommends install \
        cmake extra-cmake-modules
RUN apt update && apt-get -y --no-install-recommends install \
        git dpkg-dev default-jre ccache qt5-default libcfitsio-dev \
        libgsl-dev pkg-config wcslib-dev

RUN apt-get -y --no-install-recommends install wget apt sudo
RUN sed -i 's|^%sudo.*$|%sudo ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/dpkg|' /etc/sudoers
RUN useradd -m jenkins --groups sudo
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
