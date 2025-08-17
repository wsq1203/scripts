#!/bin/bash

. /etc/os-release

HOST=`hostname -I|awk '{print $1}'`
SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# Node Exporter
NODE_EXPORTER_VERSION=1.9.1
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"

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

Install_NodeExporter () {

    if [ ! -f ${SRC_DIR}/${NODE_EXPORTER_URL##*/} ];then
        wget -P ${SRC_DIR} $NODE_EXPORTER_URL || { color  "下载失败!" 1 ;exit ; }
    fi

    cd ${SRC_DIR} && tar xvf ${NODE_EXPORTER_URL##*/}
    ln -s ${SRC_DIR}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 /usr/local/node_exporter
    cd /usr/local/node_exporter && mkdir bin && mv node_exporter bin/
    cat > /lib/systemd/system/node_exporter.service << EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/node_exporter/bin/node_exporter
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now node_exporter.service
    systemctl is-active node_exporter.service

    if [ $?  -eq 0 ];then
        echo
        color "node_exporter 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        ${GREEN}"http://$HOST:9100"${END}
    else
        color "node_exporter 安装失败!" 1
        exit
    fi

}

Install_NodeExporter