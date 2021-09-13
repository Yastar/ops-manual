# 配置系统
cat <<EOF > /etc/sysctl.d/docker.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p /etc/sysctl.d/docker.conf

# 配置docker源
curl -o /etc/yum.repos.d/Centos-7.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 创建缓存
yum clean all && yum makecache

# 查看源中可用版本
$ yum list docker-ce --showduplicates | sort -r

# 安装docker
yum install docker-ce -y

# 配置源加速
mkdir -p /etc/docker
vi /etc/docker/daemon.json
{
    "registry-mirrors" : [
        "https://8xpk5wnt.mirror.aliyuncs.com"
    ]
}

# 设置开机自启
systemctl enable docker
systemctl daemon-reload
systemctl start docker


-----------------------------------------------------------------

# 查看docker信息
docker info
# docker-client
which docker
# docker daemon
ps aux | grep docker
# containerd
ps aux | grep containerd
systemctl status containerd
# 查看镜像
docker images
# 获取镜像
## 从远程仓库拉取
docker pull nginx:alpine
docker images
## 使用tag命令
docker tag nginx:alpine 172.21.51.143:5000/nginx:alpine
docker images
## 本地构建
docker build . -t my-nginx:ubuntu -f Dockerfile
# 启动容器
docker run --name my-nginx-alpine -d nginx:alpine
# 进入容器内部
docker exec -it my-nginx-alpine /bin/sh
# 