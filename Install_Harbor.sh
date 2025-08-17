#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"
HOST=`hostname -I|awk '{print $1}'`
GREEN="echo -e \E[1;32m"
END="\E[0m"

# hub
DOCKER_VERSION=28.0.4
COMPOSE_VERSION=1.21.2
DOCKER_URL=https://mirrors.aliyun.com/docker-ce/linux/static/stable/x86_64/
COMPOSE_URL=https://mirrors.aliyun.com/docker-toolbox/linux/compose/${COMPOSE_VERSION}/

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

Install_hub () {

    HUB_VERSION=2.5.2
    HUB_URL=https://github.com/goharbor/harbor/releases/download/${HUB_VERSION}
    #read -p "设置Hub密码: "  HUB_PASSWORD
    #HUB_PASSWORD="Harbor12345"

    docker -v &>/dev/null
    if [ ${?} -ne 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            yum install -y yum-utils
            yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
            yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            systemctl start docker
        else
            apt update
            apt install ca-certificates curl gnupg

            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            chmod a+r /etc/apt/keyrings/docker.gpg

            echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
            "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            apt update
            apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        fi
    fi

    mkdir -p /etc/docker
    tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://registry.docker-cn.com",
        "https://docker.m.daocloud.io",
        "https://docker.imgdb.de",
        "https://docker-0.unsee.tech",
        "https://docker.hlmirror.com",
        "https://docker.1ms.run",
        "https://func.ink",
        "https://lispy.org",
        "https://docker.xiaogenban1993.com"
    ],
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "200m"
    },
    "storage-driver": "overlay2"
}
EOF
    systemctl daemon-reload
    systemctl enable docker
    systemctl restart docker

    cd ${SRC_DIR}
    if [ ! -e harbor-offline-installer-v${HUB_VERSION}.tgz ];then
        wget ${HUB_URL}/harbor-offline-installer-${HUB_VERSION}.tgz
        [ $? -ne 0  ] && { echo "文件下载失败"; exit; }
    fi

    tar xf harbor-offline-installer-v${HUB_VERSION}.tgz -C /usr//
    cd /usr/local/harbor/local
    cp harbor.yml.tmpl harbor.yml

    sed -i "s/hostname: reg.mydomain.com/hostname: ${HOST}/g" harbor.yml 
    #sed -i "s/harbor_admin_password: Harbor12345/harbor_admin_password: ${HUB_PASSWORD}/g" harbor.yml
    sed -i '12,18s/^/#/' harbor.yml

    ./install.sh
    color "Harbor安装成功!" 0
    ${GREEN} "Harbor地址: http://${HOST}"${END}
    ${GREEN} "Harbor用户名: admin"${END}
    #${GREEN} "Harbor密码: ${HUB_PASSWORD}"${END}
    ${GREEN} "Harbor密码: Harbor12345"${END}
    echo
    ${GREEN}daemon.json 添加 "insecure-registries": ["${HOST}:80"]${END}
    ${GREEN}docker login ${HOST}:80 -uadmin -pHarbor12345${END}
    
}

Install_hub