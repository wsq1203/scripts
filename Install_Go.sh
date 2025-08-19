#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"

# GO
GO_VERSION=1.24.0
URL=https://studygolang.com/dl/golang/go${GO_VERSION}.linux-amd64.tar.gz

INSTALL_DIR=/usr/local
GOPATH_DIR=/opt/go

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

Install_Go () {

    if ! [[ $ID_LIKE =~ debian|rhel ]];then
        color "不支持此操作系统，退出!" 1
        exit
    fi
    
    if [ ! -f  ${SRC_DIR}/go${GO_VERSION}.linux-amd64.tar.gz ] ;then
        cd ${SRC_DIR} && wget $URL
    fi
    
    tar xf ${SRC_DIR}/go${GO_VERSION}.linux-amd64.tar.gz -C ${INSTALL_DIR} || { color "Go 解压缩失败!" 1;exit; }
    cat >  /etc/profile.d/go.sh <<EOF
export GOROOT=${INSTALL_DIR}/go
export PATH=$PATH:\$GOROOT/bin
EOF
    .  /etc/profile.d/go.sh

    ln -s ${INSTALL_DIR}/go/bin/* /usr/local/bin/

    go version 
    if [ $? -eq 0 ] ;then 
        color "Golang 安装成功!" 0  
    else 
        color "Golang 安装失败!" 1
        exit 1
    fi

    cat >>  /etc/profile.d/go.sh <<EOF
export GOPATH=${GOPATH_DIR}
EOF
    [ ! -d ${GOPATH_DIR} ] && mkdir -pv ${GOPATH_DIR}/src
    . /etc/profile.d/go.sh
    go env -w GOPROXY=https://goproxy.cn,direct

    mkdir -pv ${GOPATH_DIR}/src/hello
    cd  ${GOPATH_DIR}/src/hello
    cat > hello.go <<EOF
package main

import "fmt"

func main() {
   fmt.Println("Hello, world!")
}
EOF
   go mod init
   go build
   ./hello

}

Install_Go