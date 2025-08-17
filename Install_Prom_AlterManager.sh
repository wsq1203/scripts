#!/bin/bash

. /etc/os-release

HOST=`hostname -I|awk '{print $1}'`
SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# Alertmanager
ALERTMANAGER_VERSION=0.28.1
ALERTMANAGER_URL="https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"
    
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


Install_alertmanager () { 

    if [ ! -f ${SRC_DIR}/${ALERTMANAGER_URL##*/}];then
        wget -P ${SRC_DIR} $ALERTMANAGER_URL || { color  "下载失败!" 1 ;exit ; }
    fi

    cd ${SRC_DIR} && tar xvf ${ALERTMANAGER_URL##*/}
    ln -s ${SRC_DIR}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64 /usr/local/alertmanager
    cd /usr/local/alertmanager && mkdir ./{bin,conf,data} && { mv alertmanager.yml conf/;  mv alertmanager amtool bin/; }

    cat >  /etc/profile.d/alertmanager.sh <<EOF
export ALERTMANAGER_HOME=/usr/local/alertmanager
export PATH=\${ALERTMANAGER_HOME}/bin:\$PATH
EOF

    cat > /lib/systemd/system/alertmanager.service <<EOF
[Unit]
Description=Prometheus alertmanager
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/alertmanager/bin/alertmanager --config.file=/usr/local/alertmanager/conf/alertmanager.yml --storage.path=/usr/local/alertmanager/data --web.listen-address=0.0.0.0:9093
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now alertmanager.service

    systemctl is-active alertmanager.service
    if [ $?  -eq 0 ];then
        echo
        color "alertmanager 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        ${GREEN}"http://$HOST:9093"${END}
    else
        color "alertmanager 安装失败!" 1
        exit
    fi

}

Install_alertmanager