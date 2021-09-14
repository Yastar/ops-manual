#!/bin/bash

if [ `lsscsi | wc -l` -eq 1 ];then
    echo "no new disk"
else
    new_disk_path=` lsscsi | awk '{print$8}' | tail -n 1 `
fi

