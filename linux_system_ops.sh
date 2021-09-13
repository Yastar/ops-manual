#!/bin/bash

function update_system() {
    if [ -n $(cat /etc/redhat-release | grep CentOS | wc -l) ];then
        yum update -y
    elif [ `cat /etc/lsb-release | grep Ubuntu | wc -l` -eq 2 ];then
        apt update -y
        apt upgrade -y
    elif [ -n $(cat /etc/SuSE-release | grep openSUSE | wc -l) ];then
        apt update -y
    else
        echo "no system support"
        exit 1
    fi
}

#centos 
function off_selinux() {
    sed -i "7s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
}

function off_firewalld() {
    systemctl stop firewalld
    sleep 1
    systemctl disable firewalld > /dev/null 2>&1
}

function off_iptables() {
    iptables -F     #clean all list
}

function off_swap() {
    swapoff /mnt/swap > /dev/null 2>&1
    echo "vm.swappines = 0" >> /etc/sysctl.conf
    sysctl -p > /dev/null 2>&1
    sed -i "s/^\/mnt\/swap/#\/mnt\/swap/g" /etc/fstab
}

function add_user() {
    if [ id -u opsadmin > /dev/null 2>&1 ];then
        echo "add user exist"
    else
        useradd opsadmin -m -s /bin/bash -d /home/opsadmin
        sleep1
        echo "test1234" | passwd --stdin opsadmin > /dev/null 2>&1
        echo "add user success"
    fi
}

function add_sudoers() {
    if [ `tail -1 /etc/sudoers | grep opsadmin | wc -l` -eq 1 && `visudo -c | grep OK | wc -l` -eq 1  ];then
        echo "add sudo user exist"
    else
        cp /etc/sudoer{,.bak}
        echo "opsadmin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
        echo "add sudo user success"
    fi
}

function add_profile() {
    echo 'HISTTIMEFORMAT="%F %T `whoami`"' >> /etc/profile
    echo "exprot TMOUT=60000" >> /etc/profile
    echo "HISTSIZE=100" >> /etc/profile
    echo "HISTFILESIZE" >> /etc/profile
}

function add_ntp() {
    if [ -z $(rpm -qa | grep ntp | wc -l) ];then
        yum install ntp -y
        systemctl start ntpd
        systemctl enable ntpd
    else
        echo "ntpd exist"
        exit 1
}

function add_loginfailed_lock() {
    echo "auth required pam_tally2.so deny=5 unlock_time=1800 even_deny_root root_unlock_time=1800" >> /etc/pam.d/system-auth
}

function change_passwd_rule() {
    sed -i "s/use_authtok/use_authtok remeber=5/" /etc/pam.d/system-auth
}

function change_timezone() {
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    hwclock
}

function change_repo() {
    tar -zcvf yum.bak.tar.gz /etc/yum.repos.d/* > /dev/null 2>&1
    rm -rf /etc/yum.repos.d/*.repos

    [local]
    name=local
    baseurl=file:///yum
    enabled=1
    gpgcheck=0
}

function clean_mail_cron() {
    echo "*/30 * * * * `find /var/spool/clientmqueue/ -type f -mtime +30 | xargs rm -f` > /dev/null 2>&1" >> /var/spool/cron/root
}

function change_limit_conf() {
    echo "root soft nofile 65535" >> /etc/security/limits.conf
    echo "root hard nofile 65535" >> /etc/security/limits.conf
}