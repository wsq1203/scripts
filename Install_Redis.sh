#!/bin/bash

. /etc/os-release

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# redis
REDIS_VERSION=7.4.2
REDIS_URL=https://download.redis.io/releases/
REDIS_PASSWORD=000000

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

Install_Redis () {

    ${GREEN}开始安装依赖包${END}
    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum install -y gcc make jemalloc-devel systemd-devel wget
    else
        apt update;apt install -y wget gcc make libjemalloc-dev libsystemd-dev
    fi

    if [ ! -e ${SRC_DIR}/redis-${REDIS_VERSION}.tar.gz ];then
        ${GREEN}开始下载redis源码包${END}
        cd ${SRC_DIR}
        wget ${REDIS_URL}/redis-${REDIS_VERSION}.tar.gz
        [ $? -ne 0  ] && { color "redis-${REDIS_VERSION}.tar.gz 文件下载失败" 1; exit; }
    fi

    ${GREEN}开始编译redis${END}
    cd ${SRC_DIR} && tar xf redis-${REDIS_VERSION}.tar.gz && cd redis-${REDIS_VERSION}
    make -j ${CPUS} USE_SYSTEMD=yes PREFIX=/usr/local/redis && make install

    
    if id redis &> /dev/null ;then 
        color "Redis 用户已存在" 0
    else
        ${GREEN}创建用户redis${END}
        useradd -r -s /sbin/nologin redis
        color "Redis 用户创建成功" 0
    fi

    ln -s /usr/local/redis/bin/redis-* /usr/bin/
    mkdir -p /usr/local/redis/{etc,log,data,run}
    cp /usr/local/src/redis-${REDIS_VERSION}/redis.conf /usr/local/redis/etc/redis.conf

    sed -i -e 's/bind 127.0.0.1/bind 0.0.0.0/'  -e "/# requirepass/a requirepass ${REDIS_PASSWORD}" \
    -e "/^dir .*/c dir /usr/local/redis/data/"  -e "/logfile .*/c logfile /usr/local/redis/log/redis-6379.log"  \
    -e  "/^pidfile .*/c pidfile /usr/local/redis/run/redis_6379.pid" /usr/local/redis/etc/redis.conf

    chown redis:redis /usr/local/redis -R

    cat > /etc/redis/redis.conf <<-EOF
net.core.somaxconn = 1024
vm.overcommit_memory = 1
EOF
    sysctl -p

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.d/rc.local
        chmod +x /etc/rc.d/rc.local
        . /etc/rc.d/rc.local 
    else
        echo -e '#!/bin/bash\necho never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
        chmod +x /etc/rc.local
        . /etc/rc.local
    fi

    cat > /lib/systemd/system/redis.service <<EOF
[Unit]
Description=Redis persistent key-value database
After=network.target

[Service]
ExecStart=redis-server /usr/local/redis/etc/redis.conf --supervised systemd
ExecStop=/bin/kill -s QUIT \$MAINPID
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload 
    systemctl enable --now redis &> /dev/null 
    
    if [ $? -eq 0 ];then
        color "Redis 服务启动成功,Redis信息如下:"  0
    else
        color "Redis 启动失败" 1
        exit
    fi
    sleep 2
    redis-cli -a ${REDIS_PASSWORD} INFO Server 2> /dev/null

}

Install_Redis