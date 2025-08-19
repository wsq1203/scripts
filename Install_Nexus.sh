#!/bin/bash

. /etc/os-release

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
SRC_DIR="/usr/local/src"
HOST=`hostname -I|awk '{print $1}'`
GREEN="echo -e \E[1;32m"
END="\E[0m"

# nexus版本
NEXUS_URL=https://download.sonatype.com/nexus/3
NEXUS_VERSION=3.43.0-01
NEXUS_FILE=nexus-${NEXUS_VERSION}-unix.tar.gz

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

Install_nexus () {

    java -version &> /dev/null
    if [ ${?} -ne 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            #yum -y install java-1.8.0-openjdk-devel || { color "安装JDK失败!" 1; exit 1; }
            yum -y install java-11-openjdk || { color "安装JDK失败!" 1; exit 1; }
        else
            apt update
            apt install openjdk-11-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
            #apt install openjdk-8-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
        fi
    fi

    MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_GB=$(echo "scale=1; ${MEM_KB} / 1048576" | bc)

    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    MAJOR_VERSION=$(echo ${JAVA_VERSION} | awk -F '.' '{if($1=="1") print $2; else print $1}')

    if [ $(echo "${MEM_GB} >= 3.7" | bc) -eq 0 ] ;then
        color "最少需要 4G 内存" 3
        exit 1
    fi

    if [ "${MAJOR_VERSION}" -lt 8 ]; then
        color "Java版本需要大于等于1.8" 3
        exit 1
    fi

    cd ${SRC_DIR}

    if [ ! -e ${NEXUS_FILE} ];then
        wget ${NEXUS_URL}/${NEXUS_FILE} || { color "下载 nexus 失败" 1 ; exit; }
    fi
    
    tar xvf ${NEXUS_FILE} -C /usr/local/
    ln -s /usr/local/nexus-${NEXUS_VERSION} /usr/local/nexus
    ln -s /usr/local/nexus/bin/nexus /usr/bin/

    echo 'run_as_user="root"' > /usr/local/nexus/bin/nexus.rc

    cat > /lib/systemd/system/nexus.service <<-EOF
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/usr/bin/nexus start
ExecStop=/usr/bin/nexus stop
User=root
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now nexus.service &> /dev/null
    systemctl is-active nexus.service &> /dev/null && color "nexus 安装完成" 0 || { color "nexus 安装失败" 1 ; exit; }

    echo "-------------------------------------------------------------------"
    echo -e "访问链接: \c"
    ${GREEN}"http://${HOST}:8081/"${END}
    while [ ! -f /usr/local/sonatype-work/nexus3/admin.password ];do
        sleep 1
    done
    PASS=`cat /usr/local/sonatype-work/nexus3/admin.password`
    echo -e "用户和密码: \c"
    ${GREEN}"admin/${PASS}"${END}

}

Install_nexus