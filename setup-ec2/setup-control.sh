#!/bin/bash -x

set -e

export PYTHON_VERSION=2.7
export JDK_VERSION=8
export CEPH_RELEASE=infernalis

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

################################################################################
# Clone thrill-bench on the control box

sudo apt-get update
sudo apt-get install -y git

cd ~
[ -e thrill-bench ] || git clone https://github.com/thrill/thrill-bench.git

cd ~/thrill-bench/setup/

# Install many more packages for a useful basic system
./setup-root.sh

# Install Spark and Flink on the control box's NFS
./setup-user.sh

################################################################################
# Generate ssh key to log into compute boxes

ssh-keygen -f ~/.ssh/id_rsa -t rsa -b 2048 -N ''

################################################################################
# Setup control box as NFS server

sudo apt-get install -y nfs-kernel-server ipcalc
LOCALIP=$(ifconfig eth0 | awk '/ inet addr:/ { print $2 }' | cut -d ':' -f 2)
LOCALMASK=$(ifconfig eth0 | awk '/ Mask:/ { print $4 }' | cut -d ':' -f 2)
LOCALCIDR=$(ipcalc $LOCALIP $LOCALMASK | awk '/Network: / { print $2 }')
sudo sed -ie '/\/home/d' /etc/exports
echo "/home   $LOCALCIDR(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -av
sudo service nfs-kernel-server start

################################################################################
# Build Thrill on the control box

cd ~
[ -e thrill ] || git clone https://github.com/thrill/thrill.git

cd ~/thrill
[ -e build ] || ./compile.sh -DCMAKE_BUILD_TYPE=Release

################################################################################
# Install ceph's Cluster Monitor and MDS on the control box

# install ceph packages
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

echo "deb http://download.ceph.com/debian-${CEPH_RELEASE}/ $(lsb_release -sc) main" \
     | sudo tee /etc/apt/sources.list.d/ceph.list

sudo apt-get update && sudo apt-get install -y ceph-deploy

# move into ceph-deploy configuration directory
cd ~
mkdir ceph || true
cd ceph

# start new ceph configuration
ceph-deploy new $(hostname)

# one copy per block
echo "osd pool default size = 2" >> ceph.conf

# install ceph packages on control box
ceph-deploy install $(hostname)

# create monitor instance
ceph-deploy mon create-initial

# install ceph admin config on localhost
ceph-deploy admin $(hostname)
sudo chmod +r /etc/ceph/ceph.client.admin.keyring

# check health
ceph health

# install MDS server and create FS

ceph-deploy mds create $(hostname)

ceph osd pool create cephfs_data 32
ceph osd pool create cephfs_metadata 32

ceph fs new fs0 cephfs_metadata cephfs_data

# mount
echo "Cannot mount /ceph0 immediately, add a compute node first."

################################################################################
