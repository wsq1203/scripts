#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"

# zookeeper
ZK_VERSION=3.8.1
ZK_URL=https://archive.apache.org/dist/zookeeper/zookeeper-${ZK_VERSION}/apache-zookeeper-${ZK_VERSION}-bin.tar.gz
#ZK_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-${ZK_VERSION}/apache-zookeeper-${ZK_VERSION}-bin.tar.gz
#ZK_URL="https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/stable/apache-zookeeper-${ZK_VERSION}-bin.tar.gz"
INSTALL_DIR=/usr/local/zookeeper

Server1_IP=10.0.0.11
Server2_IP=10.0.0.12
Server3_IP=10.0.0.13

MYID=1

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

Install_zk_cluster () {

    if [ ! -f ${SRC_DIR}/apache-zookeeper-${ZK_VERSION}-bin.tar.gz ] ;then
        wget -P /usr/local/src/ --no-check-certificate ${ZK_URL} || { color  "下载失败!" 1 ;exit ; }
    fi

    java -version &> /dev/null
    if [ ${?} -ne 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            yum -y install java-1.8.0-openjdk-devel || { color "安装JDK失败!" 1; exit 1; }
            #yum -y install java-11-openjdk || { color "安装JDK失败!" 1; exit 1; }
        else
            apt update;apt install openjdk-11-jdk -y || { color "安装JDK失败!" 1; exit 1; }
        fi
    fi

    tar xf /usr/local/src/${ZK_URL##*/} -C /usr/local && ln -s /usr/local/apache-zookeeper-*-bin/ /usr/local/zookeeper
    echo "PATH=/usr/local/zookeeper/bin:\$PATH" >  /etc/profile.d/zookeeper.sh && .  /etc/profile.d/zookeeper.sh
    mkdir -p /usr/local/zookeeper/data

    cat > /usr/local/zookeeper/conf/zoo.cfg <<EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/usr/local/zookeeper/data
clientPort=2181
maxClientCnxns=128
autopurge.snapRetainCount=3
autopurge.purgeInterval=24
server.1=${Server1_IP}:2888:3888
server.2=${Server2_IP}:2888:3888
server.3=${Server3_IP}:2888:3888
EOF

    cat > /lib/systemd/system/zookeeper.service <<EOF
[Unit]
Description=zookeeper.service
After=network.target

[Service]
Type=forking
#Environment=/usr/local/zookeeper
ExecStart=/usr/local/zookeeper/bin/zkServer.sh start
ExecStop=/usr/local/zookeeper/bin/zkServer.sh stop
ExecReload=/usr/local/zookeeper/bin/zkServer.sh restart

[Install]
WantedBy=multi-user.target
EOF

    echo ${MYID} > /usr/local/zookeeper/data/myid

    systemctl daemon-reload && systemctl enable --now  zookeeper.service

    sleep 3

    . /etc/profile.d/zookeeper.sh

    color "需启动所有节点zookeeper" 3  

}

Install_zk_cluster