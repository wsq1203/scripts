#!/bin/bash

. /etc/os-release

# 虚拟IP
mask='255.255.255.255'
dev=lo:1
vip='10.0.0.200'

# server
port='80'
scheduler='wrr'
type='-g'

# backend
rs1="10.0.0.102"
rs2="10.0.0.103"

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

Install_lvs_server () {

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

Install_lvs_server