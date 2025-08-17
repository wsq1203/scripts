#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"
HOST=`hostname -I|awk '{print $1}'`

# KAFKA
KAFKA_VERSION=4.0.0
SCALA_VERSION=2.13
KAFKA_URL="https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
KAFKA_INSTALL_DIR=/usr/local/kafka

NODE_ID=1
KAFKA1_IP=10.0.0.11
KAFKA1_IP=10.0.0.12
KAFKA1_IP=10.0.0.13

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


Install_kafka_VERSION4 () {

    if [ ! -f ${SRC_DIR}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz ];then
        wget -P /usr/local/src  $KAFKA_URL  || { color  "下载失败!" 1 ;exit ; }
    fi

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

    java -version &> /dev/null
    if [ ${?} -ne 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            yum -y install java-21-openjdk-devel || { color "安装JDK失败!" 1; exit 1; }
        else               
            apt update;apt install openjdk-21-jdk -y || { color "安装JDK失败!" 1; exit 1; }
        fi
    fi

    tar xf /usr/local/src/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /usr/local && ln -s /usr/local/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_INSTALL_DIR}
    mkdir ${KAFKA_INSTALL_DIR}/data && echo PATH=${KAFKA_INSTALL_DIR}/bin:'$PATH' > /etc/profile.d/kafka.sh && . /etc/profile.d/kafka.sh
    cp ${KAFKA_INSTALL_DIR}/config/server.properties ${KAFKA_INSTALL_DIR}/config/server.properties.bak && ln -s ${KAFKA_INSTALL_DIR}/bin/*.sh /usr/local/bin/

   cat > ${KAFKA_INSTALL_DIR}/config/server.properties <<EOF
# 基础配置
node.id=${NODE_ID}
process.roles=broker,controller
controller.quorum.voters=1@${KAFKA1_IP}:9093,2@${KAFKA2_IP}:9093,3@${KAFKA3_IP}:9093

# 网络配置
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL
listeners=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
advertised.listeners=PLAINTEXT://${HOST}:9092
controller.listener.names=CONTROLLER

# 存储配置
log.dirs=${KAFKA_INSTALL_DIR}/data
num.partitions=3
default.replication.factor=3
min.insync.replicas=2

# 性能优化
socket.send.buffer.bytes=1024000
socket.receive.buffer.bytes=1024000
num.network.threads=8
num.io.threads=16
EOF


    ${KAFKA_INSTALL_DIR}/bin/kafka-storage.sh format -t `${KAFKA_INSTALL_DIR}/bin/kafka-storage.sh random-uuid` -c ${KAFKA_INSTALL_DIR}/config/server.properties
    systemctl daemon-reload && systemctl enable --now  kafka.service

    sleep 5	
 
    systemctl is-active kafka.service
    if [ $? -eq 0 ] ;then 
        color "kafka 安装成功!" 0  
    else 
        color "kafka 安装失败!" 1
        exit 1
    fi 

}

Install_kafka_VERSION4