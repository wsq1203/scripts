#!/bin/bash

. /etc/os-release

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# PHP 
ONIGURUMA_VERSION=6.9.4
PHP_VERSION=7.3.7

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

Install_php () {
  
    ${GREEN}安装依赖包${END}  

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum install -y wget autoconf automake libtool libxml2 libxml2-devel sqlite-devel libcurl-devel 
        yum install -y oniguruma-devel libicu-devel bzip2-devel pcre2-devel freetype-devel libjpeg-turbo-devel 
        yum install -y libtidy-devel postgresql13-devel openssl-devel zlib-devel gd-devel libXpm-devel ncurses-devel 
        yum install -y libmcrypt-devel ntp make screen sysstat curl wget autoconf automake libtool
    else
	    apt update && apt install -y wget autoconf automake libtool libxml2
        apt install -y libxml2-dev libsqlite3-dev libcurl4-openssl-dev libonig-dev 
        apt install -y libicu-dev libbz2-dev libpcre2-dev libfreetype6-dev 
        apt install -y libjpeg-turbo8-dev libtidy5-dev postgresql-server-dev-all 
        apt install -y libssl-dev zlib1g-dev libgd-dev libxpm-dev ncurses-dev 
        apt install -y libmcrypt-dev ntp make screen sysstat curl wget autoconf automake libtool
    fi

    ${GREEN}下载压缩包${END}

    if [ ! -f "${SRC_DIR}/php-${PHP_VERSION}.tar.gz" ];then
	    wget --no-check-certificate -P /usr/local/src/ http://www.php.net/distributions/php-${PHP_VERSION}.tar.gz
    fi

    if [ ! -f "${SRC_DIR}/oniguruma-${ONIGURUMA_VERSION}.tar.gz" ];then
        wget https://codeload.github.com/kkos/oniguruma/tar.gz/v${ONIGURUMA_VERSION} -O /usr/local/src/oniguruma-${ONIGURUMA_VERSION}.tar.gz
    fi

    ${GREEN}编译oniguruma${END}
    cd ${SRC_DIR}
    tar xf oniguruma-${ONIGURUMA_VERSION}.tar.gz && cd oniguruma-${ONIGURUMA_VERSION}/
    ./autogen.sh && ./configure --prefix=/usr || { color "oniguruma 编译失败,退出!" 1 ; exit; }
    make -j ${CPUS} && make install

    ${GREEN}编译php${END}
    cd ${SRC_DIR}
    tar xf php-${PHP_VERSION}.tar.gz && cd php-${PHP_VERSION}/
    ./configure --prefix=/usr/local/php --enable-mysqlnd --with-mysqli=mysqlnd \
                --with-pdo-mysql=mysqlnd --with-openssl --with-zlib --with-config-file-path=/etc \
                --with-config-file-scan-dir=/etc/php.d --enable-mbstring --enable-xml --enable-sockets \
                --enable-fpm --enable-maintainer-zts --disable-fileinfo
    make -j ${CPUS} && make install

    ln -s /usr/local/php/sbin/php-fpm /usr/sbin/

    cp php.ini-production /etc/php.ini &> /dev/null
    cp sapi/fpm/php-fpm.service /usr/lib/systemd/system/ &> /dev/null
    cd /usr/local/php/etc
    cp php-fpm.conf.default php-fpm.conf &> /dev/null
    cd /usr/local/php/etc/php-fpm.d/
    cp www.conf.default www.conf &> /dev/null

    mkdir /etc/php.d/ &> /dev/null
    cat > /etc/php.d/opcache.ini << EOF
[opcache]
zend_extension=opcache.so
opcache.enable=1
EOF

    systemctl daemon-reload &> /dev/null
    systemctl enable --now php-fpm.service &> /dev/null

    ss -lnt | grep 9000
    if [ $? -eq 0 ];then
        color "php安装成功" 0
    else
        color "php安装失败" 1
        exit
    fi
}

Install_php