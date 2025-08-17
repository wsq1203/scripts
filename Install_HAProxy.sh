#!/bin/bash

. /etc/os-release

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
SRC_DIR="/usr/local/src"
HOST=`hostname -I|awk '{print $1}'`
GREEN="echo -e \E[1;32m"
END="\E[0m"

# HAPROXY
HAProxy_VERSION=1.9.16
HAProxy_URL=https://www.haproxy.org/download/`echo ${HAProxy_VERSION} | awk -F "."  '{print $1"."$2}'`/src/
#read -p "创建haproxy状态页用户：" HAProxy_USER
#read -p "创建haproxy状态页密码：" HAProxy_PASSWORD
HAProxy_USER="admin"
HAProxy_PASSWORD="000000"

# read -p "$(echo -e '\033[1;32m请输入需要绑定的VIP和端口号例如 10.0.0.10:80 : \033[0m')" VIP
# read -p "$(echo -e '\033[1;32m请输入后台服务器ip和端口例如 10.0.0.7:80 : \033[0m')" SERVER1
# read -p "$(echo -e '\033[1;32m请输入后台服务器ip和端口例如 10.0.0.17:80 : \033[0m')" SERVER2
VIP="10.0.0.101:80"
SERVER1="10.0.0.102:80"
SERVER2="10.0.0.103:80"

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

Install_HAProxy () {

    lua -v &>/dev/null || { color "请先安装LUA" 2; }

    ${GREEN}开始安装HAProxy依赖包${END}
    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum install -y wget gcc readline-devel libtermcap-devel ncurses-devel libevent-devel
        yum install -y openssl-devel pcre-devel systemd-devel gcc gcc-c++ glibc glibc-devel 
        yum install -y pcre pcre-devel openssl openssl-devel systemd-devel make
    else
        apt update;apt install -y wget  gcc make libssl-dev libpcre3 libpcre3-dev zlib1g-dev libreadline-dev libsystemd-dev
    fi

    if [ ! -e ${SRC_DIR}/haproxy-${HAProxy_VERSION}.tar.gz ];then
        ${GREEN}开始下载HAProxy源码包${END}
        cd ${SRC_DIR}
        wget ${HAProxy_URL}/haproxy-${HAProxy_VERSION}.tar.gz
        [ $? -ne 0  ] && { color "haproxy-${HAProxy_VERSION}.tar.gz 文件下载失败" 1; exit; }
    fi

    useradd -s /sbin/nologin haproxy &> /dev/null

    ${GREEN}开始编译HAProxy${END}
    cd ${SRC_DIR}
    tar xf haproxy-${HAProxy_VERSION}.tar.gz && cd haproxy-${HAProxy_VERSION}
    make -j ${CPUS} ARCH=x86_64 TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_CPU_AFFINITY=1 PREFIX=/usr/local/haproxy -s
    make install PREFIX=/usr/local/haproxy -s

    ${GREEN}创建软链接${END}
    ln -s /usr/local/haproxy/sbin/haproxy /usr/local/bin/haproxy

    ${GREEN}开始创建$USER 配置文件${END}
    mkdir /etc/haproxy/conf.d/ -p
    sysctl -w net.ipv4.ip_nonlocal_bind=1
    echo "sysctl -w net.ipv4.ip_nonlocal_bind=1" > /etc/rc.d/rc.local
    chmod +x /etc/rc.d/rc.local

    cat > /usr/lib/systemd/system/haproxy.service <<-EOF
[Unit]
Description=HAProxy Load Balancer
After=syslog.target network.target

[Service]
ExecStartPre=/usr/local/bin/haproxy -f /etc/haproxy/haproxy.cfg -f /etc/haproxy/conf.d/ -c -q
ExecStart=/usr/local/bin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -f /etc/haproxy/conf.d/ -p /var/lib/haproxy/haproxy.pid
ExecReload=/bin/kill -USR2 \$MAINPID
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/haproxy/haproxy.cfg <<-EOF
global
    maxconn 100000
    chroot /usr/local/haproxy
    stats socket /var/lib/haproxy/haproxy.sock mode 600 level admin
    #uid 99
    #gid 99
    user haproxy
    group haproxy
    daemon

    #nbproc 4
    #cpu-map 1 0
    #cpu-map 2 1
    #cpu-map 3 2
    #cpu-map 4 3
    pidfile /var/lib/haproxy/haproxy.pid
    log 127.0.0.1 local2 info

defaults
    option http-keep-alive
    option forwardfor
    maxconn 100000
    mode http
    timeout connect 300000ms
    timeout client 300000ms
    timeout server 300000ms


listen stats
    mode http
    bind 0.0.0.0:9999
    stats enable
    log global
    #stats refresh 10
    stats realm HAProxy\ 
    stats uri /status
    stats auth ${HAProxy_USER}:${HAProxy_PASSWORD}

#listen web_port
#   bind 10.0.0.10:80
#   mode tcp
#   log global
#   server web1 127.0.0.1:8080 check inter 3000 fall 2 rise 5
#   server web1 127.0.0.1:8080 check inter 3000 fall 2 rise 5
EOF


    cat > /etc/haproxy/conf.d/test.cfg <<-EOF
listen test_web
bind $VIP
mode tcp
server web1 $SERVER1 check
server web2 $SERVER2 check
EOF

    mkdir /var/lib/haproxy &> /dev/null
    chown haproxy:haproxy /var/lib/haproxy/ -R &> /dev/null
    systemctl start haproxy
    systemctl enable haproxy

    ${GREEN}"启动haproxy中！"${END}
    sleep 5

    ss -ntlp|grep -wq 9999

    if [ $? -eq 0 ];then
        color " HAProxy 服务启动成功" 0
    else
        color " HAProxy 服务启动失败" 1
        exit      
    fi

    ${GREEN}HAProxy状态页：http://${HOST}:9999/status${END}
    ${GREEN}用户名/密码：${HAProxy_USER}:${HAProxy_PASSWORD}${END}


}

Install_HAProxy