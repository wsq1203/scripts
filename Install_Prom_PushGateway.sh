#!/bin/bash

. /etc/os-release

HOST=`hostname -I|awk '{print $1}'`
SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# Pushgateway
PUSHGATEWAY_VERSION=1.11.1
PUSHGATEWAY_URL="https://github.com/prometheus/pushgateway/releases/download/v${PUSHGATEWAY_VERSION}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz"


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

Install_pushgateway () { 

    if [ ! -f ${SRC_DIR}/${PUSHGATEWAY_URL##*/} ];then
        wget -P ${SRC_DIR} $PUSHGATEWAY_URL || { color  "下载失败!" 1 ;exit ; }
    fi

    cd ${SRC_DIR} && tar xvf ${PUSHGATEWAY_URL##*/}
    ln -s ${SRC_DIR}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64 /usr/local/pushgateway
    cd /usr/local/pushgateway && mkdir bin && mv pushgateway bin/
    ln -s /usr/local/pushgateway/bin/pushgateway /usr/local/bin/

    cat > /lib/systemd/system/pushgateway.service <<EOF
[Unit]
Description=Prometheus Pushgateway
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/pushgateway/bin/pushgateway
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now pushgateway.service
    systemctl is-active pushgateway.service

    if [ $?  -eq 0 ];then
        echo
        color "pushgateway 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        ${GREEN}"http://$HOST:9091"${END}
    else
        color "pushgateway 安装失败!" 1
        exit
    fi

}

Install_pushgateway