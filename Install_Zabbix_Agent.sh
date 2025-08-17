#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"

# zabbix版本信息
ZABBIX_MAJOR_VER=6.0
ZABBIX_VER=${ZABBIX_MAJOR_VER}-4
ZABBIX_URL="mirror.tuna.tsinghua.edu.cn/zabbix"

ZABBIX_SERVER_IP="10.0.0.101"

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


Install_zabbix_agent () {
 
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

Install_zabbix_agent