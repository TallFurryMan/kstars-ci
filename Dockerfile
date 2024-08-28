FROM ubuntu:24.04

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        gcc-multilib g++-multilib && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        cmake extra-cmake-modules && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        git dpkg-dev default-jre-headless ccache gettext && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        zlib1g-dev libsecret-1-dev libcurl4-openssl-dev && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        libeigen3-dev libcfitsio-dev libnova-dev libgsl-dev libraw-dev wcslib-dev libev-dev \
        libusb-1.0.0-dev libgsl-dev libjpeg-dev libtiff-dev libfftw3-dev libftdi1-dev && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev libswscale-dev && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        libgphoto2-dev libzmq3-dev && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install wget apt sudo && \
    apt-get clean

RUN userdel --remove ubuntu && groupadd --gid 1000 jenkins && useradd --uid 1000 --gid 1000 --create-home --groups sudo jenkins
RUN echo 'jenkins ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/make' > /etc/sudoers.d/50-jenkins
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN sudo /usr/bin/make --version
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
