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
        git dpkg-dev default-jre-headless ccache gettext breeze-icon-theme && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        zlib1g-dev libsecret-1-dev \
        libcurl4-openssl-dev libwxgtk3.0-gtk3-dev wx-common wx3.0-i18n && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        libeigen3-dev libcfitsio-dev libnova-dev libgsl-dev libraw-dev wcslib-dev \
        libindi-dev xplanet xplanet-images && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install wget apt sudo && \
    apt-get clean

RUN echo 'jenkins ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/dpkg' > /etc/sudoers.d/50-jenkins
RUN useradd -m jenkins --groups sudo
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN sudo /usr/bin/make --version
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
