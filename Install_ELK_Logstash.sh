#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"

# Logstash版本
LOGSTASH_VERSION=8.6.1
#LOGSTASH_VERSION=8.18.1
UBUNTU_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${LOGSTASH_VERSION} | cut -d . -f 1`.x/apt/pool/main/l/logstash/logstash-${LOGSTASH_VERSION}-amd64.deb"
RHEL_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${LOGSTASH_VERSION} | cut -d . -f 1`.x/yum/${LOGSTASH_VERSION}/logstash-${LOGSTASH_VERSION}-x86_64.rpm"

ES_HOSTS=[\"http://10.0.0.101:9200\",\"http://10.0.0.102:9200\",\"http://10.0.0.103:9200\"]


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

Install_Logstash () {

    java -version &> /dev/null
    if [ ${?} -ne 0 ];then
        if [[ ${ID} =~ centos|rocky|rhel ]];then
            #yum -y install java-1.8.0-openjdk-devel || { color "安装JDK失败!" 1; exit 1; }
            yum -y install java-21-openjdk || { color "安装JDK失败!" 1; exit 1; }
        else
            apt update
            apt install openjdk-21-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
            #apt install openjdk-8-jdk -y || { color "安装JDK失败!" 1; exit 1; } 
        fi
    fi

    if [ $ID = "centos" -o $ID = "rocky" ];then
        if [ ! -f ${SRC_DIR}/${RHEL_URL##*/} ];then
            wget -P ${SRC_DIR} $RHEL_URL || { color  "下载失败!" 1 ;exit ; } 
        fi
        yum -y install ${SRC_DIR}/${RHEL_URL##*/}
    elif [ $ID = "ubuntu" ];then
        if [ ! -f ${SRC_DIR}/${UBUNTU_URL##*/} ];then
            wget -P ${SRC_DIR} $UBUNTU_URL || { color  "下载失败!" 1 ;exit ; }
        fi
        dpkg -i ${SRC_DIR}/${UBUNTU_URL##*/}
    else
        color "不支持此操作系统!" 1
        exit
    fi
    
    ln -s /usr/share/logstash/bin/logstash /usr/local/bin/
    sed -i "s/User=logstash/User=root/g" /lib/systemd/system/logstash.service
    sed -i "s/Group=logstash/Group=root/g" /lib/systemd/system/logstash.service
    
    cat > /etc/logstash/conf.d/template.conf << EOF 
input {
  #beats {
  #  port => 5044
  #}
  #redis {
  #  host => "127.0.0.1"
  #  port => "6379"
  #  password => "123456"
  #  data_type => "list"
  #  key => "filebeat"
  #  db => "0"
  #}
  #如果有多个key，用下面形式,从而实现将每个不同的key由不同的logstash消费，实现负载均衡
  #redis {
  #  host => ["10.0.0.105"]
  #  port => "6379"
  #  password => "123456"
  #  data_type => "list"
  #  key => "nginx_access"
  #  db => "0"
  #}
  #redis {
  #  host => ["10.0.0.105"]
  #  port => "6379"
  #  password => "123456"
  #  data_type => "list"
  #  key => "nginx_error"
  #  db => "0"
  #}
  #kafka {
  #  bootstrap_servers => "10.0.0.101:9092,10.0.0.102:9092,10.0.0.103:9092"
  #  topic_id => "filebeat-log"
  #  codec => json
  #  #group_id => "logstash" #消费者组的名称
  #  #consumer_threads => "3" #建议设置为和kafka的分区相同的值为线程数
  #  #topics_pattern => "nginx-.*" #通过正则表达式匹配topic，而非用上面topics=>指定固定值
  #}
}

#filter {
#  if "nginx-access" in [tags] {
#    geoip {
#      source => "clientip"      #日志必须是json格式,且有一个clientip的key
#      target => "geoip"
#      #database => "/etc/logstash/conf.d/GeoLite2-City.mmdb"   #指定数据库文件,可选
#      add_field => ["[geoip][coordinates]","%{[geoip][geo][location][lon]}"]   #8.X添加经纬度字段包括经度
#      add_field => ["[geoip][coordinates]","%{[geoip][geo][location][lat]}"]   #8.X添加经纬度字段包括纬度
#      #add_field => ["[geoip][coordinates]", "%{[geoip][longitude]}"]    #7,X添加经纬度字段包括经度
#      #add_field => ["[geoip][coordinates]", "%{[geoip][latitude]}"]     #7,X添加经纬度字段包括纬度
#    }
#    #转换经纬度为浮点数，注意：8X必须做，7.X 可不做此步
#    mutate {
#      convert => [ "[geoip][coordinates]", "float"]       
#    }
#  }
#}


output {
#  stdout {
#    codec => "rubydebug" #输出格式,此为默认值,可省略
#  }
#  if "syslog" in [tags] {
#    elasticsearch {
#      hosts => ${ES_HOSTS}
#      index => "syslog-%{+YYYY.MM.dd}"
#    }
#  }
#  if "nginx-access" in [tags] {
#    elasticsearch {
#      hosts => ${ES_HOSTS}
#      index => "nginx-accesslog-%{+YYYY.MM.dd}"
#      #注意: 地图功能要求必须使用 logstash 开头的索引名称(旧版)
#      #index => "logstash-nginx-accesslog-%{+YYYY.MM.dd}"
#      template_overwrite => true
#    }
#  }
#  if "nginx-error" in [tags] {
#    elasticsearch {
#      hosts => ${ES_HOSTS}
#      index => "nginx-errorlog-%{+YYYY.MM.dd}"
#      template_overwrite => true
#    }
#  }
}
EOF
    systemctl daemon-reload
    systemctl restart logstash
    systemctl enable logstash.service
    systemctl is-active logstash.service
    [ $? -eq 0 ] && color "logstash安装成功" 0 || { color "logstash安装失败!" 1; exit 1; }

}

Install_Logstash