#!/bin/bash -x

set -e

export PYTHON_VERSION=2.7
export JDK_VERSION=8
export CEPH_RELEASE=jewel
#export CEPH_RELEASE=

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

pushd `dirname $0` > /dev/null
DIR=`pwd`
popd > /dev/null

################################################################################
# Clone fst-bench on the control box

sudo apt-get update
sudo apt-get install -y git

cd ~
[ -e fst-bench ] || git clone https://github.com/thrill/fst-bench.git

cd ~/fst-bench/setup/

# Install many more packages for a useful basic system
./setup-root.sh

# Install Spark and Flink on the control box's NFS
./setup-user.sh

################################################################################
# Generate ssh key to log into compute boxes

ssh-keygen -f ~/.ssh/id_rsa -t rsa -b 2048 -N ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config

################################################################################
# Setup control box as NFS server

sudo apt-get install -y nfs-kernel-server ipcalc
LOCALIP=$(ifconfig ens3 | awk '/ inet addr:/ { print $2 }' | cut -d ':' -f 2)
LOCALMASK=$(ifconfig ens3 | awk '/ Mask:/ { print $4 }' | cut -d ':' -f 2)
LOCALCIDR=$(ipcalc $LOCALIP $LOCALMASK | awk '/Network: / { print $2 }')
sudo sed -ie '/\/home/d' /etc/exports
echo "/home   $LOCALCIDR(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
sudo exportfs -av
sudo service nfs-kernel-server start

################################################################################
# Install ceph's Cluster Monitor and MDS on the control box

[ "$CEPH_RELEASE" != "" ] && $DIR/setup-control-ceph.sh

################################################################################
# setup environment hook

echo "source ~/fst-bench/setup/env.sh" >> ~/.bashrc
echo "export WORK=/efs" >> ~/.bashrc

################################################################################
# Build Thrill on the control box

cd ~
[ -e thrill ] || git clone https://github.com/thrill/thrill.git

cd ~/thrill
[ -e build ] || ./compile.sh -DCMAKE_BUILD_TYPE=Release

################################################################################
# Build HiBench java things on the control box

sudo dpkg -P maven maven2 maven3
sudo apt-add-repository -y ppa:andrei-pozolotin/maven3
sudo apt-get update
sudo apt-get install -y maven3

cd ~/fst-bench/src/
mvn package

mkdir -p ~/fst-bench/report/spark-eventlog/

################################################################################

# messages
echo "Cannot mount /efs immediately, add a compute node first."

################################################################################
