#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"
GREEN="echo -e \E[1;32m"
END="\E[0m"

# SONARQUBE
SONARQUBE_VER="9.9.0.65466"
SONARQUBE_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VER}.zip"
SONAR_USER=sonarqube
SONAR_USER_PASSWORD=000000

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

Install_sonarqube () {

    java -version &> /dev/null
    if [ ! ${?} -eq 0 ];then
        if [ $ID = "centos" -o $ID = "rocky" ];then
            yum -y install java-17-openjdk-devel unzip
        else 
            apt update
            apt -y install openjdk-17-jdk unzip
            #apt -y install openjdk-11-jdk
        fi
    fi

    useradd -s /bin/bash -m sonarqube 
    cat >> /etc/sysctl.conf <<EOF
vm.max_map_count=524288
fs.file-max=131072
EOF
    sysctl -p
    cat >> /etc/security/limits.conf  <<EOF
sonarqube  -  nofile 131072
sonarqube  -  nproc  8192
EOF

    systemctl is-active postgresql 
    if [ ${?} -eq 0 ];then
        ${GREEN}PostgreSQL 已安装!${END}
    else
        ${GREEN}开始安装PostgreSQL${END}
        if [ $ID = "centos" -o $ID = "rocky" ];then
            if [ `echo ${VERSION_ID}|cut -d. -f1` -eq 7 ];then
                rpm -i http://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
                yum -y install postgresql12-server postgresql12 postgresql12-libs unzip
                postgresql-12-setup --initdb
            elif [ `echo ${VERSION_ID}|cut -d. -f1` -eq 8 ];then
                rpm -i https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhatrepo-latest.noarch.rpm
                dnf -qy module disable postgresql
                dnf install -y postgresql12-server unzip
                /usr/pgsql-12/bin/postgresql-12-setup initdb
            else
                echo  "请自行安装PostgreSQL"
                exit
            fi
            systemctl enable  postgresql.service
            systemctl start  postgresql.service
        else 
            apt update
            apt -y install postgresql
        fi
        if [ $? -eq 0 ];then
            color "安装postgresql完成!" 0
        else
            color "安装postgresql失败!" 1
            exit
        fi
    fi

    if [ $ID = "centos" -o $ID = "rocky" ];then
        sed -i.bak "/listen_addresses/a listen_addresses = '*'"  /var/lib/pgsql/data/postgresql.conf
        cat >>  /var/lib/pgsql/data/pg_hba.conf <<EOF
host    all             all             0.0.0.0/0               md5
EOF
    else 
        sed -i.bak "/listen_addresses/c listen_addresses = '*'" /etc/postgresql/1*/main/postgresql.conf 
        cat >>  /etc/postgresql/*/main/pg_hba.conf <<EOF
host    all             all             0.0.0.0/0               md5
EOF
    fi

    systemctl restart postgresql
    
    su - postgres -c "psql -U postgres <<EOF
CREATE USER $SONAR_USER WITH ENCRYPTED PASSWORD '$SONAR_USER_PASSWORD';
CREATE DATABASE sonarqube OWNER $SONAR_USER;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO $SONAR_USER;
EOF"

    
    if [ ! -f ${SRC_DIR}/sonarqube-${SONARQUBE_VER}.zip ] ;then
        wget -P ${SRC_DIR} ${SONARQUBE_URL}  || { color  "下载失败!" 1 ;exit ; }
    fi
    cd ${SRC_DIR}
    unzip ${SONARQUBE_URL##*/}
    ln -s /usr/local/src/sonarqube-${SONARQUBE_VER} /usr/local/sonarqube
    chown -R sonarqube.sonarqube /usr/local/sonarqube/
    cat > /lib/systemd/system/sonarqube.service <<EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=simple
User=sonarqube
Group=sonarqube
PermissionsStartOnly=true
ExecStart=/usr/bin/nohup /usr/bin/java -Xms32m -Xmx32m -Djava.net.preferIPv4Stack=true -jar /usr/local/sonarqube/lib/sonar-application-${SONARQUBE_VER}.jar
StandardOutput=syslog
LimitNOFILE=65536
LimitNPROC=8192
TimeoutStartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    cat >> /usr/local/sonarqube/conf/sonar.properties <<EOF
sonar.jdbc.username=$SONAR_USER
sonar.jdbc.password=$SONAR_USER_PASSWORD
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
EOF

    systemctl enable --now   sonarqube.service 
    systemctl is-active sonarqube
    if [ $?  -eq 0 ];then  
        echo 
        color "sonarqube 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        ${GREEN}"http://$HOST:9000/"${END}
        echo -e "用户和密码: \c"
        ${GREEN}"admin/admin"${END}
    else
        color "sonarqube 安装失败!" 1
        exit
    fi

}

Install_sonarqube