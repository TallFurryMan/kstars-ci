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
        git dpkg-dev default-jre-headless ccache gettext breeze-icon-theme && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        zlib1g-dev libsecret-1-dev \
        libcurl4-openssl-dev libwxgtk3.2-dev wx-common wx3.2-i18n && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        libeigen3-dev libcfitsio-dev libnova-dev libgsl-dev libraw-dev wcslib-dev \
        libindi-dev xplanet xplanet-images libopencv-dev && \
    apt-get clean
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install wget apt sudo && \
    apt-get clean

RUN userdel --remove ubuntu && groupadd --gid 1000 jenkins && useradd --uid 1000 --gid 1000 --create-home --groups sudo jenkins
RUN echo 'jenkins ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/dpkg' > /etc/sudoers.d/50-jenkins
RUN /usr/sbin/update-ccache-symlinks

RUN apt-get -y update && apt-get -y --no-install-recommends install software-properties-common lsb-release && \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" && \
    apt-get -y update && apt-get -y install kitware-archive-keyring && rm /etc/apt/trusted.gpg.d/kitware.gpg && \
    apt-get -y update && apt-get -y --no-install-recommends install cmake extra-cmake-modules

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN sudo /usr/bin/dpkg --version
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
