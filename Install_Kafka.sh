#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"
HOST=`hostname -I|awk '{print $1}'`

# KAFKA
KAFKA_VERSION=3.3.2
SCALA_VERSION=2.13
KAFKA_URL="https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
KAFKA_INSTALL_DIR=/usr/local/kafka

NODE_ID=1
KAFKA1_IP=10.0.0.11
KAFKA1_IP=10.0.0.12
KAFKA1_IP=10.0.0.13

ZK1_IP=10.0.0.11
ZK2_IP=10.0.0.12
ZK3_IP=10.0.0.13

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

Install_kafka () {

    if [ ! -f ${SRC_DIR}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz ];then
        wget -P /usr/local/src  $KAFKA_URL  || { color  "下载失败!" 1 ;exit ; }
    fi

    tar xf ${SRC_DIR}/${KAFKA_URL##*/}  -C /usr/local/
    ln -s ${KAFKA_INSTALL_DIR}_*/ ${KAFKA_INSTALL_DIR} && mkdir ${KAFKA_INSTALL_DIR}/data
    echo PATH=${KAFKA_INSTALL_DIR}/bin:'$PATH' > /etc/profile.d/kafka.sh && . /etc/profile.d/kafka.sh

    cat > /lib/systemd/system/kafka.service <<EOF
[Unit]                                                                          
Description=Apache kafka
After=network.target

[Service]
Type=simple
#Environment=JAVA_HOME=/data/server/java
#PIDFile=${KAFKA_INSTALL_DIR}/kafka.pid
ExecStart=${KAFKA_INSTALL_DIR}/bin/kafka-server-start.sh  ${KAFKA_INSTALL_DIR}/config/server.properties
ExecStop=/bin/kill  -TERM \${MAINPID}
Restart=always
RestartSec=20

[Install]
WantedBy=multi-user.target
EOF


    cat > ${KAFKA_INSTALL_DIR}/config/server.properties <<EOF
broker.id=${NODE_ID}
listeners=PLAINTEXT://${HOST}:9092
log.dirs=${KAFKA_INSTALL_DIR}/data
num.partitions=1
log.retention.hours=168
zookeeper.connect=${ZK1_IP}:2181,${ZK2_IP}:2181,${ZK3_IP}:2181
zookeeper.connection.timeout.ms=6000
EOF

    
    systemctl daemon-reload
    #kafka-server-start.sh -daemon ${KAFKA_INSTALL_DIR}/config/server.properties
    systemctl enable --now kafka.service

    sleep 3	
 
	systemctl is-active kafka.service
	if [ ${?} -eq 0 ] ;then 
        color "kafka 安装成功!" 0  
    else 
        color "kafka 安装失败!" 1
        exit 1
    fi    

}

Install_kafka