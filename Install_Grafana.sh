#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"
HOST=`hostname -I|awk '{print $1}'`

GRAFANA_AGENT_VER=11.6.0
GRAFANA_VER=${GRAFANA_AGENT_VER}-1

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


Install_grafana () {

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

Install_grafana