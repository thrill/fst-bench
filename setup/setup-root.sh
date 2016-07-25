#!/bin/bash -x

set -e

# Make sure only a user can run our script
if [ "$(id -u)" == "0" ]; then
    echo "This script MUST NOT be run as root" 1>&2
    exit 1
fi

# Check that we can sudo
sudo true
if [ ! $? ]; then
    echo "This script MUST be also to sudo" 1>&2
    exit 1
fi

DIR=`dirname "$0"`

export PYTHON_VERSION=2.7
export JDK_VERSION=8

################################################################################
# Install lots of packages for a basic compilation environment

# enable multiverse repositories
sudo sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list

# system upgrade
sudo apt-get update
sudo apt-get -y dist-upgrade
sudo apt-get install -y build-essential
sudo apt-get install -y software-properties-common
sudo apt-get install -y wget curl man unzip vim-tiny bc git
sudo apt-get install -y bmon gdb htop parallel mc xfsprogs ncdu

# ntpd
sudo apt-get install -y ntp

# compilers and basic tools
sudo apt-get install -y make gcc cmake cmake-curses-gui global

# python
sudo apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-dev

# pip
sudo apt-get install -y python-pip

# install numpy and matplotlib
sudo apt-get install -y --force-yes python-numpy python-matplotlib

# Java 8 from webupd8team/java PPA
echo oracle-java${JDK_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | \
    sudo debconf-set-selections

sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo apt-get install -y oracle-java${JDK_VERSION}-installer
sudo rm -rf /var/cache/oracle-jdk${JDK_VERSION}-installer

# g++-5 or newer from ubuntu-toolchain-r/test PPA
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install -y g++-5

# install newer git from ppa:git-core/candidate PPA
sudo add-apt-repository -y ppa:git-core/candidate
sudo apt-get update
sudo apt-get install -y git
sudo apt-get -y dist-upgrade

# remove docker.io which is on some of the Ubuntu images by default
sudo dpkg -P docker.io || true

# cleanup
sudo apt-get clean

exit 0
