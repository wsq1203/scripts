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