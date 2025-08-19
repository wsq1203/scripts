#!/bin/bash

. /etc/os-release

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# GIT
GIT_VERSION=2.49.0
GIT_URL=https://github.com/git/git/archive/refs/tags/v${GIT_VERSION}.tar.gz

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

Install_git () {

    ${GREEN}安装依赖${END}
    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum -y install gcc make openssl-devel curl-devel expat-devel wget

    else
        apt update
        apt install gcc make dh-autoreconf libcurl4-gnutls-dev libexpat1-dev wget
    fi

    if [ ! -f ${SRC_DIR}/v${GIT_VERSION}.tar.gz ];then
        ${GREEN}下载源码包${END}
        wget -P ${SRC_DIR} ${GIT_URL}
    fi

    cd ${SRC_DIR} && tar xf v${GIT_VERSION}.tar.gz && cd git-${GIT_VERSION}
    make -j ${CPUS} prefix=/usr/local/git all && make prefix=/usr/local/git install
    echo 'PATH=/usr/local/git/bin/:$PATH' > /etc/profile.d/git.sh
    . /etc/profile.d/git.sh && git --version
    if [ ${?} -eq 0 ];then
        color "git 安装成功!" 0
    else
        color "git 安装失败!" 1
        exit 1
    fi

    ${GREEN}创建示例项目project${END}
    mkdir -p /root/project && cd /root/project
    cat > init.sh <<EOF
git init
git config --global user.name wang
git config --global user.email wang@qq.com
git config --global core.editor vim
git config --global color.ui true
git remote add origin git@gitlab.example.com:testgroup/testproject.git

# git clone https://<用户名>:<密码>@gitee.com/lbtooth/meta-project.git
# git remote add origin https://<user>:<password>@gitee.com/wsq1203/testproject.git
# git checkout -b main
# git add .
# git commit -m "init"
# git push -u origin main
# git push -u origin --tags
EOF

}

Install_git