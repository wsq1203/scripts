#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"

# TOMCAT
TOMCAT_VERSION=10.1.39
TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
JDK_DIR="/usr/local"

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

Install_tomcat () {

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


    if ! [ -f "${SRC_DIR}/${TOMCAT_FILE}" ];then
        echo -e "\E[1;$[RANDOM%7+31]m${SRC_DIR}目录下，${TOMCAT_FILE}文件不存在，需要自行下载\E[0m"
        exit; 
    elif [ -d /usr/local/tomcat ];then
        color "TOMCAT 已经安装" 1
        exit
    else 
        [ -d "${SRC_DIR}" ] || mkdir -pv ${SRC_DIR}
    fi

    tar xf ${SRC_DIR}/${TOMCAT_FILE} -C /usr/local/
    cd  /usr/local/ && ln -s apache-tomcat-*/  tomcat
    echo "PATH=/usr/local/tomcat/bin:"'$PATH' > /etc/profile.d/tomcat.sh
    id tomcat &> /dev/null || useradd -r -s /sbin/nologin tomcat

    cat > /usr/local/tomcat/conf/tomcat.conf <<-EOF
JAVA_HOME=${JDK_DIR}/jdk
EOF

    chown -R tomcat.tomcat /usr/local/tomcat/
    cat > /lib/systemd/system/tomcat.service  <<-EOF
[Unit]
Description=Tomcat
#After=syslog.target network.target remote-fs.target nss-lookup.target
After=syslog.target network.target 

[Service]
Type=forking
EnvironmentFile=/usr/local/tomcat/conf/tomcat.conf
ExecStart=/usr/local/tomcat/bin/startup.sh
ExecStop=/usr/local/tomcat/bin/shutdown.sh
RestartSec=3
PrivateTmp=true
User=tomcat
Group=tomcat

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now tomcat.service &> /dev/null
    systemctl is-active tomcat.service &> /dev/null &&  color "TOMCAT 安装完成" 0 || { color "TOMCAT 安装失败" 1 ; exit; }

}

Install_tomcat