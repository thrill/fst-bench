#!/bin/bash -x

set -e

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

DIR=`dirname "$0"`

source $DIR/user-env.sh

# install basic build environment
sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list
apt-get update
apt-get -y upgrade
apt-get install -y build-essential
apt-get install -y software-properties-common
apt-get install -y git wget curl man unzip vim-tiny bc

# compilers and basic tools
apt-get install -y make gcc

# python
apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-dev

# pip
apt-get install -y python-pip

# install numpy and matplotlib
apt-get install -y --force-yes python-numpy python-matplotlib

# Install Java

echo oracle-java${JDK_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

add-apt-repository -y ppa:webupd8team/java
apt-get update
apt-get install -y oracle-java${JDK_VERSION}-installer
rm -rf /var/cache/oracle-jdk${JDK_VERSION}-installer

# cleanup
apt-get clean
rm -rf /var/lib/apt/lists/*
