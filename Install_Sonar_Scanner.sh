#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"

# sonarqube_scanner
SONARQUBE_SERVER=10.0.0.102
SONAR_SCANNER_VER=4.8.0.2856
#SONAR_SCANNER_VER=4.7.0.2747
#SONAR_SCANNER_VER=4.6.2.2472
#SONAR_SCANNER_VER=4.3.0.2102
URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VER}-linux.zip" 


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

Install_sonar_scanner () {

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

Install_sonar_scanner