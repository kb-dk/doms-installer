#!/usr/bin/env bash

#https://samindaw.wordpress.com/2012/03/21/mounting-a-file-as-a-file-system-in-linux/

SCRIPT_DIR=$(dirname $(readlink -f $BASH_SOURCE[0]))
DISK_NR=$1
SIZE=$2

#TODO fail if params 1 and 2 are not set...

set -x
set -e

IMG=$SCRIPT_DIR/disk_$DISK_NR
MOUNT=/mnt/local-storage/hdd/disk_$DISK_NR

#Umount if already mounted
mount | grep ${MOUNT} && umount ${MOUNT}

#Detach if already detached
losetup --associated $IMG | cut -d':' -f1 | xargs -r -I'{}' losetup --detach '{}'

# Create a X M file as the file_system
dd if=/dev/zero of=$IMG bs=1M count=$SIZE

DEV=$(losetup --find --show $IMG)

mkfs -t ext4 -m 1 -v $DEV

mkdir -p $MOUNT
mount -t ext4 $DEV $MOUNT


#Steps are curtasy of http://www.walkernews.net/2007/07/01/create-linux-loopback-file-system-on-disk-file/