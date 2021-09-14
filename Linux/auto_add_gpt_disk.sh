#!/bin/bash

if [ `lsscsi | wc -l` -eq 1 ];then
    echo "no new disk"
else
    new_disk_path=` lsscsi | awk '{print$8}' | tail -n 1 `
fi

/sbin/parted ${new_disk_path} <<ESXU
    mklabel gpt
    mkpart primary 0 -1
    ignore
    quit
ESXU

sleep 3s

/sbin/mkfs.ext4 ${new_disk_path}1

if [ $? = 0 ];then
    echo "finished"

/sbin/blkid ${new_disk_path}1

sleep 1s