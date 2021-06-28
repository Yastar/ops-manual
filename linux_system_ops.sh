#!/bin/bash

#update system
if [ `cat /etc/redhat-release | grep CentOS | wc -l` -eq 1  ];then
    yum update  
elif [ `cat /etc/lsb-release | grep Ubuntu | wc -l` -eq 2 ];then
    apt update
    apt upgrade
elif [ `cat /etc/SuSE-release | grep openSUSE | wc -l` -eq 1 ];then
    apt update
else
    echo "no system support"
    exit 1
fi

#centos 
#set off selinux
sed -i "7s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

#set off firewalld
systemctl stop firewalld
systemctl disable firewalld > /dev/null 2>&1

#set off iptable

#add user
useradd opsadmin
echo "test@lfj2021" | passwd --stdin opsadmin > /dev/null 2>&1
if [ id -u opsadmin > /dev/null 2>&1 ];then
    echo "add user suceess"
else   
    echo "add user error"
fi

#add sudo user
cp /etc/sudoer{,.bak}
echo "opsadmin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
if [ `tail -1 /etc/sudoers | grep opsadmin | wc -l` -eq 1 && `visudo -c | grep OK | wc -l` -eq 1  ];then
    echo "add sudo user success."
else
    echo "add sudo user error"

