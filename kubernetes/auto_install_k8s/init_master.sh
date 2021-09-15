#!/bin/bash

#抓取主机信息
local_ip=`hostname -I | awk '{print$1}'`
local_interface_name=`ip addr | grep '^[0-9]' | egrep 'ens|eth' | awk -F':' '{print$2}' | sed 's/^ //g'`
init_file="/opt/kubeadm.yaml"

#初始化配置文件、下载镜像
kubeadm config print init-defaults > ${init_file}
sed -i "12s/1.2.3.4/${local_ip}/g" ${init_file}
sed -i "32s/k8s.gcr.io/registry.aliyuncs.com\/google_containers/g" ${init_file}
sed -i "36a\  podSubnet: 10.244.0.0/16" ${init_file}
kubeadm config images pull --config ${init_file}

#初始化master节点、配置kubectl
sleep 1s
kubeadm init --config /opt/kubeadm.yaml >> /opt/kubeadm_init.out
sleep 5s
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

#安装flannel插件
sed -i "188a\        - --iface=${local_interface_name}" /opt/kube-flannel.yml
docker pull quay.io/coreos/flannel:v0.14.0-amd64
kubectl apply -f /opt/kube-flannel.yml

#设置master节点是否可调度
kubectl taint node `hostname` node-role.kubernetes.io/master:NoSchedule-

#设置kubectl自动补全
yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc