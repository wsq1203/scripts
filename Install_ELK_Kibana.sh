#!/bin/bash

. /etc/os-release

HOST=`hostname -I|awk '{print $1}'`
SRC_DIR="/usr/local/src"


# Kibana
KIBANA_VERSION=8.6.1
#KIBANA_VERSION=8.18.1
UBUNTU_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${KIBANA_VERSION} | cut -d . -f 1`.x/apt/pool/main/k/kibana/kibana-${KIBANA_VERSION}-amd64.deb"
RHEL_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${KIBANA_VERSION} | cut -d . -f 1`.x/yum/${KIBANA_VERSION}/kibana-${KIBANA_VERSION}-x86_64.rpm"

# 从Elasticsearch读取数据
ES_HOSTS=[\"http://10.0.0.101:9200\",\"http://10.0.0.102:9200\",\"http://10.0.0.103:9200\"]

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

Install_Kibana () { 

    if [ $ID = "centos" -o $ID = "rocky" ];then
        if [ ! -f ${SRC_DIR}/${RHEL_URL##*/} ];then
            wget -P ${SRC_DIR} $RHEL_URL || { color  "下载失败!" 1 ;exit ; } 
        fi
        yum -y install ${SRC_DIR}/${RHEL_URL##*/}
    elif [ $ID = "ubuntu" ];then
        if [ ! -f ${SRC_DIR}/${UBUNTU_URL##*/} ];then
            wget -P ${SRC_DIR} $UBUNTU_URL || { color  "下载失败!" 1 ;exit ; }
        fi
        dpkg -i ${SRC_DIR}/${UBUNTU_URL##*/}
    else
        color "不支持此操作系统!" 1
        exit
    fi

    cp /etc/kibana/kibana.yml{,.bak}
    cat > /etc/kibana/kibana.yml << EOF 
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts:
  ${ES_HOSTS}
server.publicBaseUrl: "http://${HOST}"
i18n.locale: "zh-CN"
EOF

    systemctl start kibana
    systemctl enable kibana.service
    systemctl is-active kibana.service
    [ $? -eq 0 ] && color "kibana安装成功" 0 || { color "kibana安装失败!" 1; exit 1; }
    echo -e "请访问链接: \E[32;1mhttp://${HOST}:5601/\E[0m"

}

Install_Kibana