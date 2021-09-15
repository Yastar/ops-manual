#!/bin/bash

iptables -P FORWARD ACCEPT

swapoff -a
sed -i '/swap/s/^\(.*\)/#\1/g' /etc/fstab

sed -i '7s/\(SELINUX=\).*/\1disabled/g' /etc/selinux/config
setenforece 0
systemctl disable firewalld && systemctl stop firewalld

cat <<EOF > /etc/sysctl.d/docker.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward=1
vm.max_map_count=262144
EOF

sed -i "14s/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g" /etc/sysctl.conf
modprobe br_netfilter
sysctl -p /etc/sysctl.d/docker.conf

curl -o /etc/yum.repos.d/Centos-7.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum clean all && yum makecache
yum install docker-ce -y

mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{ 
    "registry-mirrors" : ["https://8xpk5wnt.mirror.aliyuncs.com"],
    "graph" : "/data/docker/"
}
EOF

systemctl enable docker
systemctl daemon-reload

sleep 1
systemctl start docker

yum install -y kubelet-1.19.8 kubeadm-1.19.8 kubectl-1.19.8 --disableexcludes=kubernetes

sleep 1
systemctl enable kubelet