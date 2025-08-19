#!/bin/bash

. /etc/os-release

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# KEEPALIVED
KEEP_VERSION=2.3.3
KEEP_URL=https://keepalived.org/software/
INTER_NAME=`ip a | grep -E "^[0-9]+: e[a-z0-9]+" | awk -F": |: " '{print $2}' | head -1`

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

Install_keepalived () {

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

Install_keepalived