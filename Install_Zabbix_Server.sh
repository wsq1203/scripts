#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"
HOST=`hostname -I|awk '{print $1}'`
GREEN="echo -e \E[1;32m"
END="\E[0m"

# zabbix版本信息
ZABBIX_MAJOR_VER=6.0
ZABBIX_VER=${ZABBIX_MAJOR_VER}-4
ZABBIX_URL="mirror.tuna.tsinghua.edu.cn/zabbix"

# zabbix连接mysql
MYSQL_HOST="10.0.0.102"
MYSQL_ROOT_PASS="000000"
MYSQL_ZABBIX_USER="zabbix@'%'"
MYSQL_ZABBIX_PASS="000000"

# 自定义字体（非必须）
FONT=HYZHENGYUAN.TTF


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


Install_zabbix_server () {

    if [ -f "${FONT}" ] ;then 
	    mv /usr/share/zabbix/assets/fonts/graphfont.ttf{,.bak}
		cp  "${FONT}" /usr/share/zabbix/assets/fonts/graphfont.ttf
	else
		color "缺少字体文件!" 1
	fi

    if [ ${MYSQL_HOST} == "localhost" ];then
        mysql --version &> /dev/null || { color "开始安装MYSQL" 0 ; Install_mysql; }
    else
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            yum -y -q install mysql
        else
            apt update; apt -y install mysql 
        fi
    fi

    mysql -h${MYSQL_HOST} -uroot -p${MYSQL_ROOT_PASS} <<EOF
set global log_bin_trust_function_creators = 0;
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user ${MYSQL_ZABBIX_USER} identified with mysql_native_password by "${MYSQL_ZABBIX_PASS}";
grant all privileges on zabbix.* to ${MYSQL_ZABBIX_USER};
set global log_bin_trust_function_creators = 1;
quit
EOF

    if [ ${?} -eq 0 ];then
        color "MySQL数据库准备完成" 0
    else
        color "MySQL数据库配置失败,退出" 1
        exit
    fi

    if [[ ${ID} =~ centos|rocky|rhel ]] ;then 
        rpm -Uvh https://${ZABBIX_URL}/zabbix/${ZABBIX_MAJOR_VER}/rhel/`echo ${VERSION_ID}|cut -d. -f1`/x86_64/zabbix-release-${ZABBIX_VER}.el`echo ${VERSION_ID}|cut -d. -f1`.noarch.rpm
        
        if [ ${?} -eq 0 ];then
	        color "YUM仓库准备完成" 0
        else
            color "YUM仓库配置失败,退出" 1
		    exit
	    fi

	    sed -i "s#repo.zabbix.com#${ZABBIX_URL}#" /etc/yum.repos.d/zabbix.repo

	    if [[ ${VERSION_ID} == 8* ]];then 
		    yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent zabbix-get langpacks-zh_CN
        else 
		    yum -y install zabbix-server-mysql zabbix-agent  zabbix-get
			yum -y install centos-release-scl
			rpm -q yum-utils  || yum -y install yum-utils
			yum-config-manager --enable zabbix-frontend
			yum -y install zabbix-web-mysql-scl zabbix-apache-conf-scl
        fi
    else 
	   	wget https://${ZABBIX_URL}/zabbix/${ZABBIX_MAJOR_VER}/ubuntu/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_VER}+ubuntu${VERSION_ID}_all.deb
        dpkg -i zabbix-release_${ZABBIX_VER}+ubuntu${VERSION_ID}_all.deb

        if [ ${?} -eq 0 ];then
           	color "APT仓库准备完成" 0
	    else
           	color "APT仓库配置失败,退出" 1
            exit
        fi

        sed -i.bak "s#repo.zabbix.com#${ZABBIX_URL}#" /etc/apt/sources.list.d/zabbix.list
        apt update
        apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent zabbix-get language-pack-zh-hans 
    fi

	zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p$MYSQL_ZABBIX_PASS -h$MYSQL_HOST zabbix
    mysql -h${MYSQL_HOST} -uroot -p${MYSQL_ROOT_PASS} -e "set global log_bin_trust_function_creators = 0"
	
	sed -i -e "/.*DBPassword=.*/c DBPassword=${MYSQL_ZABBIX_PASS}" -e "/.*DBHost=.*/c DBHost=${MYSQL_HOST}" /etc/zabbix/zabbix_server.conf

	if [[ ${ID} =~ centos|rocky|rhel ]];then
	    if [[ ${VERSION_ID} == 8* ]];then 	        
            sed -i -e "/.*date.timezone.*/c php_value[date.timezone] = Asia/Shanghai" -e "/.*upload_max_filesize.*/c php_value[upload_max_filesize] = 20M" /etc/php-fpm.d/zabbix.conf
            systemctl enable --now zabbix-server zabbix-agent httpd php-fpm
		else
		    sed -i "/.*date.timezone.*/c php_value[date.timezone] = Asia/Shanghai" /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
		    systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
		    systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm
		fi
	else
        sed -i "/date.timezone/c php_value date.timezone Asia/Shanghai" /etc/apache2/conf-available/zabbix.conf		
        chown -R www-data.www-data /usr/share/zabbix/
        systemctl enable  zabbix-server zabbix-agent apache2
        systemctl restart  zabbix-server zabbix-agent apache2
    fi

    if [ ${?}  -eq 0 ];then  
        echo 
        color "ZABBIX-${ZABBIX_VER}安装完成!" 0
        echo "-------------------------------------------------------------------"
        ${GREEN}"请访问: http://${HOST}/zabbix"${END}
    else
        color "ZABBIX-${ZABBIX_VER}安装失败!" 1
        exit
    fi

}

Install_zabbix_server