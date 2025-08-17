#!/bin/bash

. /etc/os-release

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
SRC_DIR="/usr/local/src"


# PostgreSQL
POSTGRESQL_VERSION=17.5
INSTALL_DIR=/usr/local/pgsql
DATA_DIR=/usr/local/pgsql/data
DB_USER=postgres

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

Install_postgresql () {

    if [ $ID = 'centos' -o $ID = 'rocky' ];then
	    yum install -y  gcc make readline-devel zlib-devel
	elif [ $ID = 'ubuntu' ];then
	    apt update
	    apt install -y  gcc make libreadline-dev zlib1g-dev
	else
	    color "不支持此操作系统，退出!" 1
	    exit
	fi

    if [ ! -f  ${SRC_DIR}/postgresql-${POSTGRESQL_VERSION}.tar.gz ] ;then
	    wget -P ${SRC_DIR} https://ftp.postgresql.org/pub/source/v${POSTGRESQL_VERSION}/postgresql-${POSTGRESQL_VERSION}.tar.gz
	fi

    cd ${SRC_DIR} && tar xf postgresql-${POSTGRESQL_VERSION}.tar.gz
    cd ${SRC_DIR}/postgresql-${POSTGRESQL_VERSION} && ./configure --prefix=${INSTALL_DIR}
    make -j $CPUS world
    make install-world

    useradd -s /bin/bash -m -d /home/$DB_USER  $DB_USER
    
    mkdir ${DATA_DIR} -pv
    chown -R $DB_USER.$DB_USER ${DATA_DIR}/
    
    cat > /etc/profile.d/pgsql.sh <<EOF
export PGHOME=${INSTALL_DIR}
export PATH=${INSTALL_DIR}/bin/:\$PATH
export PGDATA=/pgsql/data
export PGUSER=postgres
export MANPATH=${INSTALL_DIR}/share/man:\$MANPATH

alias pgstart="pg_ctl -D ${DATA_DIR} start"
alias pgstop="pg_ctl -D ${DATA_DIR} stop"
alias pgrestart="pg_ctl -D ${DATA_DIR} restart"
alias pgrestatus="pg_ctl -D ${DATA_DIR} status"
EOF
    
    su - $DB_USER -c 'initdb'

cat > /lib/systemd/system/postgresql.service <<EOF
[Unit]
Description=PostgreSQL database server
After=network.target

[Service]
User=postgres
Group=postgres

ExecStart=${INSTALL_DIR}/bin/postmaster -D ${DATA_DIR}
ExecReload=/bin/kill -HUP \$MAINPID

[Install]
WantedBy=multi-user.target

EOF
    systemctl daemon-reload
	systemctl enable --now postgresql.service
	systemctl is-active postgresql.service
	if [ $? -eq 0 ] ;then 
        color "PostgreSQL 安装成功!" 0  
    else 
        color "PostgreSQL 安装失败!" 1
        exit 1
    fi  

}

Install_postgresql