#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# mysql版本信息

#MYSQL='mysql-5.7.33-linux-glibc2.12-x86_64.tar.gz'
#URL=http://mirrors.163.com/mysql/Downloads/MySQL-5.7
MYSQL='mysql-8.0.23-linux-glibc2.12-x86_64.tar.xz'
MYSQL_URL='https://downloads.mysql.com/archives/get/p/23/file'
    
# read -p "mysql_root_password: " MYSQL_ROOT_PASSWORD
# read -p "是否给与root远程登录权限（y/n）: " choice
MYSQL_ROOT_PASSWORD='000000'
choice='y'

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

Install_mysql () {  

    if [ ${UID} -ne 0 ]; then
        color "当前用户不是root,安装失败" 2
        exit 1
    fi

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        rpm -q wget || yum -y -q install wget
    else
        dpkg -i wget &> /dev/null ||{ apt update; apt -y install wget; }
    fi

    cd  ${SRC_DIR}

    if [ !  -e ${MYSQL} ];then
        wget ${MYSQL_URL}/${MYSQL}
    fi

    if [ -e /usr/local/mysql ];then
        color "数据库已存在，安装失败" 1
        exit
    fi
 
    ${GREEN}"开始安装MySQL数据库..."${END}

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum  -y install libaio numactl-libs ncurses-compat-libs
    else
        apt update
        apt -y install libaio1 numactl libnuma-dev
    fi
    
    tar xf ${MYSQL} -C /usr/local/
    MYSQL_DIR=`echo ${MYSQL}| sed -nr 's/^(.*[0-9]).*/\1/p'`
    ln -s /usr/local/${MYSQL_DIR} /usr/local/mysql
    
    id mysql &> /dev/null || { useradd -s /sbin/nologin -r mysql ; color "创建mysql用户" 0; }
    echo 'PATH=/usr/local/mysql/bin/:$PATH' > /etc/profile.d/mysql.sh
    . /etc/profile.d/mysql.sh
    ln -s /usr/local/mysql/bin/* /usr/bin/
    cat > /etc/my.cnf <<-EOF
[mysqld]
server-id=`hostname -I|tr . ' '|awk '{print $4}'`
log-bin
datadir=/usr/local/mysql/data
socket=/usr/local/mysql/mysql.sock
log-error=/usr/local/mysql/logs/mysql.log
pid-file=/usr/local/mysql/mysql.pid

[client]
socket=/usr/local/mysql/mysql.sock
EOF
    mkdir /usr/local/mysql/{data,logs}
    chown -R mysql.mysql /usr/local/mysql/
    mysqld --initialize --user=mysql --datadir=/usr/local/mysql/data 
    # cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
    # chkconfig --add mysqld
    # chkconfig mysqld on
    # systemctl start mysqld

cat > /etc/systemd/system/mysqld.service <<-EOF
[Unit]
Description=MySQL Server
After=network.target

[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf
Restart=on-failure
LimitNOFILE=65535

# 数据目录权限
WorkingDirectory=/usr/local/mysql/data

[Install]
WantedBy=multi-user.target 
EOF

    systemctl daemon-reload
    systemctl enable mysqld
    systemctl start mysqld
    
    [ ${?} -ne 0 ] && { color "数据库启动失败，退出!" 1 ;exit; }
    sleep 3

    # ubuntu2204
    ldd /usr/local/mysql/bin/mysqld | grep 'not found' &> /dev/null
    [ ${?} -eq 0 ] && ln -s /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/libtinfo.so.5

    MYSQL_OLDPASSWORD=`awk '/A temporary password/{print $NF}' /usr/local/mysql/logs/mysql.log`
    mysqladmin  -uroot -p${MYSQL_OLDPASSWORD} password ${MYSQL_ROOT_PASSWORD} &>/dev/null
    if [ ${choice} == 'y' ];then
        mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "create user root@'%' identified by '${MYSQL_ROOT_PASSWORD}' "
        mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "grant all privileges on *.* to root@'%' with grant option;"
    fi
    mkdir -p /var/lib/mysql && ln -s /usr/local/mysql/mysql.sock /var/lib/mysql/mysql.sock
    ln -s /usr/local/mysql/logs/error.log /var/log/mysql.log
    color "数据库安装完成" 0

}

Install_mysql