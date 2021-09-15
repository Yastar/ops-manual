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

/sbin/mkfs.xfs ${new_disk_path}1

if [ $? = 0 ];then
    echo "finished"
fi

mkdir -p /data

sleep 1s

new_disk_uuid=` blkid ${new_disk_path}1 | awk '{print$2}' `

echo "${new_disk_uuid} /data    xfs    defaults    0 0" >> /etc/fstab

sleep 1s

mount -a

mount | grep ${new_disk_path}1
if [ $? = 0 ];then
    echo "add new disk successful"
else
    echo "add disk failed"
fi