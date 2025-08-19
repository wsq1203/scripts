#!/bin/bash

. /etc/os-release

HOST=`hostname -I|awk '{print $1}'`
SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# Prometheus
PROMETHEUS_VERSION=2.53.4
# PROMETHEUS_VERSION=2.44.0
PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"

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

Install_prometheus () {

    if [ ! -f ${SRC_DIR}/${PROMETHEUS_URL##*/} ];then
        wget -P ${SRC_DIR} $PROMETHEUS_URL || { color  "下载失败!" 1 ;exit ; }
    fi

    cd  ${SRC_DIR} && tar xvf ${PROMETHEUS_URL##*/}
    ln -s ${SRC_DIR}/prometheus-${PROMETHEUS_VERSION}.linux-amd64 /usr/local/prometheus
    cd /usr/local/prometheus && mkdir bin conf data
    mv prometheus promtool bin/ 
    mv prometheus.yml conf/
    useradd -r -s /sbin/nologin prometheus
    chown -R prometheus.prometheus /usr/local/prometheus/

    cat > /etc/profile.d/prometheus.sh <<EOF
export PROMETHEUS_HOME=/usr/local/prometheus
export PATH=${PROMETHEUS_HOME}/bin:\$PATH
EOF
    . /etc/profile.d/prometheus.sh

    sed -i "s/localhost:9090/${HOST}:9090/g" /usr/local/prometheus/conf/prometheus.yml

    cat > /lib/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
Restart=on-failure
User=prometheus
Group=prometheus
WorkingDirectory=/usr/local/prometheus/
ExecStart=/usr/local/prometheus/bin/prometheus --config.file=/usr/local/prometheus/conf/prometheus.yml  --web.enable-lifecycle 
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


    systemctl daemon-reload
    systemctl enable --now prometheus.service
    systemctl is-active prometheus.service

    if [ $?  -eq 0 ];then
        echo
        color "prometheus 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        ${GREEN}"http://$HOST:9090"${END}
    else
        color "prometheus 安装失败!" 1
        exit
    fi

}

Install_prometheus