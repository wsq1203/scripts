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


Install_elasticsearch_single () {


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

    cp /etc/elasticsearch/elasticsearch.yml{,.bak}
    cat >> /etc/elasticsearch/elasticsearch.yml  <<EOF
node.name: node-1
network.host: 0.0.0.0
discovery.seed_hosts: ["${HOST}"]
#cluster.initial_master_nodes: ["node-1"]
EOF
    sed -i "s/xpack.security.enabled: true/xpack.security.enabled: false/" /etc/elasticsearch/elasticsearch.yml
    sed -i "s/cluster.initial_master_nodes: .*/cluster.initial_master_nodes: [\"node-1\"]/" /etc/elasticsearch/elasticsearch.yml
    mkdir -p /etc/systemd/system/elasticsearch.service.d/
    cat > /etc/systemd/system/elasticsearch.service.d/override.conf <<EOF
[Service]
LimitMEMLOCK=infinity
EOF
    systemctl daemon-reload
    systemctl enable  elasticsearch.service
    echo "vm.max_map_count = 262144" >> /etc/sysctl.conf
    sysctl  -p
    systemctl start elasticsearch || { color "启动失败!" 1;exit 1; }
    sleep 3
    curl http://127.0.0.1:9200 && color "安装成功" 0   || { color "安装失败!" 1; exit 1; } 
    echo -e "请访问链接: \E[32;1mhttp://${HOST}:9200/\E[0m"

}

Install_elasticsearch_single