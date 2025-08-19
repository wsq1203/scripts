#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"
HOST=`hostname -I|awk '{print $1}'`

# Elasticsearch
ES_VERSION=8.6.1
#ES_VERSION=8.18.1
UBUNTU_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${ES_VERSION} | cut -d . -f 1`.x/apt/pool/main/e/elasticsearch/elasticsearch-${ES_VERSION}-amd64.deb"
RHEL_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${ES_VERSION} | cut -d . -f 1`.x/yum/${ES_VERSION}/elasticsearch-${ES_VERSION}-x86_64.rpm"
#https://mirrors.tuna.tsinghua.edu.cn/elasticstack/8.x/apt/pool/main/e/elasticsearch/elasticsearch-8.18.1-amd64.deb
#https://mirrors.tuna.tsinghua.edu.cn/elasticstack/8.x/yum/8.18.1/elasticsearch-8.18.1-x86_64.rpm

MEM_TOTAL=`head -n1 /proc/meminfo |awk '{print $2}'`

# 按需修改
NODE_NAME=node-1
NODE_LIST='["10.0.0.101","10.0.0.102","10.0.0.103"]'
CLUSTER_NAME=es-cluster
ES_DATA=/var/lib/elasticsearch
ES_LOGS=/var/log/elasticsearch

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


Install_elasticsearch_cluster () {

    if [ ${MEM_TOTAL} -lt 1997072 ];then
        color '内存低于2G,安装失败!' 1
        exit
    elif [ ${MEM_TOTAL} -le 2997072 ];then
        color '内存不足3G,建议调整内存大小!' 2
    else
        echo
    fi

    if [ $ID = "centos" -o $ID = "rocky" ];then
        if [ ! -f ${SRC_DIR}/${RHEL_URL##*/} ];then
            wget -P ${SRC_DIR} $RHEL_URL || { color  "下载失败!" 1 ;exit ; } 
            yum -y install ${SRC_DIR}/${RHEL_URL##*/}
        fi
    elif [ $ID = "ubuntu" ];then
        if [ ! -f ${SRC_DIR}/${UBUNTU_URL##*/} ];then
            wget -P ${SRC_DIR} $UBUNTU_URL || { color  "下载失败!" 1 ;exit ; }
            dpkg -i ${SRC_DIR}/${UBUNTU_URL##*/}
        fi
    else
        color "不支持此操作系统!" 1
        exit
    fi

    mkdir -p /etc/systemd/system/elasticsearch.service.d/ && cp /etc/elasticsearch/elasticsearch.yml{,.bak}
    cat > /etc/systemd/system/elasticsearch.service.d/override.conf <<EOF
[Service]
LimitMEMLOCK=infinity
EOF
    echo "vm.max_map_count = 262144" >> /etc/sysctl.conf && sysctl  -p
    mkdir -p $ES_DATA $ES_LOGS && chown  -R elasticsearch.elasticsearch $ES_DATA $ES_LOGS

    cat > /etc/elasticsearch/elasticsearch.yml  <<EOF
cluster.name: ${CLUSTER_NAME}
node.name: ${NODE_NAME}
path.data: ${ES_DATA}
path.logs: ${ES_LOGS}
#bootstrap.memory_lock: true
bootstrap.memory_lock: false
network.host: 0.0.0.0
discovery.seed_hosts: ${NODE_LIST}
cluster.initial_master_nodes: ${NODE_LIST}
gateway.recover_after_data_nodes: 2
action.destructive_requires_name: true
xpack.security.enabled: false #8版本添加
xpack.security.enrollment.enabled: false
xpack.security.http.ssl:
  enabled: false
  keystore.path: certs/http.p12
xpack.security.transport.ssl:
  enabled: false
  verification_mode: certificate
  keystore.path: certs/transport.p12
  truststore.path: certs/transport.p12
http.host: 0.0.0.0
EOF

    systemctl daemon-reload && systemctl enable --now elasticsearch.service
    systemctl start elasticsearch || { color "elasticsearch启动失败!" 1;exit 1; }

    sleep 3
    curl http://127.0.0.1:9200 && color "elasticsearch安装成功" 0   || { color "安装失败!" 1; exit 1; } 
    echo -e "请访问链接: \E[32;1mhttp://${HOST}:9200/\E[0m"

}


Install_elasticsearch_cluster