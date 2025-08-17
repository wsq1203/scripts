#!/bin/bash

. /etc/os-release

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# lua
LUA_VERSION=5.3.5
LUA_URL=http://www.lua.org/ftp/

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

Install_lua () {

    ${GREEN}开始安装LUA依赖包${END}
    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum install -y wget gcc readline-devel libtermcap-devel ncurses-devel libevent-devel
    else
        apt update;apt install -q -y wget  gcc make libssl-dev libpcre3 libpcre3-dev zlib1g-dev libreadline-dev libsystemd-dev
    fi

    if [ ! -e ${SRC_DIR}/lua-${LUA_VERSION}.tar.gz ];then
        ${GREEN}开始下载LUA源码包${END}
        cd ${SRC_DIR}
        wget ${LUA_URL}/lua-${LUA_VERSION}.tar.gz
        [ $? -ne 0  ] && { color "lua-${LUA_VERSION}.tar.gz 文件下载失败" 1; exit; }
    fi

    ${GREEN}开始编译LUA${END}
    cd ${SRC_DIR} && tar xf lua-${LUA_VERSION}.tar.gz && cd lua-${LUA_VERSION}
    make linux test

    ${GREEN}创建软链接${END}
    ln -s /usr/local/src/lua-${LUA_VERSION} /usr/local/
    ln -s /usr/local/src/lua-${LUA_VERSION}/src/lua /usr/local/bin/lua
    ln -s /usr/local/src/lua-${LUA_VERSION}/src/luac /usr/local/bin/luac

    lua -v
    if [ $? -ne 0  ];then
        color "LUA安装失败" 1
        exit
    else
        color "LUA安装成功" 0
        ${GREEN} "LUA版本: ${LUA_VERSION}"${END}
        ${GREEN} "LUA安装路径: /usr/local/src/lua-${LUA_VERSION}"${END}
    fi

}

Install_lua