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

config_ssh