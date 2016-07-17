#!/bin/bash -x

set -e

################################################################################
# mount efs on control node, since we cannot do this without an OSD.

cd ~/ceph
ceph health

sudo mkdir /efs || true

LOCALIP=$(ifconfig eth0 | awk '/ inet addr:/ { print $2 }' | cut -d ':' -f 2)
ADMINKEY=$(awk '/key = / { print $3 }' ceph.client.admin.keyring)

sudo mount -t ceph $LOCALIP:6789:/ /efs -o name=admin,secret=${ADMINKEY}
sudo chmod a+w /efs

################################################################################
