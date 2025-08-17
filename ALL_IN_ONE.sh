#!/bin/bash

#********************************************************************
#Author:            wangshuaiqing
#Date:              2025-05-21
#Version:           2.0
#FileName:          wsq.sh
#URL:               http://wshuaiqing.cn
#Description:       Automate the installation of software script
#********************************************************************

. /etc/os-release

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
SRC_DIR="/usr/local/src"
HOST=`hostname -I|awk '{print $1}'`
RED="\E[1;31m"
GREEN="echo -e \E[1;32m"
END="\E[0m"

Gmenu () {
    tinge=$[RANDOM%7+31]
    echo -e "\E[1;$[RANDOM%7+31]m+----------------------------------------------------------------+\E[0m"
    echo -e "\E[1;$[RANDOM%7+31]m| +------------------------------------------------------------+ |\E[0m"
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 \E[1;$[RANDOM%7+31]m查看系统信息\E[0m___________（\E[1;$[RANDOM%7+31]m1\E[0m）               \E[1;$[RANDOM%7+31]m| |\E[0m        "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 \E[1;$[RANDOM%7+31]m配置系统操作\E[0m___________（\E[1;$[RANDOM%7+31]m2\E[0m）               \E[1;$[RANDOM%7+31]m| |\E[0m        "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 \E[1;$[RANDOM%7+31]m安装软件操作\E[0m___________（\E[1;$[RANDOM%7+31]m3\E[0m）               \E[1;$[RANDOM%7+31]m| |\E[0m        "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 \E[1;$[RANDOM%7+31]m退出\E[0m___________________（\E[1;$[RANDOM%7+31]m0\E[0m）               \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| +------------------------------------------------------------+ |\E[0m"
    echo -e "\E[1;$[RANDOM%7+31]m+----------------------------------------------------------------+\E[0m"

    read -p "请输入数字：" num1
    case ${num1} in
    1)
        check_sys
        ;;
    2)
        Config_menu
        ;;
    3)
        Install_menu
        ;;
    0)
        exit
        ;;
    *)
        echo -e "\E[1;$[RANDOM%7+31]m输入错误，请重新输入\E[0m"
        Gmenu
        ;;
    esac

}

Config_menu () {
    echo -e "\E[1;$[RANDOM%7+31]m+----------------------------------------------------------------+\E[0m"
    echo -e "\E[1;$[RANDOM%7+31]m| +------------------------------------------------------------+ |\E[0m"
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 \E[1;$[RANDOM%7+31]m初始化系统\E[0m________________（\E[1;$[RANDOM%7+31]m1\E[0m）            \E[1;$[RANDOM%7+31]m| |\E[0m        "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 \E[1;$[RANDOM%7+31]m配置yum源\E[0m_________________（\E[1;$[RANDOM%7+31]m2\E[0m）            \E[1;$[RANDOM%7+31]m| |\E[0m        "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 \E[1;$[RANDOM%7+31]m实现免密登录ssh\E[0m___________（\E[1;$[RANDOM%7+31]m3\E[0m）            \E[1;$[RANDOM%7+31]m| |\E[0m        "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 \E[1;$[RANDOM%7+31]m配置vim\E[0m___________________（\E[1;$[RANDOM%7+31]m4\E[0m）            \E[1;$[RANDOM%7+31]m| |\E[0m        "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 \E[1;$[RANDOM%7+31]m配置网卡名（eth0）\E[0m________（\E[1;$[RANDOM%7+31]m5\E[0m）            \E[1;$[RANDOM%7+31]m| |\E[0m        "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 \E[1;$[RANDOM%7+31]m退出\E[0m______________________（\E[1;$[RANDOM%7+31]m0\E[0m）            \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| +------------------------------------------------------------+ |\E[0m"
    echo -e "\E[1;$[RANDOM%7+31]m+----------------------------------------------------------------+\E[0m"

    read -p "请输入数字：" num2
    case ${num2} in
    1)
        config_sys
        ;;
    2)
        config_yum
        ;;
    3)
        config_ssh
        ;;
    4)
        config_vim
        ;;
    5)
        config_instance
        ;;
    0)
        exit
        ;;
    *)
        echo -e "\E[1;$[RANDOM%7+31]m输入错误，请重新输入\E[0m"
        Config_menu
        ;;
    esac

}

Install_menu () {
    echo -e "\E[1;$[RANDOM%7+31]m+----------------------------------------------------------------+\E[0m"
    echo -e "\E[1;$[RANDOM%7+31]m| +------------------------------------------------------------+ |\E[0m"
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mLVS\E[0m ____________（\E[1;$[RANDOM%7+31]m1\E[0m）                 \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mDNS\E[0m ____________（\E[1;$[RANDOM%7+31]m2\E[0m）                 \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mMySQL\E[0m __________（\E[1;$[RANDOM%7+31]m3\E[0m）                 \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mNginx\E[0m __________（\E[1;$[RANDOM%7+31]m4\E[0m）                 \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mPHP\E[0m ____________（\E[1;$[RANDOM%7+31]m5\E[0m）                 \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mjdk\E[0m ____________（\E[1;$[RANDOM%7+31]m6\E[0m）                 \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mtomcat\E[0m _________（\E[1;$[RANDOM%7+31]m7\E[0m）                 \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mMemcache\E[0m _______（\E[1;$[RANDOM%7+31]m8\E[0m）                 \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mmaven\E[0m __________（\E[1;$[RANDOM%7+31]m9\E[0m）                 \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mnexus\E[0m 仓库______（\E[1;$[RANDOM%7+31]m10\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mzabbix\E[0m _________（\E[1;$[RANDOM%7+31]m11\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mGrafana\E[0m ________（\E[1;$[RANDOM%7+31]m12\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mDocker\E[0m _________（\E[1;$[RANDOM%7+31]m13\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mHub\E[0m 仓库________（\E[1;$[RANDOM%7+31]m14\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mLua\E[0m ____________（\E[1;$[RANDOM%7+31]m15\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mHAProxy\E[0m ________（\E[1;$[RANDOM%7+31]m16\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mkeepalived\E[0m _____（\E[1;$[RANDOM%7+31]m17\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mRedis\E[0m __________（\E[1;$[RANDOM%7+31]m18\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mzookeeper\E[0m ______（\E[1;$[RANDOM%7+31]m19\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mkafka\E[0m __________（\E[1;$[RANDOM%7+31]m20\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mGit\E[0m ____________（\E[1;$[RANDOM%7+31]m21\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mGitlab\E[0m _________（\E[1;$[RANDOM%7+31]m22\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mJenkins\E[0m ________（\E[1;$[RANDOM%7+31]m23\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mGo\E[0m _____________（\E[1;$[RANDOM%7+31]m24\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mSonarqube\E[0m ______（\E[1;$[RANDOM%7+31]m25\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mSonar_scanner\E[0m __（\E[1;$[RANDOM%7+31]m26\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mElasticsearch\E[0m __（\E[1;$[RANDOM%7+31]m27\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mFilebeat\E[0m _______（\E[1;$[RANDOM%7+31]m28\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mKibana\E[0m _________（\E[1;$[RANDOM%7+31]m29\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mLogstash\E[0m _______（\E[1;$[RANDOM%7+31]m30\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mPrometheus\E[0m _____（\E[1;$[RANDOM%7+31]m31\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mNodeExporter\E[0m ___（\E[1;$[RANDOM%7+31]m32\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mPushgateway\E[0m ____（\E[1;$[RANDOM%7+31]m33\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mAlertmanager\E[0m ___（\E[1;$[RANDOM%7+31]m34\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mpostgresql\E[0m _____（\E[1;$[RANDOM%7+31]m35\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mmongodb\E[0m ________（\E[1;$[RANDOM%7+31]m36\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    # echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 安装 \E[1;$[RANDOM%7+31]mk8s\E[0m ____________（\E[1;$[RANDOM%7+31]m37\E[0m）                \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| |\E[0m                 \E[1;$[RANDOM%7+31]m退出\E[0m_________________（\E[1;$[RANDOM%7+31]m0\E[0m）                 \E[1;$[RANDOM%7+31]m| |\E[0m         "
    echo -e "\E[1;$[RANDOM%7+31]m| +------------------------------------------------------------+ |\E[0m"
    echo -e "\E[1;$[RANDOM%7+31]m+----------------------------------------------------------------+\E[0m"    

    read -p "请输入数字：" num3
    case ${num3} in
    1)
        Install_lvs
        ;;
    2)
        Install_DNS
        ;;
    3)
        Install_mysql
        ;;
    4)
        Install_nginx
        ;;
    5)
        Install_php
        ;;
    6)
        Install_jdk
        ;;
    7)
        Install_tomcat
        ;;
    8)
        Install_memcache
        ;;
    9)
        Install_maven
        ;;
    10)
        Install_nexus
        ;;
    11)
        Install_zabbix
        ;;
    12)
        Install_grafana
        ;;
    13)
        Install_docker
        ;;
    14)
        Install_hub
        ;;
    15)
        Install_lua
        ;;
    16)
        Install_HAProxy
        ;;
    17)
        Install_keepalived
        ;;
    18)
        Install_Redis
        ;;
    19)
        Install_zookeeper
        ;;
    20)
        Install_kafka
        ;;
    21)
        Install_git
        ;;
    22)
        Install_gitlab
        ;;
    23)
        Install_Jenkins
        ;;
    24)
        Install_Go
        ;;
    25)
        Install_sonarqube
        ;;
    26)
        Install_sonar_scanner
        ;;
    27)
        Install_elasticsearch
        ;;
    28)
        Install_Filebeat
        ;;
    29)
        Install_Kibana
        ;;
    30)
        Install_Logstash
        ;;
    31)
        Install_prometheus
        ;;
    32)
        Install_NodeExporter
        ;;
    33)
        Install_pushgateway
        ;;
    34)
        Install_alertmanager
        ;;
    35)
        Install_postgresql
        ;;
    36)
        Install_mongodb
        ;;
    37)
        Install_k8s
        ;;
    0)
        exit
        ;;
    *)
        echo -e "\E[1;$[RANDOM%7+31]m输入错误，请重新输入\E[0m"
        Install_menu
        ;;
    esac
    
}

check_sys () {

    ${GREEN}----------------------- sysinfo begin --------------------------------${END}
    echo -e  "HOSTNAME:      ${RED}`hostname`${END}"
    echo -e  "IPADDR:        ${RED}` hostname -I`${END}"
    echo -e  "OSVERSION:     ${RED}${PRETTY_NAME}${END}"
    echo -e  "KERNEL:        ${RED}`uname -r`${END}"
    echo -e  "CPU:          ${RED}`lscpu|grep '^Model name'|tr -s ' '|cut -d : -f2`${END}"
    echo -e  "MEMORY:        ${RED}`free -h|grep Mem|tr -s ' ' : |cut -d : -f2`${END}"
    echo -e  "DISK:          ${RED}`lsblk |grep -E "^(sd|nvme0n1)" |tr -s ' ' |cut -d " " -f4`${END}"
    ${GREEN}----------------------- sysinfo end ----------------------------------${END}

}

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

config_sys () {

    # 关闭swap
    swapoff -a
    # cp /etc/fstab{,.bak}
    # sed -i '/swap/d' /etc/fstab
    sed -i '/swap/s/^/#/g' /etc/fstab
    color "swap已关闭" 0

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        # 关闭 SELINUX
        setenforce 0 &> /dev/null
        sed -i '/^SELINUX=/s/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
        color "selinux已关闭" 0
    else
        systemctl disable --now apparmor
        color "apparmor已关闭" 0
    fi

    # 修改文件描述符最大数量
    echo "* - nofile 65535" >> /etc/security/limits.conf
    color "文件描述符已修改" 0

    timedatectl set-timezone Asia/Shanghai
    color "时区已修改" 0

    # 配置时间同步
    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum -y -q install chrony
        sed -ri 's/^pool .* iburst/server ntp.aliyun.com iburst/g' /etc/chrony.conf
    else
        apt update;apt -y install chrony
        sed -i '/^pool/d' /etc/chrony/chrony.conf
        echo "server ntp.aliyun.com iburst" >> /etc/chrony/chrony.conf
    fi

    systemctl restart chrony* &> /dev/null
    systemctl enable chrony*  &> /dev/null

    color "时间同步已配置" 0

    # 启动相关服务，关闭防火墙
    if [[ ${ID} =~ centos|rocky|rhel ]];then
        systemctl disable --now firewalld  &> /dev/null
    else
        ufw disable &> /dev/null
    fi
    color "防火墙已关闭" 0

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
gpgcheck=0

[extras]
name=extras
baseurl=https://mirror.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch
        https://mirrors.huaweicloud.com/centos/$releasever/extras/$basearch
        https://mirrors.cloud.tencent.com/centos/$releasever/extras/$basearch
        https://mirrors.aliyun.com/centos/$releasever/extras/$basearch       
gpgcheck=0
enabled=1

[epel]
name=EPEL
baseurl=https://mirror.tuna.tsinghua.edu.cn/epel/$releasever/$basearch
        https://mirrors.cloud.tencent.com/epel/$releasever/$basearch/
        https://mirrors.huaweicloud.com/epel/$releasever/$basearch 
        https://mirrors.cloud.tencent.com/epel/$releasever/$basearch
        http://mirrors.aliyun.com/epel/$releasever/$basearch
gpgcheck=0
enabled=1 ' > /etc/yum.repos.d/centos.repo
        yum -y install sshpass bash-completion lrzsz  tree  wget tcpdump
        yum -y install rsync vim lsof gcc make gcc-c++ glibc glibc-devel
        yum -y install pcre pcre-devel openssl openssl-devel systemd-devel
        yum -y install zlib-devel tmux tcpdump net-tools bc chrony
    elif [ ${ID} = rocky ];then
        mv /etc/yum.repos.d/* /mnt/
        echo '[BaseOS]
name=BaseOS
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/x86_64/os/
        http://mirrors.163.com/rocky/$releasever/BaseOS/x86_64/os/
        https://mirrors.nju.edu.cn/rocky/$releasever/BaseOS/x86_64/os/
        https://mirrors.sjtug.sjtu.edu.cn/rocky/$releasever/BaseOS/x86_64/os/
        http://mirrors.sdu.edu.cn/rocky/$releasever/BaseOS/x86_64/os/       
gpgcheck=0

[AppStream]
name=AppStream
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/AppStream/x86_64/os/
        http://mirrors.163.com/rocky/$releasever/AppStream/x86_64/os/
        https://mirrors.nju.edu.cn/rocky/$releasever/AppStream/x86_64/os/
        https://mirrors.sjtug.sjtu.edu.cn/rocky/$releasever/AppStream/x86_64/os/
        http://mirrors.sdu.edu.cn/rocky/$releasever/AppStream/x86_64/os/
gpgcheck=0

[extras]
name=extras
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/extras/$basearch/os
        http://mirrors.163.com/rocky/$releasever/extras/$basearch/os
        https://mirrors.nju.edu.cn/rocky/$releasever/extras/$basearch/os
        https://mirrors.sjtug.sjtu.edu.cn/rocky/$releasever/extras/$basearch/os
        http://mirrors.sdu.edu.cn/rocky/$releasever/extras/$basearch/os 
gpgcheck=0
enabled=1

[PowerTools]
name=CentOS-$releasever - PowerTools
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/PowerTools/$basearch/os/
        http://mirrors.163.com/rocky/$releasever/PowerTools/$basearch/os/
        http://mirrors.sdu.edu.cn/rocky/$releasever/PowerTools/$basearch/os/
        https://mirrors.sjtug.sjtu.edu.cn/rocky/$releasever/PowerTools/$basearch/os/
        http://mirrors.sdu.edu.cn/rocky/$releasever/PowerTools/$basearch/os/
gpgcheck=0
enabled=0

[epel]
name=EPEL
baseurl=https://mirror.tuna.tsinghua.edu.cn/epel/$releasever/Everything/$basearch
        https://mirrors.cloud.tencent.com/epel/$releasever/Everything/$basearch
        https://mirrors.huaweicloud.com/epel/$releasever/Everything/$basearch
        https://mirrors.aliyun.com/epel/$releasever/Everything/$basearch
gpgcheck=0
enabled=1' > /etc/yum.repos.d/Rocky.repo
        yum -y -q install sshpass bash-completion lrzsz  tree  wget tcpdump
        yum -y -q install rsync vim lsof gcc make gcc-c++ glibc glibc-devel
        yum -y -q install pcre pcre-devel openssl openssl-devel systemd-devel
        yum -y -q install zlib-devel tmux tcpdump net-tools bc chrony
    elif [ ${ID} = ubuntu ];then
        mv /etc/apt/sources.list /mnt/
        echo "
deb http://mirrors.aliyun.com/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse

deb http://mirrors.163.com/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse

deb http://mirrors.pku.edu.cn/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse
deb http://mirrors.pku.edu.cn/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse
deb http://mirrors.pku.edu.cn/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse
deb http://mirrors.pku.edu.cn/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse

# deb http://mirrors.sjtug.sjtu.edu.cn/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse
# deb http://mirrors.sjtug.sjtu.edu.cn/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse
# deb http://mirrors.sjtug.sjtu.edu.cn/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse
# deb http://mirrors.sjtug.sjtu.edu.cn/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse

deb http://mirrors.sdu.edu.cn/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse
deb http://mirrors.sdu.edu.cn/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse
deb http://mirrors.sdu.edu.cn/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse
deb http://mirrors.sdu.edu.cn/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse" > /etc/apt/sources.list
        apt update
        apt -y install sshpass bash-completion lrzsz  tree 
        apt -y install wget tcpdump rsync vim lsof gcc make g++ glibc
        apt -y install libc6-dev libpcre3 libpcre3-dev openssl libssl-dev
        apt -y install libsystemd-dev zlib-dev tmux tcpdump net-tools bc chrony
    else
        color "请手动配置yum源" 3
        exit
    fi
    color "镜像源配置完成" 0

}

config_ssh () {

    # 设置变量
    PASS=000000
    END=254

    #IP=`ifconfig ens160 | awk 'NR==2{print $2}' `
    IP=`hostname -I | awk '{print $1}'`
    NET=`echo ${IP} | awk -v FS="." -v OFS="." '{print $1,$2,$3}'`.
    
    # 删除原有私钥
    rm -f /root/.ssh/id_rsa
    [ -e ./SCANIP.log ] && rm -f SCANIP.log

    # 查找可用IP
    for((i=3;i<="${END}";i++));do
        ping -c 1 -w 1  ${NET}${i} &> /dev/null  && echo "${NET}${i}" >> SCANIP.log &
    done
    wait
    
    # 生成私钥
    ssh-keygen -P "" -f /root/.ssh/id_rsa &> /dev/null

    # 安装sshpass
    if [[ ${ID} =~ centos|rocky|rhel ]];then
      rpm -q sshpass || yum -y -q install sshpass
    else
      dpkg -i sshpass &> /dev/null ||{ apt update; apt -y install sshpass; }
    fi

    #拷贝公钥给本机
    sshpass -p ${PASS} ssh-copy-id -o StrictHostKeyChecking=no ${IP}
    
    #把.ssh目录拷贝给可用主机
    AliveIP=(`cat SCANIP.log`)
    for n in ${AliveIP[*]};do
        sshpass -p ${PASS} scp -o StrictHostKeyChecking=no -r /root/.ssh root@${n}:
    done

    #把.ssh/known_hosts拷贝到所有主机，使它们第一次互相访问时不需要输入回车
    for n in ${AliveIP[*]};do
        scp /root/.ssh/known_hosts ${n}:.ssh/
    done

    color "ssh配置完成" 0

}

config_vim () {

    mkdir -p ~/.vim/templates &> /dev/null
    echo '#!/bin/bash
color () {
    RES_COL=50
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    if [ $2 = "success" -o $2 = "0" ];then
        ${SETCOLOR_SUCCESS}
        echo -n $"  OK  "
    elif [ $2 = "failure" -o $2 = "1" ];then
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
'> ~/.vim/templates/sh-template.sh

    echo 'autocmd BufNewFile *.sh 0r ~/.vim/templates/sh-template.sh' > ~/.vimrc
    echo 'set shiftwidth=4' >> ~/.vimrc
    echo 'set tabstop=4' >> ~/.vimrc

    color "vim配置完成" 0

}

config_instance () {

    in_num=0


    if [[ ${ID} =~ centos|rocky|rhel ]];then
        for i in `ip a | grep -E "^[0-9]+: e[a-z0-9]+" | awk -F": |: " '{print $2}'`
        do
            sed -i "s#${i}#eth${in_num}#g" /etc/sysconfig/network-scripts/ifcfg-${i}
            mv /etc/sysconfig/network-scripts/ifcfg-${i} /etc/sysconfig/network-scripts/ifcfg-eth${in_num}
            let in_num++
        done        
    fi

    grep "net.ifnames=0" /etc/default/grub
    if [ $? -ne 0 ];then
            cp /etc/default/grub{,.bak}
            sed -i '/^GRUB_CMDLINE_LINUX=/s/"$/ net.ifnames=0"/' /etc/default/grub
            grub2-mkconfig -o /boot/grub2/grub.cfg
    fi

    echo -e "\E[1;$[RANDOM%7+31]m重启系统生效\E[0m"
    sleep 3
    reboot

}

Install_lvs () {

    mask='255.255.255.255'
    dev=lo:1

    ${GREEN}代理服务器（LVS）/后端服务器（rs）${END}
    # read -p "lvs|rs： " choice1
    # read -p "start|stop： " choice2
    # read -p "虚拟IP: " vip

    choice1='lvs'
    choice2='start'
    vip='10.0.0.200'

    if [ ${choice1} == 'lvs' ];then
        if [ ${choice2} == 'start' ];then
            init_lvs_lvs start
        elif [ ${choice2} == 'stop' ];then
            init_lvs_lvs stop
        else
            echo "lvs|rs start|stop"
            exit 1
        fi
    elif [ ${choice1} == 'rs' ];then
        if [ ${choice2} == 'start' ];then
            init_lvs_rs start
        elif [ ${choice2} == 'stop' ];then
            init_lvs_rs stop
        else
            echo "lvs|rs start|stop"
            exit 1
        fi
    else
        echo "lvs|rs start|stop"
        exit 1
    fi
}

init_lvs_lvs () {

    port='80'
    scheduler='wrr'
    type='-g'

    # read -p "server-1_IP: " rs1
    # read -p "server-2_IP: " rs2

    rs1="10.0.0.102"
    rs2="10.0.0.103"

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        rpm -q ipvsadm &> /dev/null || yum -y install ipvsadm
    else
        dpkg -i ipvsadm &> /dev/null ||{ apt update; apt -y install ipvsadm; }
    fi

    case ${1} in
    start)
        ifconfig ${iface} ${vip} netmask ${mask} #broadcast $vip up
        iptables -F

        ipvsadm -A -t ${vip}:${port} -s ${scheduler}
        ipvsadm -a -t ${vip}:${port} -r ${rs1} ${type} -w 1
        ipvsadm -a -t ${vip}:${port} -r ${rs2} ${type} -w 1
        color "The VS Server is Ready!" 0
        ;;
    stop)
        ipvsadm -C
        ifconfig ${iface} down
        color "The VS Server is Canceled!" 0
        ;;
    *)
        echo "Usage: $(basename ${0}) start|stop"
        exit 1
        ;;
    esac

}

init_lvs_rs () {

    case ${1} in
    start)
        echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
        echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
        echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
        ifconfig ${dev} ${vip} netmask ${mask} #broadcast ${vip} up
        #route add -host ${vip} dev ${dev}
        color "The RS Server is Ready!" 0
        ;;
    stop)
        ifconfig ${dev} down
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_announce
        color "The RS Server is Canceled!" 0
        ;;
    *) 
        echo "Usage: $(basename ${0}) start|stop"
        exit 1
        ;;
    esac

}   

Install_DNS () {

    WZ=wang.org
    IPADDR=10.0.0.13
    YM=www
    NET_NAME=`ip a | grep "^[0-9]" | grep -v "lo" | tr -s ':' ' '|awk '{print $2}'`

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum  -y install bind bind-utils
        cat >> /etc/named.conf << EOF
zone "${WZ}" IN {
       type master;
       file "/etc/named/${WZ}.zone";
};
EOF
    cat > /etc/named/${WZ}.zone <<EOF
\$TTL    604800
@       IN     SOA     ${WZ}. admin (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
        IN     NS     master
master  IN     A       ${HOST}
www     IN     A       ${IPADDR}
EOF
    systemctl restart named
    systemctl enable named
    rdnc reload
    
    sed -i '/DNS/d' /etc/sysconfig/network-scripts/ifcfg-${NET_NAME}
    echo "DNS=${HOST}" >> /etc/sysconfig/network-scripts/ifcfg-${NET_NAME}
    nmcli connection reload 
    nmcli connection up ${NET_NAME}

    ping -c 3 ${YM}.${WZ}
    if [ $? -eq 0 ];then
        color "DNS配置完成" 0
    else
        color "DNS配置失败" 1
        exit 1
    fi

    else
        apt update
        apt -y install bind9 bind9-utils bind9-host bind9-dnsutils
        cat >> /etc/bind/named.conf.default-zones <<EOF
zone "${WZ}" IN {
       type master;
       file "/etc/bind/${WZ}.zone";
};
EOF
        cat > /etc/bind/${WZ}.zone <<EOF
\$TTL    604800
@       IN     SOA     ${WZ}. admin (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
        IN     NS     master
master  IN     A       ${HOST}
www     IN     A       ${IPADDR}
EOF
    rndc reload
    color "DNS配置完成" 0
# network:
#   ethernets:
#     ens32:
#       addresses:
#       - 10.0.0.101/8
#       gateway4: 10.0.0.2
#       nameservers:
#         addresses:
#         - 10.0.0.101
#         search: [wang.org]
#   version: 2
    fi

}

Install_mysql () {

    #MYSQL='mysql-5.7.33-linux-glibc2.12-x86_64.tar.gz'
    #URL=http://mirrors.163.com/mysql/Downloads/MySQL-5.7
    MYSQL='mysql-8.0.23-linux-glibc2.12-x86_64.tar.xz'
    MYSQL_URL='https://downloads.mysql.com/archives/get/p/23/file'
    
    # read -p "mysql_root_password: " MYSQL_ROOT_PASSWORD
    # read -p "是否给与root远程登录权限（y/n）: " choice

    MYSQL_ROOT_PASSWORD='000000'
    choice='y'   

    if [ ${UID} -ne 0 ]; then
        color "当前用户不是root,安装失败" 2
        exit 1
    fi

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        rpm -q wget || yum -y -q install wget
    else
        dpkg -i wget &> /dev/null ||{ apt update; apt -y install wget; }
    fi

    cd  ${SRC_DIR}

    if [ !  -e ${MYSQL} ];then
        wget ${MYSQL_URL}/${MYSQL}
    fi

    if [ -e /usr/local/mysql ];then
        color "数据库已存在，安装失败" 1
        exit
    fi
 
    ${GREEN}"开始安装MySQL数据库..."${END}

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum  -y install libaio numactl-libs ncurses-compat-libs
    else
        apt update
        apt -y install libaio numactl-libs ncurses-compat-libs
    fi
    
    tar xf ${MYSQL} -C /usr/local/
    MYSQL_DIR=`echo ${MYSQL}| sed -nr 's/^(.*[0-9]).*/\1/p'`
    ln -s /usr/local/${MYSQL_DIR} /usr/local/mysql
    
    id mysql &> /dev/null || { useradd -s /sbin/nologin -r mysql ; color "创建mysql用户" 0; }
    echo 'PATH=/usr/local/mysql/bin/:$PATH' > /etc/profile.d/mysql.sh
    . /etc/profile.d/mysql.sh
    ln -s /usr/local/mysql/bin/* /usr/bin/
    cat > /etc/my.cnf <<-EOF
[mysqld]
server-id=`hostname -I|cut -d. -f4`
log-bin
datadir=/usr/local/mysql/data
socket=/usr/local/mysql/mysql.sock
log-error=/usr/local/mysql/logs/mysql.log
pid-file=/usr/local/mysql/mysql.pid

[client]
socket=/usr/local/mysql/mysql.sock
EOF
    mkdir /usr/local/mysql/{data,logs}
    chown -R mysql.mysql /usr/local/mysql/
    mysqld --initialize --user=mysql --datadir=/usr/local/mysql/data 
    cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
    chkconfig --add mysqld
    chkconfig mysqld on
    systemctl start mysqld

    [ ${?} -ne 0 ] && { color "数据库启动失败，退出!" 1 ;exit; }
    sleep 3
    MYSQL_OLDPASSWORD=`awk '/A temporary password/{print $NF}' /usr/local/mysql/logs/mysql.log`
    mysqladmin  -uroot -p${MYSQL_OLDPASSWORD} password ${MYSQL_ROOT_PASSWORD} &>/dev/null
    if [ ${choice} == 'y' ];then
        mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "create user root@'%' identified by '${MYSQL_ROOT_PASSWORD}' "
        mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "grant all privileges on *.* to root@'%' with grant option;"
    fi
    mkdir -p /var/lib/mysql && ln -s /usr/local/mysql/mysql.sock /var/lib/mysql/mysql.sock
    ln -s /usr/local/mysql/logs/error.log /var/log/mysql.log
    color "数据库安装完成" 0

}

Install_nginx () {

    NGINX_FILE=nginx-1.20.2
    NGINX_URL=http://nginx.org/download/
    TAR=.tar.gz
    NGINX_INSTALL_DIR=/usr/local/${NGINX_FILE}

    [ -e ${NGINX_INSTALL_DIR} ] && { color "nginx 已安装,请卸载后再安装" 1 ; exit; }

    cd  ${SRC_DIR}

    if [  -e ${NGINX_FILE}${TAR} ];then
        color "相关文件已准备好" 0
    else
        color '开始下载 nginx 源码包' 0
         wget ${NGINX_URL}${NGINX_FILE}${TAR}
        [ ${?} -ne 0 ] && { color "下载 ${NGINX_FILE}${TAR}文件失败" 1 ; exit; } 
    fi

    color "开始安装 nginx" 0
    
    if id nginx &> /dev/null;then
        color "nginx 用户已存在" 1
    else
        useradd -s /sbin/nologin -r nginx
        color "创建 nginx 用户" 0
    fi
    
    color "开始安装 nginx 依赖包" 0
    
    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum -y install make gcc gcc-c++ libtool pcre pcre-devel zlib zlib-devel openssl openssl-devel perl-ExtUtils-Embed
    else
        apt update
        apt -y install make gcc libpcre3 libpcre3-dev openssl libssl-dev zlib1g-dev
    fi
    
    tar xf ${NGINX_FILE}${TAR}
    NGINX_DIR=`echo ${NGINX_FILE}${TAR}| sed -nr 's/^(.*[0-9]).*/\1/p'`
    
    cd ${NGINX_DIR}
    
    ./configure --prefix=${NGINX_INSTALL_DIR} --user=nginx --group=nginx \
    --with-http_ssl_module --with-http_v2_module --with-http_realip_module \
    --with-http_stub_status_module --with-http_gzip_static_module --with-pcre \
    --with-stream --with-stream_ssl_module --with-stream_realip_module
    
    make -j ${CPUS} && make install 
    
    ln -s ${NGINX_INSTALL_DIR} /usr/local/nginx

    [ ${?} -eq 0 ] && color "nginx 编译安装成功" 0 || { color "nginx 编译安装失败,退出!" 1 ;exit; }
    
    echo "PATH=/usr/local/nginx/sbin:${PATH}" > /etc/profile.d/nginx.sh
    chown -R nginx.nginx /usr/local/nginx
    
    cat > /lib/systemd/system/nginx.service <<EOF
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=${NGINX_INSTALL_DIR}/logs/nginx.pid
ExecStartPre=/bin/rm -f ${NGINX_INSTALL_DIR}/logs/nginx.pid
ExecStartPre=${NGINX_INSTALL_DIR}/sbin/nginx -t
ExecStart=${NGINX_INSTALL_DIR}/sbin/nginx
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now nginx &> /dev/null 
    systemctl is-active nginx &> /dev/null || { color "nginx 启动失败,退出!" 1 ; exit; }
    
    color "nginx 安装完成" 0

}

Install_php () {

    ONIGURUMA_VERSION=6.9.4
    PHP_VERSION=7.3.7
  
    ${GREEN}安装依赖包${END}  

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum install -y wget autoconf automake libtool libxml2 libxml2-devel sqlite-devel libcurl-devel 
        yum install -y oniguruma-devel libicu-devel bzip2-devel pcre2-devel freetype-devel libjpeg-turbo-devel 
        yum install -y libtidy-devel postgresql13-devel openssl-devel zlib-devel gd-devel libXpm-devel ncurses-devel 
        yum install -y libmcrypt-devel ntp make screen sysstat curl wget autoconf automake libtool
    else
	    apt update && apt install -y wget autoconf automake libtool libxml2
        apt install -y libxml2-dev libsqlite3-dev libcurl4-openssl-dev libonig-dev 
        apt install -y libicu-dev libbz2-dev libpcre2-dev libfreetype6-dev 
        apt install -y libjpeg-turbo8-dev libtidy5-dev postgresql-server-dev-all 
        apt install -y libssl-dev zlib1g-dev libgd-dev libxpm-dev ncurses-dev 
        apt install -y libmcrypt-dev ntp make screen sysstat curl wget autoconf automake libtool
    fi

    ${GREEN}下载压缩包${END}

    if [ ! -f "${SRC_DIR}/php-${PHP_VERSION}.tar.gz" ];then
	    wget --no-check-certificate -P /usr/local/src/ http://www.php.net/distributions/php-${PHP_VERSION}.tar.gz
    fi

    if [ ! -f "${SRC_DIR}/oniguruma-${ONIGURUMA_VERSION}.tar.gz" ];then
        wget https://codeload.github.com/kkos/oniguruma/tar.gz/v${ONIGURUMA_VERSION} -O /usr/local/src/oniguruma-${ONIGURUMA_VERSION}.tar.gz
    fi

    ${GREEN}编译oniguruma${END}
    cd ${SRC_DIR}
    tar xf oniguruma-${ONIGURUMA_VERSION}.tar.gz && cd oniguruma-${ONIGURUMA_VERSION}/
    ./autogen.sh && ./configure --prefix=/usr || { color "oniguruma 编译失败,退出!" 1 ; exit; }
    make -j ${CPUS} && make install

    ${GREEN}编译php${END}
    cd ${SRC_DIR}
    tar xf php-${PHP_VERSION}.tar.gz && cd php-${PHP_VERSION}/
    ./configure --prefix=/usr/local/php --enable-mysqlnd --with-mysqli=mysqlnd \
                --with-pdo-mysql=mysqlnd --with-openssl --with-zlib --with-config-file-path=/etc \
                --with-config-file-scan-dir=/etc/php.d --enable-mbstring --enable-xml --enable-sockets \
                --enable-fpm --enable-maintainer-zts --disable-fileinfo
    make -j ${CPUS} && make install

    ln -s /usr/local/php/sbin/php-fpm /usr/sbin/

    cp php.ini-production /etc/php.ini &> /dev/null
    cp sapi/fpm/php-fpm.service /usr/lib/systemd/system/ &> /dev/null
    cd /usr/local/php/etc
    cp php-fpm.conf.default php-fpm.conf &> /dev/null
    cd /usr/local/php/etc/php-fpm.d/
    cp www.conf.default www.conf &> /dev/null

    mkdir /etc/php.d/ &> /dev/null
    cat > /etc/php.d/opcache.ini << EOF
[opcache]
zend_extension=opcache.so
opcache.enable=1
EOF

    systemctl daemon-reload &> /dev/null
    systemctl enable --now php-fpm.service &> /dev/null

    ss -lnt | grep 9000
    if [ $? -eq 0 ];then
        color "php安装成功" 0
    else
        color "php安装失败" 1
        exit
    fi
}


Install_jdk () {

    JDK_FILE="jdk-11.0.26_linux-x64_bin.tar.gz"

    if   [ ! -f "${SRC_DIR}/${JDK_FILE}" ];then
        echo -e "\E[1;$[RANDOM%7+31]m${SRC_DIR}目录下，${JDK_FILE}文件不存在，需要自行下载JDK\E[0m"
	    exit; 
    elif [ -d /usr/local/jdk ];then
        color "JDK 已经安装" 1
	    exit
    else 
        [ -d "${SRC_DIR}" ] || mkdir -pv $SRC_DIR
    fi

    tar xvf ${SRC_DIR}/${JDK_FILE}  -C /usr/local
    
    cd  /usr/local/ && ln -s /usr/local/jdk* /usr/local/jdk 

    cat >  /etc/profile.d/jdk.sh <<-EOF
export JAVA_HOME=/usr/local/jdk
export PATH=\$PATH:\$JAVA_HOME/bin
#export JRE_HOME=\$JAVA_HOME/jre
#export CLASSPATH=.:\$JAVA_HOME/lib/:\$JRE_HOME/lib/
EOF

    .  /etc/profile.d/jdk.sh
    java -version && color "JDK 安装完成" 0 || { color "JDK 安装失败" 1 ; exit; }

}

Install_tomcat () {

    TOMCAT_VERSION=10.1.39
    TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
    JDK_DIR="/usr/local"

    java -version &> /dev/null
    if [ ${?} -ne 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            #yum -y install java-1.8.0-openjdk-devel || { color "安装JDK失败!" 1; exit 1; }
            yum -y install java-11-openjdk || { color "安装JDK失败!" 1; exit 1; }
        else
            apt update
            apt install openjdk-11-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
            #apt install openjdk-8-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
        fi
    fi


    if ! [ -f "${SRC_DIR}/${TOMCAT_FILE}" ];then
        echo -e "\E[1;$[RANDOM%7+31]m${SRC_DIR}目录下，${TOMCAT_FILE}文件不存在，需要自行下载\E[0m"
        exit; 
    elif [ -d /usr/local/tomcat ];then
        color "TOMCAT 已经安装" 1
        exit
    else 
        [ -d "${SRC_DIR}" ] || mkdir -pv ${SRC_DIR}
    fi

    tar xf ${SRC_DIR}/${TOMCAT_FILE} -C /usr/local/
    cd  /usr/local/ && ln -s apache-tomcat-*/  tomcat
    echo "PATH=/usr/local/tomcat/bin:"'$PATH' > /etc/profile.d/tomcat.sh
    id tomcat &> /dev/null || useradd -r -s /sbin/nologin tomcat

    cat > /usr/local/tomcat/conf/tomcat.conf <<-EOF
JAVA_HOME=${JDK_DIR}/jdk
EOF

    chown -R tomcat.tomcat /usr/local/tomcat/
    cat > /lib/systemd/system/tomcat.service  <<-EOF
[Unit]
Description=Tomcat
#After=syslog.target network.target remote-fs.target nss-lookup.target
After=syslog.target network.target 

[Service]
Type=forking
EnvironmentFile=/usr/local/tomcat/conf/tomcat.conf
ExecStart=/usr/local/tomcat/bin/startup.sh
ExecStop=/usr/local/tomcat/bin/shutdown.sh
RestartSec=3
PrivateTmp=true
User=tomcat
Group=tomcat

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now tomcat.service &> /dev/null
    systemctl is-active tomcat.service &> /dev/null &&  color "TOMCAT 安装完成" 0 || { color "TOMCAT 安装失败" 1 ; exit; }

}

Install_memcache () {

    MEMCACHE_VERSION="1.6.17"
    MEMCACHE_FILE="memcached-${MEMCACHE_VERSION}.tar.gz"
    MEMCACHE_DIR="/usr/local"
    MEMCACHE_URL="http://memcached.org/files"

    if [ -e ${MEMCACHE_DIR}/memcached ];then
        color "memcache 已安装" 1
        exit
    fi

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum -y -q install gcc libevent-devel wget
    else
        apt update; apt -y install wget gcc make libevent-dev
    fi

    cd ${SRC_DIR}

    if [ ! -e ${MEMCACHE_FILE} ];then
        wget ${MEMCACHE_URL}/${MEMCACHE_FILE}
        [ $? -ne 0 ] && { color "下载 ${MEMCACHE_FILE} 文件失败" 1 ; exit; } 
    fi

    tar xvf ${MEMCACHE_FILE} -C ${MEMCACHE_DIR}
    
    cd /usr/local/memcached-${MEMCACHE_VERSION}
    ./configure --prefix=${MEMCACHE_DIR}/memcached-${MEMCACHE_VERSION}
    make -j ${CPUS} && make install
    ln -s ${MEMCACHE_DIR}/memcached-${MEMCACHE_VERSION} /usr/local/memcached

    useradd -r -s /sbin/nologin memcached || { color "用户 memcached 存在" 1 ; exit; }

    cat > /etc/sysconfig/memcached <<-EOF
PORT=11211
USER=memcached
MAXCONN=1024
CACHESIZE=64
OPTIONS="-l 0.0.0.0"
EOF

    cat > /lib/systemd/system/memcached.service <<-EOF
[Unit]
Description=memcached daemon
Before=httpd.service
After=network.target


[Service]
EnvironmentFile=/etc/sysconfig/memcached
ExecStart=${MEMCACHE_DIR}/memcached/bin/memcached -p \${PORT} -u \${USER} -m \${CACHESIZE} -c \${MAXCONN} \$OPTIONS

[Install]
WantedBy=multi-user.target
EOF
    echo "PATH=${MEMCACHE_DIR}/memcached/bin:\$PATH" > /etc/profile.d/memcached.sh
    . /etc/profile.d/memcached.sh

    systemctl daemon-reload 
    systemctl enable --now memcached.service
    systemctl is-active memcached.service &> /dev/null && color "memcache 安装完成" 0 || { color "memcache 安装失败" 1 ; exit; }

}

Install_maven () {

    MAVEN_VERSION=3.8.8
    MAVEN_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
    #MAVEN_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
    MAVEN_DIR="/usr/local"

    java -version &> /dev/null
    if [ ${?} -ne 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            #yum -y install java-1.8.0-openjdk-devel || { color "安装JDK失败!" 1; exit 1; }
            yum -y install java-11-openjdk || { color "安装JDK失败!" 1; exit 1; }
        else
            apt update
            apt install openjdk-11-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
            #apt install openjdk-8-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
        fi
    fi

    if [ -e ${MAVEN_DIR}/maven ];then
        color "maven 已安装" 1
        exit
    fi

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum -y -q install wget
    else
        apt update; apt -y install wget 
    fi
    
    if [ ! -e ${SRC_DIR}/apache-maven-${MAVEN_VERSION}-bin.tar.gz ];then
        cd ${SRC_DIR} && wget ${MAVEN_URL}
    fi

    tar xf apache-maven-${MAVEN_VERSION}-bin.tar.gz  -C ${MAVEN_DIR}
    ln -s /usr/local/apache-maven-${MAVEN_VERSION} /usr/local/maven
    echo "PATH=${MAVEN_DIR}/maven/bin:\$PATH" > /etc/profile.d/maven.sh
    echo "export MAVEN_HOME=${MAVEN_DIR}/maven" >> /etc/profile.d/maven.sh
    . /etc/profile.d/maven.sh
    mvn -v && { color "MAVEN安装成功!" 0 ; sed -i  '/\/mirrors>/i <mirror> \n <id>nexus-aliyun</id> \n  <mirrorOf>*</mirrorOf> \n <name>Nexus aliyun</name> \n <url>http://maven.aliyun.com/nexus/content/groups/public</url> \n </mirror> ' /usr/local/maven/conf/settings.xml ; } || color "MAVEN安装失败!" 1 

}

Install_nexus () {

    NEXUS_URL=https://download.sonatype.com/nexus/3
    NEXUS_VERSION=3.43.0-01
    NEXUS_FILE=nexus-${NEXUS_VERSION}-unix.tar.gz

    java -version &> /dev/null
    if [ ${?} -ne 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            #yum -y install java-1.8.0-openjdk-devel || { color "安装JDK失败!" 1; exit 1; }
            yum -y install java-11-openjdk || { color "安装JDK失败!" 1; exit 1; }
        else
            apt update
            apt install openjdk-11-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
            #apt install openjdk-8-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
        fi
    fi

    MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_GB=$(echo "scale=1; ${MEM_KB} / 1048576" | bc)

    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    MAJOR_VERSION=$(echo ${JAVA_VERSION} | awk -F '.' '{if($1=="1") print $2; else print $1}')

    if [ $(echo "${MEM_GB} >= 3.7" | bc) -eq 0 ] ;then
        color "最少需要 4G 内存" 3
        exit 1
    fi

    if [ "${MAJOR_VERSION}" -lt 8 ]; then
        color "Java版本需要大于等于1.8" 3
        exit 1
    fi

    cd ${SRC_DIR}

    if [ ! -e ${NEXUS_FILE} ];then
        wget ${NEXUS_URL}/${NEXUS_FILE} || { color "下载 nexus 失败" 1 ; exit; }
    fi
    
    tar xvf ${NEXUS_FILE} -C /usr/local/
    ln -s /usr/local/nexus-${NEXUS_VERSION} /usr/local/nexus
    ln -s /usr/local/nexus/bin/nexus /usr/bin/

    echo 'run_as_user="root"' > /usr/local/nexus/bin/nexus.rc

    cat > /lib/systemd/system/nexus.service <<-EOF
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/usr/bin/nexus start
ExecStop=/usr/bin/nexus stop
User=root
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now nexus.service &> /dev/null
    systemctl is-active nexus.service &> /dev/null && color "nexus 安装完成" 0 || { color "nexus 安装失败" 1 ; exit; }

    echo "-------------------------------------------------------------------"
    echo -e "访问链接: \c"
    ${GREEN}"http://${HOST}:8081/"${END}
    while [ ! -f /usr/local/sonatype-work/nexus3/admin.password ];do
        sleep 1
    done
    PASS=`cat /usr/local/sonatype-work/nexus3/admin.password`
    echo -e "用户和密码: \c"
    ${GREEN}"admin/${PASS}"${END}

}

Install_zabbix () {

    ZABBIX_MAJOR_VER=6.0
    ZABBIX_VER=${ZABBIX_MAJOR_VER}-4
    ZABBIX_URL="mirror.tuna.tsinghua.edu.cn/zabbix"

    echo -e "\E[32;1mzabbix_server/agent_server\E[0m"
    read -p "zabbix|agent： " choice1

    if [ ${choice1} == 'zabbix' ];then
        Install_zabbix_server
    elif [ ${choice1} == 'agent' ];then
        Install_zabbix_agent
    else
        echo -e "\E[31;1mzabbix|agent\E[0m"
        exit 1
    fi

}

Install_zabbix_server () {

    # read -p "mysql_host(localhost): " MYSQL_HOST
    # read -p "mysql_root_passwd: " MYSQL_ROOT_PASS
    # read -p "mysql_zabbix_user(zabbix@'localhost'): " MYSQL_ZABBIX_USER
    # read -p "mysql_zabbix_passwd: " MYSQL_ZABBIX_PASS

    MYSQL_HOST="10.0.0.102"
    MYSQL_ROOT_PASS="000000"
    MYSQL_ZABBIX_USER="zabbix@'%'"
    MYSQL_ZABBIX_PASS="000000"

    FONT=HYZHENGYUAN.TTF

    if [ -f "${FONT}" ] ;then 
	    mv /usr/share/zabbix/assets/fonts/graphfont.ttf{,.bak}
		cp  "${FONT}" /usr/share/zabbix/assets/fonts/graphfont.ttf
	else
		color "缺少字体文件!" 1
	fi

    if [ ${MYSQL_HOST} == "localhost" ];then
        mysql --version &> /dev/null || { color "开始安装MYSQL" 0 ; Install_mysql; }
    else
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            yum -y -q install mysql
        else
            apt update; apt -y install mysql 
        fi
    fi

    mysql -h${MYSQL_HOST} -uroot -p${MYSQL_ROOT_PASS} <<EOF
set global log_bin_trust_function_creators = 0;
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user ${MYSQL_ZABBIX_USER} identified with mysql_native_password by "${MYSQL_ZABBIX_PASS}";
grant all privileges on zabbix.* to ${MYSQL_ZABBIX_USER};
set global log_bin_trust_function_creators = 1;
quit
EOF

    if [ ${?} -eq 0 ];then
        color "MySQL数据库准备完成" 0
    else
        color "MySQL数据库配置失败,退出" 1
        exit
    fi

    if [[ ${ID} =~ centos|rocky|rhel ]] ;then 
        rpm -Uvh https://${ZABBIX_URL}/zabbix/${ZABBIX_MAJOR_VER}/rhel/`echo ${VERSION_ID}|cut -d. -f1`/x86_64/zabbix-release-${ZABBIX_VER}.el`echo ${VERSION_ID}|cut -d. -f1`.noarch.rpm
        
        if [ ${?} -eq 0 ];then
	        color "YUM仓库准备完成" 0
        else
            color "YUM仓库配置失败,退出" 1
		    exit
	    fi

	    sed -i "s#repo.zabbix.com#${ZABBIX_URL}#" /etc/yum.repos.d/zabbix.repo

	    if [[ ${VERSION_ID} == 8* ]];then 
		    yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent zabbix-get langpacks-zh_CN
        else 
		    yum -y install zabbix-server-mysql zabbix-agent  zabbix-get
			yum -y install centos-release-scl
			rpm -q yum-utils  || yum -y install yum-utils
			yum-config-manager --enable zabbix-frontend
			yum -y install zabbix-web-mysql-scl zabbix-apache-conf-scl
        fi
    else 
	   	wget https://${ZABBIX_URL}/zabbix/${ZABBIX_MAJOR_VER}/ubuntu/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_VER}+ubuntu${VERSION_ID}_all.deb
        dpkg -i zabbix-release_${ZABBIX_VER}+ubuntu${VERSION_ID}_all.deb

        if [ ${?} -eq 0 ];then
           	color "APT仓库准备完成" 0
	    else
           	color "APT仓库配置失败,退出" 1
            exit
        fi

        sed -i.bak "s#repo.zabbix.com#${ZABBIX_URL}#" /etc/apt/sources.list.d/zabbix.list
        apt update
        apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent zabbix-get language-pack-zh-hans 
    fi

	zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p$MYSQL_ZABBIX_PASS -h$MYSQL_HOST zabbix
    mysql -h${MYSQL_HOST} -uroot -p${MYSQL_ROOT_PASS} -e "set global log_bin_trust_function_creators = 0"
	
	sed -i -e "/.*DBPassword=.*/c DBPassword=${MYSQL_ZABBIX_PASS}" -e "/.*DBHost=.*/c DBHost=${MYSQL_HOST}" /etc/zabbix/zabbix_server.conf

	if [[ ${ID} =~ centos|rocky|rhel ]];then
	    if [[ ${VERSION_ID} == 8* ]];then 	        
            sed -i -e "/.*date.timezone.*/c php_value[date.timezone] = Asia/Shanghai" -e "/.*upload_max_filesize.*/c php_value[upload_max_filesize] = 20M" /etc/php-fpm.d/zabbix.conf
            systemctl enable --now zabbix-server zabbix-agent httpd php-fpm
		else
		    sed -i "/.*date.timezone.*/c php_value[date.timezone] = Asia/Shanghai" /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
		    systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
		    systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm
		fi
	else
        sed -i "/date.timezone/c php_value date.timezone Asia/Shanghai" /etc/apache2/conf-available/zabbix.conf		
        chown -R www-data.www-data /usr/share/zabbix/
        systemctl enable  zabbix-server zabbix-agent apache2
        systemctl restart  zabbix-server zabbix-agent apache2
    fi

    if [ ${?}  -eq 0 ];then  
        echo 
        color "ZABBIX-${ZABBIX_VER}安装完成!" 0
        echo "-------------------------------------------------------------------"
        ${GREEN}"请访问: http://${HOST}/zabbix"${END}
    else
        color "ZABBIX-${ZABBIX_VER}安装失败!" 1
        exit
    fi

}

Install_zabbix_agent () {

    #read -p "zabbix_server_ip:  " ZABBIX_SERVER_IP  
    ZABBIX_SERVER_IP="10.0.0.101"

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        rpm -ivh https://${ZABBIX_URL}/zabbix/${ZABBIX_MAJOR_VER}/rhel/`echo ${VERSION_ID}|cut -d. -f1`/x86_64/zabbix-agent2-`echo $ZABBIX_VER | tr "-" "."`-1.el`echo ${VERSION_ID}|cut -d. -f1`.x86_64.rpm
    else
        wget https://${ZABBIX_URL}/zabbix/${ZABBIX_MAJOR_VER}/ubuntu/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_VER}+ubuntu${VERSION_ID}_all.deb
    fi
    
    sed -i "s#Server=.*#Server=${ZABBIX_SERVER_IP}#g" /etc/zabbix/zabbix_agent2.conf
    systemctl restart zabbix-agent2.service
    systemctl enable zabbix-agent2.service
    systemctl is-active zabbix-agent2.service && color "ZABBIX-AGENT安装完成!" 0 || { color "ZABBIX-AGENT安装失败!" 1; exit; }
    echo -e "\E[32;1m还需在zabbix_server添加本主机监控\E[0m"

}
            
Install_grafana () {

    GRAFANA_AGENT_VER=11.6.0
    GRAFANA_VER=${GRAFANA_AGENT_VER}-1

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum install -q -y wget 
        if [ ! -f ${SRC_DIR}/grafana-${GRAFANA_VER}.x86_64.rpm ];then
            wget -P ${SRC_DIR} https://mirrors.tuna.tsinghua.edu.cn/grafana/yum/rpm/Packages/grafana-${GRAFANA_VER}.x86_64.rpm 
        fi
        yum install -q -y ${SRC_DIR}/grafana-${GRAFANA_VER}.x86_64.rpm
    else
        apt update;apt install -q -y wget
        if [ ! -f ${SRC_DIR}/grafana_${GRAFANA_AGENT_VER}_arm64.deb ];then
            wget -P ${SRC_DIR} https://mirrors.tuna.tsinghua.edu.cn/grafana/apt/pool/main/g/grafana/grafana_${GRAFANA_AGENT_VER}_arm64.deb
        fi
        dpkg -i ${SRC_DIR}/grafana_${GRAFANA_AGENT_VER}_arm64.deb
    fi

    systemctl enable --now grafana-server
    systemctl is-active grafana-server  &&   color "Grafana安装成功!" 0   || { color "Grafana安装失败!" 1;exit; }
    ss -lnt| grep 3000
    echo -e "\E[32;1m浏览器访问grafana的web界面: http://${HOST}:3000/\E[0m"
    echo -e "\E[32;1m默认用户名和密码都是\E[31;1madmin\E[0m\E[0m"

}

Install_docker () {

    DOCKER_VERSION=28.0.4
    COMPOSE_VERSION=1.21.2
    DOCKER_URL=https://mirrors.aliyun.com/docker-ce/linux/static/stable/x86_64/
    COMPOSE_URL=https://mirrors.aliyun.com/docker-toolbox/linux/compose/${COMPOSE_VERSION}/
    
    cd ${SRC_DIR}
    if [ ! -e docker-${DOCKER_VERSION}.tgz ];then
        wget ${DOCKER_URL}/docker-${DOCKER_VERSION}.tgz
        [ $? -ne 0  ] && { echo "文件下载失败"; exit; }
    fi
    
    tar xf docker-${DOCKER_VERSION}.tgz -C /usr/local/
    cp /usr/local/docker/* /usr/bin/

    cat > /lib/systemd/system/docker.service <<-EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H unix://var/run/docker.sock
ExecReload=/bin/kill -s HUP \$MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable --now docker

    docker info && color "docker安装成功" 0 || { color "docker安装失败" 1; exit; }

    mkdir -p /etc/docker
    tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://registry.docker-cn.com",
        "https://docker.m.daocloud.io",
        "https://docker.imgdb.de",
        "https://docker-0.unsee.tech",
        "https://docker.hlmirror.com",
        "https://docker.1ms.run",
        "https://func.ink",
        "https://lispy.org",
        "https://docker.xiaogenban1993.com"
    ],
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "200m"
    },
    "storage-driver": "overlay2"
}
EOF
    systemctl restart docker

    if [ ! -e ${SRC_DIR}/docker-compose-Linux-x86_64 ];then
        wget -P ${SRC_DIR} ${COMPOSE_URL}/docker-compose-Linux-x86_64
    fi
    mv ${SRC_DIR}/docker-compose-Linux-x86_64 /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
    docker-compose --version && color "docker-compose安装成功" 0 || { color "docker-compose安装失败" 1; exit; }

}

Install_hub () {

    HUB_VERSION=2.5.2
    HUB_URL=https://github.com/goharbor/harbor/releases/download/${HUB_VERSION}
    #read -p "设置Hub密码: "  HUB_PASSWORD
    #HUB_PASSWORD="Harbor12345"

    # docker -v &>/dev/null || { color "开始安装docker" 0; Install_docker; }
    docker -v &>/dev/null
    if [ ${?} -ne 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            yum install -y yum-utils
            yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
            yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            systemctl start docker
        else
            apt update
            apt install ca-certificates curl gnupg

            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            chmod a+r /etc/apt/keyrings/docker.gpg

            echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
            "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            apt update
            apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        fi
    fi

    mkdir -p /etc/docker
    tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://registry.docker-cn.com",
        "https://docker.m.daocloud.io",
        "https://docker.imgdb.de",
        "https://docker-0.unsee.tech",
        "https://docker.hlmirror.com",
        "https://docker.1ms.run",
        "https://func.ink",
        "https://lispy.org",
        "https://docker.xiaogenban1993.com"
    ],
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "200m"
    },
    "storage-driver": "overlay2"
}
EOF
    systemctl daemon-reload
    systemctl enable docker
    systemctl restart docker

    cd ${SRC_DIR}
    if [ ! -e harbor-offline-installer-v${HUB_VERSION}.tgz ];then
        wget ${HUB_URL}/harbor-offline-installer-${HUB_VERSION}.tgz
        [ $? -ne 0  ] && { echo "文件下载失败"; exit; }
    fi

    tar xf harbor-offline-installer-v${HUB_VERSION}.tgz -C /usr/local/
    cd /usr/local/harbor/
    cp harbor.yml.tmpl harbor.yml

    sed -i "s/hostname: reg.mydomain.com/hostname: ${HOST}/g" harbor.yml 
    #sed -i "s/harbor_admin_password: Harbor12345/harbor_admin_password: ${HUB_PASSWORD}/g" harbor.yml
    sed -i '12,18s/^/#/' harbor.yml

    ./install.sh
    color "Harbor安装成功!" 0
    ${GREEN} "Harbor地址: http://${HOST}"${END}
    ${GREEN} "Harbor用户名: admin"${END}
    #${GREEN} "Harbor密码: ${HUB_PASSWORD}"${END}
    ${GREEN} "Harbor密码: Harbor12345"${END}
    echo
    ${GREEN}daemon.json 添加 "insecure-registries": ["${HOST}:80"]${END}
    ${GREEN}docker login ${HOST}:80 -uadmin -pHarbor12345${END}
    
}


Install_lua () {

    LUA_VERSION=5.3.5
    LUA_URL=http://www.lua.org/ftp/

    ${GREEN}开始安装LUA依赖包${END}
    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum install -y wget gcc readline-devel libtermcap-devel ncurses-devel libevent-devel
    else
        apt update;apt install -q -y wget  gcc make libssl-dev libpcre3 libpcre3-dev zlib1g-dev libreadline-dev libsystemd-dev
    fi

    if [ ! -e ${SRC_DIR}/lua-${LUA_VERSION}.tar.gz ];then
        ${GREEN}开始下载LUA源码包${END}
        cd ${SRC_DIR}
        wget ${LUA_URL}/lua-${LUA_VERSION}.tar.gz
        [ $? -ne 0  ] && { color "lua-${LUA_VERSION}.tar.gz 文件下载失败" 1; exit; }
    fi

    ${GREEN}开始编译LUA${END}
    cd ${SRC_DIR} && tar xf lua-${LUA_VERSION}.tar.gz && cd lua-${LUA_VERSION}
    make linux test

    ${GREEN}创建软链接${END}
    ln -s /usr/local/src/lua-${LUA_VERSION} /usr/local/
    ln -s /usr/local/src/lua-${LUA_VERSION}/src/lua /usr/local/bin/lua
    ln -s /usr/local/src/lua-${LUA_VERSION}/src/luac /usr/local/bin/luac

    lua -v
    if [ $? -ne 0  ];then
        color "LUA安装失败" 1
        exit
    else
        color "LUA安装成功" 0
        ${GREEN} "LUA版本: ${LUA_VERSION}"${END}
        ${GREEN} "LUA安装路径: /usr/local/src/lua-${LUA_VERSION}"${END}
    fi

}


Install_HAProxy () {

    HAProxy_VERSION=1.9.16
    HAProxy_URL=https://www.haproxy.org/download/`echo ${HAProxy_VERSION} | awk -F "."  '{print $1"."$2}'`/src/
    #read -p "创建haproxy状态页用户：" HAProxy_USER
    #read -p "创建haproxy状态页密码：" HAProxy_PASSWORD

    HAProxy_USER="admin"
    HAProxy_PASSWORD="000000"


    lua -v &>/dev/null || { color "开始安装LUA" 0; Install_lua; }

    ${GREEN}开始安装HAProxy依赖包${END}
    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum install -y wget gcc readline-devel libtermcap-devel ncurses-devel libevent-devel
        yum install -y openssl-devel pcre-devel systemd-devel gcc gcc-c++ glibc glibc-devel 
        yum install -y pcre pcre-devel openssl openssl-devel systemd-devel make
    else
        apt update;apt install -y wget  gcc make libssl-dev libpcre3 libpcre3-dev zlib1g-dev libreadline-dev libsystemd-dev
    fi

    if [ ! -e ${SRC_DIR}/haproxy-${HAProxy_VERSION}.tar.gz ];then
        ${GREEN}开始下载HAProxy源码包${END}
        cd ${SRC_DIR}
        wget ${HAProxy_URL}/haproxy-${HAProxy_VERSION}.tar.gz
        [ $? -ne 0  ] && { color "haproxy-${HAProxy_VERSION}.tar.gz 文件下载失败" 1; exit; }
    fi

    useradd -s /sbin/nologin haproxy &> /dev/null

    ${GREEN}开始编译HAProxy${END}
    cd ${SRC_DIR}
    tar xf haproxy-${HAProxy_VERSION}.tar.gz && cd haproxy-${HAProxy_VERSION}
    make -j ${CPUS} ARCH=x86_64 TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_CPU_AFFINITY=1 PREFIX=/usr/local/haproxy -s
    make install PREFIX=/usr/local/haproxy -s

    ${GREEN}创建软链接${END}
    ln -s /usr/local/haproxy/sbin/haproxy /usr/local/bin/haproxy

    ${GREEN}开始创建$USER 配置文件${END}
    mkdir /etc/haproxy/conf.d/ -p
    sysctl -w net.ipv4.ip_nonlocal_bind=1
    echo "sysctl -w net.ipv4.ip_nonlocal_bind=1" > /etc/rc.d/rc.local
    chmod +x /etc/rc.d/rc.local

    cat > /usr/lib/systemd/system/haproxy.service <<-EOF
[Unit]
Description=HAProxy Load Balancer
After=syslog.target network.target

[Service]
ExecStartPre=/usr/local/bin/haproxy -f /etc/haproxy/haproxy.cfg -f /etc/haproxy/conf.d/ -c -q
ExecStart=/usr/local/bin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -f /etc/haproxy/conf.d/ -p /var/lib/haproxy/haproxy.pid
ExecReload=/bin/kill -USR2 \$MAINPID
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/haproxy/haproxy.cfg <<-EOF
global
    maxconn 100000
    chroot /usr/local/haproxy
    stats socket /var/lib/haproxy/haproxy.sock mode 600 level admin
    #uid 99
    #gid 99
    user haproxy
    group haproxy
    daemon

    #nbproc 4
    #cpu-map 1 0
    #cpu-map 2 1
    #cpu-map 3 2
    #cpu-map 4 3
    pidfile /var/lib/haproxy/haproxy.pid
    log 127.0.0.1 local2 info

defaults
    option http-keep-alive
    option forwardfor
    maxconn 100000
    mode http
    timeout connect 300000ms
    timeout client 300000ms
    timeout server 300000ms


listen stats
    mode http
    bind 0.0.0.0:9999
    stats enable
    log global
    #stats refresh 10
    stats realm HAProxy\ 
    stats uri /status
    stats auth ${HAProxy_USER}:${HAProxy_PASSWORD}

#listen web_port
#   bind 10.0.0.10:80
#   mode tcp
#   log global
#   server web1 127.0.0.1:8080 check inter 3000 fall 2 rise 5
#   server web1 127.0.0.1:8080 check inter 3000 fall 2 rise 5
EOF

    # read -p "$(echo -e '\033[1;32m请输入需要绑定的VIP和端口号例如 10.0.0.10:80 : \033[0m')" VIP
    # read -p "$(echo -e '\033[1;32m请输入后台服务器ip和端口例如 10.0.0.7:80 : \033[0m')" SERVER
    # read -p "$(echo -e '\033[1;32m请输入后台服务器ip和端口例如 10.0.0.17:80 : \033[0m')" SERVERI

    VIP="10.0.0.101:80"
    SERVER="10.0.0.102:80"
    SERVERI="10.0.0.103:80"

    cat > /etc/haproxy/conf.d/test.cfg <<-EOF
listen test_web
bind $VIP
mode tcp
server web1 $SERVER check
server web2 $SERVERI check
EOF

    mkdir /var/lib/haproxy &> /dev/null
    chown haproxy:haproxy /var/lib/haproxy/ -R &> /dev/null
    systemctl start haproxy
    systemctl enable haproxy

    ${GREEN}"启动haproxy中！"${END}
    sleep 5

    ss -ntlp|grep -wq 9999

    if [ $? -eq 0 ];then
        color " HAProxy 服务启动成功" 0
    else
        color " HAProxy 服务启动失败" 1
        exit      
    fi

    ${GREEN}HAProxy状态页：http://${HOST}:9999/status${END}
    ${GREEN}用户名/密码：${HAProxy_USER}:${HAProxy_PASSWORD}${END}


}

Install_keepalived () {

    KEEP_VERSION=2.3.3
    KEEP_URL=https://keepalived.org/software/
    INTER_NAME=`ip a | grep -E "^[0-9]+: e[a-z0-9]+" | awk -F": |: " '{print $2}' | head -1`

    ${GREEN}开始安装keepalived依赖包${END}

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum install -y gcc curl openssl-devel libnl3-devel net-snmp-devel wget make
    else
        apt update;apt -y install make gcc ipvsadm build-essential pkg-config libmnl-dev libsystemd-dev
        apt install -y automake autoconf libipset-dev libnl-3-dev libnl-genl-3-dev
        apt install -y libssl-dev libxtables-dev libip4tc-dev libip6tc-dev libipset-dev
        apt install -y libmagic-dev libsnmp-dev libglib2.0-dev libpcre2-dev libnftnl-dev 
    fi

    if [ ! -e ${SRC_DIR}/keepalived-${KEEP_VERSION}.tar.gz ];then
        ${GREEN}开始下载keepalived源码包${END}
        cd ${SRC_DIR}
        wget ${KEEP_URL}/keepalived-${KEEP_VERSION}.tar.gz
        [ $? -ne 0  ] && { color "keepalived-${KEEP_VERSION}.tar.gz 文件下载失败" 1; exit; }
    fi

    ${GREEN}开始编译keepalived${END}
    cd ${SRC_DIR} && tar xf keepalived-${KEEP_VERSION}.tar.gz && cd keepalived-${KEEP_VERSION}
    ./configure --prefix=/usr/local/keepalived && make -j ${CPUS}&& make install

    ln -s /usr/local/keepalived/sbin/keepalived /usr/local/bin/
    #cp ${SRC-DIR}/keepalived-${KEEP_VERSION}/keepalived.service /usr/lib/systemd/system/keepalived.service
    mkdir /etc/keepalived
    cp /usr/local/keepalived/etc/keepalived/keepalived.conf.sample /etc/keepalived/keepalived.conf

    sed -i "s/eth0/${INTER_NAME}/g" /etc/keepalived/keepalived.conf
    systemctl enable keepalived --now &> /dev/null
    if [ $? -eq 0 ];then
        color " keepalived 服务启动成功" 0
    else
        color " keepalived 服务启动失败" 1
        exit      
    fi

}

Install_Redis () {

    REDIS_VERSION=7.4.2
    REDIS_URL=https://download.redis.io/releases/
    REDIS_PASSWORD=000000

    ${GREEN}开始安装依赖包${END}
    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum install -y gcc make jemalloc-devel systemd-devel wget
    else
        apt update;apt install -y wget gcc make libjemalloc-dev libsystemd-dev
    fi

    if [ ! -e ${SRC_DIR}/redis-${REDIS_VERSION}.tar.gz ];then
        ${GREEN}开始下载redis源码包${END}
        cd ${SRC_DIR}
        wget ${REDIS_URL}/redis-${REDIS_VERSION}.tar.gz
        [ $? -ne 0  ] && { color "redis-${REDIS_VERSION}.tar.gz 文件下载失败" 1; exit; }
    fi

    ${GREEN}开始编译redis${END}
    cd ${SRC_DIR} && tar xf redis-${REDIS_VERSION}.tar.gz && cd redis-${REDIS_VERSION}
    make -j ${CPUS} USE_SYSTEMD=yes PREFIX=/usr/local/redis && make install

    
    if id redis &> /dev/null ;then 
        color "Redis 用户已存在" 0
    else
        ${GREEN}创建用户redis${END}
        useradd -r -s /sbin/nologin redis
        color "Redis 用户创建成功" 0
    fi

    ln -s /usr/local/redis/bin/redis-* /usr/bin/
    mkdir -p /usr/local/redis/{etc,log,data,run}
    cp /usr/local/src/redis-${REDIS_VERSION}/redis.conf /usr/local/redis/etc/redis.conf

    sed -i -e 's/bind 127.0.0.1/bind 0.0.0.0/'  -e "/# requirepass/a requirepass ${REDIS_PASSWORD}" \
    -e "/^dir .*/c dir /usr/local/redis/data/"  -e "/logfile .*/c logfile /usr/local/redis/log/redis-6379.log"  \
    -e  "/^pidfile .*/c pidfile /usr/local/redis/run/redis_6379.pid" /usr/local/redis/etc/redis.conf

    chown redis:redis /usr/local/redis -R

    cat > /etc/redis/redis.conf <<-EOF
net.core.somaxconn = 1024
vm.overcommit_memory = 1
EOF
    sysctl -p

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.d/rc.local
        chmod +x /etc/rc.d/rc.local
        . /etc/rc.d/rc.local 
    else
        echo -e '#!/bin/bash\necho never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
        chmod +x /etc/rc.local
        . /etc/rc.local
    fi

    cat > /lib/systemd/system/redis.service <<EOF
[Unit]
Description=Redis persistent key-value database
After=network.target

[Service]
ExecStart=redis-server /usr/local/redis/etc/redis.conf --supervised systemd
ExecStop=/bin/kill -s QUIT \$MAINPID
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload 
    systemctl enable --now redis &> /dev/null 
    
    if [ $? -eq 0 ];then
        color "Redis 服务启动成功,Redis信息如下:"  0
    else
        color "Redis 启动失败" 1
        exit
    fi
    sleep 2
    redis-cli -a ${REDIS_PASSWORD} INFO Server 2> /dev/null

}

Install_zookeeper () {

    ZK_VERSION=3.8.1
    ZK_URL=https://archive.apache.org/dist/zookeeper/zookeeper-${ZK_VERSION}/apache-zookeeper-${ZK_VERSION}-bin.tar.gz
    #ZK_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-${ZK_VERSION}/apache-zookeeper-${ZK_VERSION}-bin.tar.gz
    #ZK_URL="https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/stable/apache-zookeeper-${ZK_VERSION}-bin.tar.gz"
    INSTALL_DIR=/usr/local/zookeeper

    #echo -e "\E[1;$[RANDOM%7+31]m请输入集群IP以逗号隔开(单机只需要输入本机IP即可)\E[0m"
    #read -p "CLUSTER_IPS： " ZK_IP
    ZK_IP="10.0.0.101,10.0.0.102,10.0.0.103"
    NUM=`echo ${ZK_IP} | sed 's/,/\n/g' | wc -l`

    if [ ${NUM} -eq 1 ];then
        Install_zk_single
    else
        Install_zk_cluster
    fi

}

Install_zk_single () {

    java -version &> /dev/null
    if [ ${?} -ne 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            yum -y install java-1.8.0-openjdk-devel || { color "安装JDK失败!" 1; exit 1; }
            #yum -y install java-11-openjdk || { color "安装JDK失败!" 1; exit 1; }
        else
            apt update
            apt install openjdk-11-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
            #apt install openjdk-8-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
        fi
    fi

    if [ ! -f ${SRC_DIR}/apache-zookeeper-${ZK_VERSION}-bin.tar.gz ] ;then
        wget -P /usr/local/src/ --no-check-certificate ${ZK_URL} || { color  "下载失败!" 1 ;exit ; }
    fi
    tar xf /usr/local/src/${ZK_URL##*/} -C /usr/local
    ln -s /usr/local/apache-zookeeper-*-bin/ ${INSTALL_DIR}
    echo "PATH=${INSTALL_DIR}/bin:\$PATH" >  /etc/profile.d/zookeeper.sh
    .  /etc/profile.d/zookeeper.sh
    mkdir -p ${INSTALL_DIR}/data 
    cat > ${INSTALL_DIR}/conf/zoo.cfg <<EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=${INSTALL_DIR}/data
clientPort=2181
maxClientCnxns=128
autopurge.snapRetainCount=3
autopurge.purgeInterval=24
EOF
	cat > /lib/systemd/system/zookeeper.service <<EOF
[Unit]
Description=zookeeper.service
After=network.target

[Service]
Type=forking
#Environment=${INSTALL_DIR}
ExecStart=${INSTALL_DIR}/bin/zkServer.sh start
ExecStop=${INSTALL_DIR}/bin/zkServer.sh stop
ExecReload=${INSTALL_DIR}/bin/zkServer.sh restart

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now  zookeeper.service
    systemctl is-active zookeeper.service

	if [ ${?} -eq 0 ] ;then 
        color "zookeeper 安装成功!" 0  
    else 
        color "zookeeper 安装失败!" 1
        exit 1
    fi

}

Install_zk_cluster () {

    config_ssh

    if [ ! -f ${SRC_DIR}/apache-zookeeper-${ZK_VERSION}-bin.tar.gz ] ;then
        wget -P /usr/local/src/ --no-check-certificate ${ZK_URL} || { color  "下载失败!" 1 ;exit ; }
    fi

    for i in `echo ${ZK_IP} | sed 's/,/\n/g'`
    do
        ssh ${i} "java -version" &> /dev/null
        if [ ${?} -ne 0 ];then
            if [[ ${ID} =~ centos|rocky|rhel ]];then
                ssh ${i} "yum -y install java-1.8.0-openjdk-devel" || { color "安装JDK失败!" 1; exit 1; }
                #yum -y install java-11-openjdk || { color "安装JDK失败!" 1; exit 1; }
            else
                ssh ${i} "apt update;apt install openjdk-11-jdk -y" || { color "安装JDK失败!" 1; exit 1; }
            fi
        fi

        scp ${SRC_DIR}/apache-zookeeper-${ZK_VERSION}-bin.tar.gz  ${i}:/usr/local/src/

        ssh ${i} "tar xf /usr/local/src/${ZK_URL##*/} -C /usr/local && ln -s /usr/local/apache-zookeeper-*-bin/ /usr/local/zookeeper"
        ssh ${i} "echo 'PATH=/usr/local/zookeeper/bin:\$PATH' >  /etc/profile.d/zookeeper.sh && .  /etc/profile.d/zookeeper.sh"
        ssh ${i} "mkdir -p /usr/local/zookeeper/data"

    done

    cat > /usr/local/zookeeper/conf/zoo.cfg <<EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/usr/local/zookeeper/data
clientPort=2181
maxClientCnxns=128
autopurge.snapRetainCount=3
autopurge.purgeInterval=24
EOF

    cat > /lib/systemd/system/zookeeper.service <<EOF
[Unit]
Description=zookeeper.service
After=network.target

[Service]
Type=forking
#Environment=/usr/local/zookeeper
ExecStart=/usr/local/zookeeper/bin/zkServer.sh start
ExecStop=/usr/local/zookeeper/bin/zkServer.sh stop
ExecReload=/usr/local/zookeeper/bin/zkServer.sh restart

[Install]
WantedBy=multi-user.target
EOF

    for i in `seq 1 ${NUM}`
    do
        echo "server.`echo ${ZK_IP} | sed 's/,/\n/g'| awk "NR==${i}" | awk -F '.' '{print $4}'` `echo ${ZK_IP} | sed 's/,/\n/g'| awk "NR==${i}"`:2888:3888" >> /usr/local/zookeeper/conf/zoo.cfg
        ssh `echo ${ZK_IP} | sed 's/,/\n/g'| awk "NR==${i}"` "echo `echo ${ZK_IP} | sed 's/,/\n/g'| awk "NR==${i}" | awk -F '.' '{print $4}'` > /usr/local/zookeeper/data/myid"
    done

    for x in `echo ${ZK_IP} | sed 's/,/\n/g'`
    do
        scp /usr/local/zookeeper/conf/zoo.cfg ${x}:/usr/local/zookeeper/conf/zoo.cfg
        scp /lib/systemd/system/zookeeper.service ${x}:/lib/systemd/system/zookeeper.service
        ssh ${x} "systemctl daemon-reload && systemctl enable --now  zookeeper.service"
    done

    sleep 5

    . /etc/profile.d/zookeeper.sh

    zkServer.sh status | grep  "Mode:"

    if [ ${?} -eq 0 ] ;then 
        color "zookeeper 安装成功!" 0  
    else 
        color "zookeeper 安装失败!" 1
        exit 1
    fi

}

Install_kafka () {

    KAFKA_VERSION=4.0.0
    #KAFKA_VERSION=3.3.2
    SCALA_VERSION=2.13
    KAFKA_URL="https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
    KAFKA_INSTALL_DIR=/usr/local/kafka

    if [ `echo ${KAFKA_VERSION} | cut -d '.' -f 1` == 4 ];then
        install_kafka_4
    else
        install_kafka
    fi

}

install_kafka_4 () {

    #echo -e "\E[1;$[RANDOM%7+31]m请输入集群IP以逗号隔开\E[0m"
    #read -p "CLUSTER_IPS： " KA_IP
    KA_IP="10.0.0.101,10.0.0.102,10.0.0.103"
    NUM=`echo ${KA_IP} | sed 's/,/\n/g' | wc -l`

    grep `echo ${KA_IP} | sed 's/,/\n/g' | awk "NR==$[RANDOM%${NUM}+1]"` /root/.ssh/known_hosts &> /dev/null
    if [ ${?} -ne 0 ];then
        config_ssh
    fi

    if [ ! -f ${SRC_DIR}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz ];then
        wget -P /usr/local/src  $KAFKA_URL  || { color  "下载失败!" 1 ;exit ; }
    fi

    cat > /lib/systemd/system/kafka.service <<EOF
[Unit]                                                                          
Description=Apache kafka
After=network.target

[Service]
Type=simple
#Environment=JAVA_HOME=/data/server/java
#PIDFile=${KAFKA_INSTALL_DIR}/kafka.pid
ExecStart=${KAFKA_INSTALL_DIR}/bin/kafka-server-start.sh  ${KAFKA_INSTALL_DIR}/config/server.properties
ExecStop=/bin/kill  -TERM \${MAINPID}
Restart=always
RestartSec=20

[Install]
WantedBy=multi-user.target
EOF

    for i in `echo ${KA_IP} | sed 's/,/\n/g'`
    do
        ssh ${i} "java -version" &> /dev/null
        if [ ${?} -ne 0 ];then
            if [[ ${ID} =~ centos|rocky|rhel ]];then
                ssh ${i} "yum -y install java-21-openjdk-devel" || { color "安装JDK失败!" 1; exit 1; }
            else               
                ssh ${i} "apt update;apt install openjdk-21-jdk -y" || { color "安装JDK失败!" 1; exit 1; }
            fi
        fi
        scp ${SRC_DIR}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz  ${i}:/usr/local/src/
        scp /lib/systemd/system/kafka.service ${i}:/lib/systemd/system/kafka.service
        ssh ${i} "tar xf /usr/local/src/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /usr/local && ln -s /usr/local/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /usr/local/kafka"
        ssh ${i} "mkdir ${KAFKA_INSTALL_DIR}/data && echo PATH=${KAFKA_INSTALL_DIR}/bin:'$PATH' > /etc/profile.d/kafka.sh && . /etc/profile.d/kafka.sh"
        ssh ${i} "cp ${KAFKA_INSTALL_DIR}/config/server.properties ${KAFKA_INSTALL_DIR}/config/server.properties.bak && ln -s ${KAFKA_INSTALL_DIR}/bin/*.sh /usr/local/bin/"
    done

    for i in `seq 1 ${NUM}`
    do
        ssh `echo ${KA_IP} | sed 's/,/\n/g'| awk "NR==${i}"` "cat > ${KAFKA_INSTALL_DIR}/config/server.properties <<EOF
# 基础配置
node.id=${i}
process.roles=broker,controller
controller.quorum.voters=1@`echo ${KA_IP} | sed 's/,/\n/g'| awk "NR==1"`:9093,2@`echo ${KA_IP} | sed 's/,/\n/g'| awk "NR==2"`:9093,3@`echo ${KA_IP} | sed 's/,/\n/g'| awk "NR==3"`:9093

# 网络配置
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL
listeners=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
advertised.listeners=PLAINTEXT://`echo ${KA_IP} | sed 's/,/\n/g'| awk "NR==${i}"`:9092
controller.listener.names=CONTROLLER

# 存储配置
log.dirs=${KAFKA_INSTALL_DIR}/data
num.partitions=3
default.replication.factor=3
min.insync.replicas=2

# 性能优化
socket.send.buffer.bytes=1024000
socket.receive.buffer.bytes=1024000
num.network.threads=8
num.io.threads=16
EOF"
    done

    for i in `echo ${KA_IP} | sed 's/,/\n/g'`
    do
        ssh ${i} "${KAFKA_INSTALL_DIR}/bin/kafka-storage.sh format -t `${KAFKA_INSTALL_DIR}/bin/kafka-storage.sh random-uuid` -c ${KAFKA_INSTALL_DIR}/config/server.properties"
        ssh ${i} "systemctl daemon-reload && systemctl enable --now  kafka.service"
    done

    sleep 5	
 
	systemctl is-active kafka.service
	if [ $? -eq 0 ] ;then 
        color "kafka 安装成功!" 0  
    else 
        color "kafka 安装失败!" 1
        exit 1
    fi 

}



install_kafka () {

    systemctl is-active zookeeper.service &> /dev/null
    if [ ${?} -ne 0 ];then
        Install_zookeeper
    fi

    if [ ! -f ${SRC_DIR}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz ];then
        wget -P /usr/local/src  $KAFKA_URL  || { color  "下载失败!" 1 ;exit ; }
    fi

    echo ${ZK_IP} | grep '.'
    if [ ${?} -ne 0 ];then
        # echo -e "\E[1;$[RANDOM%7+31]m请输入集群IP以逗号隔开\E[0m"
        # read -p "CLUSTER_IPS： " ZK_IP
        ZK_IP="10.0.0.101,10.0.0.102,10.0.0.103"
        NUM=`echo ${ZK_IP} | sed 's/,/\n/g' | wc -l`
    fi

    grep `echo ${ZK_IP} | sed 's/,/\n/g' | awk "NR==$[RANDOM%${NUM}+1]"` /root/.ssh/known_hosts &> /dev/null
    if [ ${?} -ne 0 ];then
        config_ssh
    fi

    cat > /lib/systemd/system/kafka.service <<EOF
[Unit]                                                                          
Description=Apache kafka
After=network.target

[Service]
Type=simple
#Environment=JAVA_HOME=/data/server/java
#PIDFile=${KAFKA_INSTALL_DIR}/kafka.pid
ExecStart=${KAFKA_INSTALL_DIR}/bin/kafka-server-start.sh  ${KAFKA_INSTALL_DIR}/config/server.properties
ExecStop=/bin/kill  -TERM \${MAINPID}
Restart=always
RestartSec=20

[Install]
WantedBy=multi-user.target
EOF

    for i in `echo ${ZK_IP} | sed 's/,/\n/g'`
    do
        scp ${SRC_DIR}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz  ${i}:${SRC_DIR}/
        scp /lib/systemd/system/kafka.service ${i}:/lib/systemd/system/kafka.service
        ssh ${i} "tar xf ${SRC_DIR}/${KAFKA_URL##*/}  -C /usr/local/"
        ssh ${i} "ln -s ${KAFKA_INSTALL_DIR}_*/ ${KAFKA_INSTALL_DIR} && mkdir ${KAFKA_INSTALL_DIR}/data"
        ssh ${i} "echo PATH=${KAFKA_INSTALL_DIR}/bin:'$PATH' > /etc/profile.d/kafka.sh && . /etc/profile.d/kafka.sh"
    done

    for i in `seq 1 ${NUM}`
    do
        ssh `echo ${ZK_IP} | sed 's/,/\n/g'| awk "NR==${i}"` "cat > ${KAFKA_INSTALL_DIR}/config/server.properties <<EOF
broker.id=`echo ${ZK_IP} | sed 's/,/\n/g'| awk "NR==${i}" | awk -F '.' '{print $4}'`
listeners=PLAINTEXT://`echo ${ZK_IP} | sed 's/,/\n/g'| awk "NR==${i}"`:9092
log.dirs=${KAFKA_INSTALL_DIR}/data
num.partitions=1
log.retention.hours=168
zookeeper.connect=`echo ${ZK_IP} | sed 's/,/\n/g'| awk "NR==1"`:2181,`echo ${ZK_IP} | sed 's/,/\n/g'| awk "NR==3"`:2181,`echo ${ZK_IP} | sed 's/,/\n/g'| awk "NR==3"`:2181
zookeeper.connection.timeout.ms=6000
EOF"
    done

    
    for i in `echo ${ZK_IP} | sed 's/,/\n/g'`
    do
        ssh ${i} "systemctl daemon-reload"
        	#kafka-server-start.sh -daemon ${KAFKA_INSTALL_DIR}/config/server.properties
        ssh ${i} "systemctl enable --now kafka.service"
    done

    sleep 5	
 
	systemctl is-active kafka.service
	if [ ${?} -eq 0 ] ;then 
        color "kafka 安装成功!" 0  
    else 
        color "kafka 安装失败!" 1
        exit 1
    fi    

}

Install_git () {

    GIT_VERSION=2.49.0
    GIT_URL=https://github.com/git/git/archive/refs/tags/v${GIT_VERSION}.tar.gz

    ${GREEN}安装依赖${END}
    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum -y install gcc make openssl-devel curl-devel expat-devel wget

    else
        apt update
        apt install gcc make dh-autoreconf libcurl4-gnutls-dev libexpat1-dev wget
    fi

    if [ ! -f ${SRC_DIR}/v${GIT_VERSION}.tar.gz ];then
        ${GREEN}下载源码包${END}
        wget -P ${SRC_DIR} ${GIT_URL}
    fi

    cd ${SRC_DIR} && tar xf v${GIT_VERSION}.tar.gz && cd git-${GIT_VERSION}
    make -j ${CPUS} prefix=/usr/local/git all && make prefix=/usr/local/git install
    echo 'PATH=/usr/local/git/bin/:$PATH' > /etc/profile.d/git.sh
    . /etc/profile.d/git.sh && git --version
    if [ ${?} -eq 0 ];then
        color "git 安装成功!" 0
    else
        color "git 安装失败!" 1
        exit 1
    fi

    ${GREEN}创建示例项目project${END}
    mkdir -p /root/project && cd /root/project
    cat > init.sh <<EOF
git init
git config --global user.name wang
git config --global user.email wang@qq.com
git config --global core.editor vim
git config --global color.ui true
git remote add origin git@gitlab.example.com:testgroup/testproject.git

# git clone https://<用户名>:<密码>@gitee.com/lbtooth/meta-project.git
# git remote add origin https://<user>:<password>@gitee.com/wsq1203/testproject.git
# git checkout -b main
# git add .
# git commit -m "init"
# git push -u origin main
# git push -u origin --tags
EOF

}

Install_gitlab () {

    GITLAB_VERSION=17.11.1
    GITLAB_R_URL=https://packages.gitlab.com/gitlab/gitlab-ce/packages/el/`echo ${VERSION_ID}|cut -d. -f1`/gitlab-ce-${GITLAB_VERSION}-ce.0.el`echo ${VERSION_ID}|cut -d. -f1`.x86_64.rpm/download.rpm
    GITLAB_U_URL=https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/${VERSION_CODENAME}/gitlab-ce_${GITLAB_VERSION}-ce.0_amd64.deb/download.deb
    #GITLAB_U_URL=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/ubuntu/pool/${VERSION_CODENAME}/main/g/gitlab-ce/gitlab-ce_${GITLAB_VERSION}-ce.0_amd64.deb

    GITLAB_ROOT_PASSWORD=wsq011203
    SMTP_PASSWORD=fgprsdjtojaicifd

    git --version &> /dev/null
    if [ ! ${?} -eq 0 ];then
        Install_git
    fi


    if [[ ${ID} =~ centos|rocky|rhel ]];then
        if [ ! -f ${SRC_DIR}/gitlab-ce-${GITLAB_VERSION}-ce.0.el`echo ${VERSION_ID}|cut -d. -f1`.x86_64.rpm ];then
            wget -P ${SRC_DIR} ${GITLAB_R_URL}  || { color  "下载失败!" 1 ;exit ; }          
        fi
        yum install -y ${SRC_DIR}/gitlab-ce-${GITLAB_VERSION}-ce.0.el`echo ${VERSION_ID}|cut -d. -f1`.x86_64.rpm 2> /dev/null
        yum install -y ${SRC_DIR}/download.rpm 2> /dev/null
    else
        if [ ! -f ${SRC_DIR}/gitlab-ce_${GITLAB_VERSION}-ce.0_amd64.deb ];then
            wget -P ${SRC_DIR} ${GITLAB_U_URL} || { color  "下载失败!" 1 ;exit ; }
        fi
        apt update
        apt install -y ${SRC_DIR}/gitlab-ce_${GITLAB_VERSION}-ce.0_amd64.deb 2> /dev/null
        apt install -y ${SRC_DIR}/download.deb 2> /dev/null
    fi

    sed -i.bak  "/^external_url.*/c external_url \'http://${HOST}\'" /etc/gitlab/gitlab.rb
    cat >> /etc/gitlab/gitlab.rb <<EOF
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.qq.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "3311987957@qq.com"
gitlab_rails['smtp_password'] = "${SMTP_PASSWORD}"
gitlab_rails['smtp_domain'] = "qq.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = false
gitlab_rails['smtp_tls'] = true
gitlab_rails['gitlab_email_from'] = "3311987957@qq.com"
gitlab_rails['initial_root_password'] = "${GITLAB_ROOT_PASSWORD}"
EOF
    gitlab-ctl reconfigure
    gitlab-ctl status

    if [ ${?} -eq 0 ];then
        color "gitlab 安装成功!" 0
    else
        color "gitlab 安装失败!" 1
        exit 1
    fi
    echo "-------------------------------------------------------------------"
    echo -e "请访问链接: \E[32;1mhttp://$HOST/\E[0m"
 	echo -e "用户和密码: \E[32;1mroot/${GITLAB_ROOT_PASSWORD}\E[0m"

}

Install_Jenkins () {

    JENKINS_VERSION=2.492.3
    JENKINS_R_URL=https://mirrors.tuna.tsinghua.edu.cn/jenkins/redhat-stable/jenkins-${JENKINS_VERSION}-1.1.noarch.rpm
    JENKINS_U_URL=https://mirrors.tuna.tsinghua.edu.cn/jenkins/debian-stable/jenkins_${JENKINS_VERSION}_all.deb
    #JENKINS_R_URL=https://get.jenkins.io/redhat-stable/jenkins-${JENKINS_VERSION}-1.1.noarch.rpm
    #JENKINS_U_URL=https://get.jenkins.io/debian-stable/jenkins_${JENKINS_VERSION}_all.deb

    java -version &> /dev/null
    if [ ! ${?} -eq 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            yum -y install java-21-openjdk
        else
            apt update; apt -y install openjdk-21-jdk
        fi
    fi

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        if [ ! -f ${SRC_DIR}/jenkins-${JENKINS_VERSION}-1.1.noarch.rpm ];then
            wget -P ${SRC_DIR} ${JENKINS_R_URL} || { color  "下载失败!" 1 ;exit ; }
        fi
        yum install -y ${SRC_DIR}/jenkins-${JENKINS_VERSION}-1.1.noarch.rpm
    else
        if [ ! -f ${SRC_DIR}/jenkins_${JENKINS_VERSION}_all.deb ];then
            wget -P ${SRC_DIR} ${JENKINS_U_URL} || { color  "下载失败!" 1 ;exit ; }
        fi
        apt update;apt install -y daemon net-tools
        apt install -y ${SRC_DIR}/jenkins_${JENKINS_VERSION}_all.deb
    fi

    systemctl enable --now jenkins

    while :;do
        [ -f /var/lib/jenkins/secrets/initialAdminPassword ] && { key=`cat /var/lib/jenkins/secrets/initialAdminPassword` ; break; }
        sleep 1
    done

    systemctl is-active jenkins || ss -lnt | grep 8080

    if [ ${?} -eq 0 ];then
        color "jenkins 安装成功!" 0
    else
        color "jenkins 安装失败!" 1
        exit 1
    fi

    echo "-------------------------------------------------------------------"
    echo -e "请访问链接: \E[32;1mhttp://${HOST}:8080/\E[0m"
    echo -e "登录秘钥: \c"
    ${GREEN}${key}${END}

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        sed -i 's/JENKINS_USER="jenkins"/JENKINS_USER="root"/g' /etc/sysconfig/jenkins
    else
        sed -i 's/User=jenkins/User=root/g' /lib/systemd/system/jenkins.service
        sed -i 's/Group=jenkins/Group=root/g' /lib/systemd/system/jenkins.service
    fi

    systemctl daemon-reload
    systemctl restart jenkins.service 

    sed -i.bak 's#updates.jenkins.io/download#mirror.tuna.tsinghua.edu.cn/jenkins#g' /var/lib/jenkins/updates/default.json
    sed -i 's#www.google.com#www.baidu.com#g' /var/lib/jenkins/updates/default.json
    ${GREEN}WEB修改安装源：${END}
    ${GREEN}https://mirror.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json${END}
    ${GREEN}https://mirrors.huaweicloud.com/jenkins/update-center.json${END}

    # mirrors.huaweicloud.com/jenkins/plugins
    # https://mirrors.huaweicloud.com/jenkins/update-center.json
    
}

Install_Go () {

    GO_VERSION=1.24.0
    URL=https://studygolang.com/dl/golang/go${GO_VERSION}.linux-amd64.tar.gz

    INSTALL_DIR=/usr/local
    GOPATH_DIR=/opt/go

    if ! [[ $ID_LIKE =~ debian|rhel ]];then
        color "不支持此操作系统，退出!" 1
        exit
    fi
    
    if [ ! -f  ${SRC_DIR}/go${GO_VERSION}.linux-amd64.tar.gz ] ;then
        cd ${SRC_DIR} && wget $URL
    fi
    
    tar xf ${SRC_DIR}/go${GO_VERSION}.linux-amd64.tar.gz -C ${INSTALL_DIR} || { color "Go 解压缩失败!" 1;exit; }
    cat >  /etc/profile.d/go.sh <<EOF
export GOROOT=${INSTALL_DIR}/go
export PATH=$PATH:\$GOROOT/bin
EOF
    .  /etc/profile.d/go.sh

    ln -s ${INSTALL_DIR}/go/bin/* /usr/local/bin/

    go version 
    if [ $? -eq 0 ] ;then 
        color "Golang 安装成功!" 0  
    else 
        color "Golang 安装失败!" 1
        exit 1
    fi

    cat >>  /etc/profile.d/go.sh <<EOF
export GOPATH=${GOPATH_DIR}
EOF
    [ ! -d ${GOPATH_DIR} ] && mkdir -pv ${GOPATH_DIR}/src
    . /etc/profile.d/go.sh
    go env -w GOPROXY=https://goproxy.cn,direct

    mkdir -pv ${GOPATH_DIR}/src/hello
    cd  ${GOPATH_DIR}/src/hello
    cat > hello.go <<EOF
package main

import "fmt"

func main() {
   fmt.Println("Hello, world!")
}
EOF
   go mod init
   go build
   ./hello

}

Install_sonarqube () {

    SONARQUBE_VER="9.9.0.65466"
    SONARQUBE_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VER}.zip"
    SONAR_USER=sonarqube
    SONAR_USER_PASSWORD=000000

    java -version &> /dev/null
    if [ ! ${?} -eq 0 ];then
        if [ $ID = "centos" -o $ID = "rocky" ];then
            yum -y install java-17-openjdk-devel unzip
        else 
            apt update
            apt -y install openjdk-17-jdk unzip
            #apt -y install openjdk-11-jdk
        fi
    fi

    useradd -s /bin/bash -m sonarqube 
    cat >> /etc/sysctl.conf <<EOF
vm.max_map_count=524288
fs.file-max=131072
EOF
    sysctl -p
    cat >> /etc/security/limits.conf  <<EOF
sonarqube  -  nofile 131072
sonarqube  -  nproc  8192
EOF

    systemctl is-active postgresql 
    if [ ${?} -eq 0 ];then
        ${GREEN}PostgreSQL 已安装!${END}
    else
        ${GREEN}开始安装PostgreSQL${END}
        if [ $ID = "centos" -o $ID = "rocky" ];then
            if [ `echo ${VERSION_ID}|cut -d. -f1` -eq 7 ];then
                rpm -i http://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
                yum -y install postgresql12-server postgresql12 postgresql12-libs unzip
                postgresql-12-setup --initdb
            elif [ `echo ${VERSION_ID}|cut -d. -f1` -eq 8 ];then
                rpm -i https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhatrepo-latest.noarch.rpm
                dnf -qy module disable postgresql
                dnf install -y postgresql12-server unzip
                /usr/pgsql-12/bin/postgresql-12-setup initdb
            else
                echo  "请自行安装PostgreSQL"
                exit
            fi
            systemctl enable  postgresql.service
            systemctl start  postgresql.service
        else 
            apt update
            apt -y install postgresql
        fi
        if [ $? -eq 0 ];then
            color "安装postgresql完成!" 0
        else
            color "安装postgresql失败!" 1
            exit
        fi
    fi

    if [ $ID = "centos" -o $ID = "rocky" ];then
        sed -i.bak "/listen_addresses/a listen_addresses = '*'"  /var/lib/pgsql/data/postgresql.conf
        cat >>  /var/lib/pgsql/data/pg_hba.conf <<EOF
host    all             all             0.0.0.0/0               md5
EOF
    else 
        sed -i.bak "/listen_addresses/c listen_addresses = '*'" /etc/postgresql/1*/main/postgresql.conf 
        cat >>  /etc/postgresql/*/main/pg_hba.conf <<EOF
host    all             all             0.0.0.0/0               md5
EOF
    fi

    systemctl restart postgresql
    
    su - postgres -c "psql -U postgres <<EOF
CREATE USER $SONAR_USER WITH ENCRYPTED PASSWORD '$SONAR_USER_PASSWORD';
CREATE DATABASE sonarqube OWNER $SONAR_USER;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO $SONAR_USER;
EOF"

    
    if [ ! -f ${SRC_DIR}/sonarqube-${SONARQUBE_VER}.zip ] ;then
        wget -P ${SRC_DIR} ${SONARQUBE_URL}  || { color  "下载失败!" 1 ;exit ; }
    fi
    cd ${SRC_DIR}
    unzip ${SONARQUBE_URL##*/}
    ln -s /usr/local/src/sonarqube-${SONARQUBE_VER} /usr/local/sonarqube
    chown -R sonarqube.sonarqube /usr/local/sonarqube/
    cat > /lib/systemd/system/sonarqube.service <<EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=simple
User=sonarqube
Group=sonarqube
PermissionsStartOnly=true
ExecStart=/usr/bin/nohup /usr/bin/java -Xms32m -Xmx32m -Djava.net.preferIPv4Stack=true -jar /usr/local/sonarqube/lib/sonar-application-${SONARQUBE_VER}.jar
StandardOutput=syslog
LimitNOFILE=65536
LimitNPROC=8192
TimeoutStartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    cat >> /usr/local/sonarqube/conf/sonar.properties <<EOF
sonar.jdbc.username=$SONAR_USER
sonar.jdbc.password=$SONAR_USER_PASSWORD
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
EOF

    systemctl enable --now   sonarqube.service 
    systemctl is-active sonarqube
    if [ $?  -eq 0 ];then  
        echo 
        color "sonarqube 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        ${GREEN}"http://$HOST:9000/"${END}
        echo -e "用户和密码: \c"
        ${GREEN}"admin/admin"${END}
    else
        color "sonarqube 安装失败!" 1
        exit
    fi

}

Install_sonar_scanner () {

    SONARQUBE_SERVER=10.0.0.102
    SONAR_SCANNER_VER=4.8.0.2856
    #SONAR_SCANNER_VER=4.7.0.2747
    #SONAR_SCANNER_VER=4.6.2.2472
    #SONAR_SCANNER_VER=4.3.0.2102
    URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VER}-linux.zip" 

    if [ ! -f ${SRC_DIR}/sonar-scanner-cli-${SONAR_SCANNER_VER}-linux.zip ] ;then
        wget -P ${SRC_DIR} $URL || { color  "下载失败!" 1 ;exit ; }
    fi
    cd ${SRC_DIR} && unzip sonar-scanner-cli-${SONAR_SCANNER_VER}-linux.zip -d /usr/local/src
    ln -s /usr/local/src/sonar-scanner-${SONAR_SCANNER_VER}-linux/ /usr/local/sonar-scanner
    ln -s /usr/local/sonar-scanner/bin/sonar-scanner /usr/bin/
    cat >>  /usr/local/sonar-scanner/conf/sonar-scanner.properties <<EOF
sonar.host.url=http://${SONARQUBE_SERVER}:9000 
sonar.sourceEncoding=UTF-8
EOF
    if [ $?  -eq 0 ];then  
        echo 
        color "sonar_scanner 安装完成!" 0
    else
        color "sonar_scanner 安装失败!" 1
        exit
    fi 

}

Install_elasticsearch () {

    ES_VERSION=8.6.1
    #ES_VERSION=8.18.1
    #ES_VERSION=7.17.5
    #ES_VERSION=7.9.3
    #ES_VERSION=7.6.2
    UBUNTU_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${ES_VERSION} | cut -d . -f 1`.x/apt/pool/main/e/elasticsearch/elasticsearch-${ES_VERSION}-amd64.deb"
    RHEL_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${ES_VERSION} | cut -d . -f 1`.x/yum/${ES_VERSION}/elasticsearch-${ES_VERSION}-x86_64.rpm"
    #https://mirrors.tuna.tsinghua.edu.cn/elasticstack/8.x/apt/pool/main/e/elasticsearch/elasticsearch-8.18.1-amd64.deb
    #https://mirrors.tuna.tsinghua.edu.cn/elasticstack/8.x/yum/8.18.1/elasticsearch-8.18.1-x86_64.rpm

    CLUSTER_NAME=es-cluster
    NODE_LIST='["10.0.0.101","10.0.0.102","10.0.0.103"]'
    ES_DATA=/var/lib/elasticsearch
    ES_LOGS=/var/log/elasticsearch

    MEM_TOTAL=`head -n1 /proc/meminfo |awk '{print $2}'`

    CLUSTER_NUM=`echo $NODE_LIST | tr ',' "\n" | wc -l`

    if [ ${MEM_TOTAL} -lt 1997072 ];then
        color '内存低于2G,安装失败!' 1
        exit
    elif [ ${MEM_TOTAL} -le 2997072 ];then
        color '内存不足3G,建议调整内存大小!' 2
    else
        echo
    fi

    if [ $ID = "centos" -o $ID = "rocky" ];then
        if [ ! -f ${SRC_DIR}/${RHEL_URL##*/} ];then
            wget -P ${SRC_DIR} $RHEL_URL || { color  "下载失败!" 1 ;exit ; } 
            #yum -y install ${SRC_DIR}/${RHEL_URL##*/}
        fi
    elif [ $ID = "ubuntu" ];then
        if [ ! -f ${SRC_DIR}/${UBUNTU_URL##*/} ];then
            wget -P ${SRC_DIR} $UBUNTU_URL || { color  "下载失败!" 1 ;exit ; }
            #dpkg -i ${SRC_DIR}/${UBUNTU_URL##*/}
        fi
    else
        color "不支持此操作系统!" 1
        exit
    fi

    if [ ${CLUSTER_NUM} == 1 ];then
        Install_elasticsearch_single_node
    else
        Install_elasticsearch_cluster
    fi

}

Install_elasticsearch_cluster () {

    config_ssh
    
    for i in `echo $NODE_LIST | cut -d '"' -f 2,4,6 | tr '"' '\n'`
    do
        if [ $ID = "centos" -o $ID = "rocky" ];then
            scp ${SRC_DIR}/${RHEL_URL##*/} ${i}:${SRC_DIR}/
            ssh ${i} "yum -y install ${SRC_DIR}/${RHEL_URL##*/}"
        else
            scp ${SRC_DIR}/${UBUNTU_URL##*/} ${i}:${SRC_DIR}/
            ssh ${i} "dpkg -i ${SRC_DIR}/${UBUNTU_URL##*/}"
        fi

        [ $? -eq 0 ] ||  { color '安装软件包失败,退出!' 1; exit; }

        ssh ${i} "mkdir -p /etc/systemd/system/elasticsearch.service.d/ && cp /etc/elasticsearch/elasticsearch.yml{,.bak}"
        ssh ${i} "cat > /etc/systemd/system/elasticsearch.service.d/override.conf <<EOF
[Service]
LimitMEMLOCK=infinity
EOF"
        ssh ${i} "echo "vm.max_map_count = 262144" >> /etc/sysctl.conf && sysctl  -p"
        ssh ${i} "mkdir -p $ES_DATA $ES_LOGS && chown  -R elasticsearch.elasticsearch $ES_DATA $ES_LOGS"

    done

    for i in `seq 1 ${CLUSTER_NUM}`
    do
        ssh `echo $NODE_LIST | cut -d '"' -f 2,4,6 | tr '"' '\n' | awk NR==${i}` "cat > /etc/elasticsearch/elasticsearch.yml  <<EOF
cluster.name: $CLUSTER_NAME
node.name: node-$i
path.data: $ES_DATA
path.logs: $ES_LOGS
#bootstrap.memory_lock: true
bootstrap.memory_lock: false
network.host: 0.0.0.0
discovery.seed_hosts: $NODE_LIST
cluster.initial_master_nodes: $NODE_LIST
gateway.recover_after_data_nodes: 2
action.destructive_requires_name: true
xpack.security.enabled: false #8版本添加
xpack.security.enrollment.enabled: false
xpack.security.http.ssl:
  enabled: false
  keystore.path: certs/http.p12
xpack.security.transport.ssl:
  enabled: false
  verification_mode: certificate
  keystore.path: certs/transport.p12
  truststore.path: certs/transport.p12
http.host: 0.0.0.0
EOF"
    done

    for i in `echo $NODE_LIST | cut -d '"' -f 2,4,6 | tr '"' '\n'`
    do
        ssh ${i} "systemctl daemon-reload && systemctl enable --now elasticsearch.service"
        ssh ${i} "systemctl start elasticsearch || { echo "${i}启动失败!" 1;exit 1; }"
    done

    sleep 3
    curl http://127.0.0.1:9200 && color "安装成功" 0   || { color "安装失败!" 1; exit 1; } 
    echo -e "请访问链接: \E[32;1mhttp://${HOST}:9200/\E[0m"

}

Install_elasticsearch_single_node () {

    if [ $ID = "centos" -o $ID = "rocky" ];then
        yum -y install /usr/local/src/${RHEL_URL##*/}
    else
        dpkg -i /usr/local/src/${UBUNTU_URL##*/}
    fi
    [ $? -eq 0 ] ||  { color '安装软件包失败,退出!' 1; exit; }

    cp /etc/elasticsearch/elasticsearch.yml{,.bak}
    cat >> /etc/elasticsearch/elasticsearch.yml  <<EOF
node.name: node-1
network.host: 0.0.0.0
discovery.seed_hosts: ["${NODE_LIST}"]
#cluster.initial_master_nodes: ["node-1"]
EOF
    sed -i "s/xpack.security.enabled: true/xpack.security.enabled: false/" /etc/elasticsearch/elasticsearch.yml
    sed -i "s/cluster.initial_master_nodes: .*/cluster.initial_master_nodes: [\"node-1\"]/" /etc/elasticsearch/elasticsearch.yml
    mkdir -p /etc/systemd/system/elasticsearch.service.d/
    cat > /etc/systemd/system/elasticsearch.service.d/override.conf <<EOF
[Service]
LimitMEMLOCK=infinity
EOF
    systemctl daemon-reload
    systemctl enable  elasticsearch.service
    echo "vm.max_map_count = 262144" >> /etc/sysctl.conf
    sysctl  -p
    systemctl start elasticsearch || { color "启动失败!" 1;exit 1; }
    sleep 3
    curl http://127.0.0.1:9200 && color "安装成功" 0   || { color "安装失败!" 1; exit 1; } 
    echo -e "请访问链接: \E[32;1mhttp://${HOST}:9200/\E[0m"

}

Install_Filebeat () {

    FILEBEAT_VERSION=8.6.1
    # FILEBEAT_VERSION=8.18.1
    UBUNTU_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${FILEBEAT_VERSION} | cut -d . -f 1`.x/apt/pool/main/f/filebeat/filebeat-${FILEBEAT_VERSION}-amd64.deb"
    RHEL_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${FILEBEAT_VERSION} | cut -d . -f 1`.x/yum/${FILEBEAT_VERSION}/filebeat-${FILEBEAT_VERSION}-x86_64.rpm"
    ES_HOSTS=[\"10.0.0.101:9200\",\"10.0.0.102:9200\",\"10.0.0.103:9200\"]
    LOGSTASH=[\"10.0.0.103:5044\"]
    KAFKA=[\"10.0.0.101:9200\",\"10.0.0.102:9200\",\"10.0.0.103:9200\"]
    REDIS=[\"10.0.0.103:6379\"]

    if [ $ID = "centos" -o $ID = "rocky" ];then
        if [ ! -f ${SRC_DIR}/${RHEL_URL##*/} ];then
            wget -P ${SRC_DIR} $RHEL_URL || { color  "下载失败!" 1 ;exit ; } 
        fi
        yum -y install ${SRC_DIR}/${RHEL_URL##*/}
    elif [ $ID = "ubuntu" ];then
        if [ ! -f ${SRC_DIR}/${UBUNTU_URL##*/} ];then
            wget -P ${SRC_DIR} $UBUNTU_URL || { color  "下载失败!" 1 ;exit ; }
        fi
        dpkg -i ${SRC_DIR}/${UBUNTU_URL##*/}
    else
        color "不支持此操作系统!" 1
        exit
    fi

    # cp /etc/filebeat/filebeat.yml{,.bak}
    cat > /etc/filebeat/template-filebeat.yml << EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
  - /var/log/*

#-------------------------- Nginx input ------------------------------
- type: log
  enabled: true
  paths:
    - /var/log/nginx/access_json.log
  json.keys_under_root: true #默认false,只识别为普通文本,会将全部日志数据存储至message字段，改为true则会以Json格式存储
  json.overwrite_keys: true  #设为true,使用json格式日志中自定义的key替代默认的message字段
  tags: ["nginx-access"]     #指定tag,用于分类 

- type: log
  enabled: true
  paths:
    - /var/log/nginx/error.log
  tags: ["nginx-error"]



#-------------------------- Elasticsearch output ------------------------------
#output.elasticsearch:
#  hosts: ${ES_HOSTS}
#  indices:
#    - index: "nginx-access-%{[agent.version]}-%{+yyy.MM.dd}"
#      when.contains:
#        tags: "nginx-access"   #如果记志中有access的tag,就记录到nginx-access的索引中
#    - index: "nginx-error-%{[agent.version]}-%{+yyy.MM.dd}"
#      when.contains:
#        tags: "nginx-error"   #如果记志中有error的tag,就记录到nginx-error的索引中
 
#setup.ilm.enabled: false #关闭索引生命周期ilm功能，默认开启时索引名称只能为filebeat-*
#setup.template.name: "nginx" #定义模板名称,要自定义索引名称,必须指定此项,否则无法启动
#setup.template.pattern: "nginx-*" #定义模板的匹配索引名称,要自定义索引名称,必须指定此项,否则无法启动


#-------------------------- logstash output -----------------------------------
#output.logstash:
#  hosts: ${LOGSTASH}
#  index: filebeat  
#  loadbalance: true    #默认为false,只随机输出至一个可用的logstash,设为true,则输出至全部logstash
#  worker: 1     #线程数量
#  compression_level: 3 #压缩比

#-------------------------- Redis output ---------------------------------------
#output.redis:
#  hosts: ${REDIS}
#  password: "123456"
#  db: "0"
#  key: "filebeat"
  #keys: #也可以用下面的不同日志存放在不同的key的形式
  #  - key: "nginx_access"
  #    when.contains:
  #    tags: "access"
  #  - key: "nginx_error"
  #    when.contains:
  #    tags: "error"

#-------------------------- Kafka output ---------------------------------------
#output.kafka:
#  hosts: ${KAFKA}
#  topic: filebeat-log   #指定kafka的topic
#  partition.round_robin:
#    reachable_only: true#true表示只发布到可用的分区，false时表示所有分区，如果一个节点down，会block
#  required_acks: 1  #如果为0，错误消息可能会丢失，1等待写入主分区（默认），-1等待写入副本分区
#  compression: gzip  
#  max_message_bytes: 1000000 #每条消息最大长度，以字节为单位，如果超过将丢弃
EOF
    systemctl enable filebeat.service
    systemctl restart filebeat.service
    systemctl is-active filebeat.service
    [ $? -eq 0 ] && color "filebeat安装成功" 0 || { color "filebeat安装失败!" 1; exit 1; }

}

Install_Kibana () { 

    KIBANA_VERSION=8.6.1
    #KIBANA_VERSION=8.18.1
    UBUNTU_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${KIBANA_VERSION} | cut -d . -f 1`.x/apt/pool/main/k/kibana/kibana-${KIBANA_VERSION}-amd64.deb"
    RHEL_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${KIBANA_VERSION} | cut -d . -f 1`.x/yum/${KIBANA_VERSION}/kibana-${KIBANA_VERSION}-x86_64.rpm"
    ES_HOSTS=[\"http://10.0.0.101:9200\",\"http://10.0.0.102:9200\",\"http://10.0.0.103:9200\"]

    if [ $ID = "centos" -o $ID = "rocky" ];then
        if [ ! -f ${SRC_DIR}/${RHEL_URL##*/} ];then
            wget -P ${SRC_DIR} $RHEL_URL || { color  "下载失败!" 1 ;exit ; } 
        fi
        yum -y install ${SRC_DIR}/${RHEL_URL##*/}
    elif [ $ID = "ubuntu" ];then
        if [ ! -f ${SRC_DIR}/${UBUNTU_URL##*/} ];then
            wget -P ${SRC_DIR} $UBUNTU_URL || { color  "下载失败!" 1 ;exit ; }
        fi
        dpkg -i ${SRC_DIR}/${UBUNTU_URL##*/}
    else
        color "不支持此操作系统!" 1
        exit
    fi

    cp /etc/kibana/kibana.yml{,.bak}
    cat > /etc/kibana/kibana.yml << EOF 
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts:
  ${ES_HOSTS}
server.publicBaseUrl: "http://${HOST}"
i18n.locale: "zh-CN"
EOF

    systemctl start kibana
    systemctl enable kibana.service
    systemctl is-active kibana.service
    [ $? -eq 0 ] && color "kibana安装成功" 0 || { color "kibana安装失败!" 1; exit 1; }

}

Install_Logstash () {

    LOGSTASH_VERSION=8.6.1
    #LOGSTASH_VERSION=8.18.1
    UBUNTU_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${LOGSTASH_VERSION} | cut -d . -f 1`.x/apt/pool/main/l/logstash/logstash-${LOGSTASH_VERSION}-amd64.deb"
    RHEL_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${LOGSTASH_VERSION} | cut -d . -f 1`.x/yum/${LOGSTASH_VERSION}/logstash-${LOGSTASH_VERSION}-x86_64.rpm"
    ES_HOSTS=[\"http://10.0.0.101:9200\",\"http://10.0.0.102:9200\",\"http://10.0.0.103:9200\"]

    java -version &> /dev/null
    if [ ${?} -ne 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            #yum -y install java-1.8.0-openjdk-devel || { color "安装JDK失败!" 1; exit 1; }
            yum -y install java-21-openjdk || { color "安装JDK失败!" 1; exit 1; }
        else
            apt update
            apt install openjdk-21-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
            #apt install openjdk-8-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
        fi
    fi

    if [ $ID = "centos" -o $ID = "rocky" ];then
        if [ ! -f ${SRC_DIR}/${RHEL_URL##*/} ];then
            wget -P ${SRC_DIR} $RHEL_URL || { color  "下载失败!" 1 ;exit ; } 
        fi
        yum -y install ${SRC_DIR}/${RHEL_URL##*/}
    elif [ $ID = "ubuntu" ];then
        if [ ! -f ${SRC_DIR}/${UBUNTU_URL##*/} ];then
            wget -P ${SRC_DIR} $UBUNTU_URL || { color  "下载失败!" 1 ;exit ; }
        fi
        dpkg -i ${SRC_DIR}/${UBUNTU_URL##*/}
    else
        color "不支持此操作系统!" 1
        exit
    fi
    
    ln -s /usr/share/logstash/bin/logstash /usr/local/bin/
    sed -i "s/User=logstash/User=root/g" /lib/systemd/system/logstash.service
    sed -i "s/Group=logstash/Group=root/g" /lib/systemd/system/logstash.service
    
    cat > /etc/logstash/conf.d/template.conf << EOF 
input {
  #beats {
  #  port => 5044
  #}
  #redis {
  #  host => "127.0.0.1"
  #  port => "6379"
  #  password => "123456"
  #  data_type => "list"
  #  key => "filebeat"
  #  db => "0"
  #}
  #如果有多个key，用下面形式,从而实现将每个不同的key由不同的logstash消费，实现负载均衡
  #redis {
  #  host => ["10.0.0.105"]
  #  port => "6379"
  #  password => "123456"
  #  data_type => "list"
  #  key => "nginx_access"
  #  db => "0"
  #}
  #redis {
  #  host => ["10.0.0.105"]
  #  port => "6379"
  #  password => "123456"
  #  data_type => "list"
  #  key => "nginx_error"
  #  db => "0"
  #}
  #kafka {
  #  bootstrap_servers => "10.0.0.101:9092,10.0.0.102:9092,10.0.0.103:9092"
  #  topic_id => "filebeat-log"
  #  codec => json
  #  #group_id => "logstash" #消费者组的名称
  #  #consumer_threads => "3" #建议设置为和kafka的分区相同的值为线程数
  #  #topics_pattern => "nginx-.*" #通过正则表达式匹配topic，而非用上面topics=>指定固定值
  #}
}

#filter {
#  if "nginx-access" in [tags] {
#    geoip {
#      source => "clientip"      #日志必须是json格式,且有一个clientip的key
#      target => "geoip"
#      #database => "/etc/logstash/conf.d/GeoLite2-City.mmdb"   #指定数据库文件,可选
#      add_field => ["[geoip][coordinates]","%{[geoip][geo][location][lon]}"]   #8.X添加经纬度字段包括经度
#      add_field => ["[geoip][coordinates]","%{[geoip][geo][location][lat]}"]   #8.X添加经纬度字段包括纬度
#      #add_field => ["[geoip][coordinates]", "%{[geoip][longitude]}"]    #7,X添加经纬度字段包括经度
#      #add_field => ["[geoip][coordinates]", "%{[geoip][latitude]}"]     #7,X添加经纬度字段包括纬度
#    }
#    #转换经纬度为浮点数，注意：8X必须做，7.X 可不做此步
#    mutate {
#      convert => [ "[geoip][coordinates]", "float"]       
#    }
#  }
#}


output {
#  stdout {
#    codec => "rubydebug" #输出格式,此为默认值,可省略
#  }
#  if "syslog" in [tags] {
#    elasticsearch {
#      hosts => ${ES_HOSTS}
#      index => "syslog-%{+YYYY.MM.dd}"
#    }
#  }
#  if "nginx-access" in [tags] {
#    elasticsearch {
#      hosts => ${ES_HOSTS}
#      index => "nginx-accesslog-%{+YYYY.MM.dd}"
#      #注意: 地图功能要求必须使用 logstash 开头的索引名称(旧版)
#      #index => "logstash-nginx-accesslog-%{+YYYY.MM.dd}"
#      template_overwrite => true
#    }
#  }
#  if "nginx-error" in [tags] {
#    elasticsearch {
#      hosts => ${ES_HOSTS}
#      index => "nginx-errorlog-%{+YYYY.MM.dd}"
#      template_overwrite => true
#    }
#  }
}
EOF
    systemctl daemon-reload
    systemctl restart logstash
    systemctl enable logstash.service
    systemctl is-active logstash.service
    [ $? -eq 0 ] && color "logstash安装成功" 0 || { color "logstash安装失败!" 1; exit 1; }

}

Install_prometheus () {

    PROMETHEUS_VERSION=2.53.4
    # PROMETHEUS_VERSION=2.44.0
    PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"

    if [ ! -f ${SRC_DIR}/${PROMETHEUS_URL##*/} ];then
        wget -P ${SRC_DIR} $PROMETHEUS_URL || { color  "下载失败!" 1 ;exit ; }
    fi

    cd  ${SRC_DIR} && tar xvf ${PROMETHEUS_URL##*/}
    ln -s ${SRC_DIR}/prometheus-${PROMETHEUS_VERSION}.linux-amd64 /usr/local/prometheus
    cd /usr/local/prometheus && mkdir bin conf data
    mv prometheus promtool bin/ 
    mv prometheus.yml conf/
    useradd -r -s /sbin/nologin prometheus
    chown -R prometheus.prometheus /usr/local/prometheus/

    cat > /etc/profile.d/prometheus.sh <<EOF
export PROMETHEUS_HOME=/usr/local/prometheus
export PATH=${PROMETHEUS_HOME}/bin:$PATH
EOF
    . /etc/profile.d/prometheus.sh

    sed -i "s/localhost:9090/${HOST}:9090/g" /usr/local/prometheus/conf/prometheus.yml

    cat > /lib/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
Restart=on-failure
User=prometheus
Group=prometheus
WorkingDirectory=/usr/local/prometheus/
ExecStart=/usr/local/prometheus/bin/prometheus --config.file=/usr/local/prometheus/conf/prometheus.yml  --web.enable-lifecycle 
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


    systemctl daemon-reload
    systemctl enable --now prometheus.service
    systemctl is-active prometheus.service

    if [ $?  -eq 0 ];then
        echo
        color "prometheus 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        ${GREEN}"http://$HOST:9090"${END}
    else
        color "prometheus 安装失败!" 1
        exit
    fi
    # [ $? -eq 0 ] && color "prometheus安装成功" 0 || { color "prometheus安装失败!" 1; exit 1; }
    # echo -e "请访问链接: \E[32;1mhttp://${HOST}:9090/\E[0m"

}

Install_NodeExporter () {

    NODE_EXPORTER_VERSION=1.9.1
    NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"

    if [ ! -f ${SRC_DIR}/${NODE_EXPORTER_URL##*/} ];then
        wget -P ${SRC_DIR} $NODE_EXPORTER_URL || { color  "下载失败!" 1 ;exit ; }
    fi

    cd ${SRC_DIR} && tar xvf ${NODE_EXPORTER_URL##*/}
    ln -s ${SRC_DIR}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 /usr/local/node_exporter
    cd /usr/local/node_exporter && mkdir bin && mv node_exporter bin/
    cat > /lib/systemd/system/node_exporter.service << EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/node_exporter/bin/node_exporter
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now node_exporter.service
    systemctl is-active node_exporter.service

    if [ $?  -eq 0 ];then
        echo
        color "node_exporter 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        ${GREEN}"http://$HOST:9100"${END}
    else
        color "node_exporter 安装失败!" 1
        exit
    fi

    # [ $? -eq 0 ] && color "node_exporter安装成功" 0 || { color "node_exporter安装失败!" 1; exit 1; }
    # echo -e "请访问链接: \E[32;1mhttp://${HOST}:9100/\E[0m"

}

Install_pushgateway () { 

    PUSHGATEWAY_VERSION=1.11.1
    PUSHGATEWAY_URL="https://github.com/prometheus/pushgateway/releases/download/v${PUSHGATEWAY_VERSION}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz"

    if [ ! -f ${SRC_DIR}/${PUSHGATEWAY_URL##*/} ];then
        wget -P ${SRC_DIR} $PUSHGATEWAY_URL || { color  "下载失败!" 1 ;exit ; }
    fi

    cd ${SRC_DIR} && tar xvf ${PUSHGATEWAY_URL##*/}
    ln -s ${SRC_DIR}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64 /usr/local/pushgateway
    cd /usr/local/pushgateway && mkdir bin && mv pushgateway bin/
    ln -s /usr/local/pushgateway/bin/pushgateway /usr/local/bin/

    cat > /lib/systemd/system/pushgateway.service <<EOF
[Unit]
Description=Prometheus Pushgateway
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/pushgateway/bin/pushgateway
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now pushgateway.service
    systemctl is-active pushgateway.service

    if [ $?  -eq 0 ];then
        echo
        color "pushgateway 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        ${GREEN}"http://$HOST:9091"${END}
    else
        color "pushgateway 安装失败!" 1
        exit
    fi


    # [ $? -eq 0 ] && color "pushgateway安装成功" 0 || { color "pushgateway安装失败!" 1; exit 1; }
    # echo -e "请访问链接: \E[32;1mhttp://${HOST}:9091/\E[0m"

}

Install_alertmanager () { 

    ALERTMANAGER_VERSION=0.28.1
    ALERTMANAGER_URL="https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"
    
    if [ ! -f ${SRC_DIR}/${ALERTMANAGER_URL##*/}];then
        wget -P ${SRC_DIR} $ALERTMANAGER_URL || { color  "下载失败!" 1 ;exit ; }
    fi

    cd ${SRC_DIR} && tar xvf ${ALERTMANAGER_URL##*/}
    ln -s ${SRC_DIR}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64 /usr/local/alertmanager
    cd /usr/local/alertmanager && mkdir ./{bin,conf,data} && { mv alertmanager.yml conf/;  mv alertmanager amtool bin/; }

    cat >  /etc/profile.d/alertmanager.sh <<EOF
export ALERTMANAGER_HOME=/usr/local/alertmanager
export PATH=\${ALERTMANAGER_HOME}/bin:\$PATH
EOF

    cat > /lib/systemd/system/alertmanager.service <<EOF
[Unit]
Description=Prometheus alertmanager
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/alertmanager/bin/alertmanager --config.file=/usr/local/alertmanager/conf/alertmanager.yml --storage.path=/usr/local/alertmanager/data --web.listen-address=0.0.0.0:9093
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now alertmanager.service

    systemctl is-active alertmanager.service
    if [ $?  -eq 0 ];then
        echo
        color "alertmanager 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        ${GREEN}"http://$HOST:9093"${END}
    else
        color "alertmanager 安装失败!" 1
        exit
    fi

}

Install_postgresql () {

    POSTGRESQL_VERSION=17.5
    INSTALL_DIR=/usr/local/pgsql
    DATA_DIR=/usr/local/pgsql/data
    DB_USER=postgres


    if [ $ID = 'centos' -o $ID = 'rocky' ];then
	    yum install -y  gcc make readline-devel zlib-devel
	elif [ $ID = 'ubuntu' ];then
	    apt update
	    apt install -y  gcc make libreadline-dev zlib1g-dev
	else
	    color "不支持此操作系统，退出!" 1
	    exit
	fi

    if [ ! -f  ${SRC_DIR}/postgresql-${POSTGRESQL_VERSION}.tar.gz ] ;then
	    wget -P ${SRC_DIR} https://ftp.postgresql.org/pub/source/v${POSTGRESQL_VERSION}/postgresql-${POSTGRESQL_VERSION}.tar.gz
	fi

    cd ${SRC_DIR} && tar xf postgresql-${POSTGRESQL_VERSION}.tar.gz
    cd ${SRC_DIR}/postgresql-${POSTGRESQL_VERSION} && ./configure --prefix=${INSTALL_DIR}
    make -j $CPUS world
    make install-world

    useradd -s /bin/bash -m -d /home/$DB_USER  $DB_USER
    
    mkdir ${DATA_DIR} -pv
    chown -R $DB_USER.$DB_USER ${DATA_DIR}/
    
    cat > /etc/profile.d/pgsql.sh <<EOF
export PGHOME=${INSTALL_DIR}
export PATH=${INSTALL_DIR}/bin/:\$PATH
export PGDATA=/pgsql/data
export PGUSER=postgres
export MANPATH=${INSTALL_DIR}/share/man:\$MANPATH

alias pgstart="pg_ctl -D ${DATA_DIR} start"
alias pgstop="pg_ctl -D ${DATA_DIR} stop"
alias pgrestart="pg_ctl -D ${DATA_DIR} restart"
alias pgrestatus="pg_ctl -D ${DATA_DIR} status"
EOF
    
    su - $DB_USER -c 'initdb'

cat > /lib/systemd/system/postgresql.service <<EOF
[Unit]
Description=PostgreSQL database server
After=network.target

[Service]
User=postgres
Group=postgres

ExecStart=${INSTALL_DIR}/bin/postmaster -D ${DATA_DIR}
ExecReload=/bin/kill -HUP \$MAINPID

[Install]
WantedBy=multi-user.target

EOF
    systemctl daemon-reload
	systemctl enable --now postgresql.service
	systemctl is-active postgresql.service
	if [ $? -eq 0 ] ;then 
        color "PostgreSQL 安装成功!" 0  
    else 
        color "PostgreSQL 安装失败!" 1
        exit 1
    fi  

}

Install_mongodb () {

    MONGODB_MAIN_VERSION=8.0.9

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        MONGODB_VERSOIN=`echo ${VERSION_ID}|cut -d '.' -f1`-${MONGODB_MAIN_VERSION}
    elif [ $ID = "ubuntu" ];then
        MONGODB_VERSOIN=`echo ${VERSION_ID} | tr '.' ' ' | awk '{print $1$2}'`-${MONGODB_MAIN_VERSION}
    else
        color  '不支持当前操作系统!' 1
        exit
    fi

    MONGODB_FILE=mongodb-linux-x86_64-${MONGODB_VERSOIN}.tgz
    URL=https://fastdl.mongodb.org/linux/$MONGODB_FILE
    # https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel8-8.0.9.tgz
    # https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2004-8.0.9.tgz
    MONGODB_DIR=/mongodb
    INSTALL_DIR=/usr/local
    PORT=27017

    if [ -e /etc/rc.local ];then
        echo "echo never > /sys/kernel/mm/transparent hugepage/enabled" >> /etc/rc.local
    else
        cat > /etc/rc.local <<EOF
#!/bin/bash
echo never > /sys/kernel/mm/transparent hugepage/enabled
EOF
    fi
    chmod +x /etc/rc.local

    if [ ! -f ${SRC_DIR}/$MONGODB_FILE ];then
        wget -P  ${SRC_DIR} $URL || { color  "MongoDB 数据库文件下载失败" 1; exit; } 
    fi

    id mongod &> /dev/null || useradd -m -s /bin/bash mongod
    cd ${SRC_DIR} && tar xf ${MONGODB_FILE}
    ln -s ${SRC_DIR}/mongodb-linux-x86_64-${MONGODB_VERSOIN} ${INSTALL_DIR}/mongodb
    #mongod --dbpath $db_dir --bind_ip_all --port $PORT --logpath $db_dir/mongod.log --fork

    echo PATH=${INSTALL_DIR}/mongodb/bin/:'$PATH' > /etc/profile.d/mongodb.sh
    . /etc/profile.d/mongodb.sh

    mkdir -p ${MONGODB_DIR}/{conf,data,log}
    cat > ${MONGODB_DIR}/conf/mongo.conf <<EOF
systemLog:
  destination: file
  path: "${MONGODB_DIR}/log/mongodb.log"
  logAppend: true

storage:
  dbPath: "${MONGODB_DIR}/data/"
  journal:
    enabled: true
 
processManagement:
  fork: true

net:
  port: 27017
  bindIp: 0.0.0.0
EOF
    chown -R  mongod.mongod ${MONGODB_DIR}/

    cat > /lib/systemd/system/mongod.service <<EOF
[Unit]
Description=mongodb
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
User=mongod
Group=mongod
ExecStart=${INSTALL_DIR}/mongodb/bin/mongod --config ${MONGODB_DIR}/conf/mongo.conf
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=${INSTALL_DIR}/bin/mongod --config ${MONGODB}/conf/mongo.conf --shutdown
PrivateTmp=true
# file size
LimitFSIZE=infinity
# cpu time
LimitCPU=infinity
# virtual memory size
LimitAS=infinity
# open files
LimitNOFILE=64000
# processes/threads
LimitNPROC=64000
# locked memory
LimitMEMLOCK=infinity
# total threads (user+kernel)
TasksMax=infinity
TasksAccounting=false
# Recommended limits for mongod as specified in
# https://docs.mongodb.com/manual/reference/ulimit/#recommended-ulimit-settings

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now  mongod &>/dev/null
    systemctl is-active mongod.service &>/dev/null
    if [ $?  -eq 0 ];then  
        echo 
        color "MongoDB 安装完成!" 0
    else
        color "MongoDB 安装失败!" 1
        exit
    fi 

}



case ${1} in
    1)
        check_sys
        ;;
    2)
        Config_menu
        ;;
    3)
        Install_menu
        ;;
    *)
        Gmenu
        ;;
esac