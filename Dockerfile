FROM ubuntu:24.04

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        flatpak flatpak-builder ca-certificates \
        ostree libfuse2 elfutils git bzr \
        wget apt sudo curl libcurl4-openssl-dev ccache dbus

RUN userdel --remove ubuntu && groupadd --gid 1000 jenkins && useradd --uid 1000 --gid 1000 --create-home --groups sudo jenkins
RUN echo 'jenkins ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/dpkg' > /etc/sudoers.d/50-jenkins
RUN /usr/sbin/update-ccache-symlinks

USER jenkins
RUN date | tee /home/jenkins/built_on
RUN sudo /usr/bin/dpkg --version
RUN mkdir /home/jenkins/workspace /home/jenkins/.ccache
WORKDIR /home/jenkins
CMD id
