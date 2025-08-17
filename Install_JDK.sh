#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"

JDK_FILE="jdk-11.0.26_linux-x64_bin.tar.gz"

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

Install_jdk () {

    if   [ ! -f "${SRC_DIR}/${JDK_FILE}" ];then
        echo -e "\E[1;$[RANDOM%7+31]m${SRC_DIR}目录下，${JDK_FILE}文件不存在，需要自行下载JDK\E[0m"
	    exit; 
    elif [ -d /usr/local/jdk ];then
        color "JDK 已经安装" 1
	    exit
    else 
        [ -d "${SRC_DIR}" ] || mkdir -pv $SRC_DIR
    fi

    tar xvf ${SRC_DIR}/${JDK_FILE}  -C /usr/local
    
    cd  /usr/local/ && ln -s /usr/local/jdk* /usr/local/jdk 

    cat >  /etc/profile.d/jdk.sh <<-EOF
export JAVA_HOME=/usr/local/jdk
export PATH=\$PATH:\$JAVA_HOME/bin
#export JRE_HOME=\$JAVA_HOME/jre
#export CLASSPATH=.:\$JAVA_HOME/lib/:\$JRE_HOME/lib/
EOF

    .  /etc/profile.d/jdk.sh
    java -version && color "JDK 安装完成" 0 || { color "JDK 安装失败" 1 ; exit; }

}

Install_jdk