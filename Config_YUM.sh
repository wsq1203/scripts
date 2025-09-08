#!/bin/bash

. /etc/os-release

color () {

        RES_COL=50
        MOVE_TO_COL="echo -en \\033[${RES_COL}G"
        SETCOLOR_SUCCESS="echo -en \\033[1;32m"
        SETCOLOR_FAILURE="echo -en \\033[1;31m"
        SETCOLOR_WARNING="echo -en \\033[1;33m"
        SETCOLOR_NORMAL="echo -en \E[0m"

        echo -n "${1}" && ${MOVE_TO_COL}
        echo -n "["
        if [ ${2} = "success" -o ${2} = "0" ];then
                ${SETCOLOR_SUCCESS}
                echo -n $"  OK  "
        elif [ ${2} = "failure" -o ${2} = "1" ];then
                ${SETCOLOR_FAILURE}
                echo -n $"FAILED"
        else
                ${SETCOLOR_WARNING}
                echo -n $"WARNING"
        fi
        ${SETCOLOR_NORMAL}
        echo -n "]"
        echo

}

config_yum () {
    
    if [ ${ID} = centos ];then
        mv /etc/yum.repos.d/* /mnt/
        echo '[base]
name=CentOS
baseurl=https://mirror.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/
        https://mirrors.huaweicloud.com/centos/$releasever/os/$basearch/
        https://mirrors.cloud.tencent.com/centos/$releasever/os/$basearch/
        https://mirrors.aliyun.com/centos/$releasever/os/$basearch/
        https://mirrors.163.com/centos/$releasever/os/$basearch/
gpgcheck=0

[extras]
name=extras
baseurl=https://mirror.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/
        https://mirrors.huaweicloud.com/centos/$releasever/extras/$basearch/
        https://mirrors.cloud.tencent.com/centos/$releasever/extras/$basearch/
        https://mirrors.aliyun.com/centos/$releasever/extras/$basearch/
        https://mirrors.163.com/centos/$releasever/extras/$basearch/       
gpgcheck=0
enabled=1

[epel]
name=EPEL
baseurl=https://mirror.tuna.tsinghua.edu.cn/epel/$releasever/$basearch/
        https://mirrors.cloud.tencent.com/epel/$releasever/$basearch/
        https://mirrors.huaweicloud.com/epel/$releasever/$basearch/ 
        https://mirrors.aliyun.com/epel/$releasever/$basearch/
        http://mirrors.163.com/epel/$releasever/extras/$basearch/
gpgcheck=0
enabled=1 ' > /etc/yum.repos.d/centos.repo
        yum -y install sshpass bash-completion lrzsz  tree  wget tcpdump tar zip
        yum -y install rsync vim lsof gcc make gcc-c++ glibc glibc-devel unzip
        yum -y install pcre pcre-devel openssl openssl-devel systemd-devel
        yum -y install zlib-devel tmux tcpdump net-tools bc chrony
    elif [ ${ID} = rocky ];then
        mv /etc/yum.repos.d/* /mnt/
        echo '[BaseOS]
name=BaseOS
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/$basearch/os/
        https://mirrors.163.com/rocky/$releasever/BaseOS/$basearch/os/
        https://mirrors.tuna.tsinghua.edu.cn/rocky/$releasever/BaseOS/$basearch/os/
        https://mirrors.tencent.com/rocky/$releasever/BaseOS/$basearch/os/
        https://mirrors.huaweicloud.com/rocky/$releasever/BaseOS/$basearch/os/
        
gpgcheck=0

[AppStream]
name=AppStream
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/AppStream/$basearch/os/
        https://mirrors.163.com/rocky/$releasever/AppStream/$basearch/os/
        https://mirrors.tuna.tsinghua.edu.cn/rocky/$releasever/AppStream/$basearch/os/
        https://mirrors.tencent.com/rocky/$releasever/AppStream/$basearch/os/
        https://mirrors.huaweicloud.com/rocky/$releasever/AppStream/$basearch/os/
gpgcheck=0

[extras]
name=extras
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/extras/$basearch/os/
        https://mirrors.163.com/rocky/$releasever/extras/$basearch/os/
        https://mirrors.tuna.tsinghua.edu.cn/rocky/$releasever/extras/$basearch/os/
        https://mirrors.tencent.com/rocky/$releasever/extras/$basearch/os/
        https://mirrors.huaweicloud.com/rocky/$releasever/extras/$basearch/os/
gpgcheck=0
enabled=1

[PowerTools]
name=CentOS-$releasever - PowerTools
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/PowerTools/$basearch/os/
        https://mirrors.163.com/rocky/$releasever/PowerTools/$basearch/os/
        https://mirrors.tuna.tsinghua.edu.cn/rocky/$releasever/PowerTools/$basearch/os/
        https://mirrors.tencent.com/rocky/$releasever/PowerTools/$basearch/os/
        https://mirrors.huaweicloud.com/rocky/$releasever/PowerTools/$basearch/os/ 
gpgcheck=0
enabled=0

[epel]
name=EPEL
baseurl=https://mirror.tuna.tsinghua.edu.cn/epel/$releasever/Everything/$basearch/
        https://mirrors.cloud.tencent.com/epel/$releasever/Everything/$basearch/
        https://mirrors.huaweicloud.com/epel/$releasever/Everything/$basearch/
        https://mirrors.aliyun.com/epel/$releasever/Everything/$basearch/
        https://mirrors.163.com/epel/$releasever/Everything/$basearch/
gpgcheck=0
enabled=1' > /etc/yum.repos.d/Rocky.repo
        yum -y -q install sshpass bash-completion lrzsz  tree  wget tcpdump tar
        yum -y -q install rsync vim lsof gcc make gcc-c++ glibc glibc-devel unzip
        yum -y -q install pcre pcre-devel openssl openssl-devel systemd-devel
        yum -y -q install zlib-devel tmux tcpdump net-tools bc chrony zip
    elif [ ${ID} = ubuntu ];then
        mv /etc/apt/sources.list /mnt/
        echo "
deb https://mirrors.aliyun.com/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse

deb https://mirrors.163.com/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse
deb https://mirrors.163.com/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse
deb https://mirrors.163.com/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse
deb https://mirrors.163.com/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse
" > /etc/apt/sources.list
        apt update
        apt -y install sshpass bash-completion lrzsz  tree tar zip unzip
        apt -y install wget tcpdump rsync vim lsof gcc make g++ glibc
        apt -y install libc6-dev libpcre3 libpcre3-dev openssl libssl-dev
        apt -y install libsystemd-dev zlib1g-dev tmux tcpdump net-tools bc chrony
    else
        color "请手动配置yum源" 3
        exit
    fi
    color "镜像源配置完成" 0

}

config_yum