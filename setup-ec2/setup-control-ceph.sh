#!/bin/bash -x

set -e

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

DIR=`dirname "$0"`

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
echo "osd pool default size = 1" >> ceph.conf

# install ceph packages on control box
ceph-deploy install --release ${CEPH_RELEASE} $(hostname)

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

################################################################################
