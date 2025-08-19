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

config_sys () {

    # 关闭swap
    swapoff -a
    sed -i '/swap/s/^/#/g' /etc/fstab
    color "swap已关闭" 0

    if [[ ${ID} =~ centos|rocky|rhel ]];then
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

config_sys