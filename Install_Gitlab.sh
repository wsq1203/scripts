#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"
HOST=`hostname -I|awk '{print $1}'`

# GITLAB
GITLAB_VERSION=17.11.1
GITLAB_R_URL=https://packages.gitlab.com/gitlab/gitlab-ce/packages/el/`echo ${VERSION_ID}|cut -d. -f1`/gitlab-ce-${GITLAB_VERSION}-ce.0.el`echo ${VERSION_ID}|cut -d. -f1`.x86_64.rpm/download.rpm
GITLAB_U_URL=https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/${VERSION_CODENAME}/gitlab-ce_${GITLAB_VERSION}-ce.0_amd64.deb/download.deb
#GITLAB_U_URL=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/ubuntu/pool/${VERSION_CODENAME}/main/g/gitlab-ce/gitlab-ce_${GITLAB_VERSION}-ce.0_amd64.deb

GITLAB_ROOT_PASSWORD=wsq011203
SMTP_PASSWORD=fgprsdjtojaicifd

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

Install_gitlab () {

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        if [ ! -f ${SRC_DIR}/gitlab-ce-${GITLAB_VERSION}-ce.0.el`echo ${VERSION_ID}|cut -d. -f1`.x86_64.rpm ];then
            wget -P ${SRC_DIR} ${GITLAB_R_URL}  || { color  "下载失败!" 1 ;exit ; }          
        fi
        yum install -y ${SRC_DIR}/gitlab-ce-${GITLAB_VERSION}-ce.0.el`echo ${VERSION_ID}|cut -d. -f1`.x86_64.rpm 2> /dev/null
        yum install -y ${SRC_DIR}/download.rpm 2> /dev/null
    else
        if [ ! -f ${SRC_DIR}/gitlab-ce_${GITLAB_VERSION}-ce.0_amd64.deb ];then
            wget -P ${SRC_DIR} ${GITLAB_U_URL} || { color  "下载失败!" 1 ;exit ; }
        fi
        apt update
        apt install -y ${SRC_DIR}/gitlab-ce_${GITLAB_VERSION}-ce.0_amd64.deb 2> /dev/null
        apt install -y ${SRC_DIR}/download.deb 2> /dev/null
    fi

    sed -i.bak  "/^external_url.*/c external_url \'http://${HOST}\'" /etc/gitlab/gitlab.rb
    cat >> /etc/gitlab/gitlab.rb <<EOF
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.qq.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "3311987957@qq.com"
gitlab_rails['smtp_password'] = "${SMTP_PASSWORD}"
gitlab_rails['smtp_domain'] = "qq.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = false
gitlab_rails['smtp_tls'] = true
gitlab_rails['gitlab_email_from'] = "3311987957@qq.com"
gitlab_rails['initial_root_password'] = "${GITLAB_ROOT_PASSWORD}"
EOF
    gitlab-ctl reconfigure
    gitlab-ctl status

    if [ ${?} -eq 0 ];then
        color "gitlab 安装成功!" 0
    else
        color "gitlab 安装失败!" 1
        exit 1
    fi
    
    echo "-------------------------------------------------------------------"
    echo -e "请访问链接: \E[32;1mhttp://$HOST/\E[0m"
 	echo -e "用户和密码: \E[32;1mroot/${GITLAB_ROOT_PASSWORD}\E[0m"

}

Install_gitlab