#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"

MAVEN_VERSION=3.8.8
MAVEN_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
#MAVEN_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
    
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


Install_maven () {

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

    if [ -e /usr/local/maven ];then
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

    tar xf apache-maven-${MAVEN_VERSION}-bin.tar.gz  -C /usr/local/
    ln -s /usr/local/apache-maven-${MAVEN_VERSION} /usr/local/maven
    echo "PATH=/usr/local/maven/bin:\$PATH" > /etc/profile.d/maven.sh
    echo "export MAVEN_HOME=/usr/local/maven" >> /etc/profile.d/maven.sh
    . /etc/profile.d/maven.sh
    mvn -v && { color "MAVEN安装成功!" 0 ; sed -i  '/\/mirrors>/i <mirror> \n <id>nexus-aliyun</id> \n  <mirrorOf>*</mirrorOf> \n <name>Nexus aliyun</name> \n <url>http://maven.aliyun.com/nexus/content/groups/public</url> \n </mirror> ' /usr/local/maven/conf/settings.xml ; } || color "MAVEN安装失败!" 1 

}

Install_maven