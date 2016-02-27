#!/bin/bash -x

set -e

ceph_release=infernalis

# Make sure only root can run our script
if [ "$(id -u)" == "0" ]; then
    echo "This script MUST NOT be run as root" 1>&2
    exit 1
fi

DIR=`dirname "$0"`

if false; then
# install ceph packages
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

echo "deb http://download.ceph.com/debian-${ceph_release}/ $(lsb_release -sc) main" \
     | sudo tee /etc/apt/sources.list.d/ceph.list

sudo apt-get update && sudo apt-get install -y ceph-deploy
fi

# test ssh connections to ceph servers

HOSTS=("ip-172-31-15-109.eu-west-1.compute.internal"
       "ip-172-31-4-6.eu-west-1.compute.internal")

for h in $HOSTS; do
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no $h true
done


ceph-deploy purge ${HOSTS[@]}
ceph-deploy purgedata ${HOSTS[@]}
ceph-deploy forgetkeys

################################################################################
### Setup Ceph Nodes

ceph-deploy new ${HOSTS[0]}

# one copy per block
echo "osd pool default size = 1" >> ceph.conf

ceph-deploy install ${HOSTS[@]}

ceph-deploy mon create-initial

ceph-deploy osd prepare --zap-disk ${HOSTS[0]}:/dev/xvdb
ceph-deploy osd prepare --zap-disk ${HOSTS[1]}:/dev/xvdb
ceph-deploy osd activate ${HOSTS[0]}:/dev/xvdb1
ceph-deploy osd activate ${HOSTS[1]}:/dev/xvdb1

ceph-deploy admin ${HOSTS[0]} ${HOSTS[@]}

sudo chmod +r /etc/ceph/ceph.client.admin.keyring

ceph health

################################################################################
### Setup Nodes as Ceph FS Clients

ceph-deploy mds create ${HOSTS[0]}

ceph osd pool create cephfs_data 128
ceph osd pool create cephfs_metadata 128

ceph fs new fs0 cephfs_metadata cephfs_data

sudo mkdir /ceph0
sudo mount -t ceph ${HOSTS[0]}:6789:/ /ceph0 -o name=admin,secret=AQDU8NFW2uhKAxAAGosvZaWW593FtFuBM1/dQQ==
