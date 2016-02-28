#!/bin/bash -x

set -e

BOX=$1

if [ -z "$BOX" ]; then
    echo "Usage: $0 <compute-box-IP>"
    exit 0
fi

# Make sure only a user can run our script
if [ "$(id -u)" == "0" ]; then
    echo "This script MUST NOT be run as root" 1>&2
    exit 1
fi

SSHTOBOX="ssh -o BatchMode=yes -o StrictHostKeyChecking=no $BOX"

# Check that we can ssh and sudo onto the compute box
PUBKEY=$(cat ~/.ssh/id_rsa.pub)
$SSHTOBOX "grep -c '$PUBKEY' ~/.ssh/authorized_keys || echo '$PUBKEY' >> ~/.ssh/authorized_keys; sudo true"
if [ ! $? ]; then
    echo "This script MUST be able to ssh sudo to $BOX" 1>&2
    exit 1
fi
unset PUBKEY

# Install many more packages for a useful basic system (same as control box)
$SSHTOBOX 'bash' < ~/thrill-bench/setup/setup-root.sh

################################################################################
# Setup compute node as Ceph Storage Device

# these commands must be run on the control box
cd ~/ceph
ceph health

# install ceph packages on control box
ceph-deploy install $BOX

# find disks (all of them) and add them to ceph system
DISKS=$($SSHTOBOX ls /dev/xvd[b-z])
echo "Disks on compute node: $DISKS"

for disk in $DISKS; do
    ceph-deploy osd prepare --zap-disk $BOX:$disk
done

# copy admin files
ceph-deploy admin $BOX

for disk in $DISKS; do
    ceph-deploy osd activate $BOX:${disk}1
done

# mount ceph file system

LOCALIP=$(ifconfig eth0 | awk '/ inet addr:/ { print $2 }' | cut -d ':' -f 2)
ADMINKEY=$(awk '/key = / { print $3 }' ceph.client.admin.keyring)

$SSHTOBOX "sudo mkdir /ceph0"
$SSHTOBOX "sudo mount -t ceph $LOCALIP:6789:/ /ceph0 -o name=admin,secret=${ADMINKEY}"

################################################################################
# mount NFS on compute box (overrides /home)

$SSHTOBOX "sudo apt-get install -y nfs-common"
$SSHTOBOX "sudo mount $LOCALIP:/home /home"

################################################################################
# Save $BOX in ~/boxes.txt for running benchmarks

$SSHTOBOX "df"

grep -F "$BOX" -c ~/boxes.txt || echo "$BOX" >> ~/boxes.txt

################################################################################
exit 0
