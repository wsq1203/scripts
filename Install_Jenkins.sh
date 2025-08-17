#!/bin/bash

. /etc/os-release

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# jenkins
JENKINS_VERSION=2.492.3
JENKINS_R_URL=https://mirrors.tuna.tsinghua.edu.cn/jenkins/redhat-stable/jenkins-${JENKINS_VERSION}-1.1.noarch.rpm
JENKINS_U_URL=https://mirrors.tuna.tsinghua.edu.cn/jenkins/debian-stable/jenkins_${JENKINS_VERSION}_all.deb
#JENKINS_R_URL=https://get.jenkins.io/redhat-stable/jenkins-${JENKINS_VERSION}-1.1.noarch.rpm
#JENKINS_U_URL=https://get.jenkins.io/debian-stable/jenkins_${JENKINS_VERSION}_all.deb


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

Install_Jenkins () {

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

Install_Jenkins