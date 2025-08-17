#!/bin/bash

. /etc/os-release

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
SRC_DIR="/usr/local/src"

# memcached版本
MEMCACHE_VERSION="1.6.17"
MEMCACHE_FILE="memcached-${MEMCACHE_VERSION}.tar.gz"
MEMCACHE_DIR="/usr/local"
MEMCACHE_URL="http://memcached.org/files"


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

Install_memcache () {

    if [ -e ${MEMCACHE_DIR}/memcached ];then
        color "memcache 已安装" 1
        exit
    fi

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum -y -q install gcc libevent-devel wget
    else
        apt update; apt -y install wget gcc make libevent-dev
    fi

    cd ${SRC_DIR}

    if [ ! -e ${MEMCACHE_FILE} ];then
        wget ${MEMCACHE_URL}/${MEMCACHE_FILE}
        [ $? -ne 0 ] && { color "下载 ${MEMCACHE_FILE} 文件失败" 1 ; exit; } 
    fi

    tar xvf ${MEMCACHE_FILE} -C ${MEMCACHE_DIR}
    
    cd /usr/local/memcached-${MEMCACHE_VERSION}
    ./configure --prefix=${MEMCACHE_DIR}/memcached-${MEMCACHE_VERSION}
    make -j ${CPUS} && make install
    ln -s ${MEMCACHE_DIR}/memcached-${MEMCACHE_VERSION} /usr/local/memcached

    useradd -r -s /sbin/nologin memcached || { color "用户 memcached 存在" 1 ; exit; }

    cat > /etc/sysconfig/memcached <<-EOF
PORT=11211
USER=memcached
MAXCONN=1024
CACHESIZE=64
OPTIONS="-l 0.0.0.0"
EOF

    cat > /lib/systemd/system/memcached.service <<-EOF
[Unit]
Description=memcached daemon
Before=httpd.service
After=network.target


[Service]
EnvironmentFile=/etc/sysconfig/memcached
ExecStart=${MEMCACHE_DIR}/memcached/bin/memcached -p \${PORT} -u \${USER} -m \${CACHESIZE} -c \${MAXCONN} \$OPTIONS

[Install]
WantedBy=multi-user.target
EOF
    echo "PATH=${MEMCACHE_DIR}/memcached/bin:\$PATH" > /etc/profile.d/memcached.sh
    . /etc/profile.d/memcached.sh

    systemctl daemon-reload 
    systemctl enable --now memcached.service
    systemctl is-active memcached.service &> /dev/null && color "memcache 安装完成" 0 || { color "memcache 安装失败" 1 ; exit; }

}

Install_memcache