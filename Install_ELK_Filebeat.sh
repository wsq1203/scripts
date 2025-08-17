#!/bin/bash

. /etc/os-release

SRC_DIR="/usr/local/src"


# Filebeat版本
FILEBEAT_VERSION=8.6.1
# FILEBEAT_VERSION=8.18.1
UBUNTU_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${FILEBEAT_VERSION} | cut -d . -f 1`.x/apt/pool/main/f/filebeat/filebeat-${FILEBEAT_VERSION}-amd64.deb"
RHEL_URL="https://mirrors.tuna.tsinghua.edu.cn/elasticstack/`echo ${FILEBEAT_VERSION} | cut -d . -f 1`.x/yum/${FILEBEAT_VERSION}/filebeat-${FILEBEAT_VERSION}-x86_64.rpm"

# 采集日志推送地址
ES_HOSTS=[\"10.0.0.101:9200\",\"10.0.0.102:9200\",\"10.0.0.103:9200\"]
LOGSTASH=[\"10.0.0.103:5044\"]
KAFKA=[\"10.0.0.101:9200\",\"10.0.0.102:9200\",\"10.0.0.103:9200\"]
REDIS=[\"10.0.0.103:6379\"]
#REDIS=[\"10.0.0.101:9200\",\"10.0.0.102:9200\",\"10.0.0.103:9200\"]

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

Install_Filebeat () {

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

    # cp /etc/filebeat/filebeat.yml{,.bak}
    cat > /etc/filebeat/template-filebeat.yml << EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
  - /var/log/*

#-------------------------- Nginx input ------------------------------
- type: log
  enabled: true
  paths:
    - /var/log/nginx/access_json.log
  json.keys_under_root: true #默认false,只识别为普通文本,会将全部日志数据存储至message字段，改为true则会以Json格式存储
  json.overwrite_keys: true  #设为true,使用json格式日志中自定义的key替代默认的message字段
  tags: ["nginx-access"]     #指定tag,用于分类 

- type: log
  enabled: true
  paths:
    - /var/log/nginx/error.log
  tags: ["nginx-error"]



#-------------------------- Elasticsearch output ------------------------------
#output.elasticsearch:
#  hosts: ${ES_HOSTS}
#  indices:
#    - index: "nginx-access-%{[agent.version]}-%{+yyy.MM.dd}"
#      when.contains:
#        tags: "nginx-access"   #如果记志中有access的tag,就记录到nginx-access的索引中
#    - index: "nginx-error-%{[agent.version]}-%{+yyy.MM.dd}"
#      when.contains:
#        tags: "nginx-error"   #如果记志中有error的tag,就记录到nginx-error的索引中
 
#setup.ilm.enabled: false #关闭索引生命周期ilm功能，默认开启时索引名称只能为filebeat-*
#setup.template.name: "nginx" #定义模板名称,要自定义索引名称,必须指定此项,否则无法启动
#setup.template.pattern: "nginx-*" #定义模板的匹配索引名称,要自定义索引名称,必须指定此项,否则无法启动


#-------------------------- logstash output -----------------------------------
#output.logstash:
#  hosts: ${LOGSTASH}
#  index: filebeat  
#  loadbalance: true    #默认为false,只随机输出至一个可用的logstash,设为true,则输出至全部logstash
#  worker: 1     #线程数量
#  compression_level: 3 #压缩比

#-------------------------- Redis output ---------------------------------------
#output.redis:
#  hosts: ${REDIS}
#  password: "123456"
#  db: "0"
#  key: "filebeat"
  #keys: #也可以用下面的不同日志存放在不同的key的形式
  #  - key: "nginx_access"
  #    when.contains:
  #    tags: "access"
  #  - key: "nginx_error"
  #    when.contains:
  #    tags: "error"

#-------------------------- Kafka output ---------------------------------------
#output.kafka:
#  hosts: ${KAFKA}
#  topic: filebeat-log   #指定kafka的topic
#  partition.round_robin:
#    reachable_only: true#true表示只发布到可用的分区，false时表示所有分区，如果一个节点down，会block
#  required_acks: 1  #如果为0，错误消息可能会丢失，1等待写入主分区（默认），-1等待写入副本分区
#  compression: gzip  
#  max_message_bytes: 1000000 #每条消息最大长度，以字节为单位，如果超过将丢弃
EOF
    systemctl enable filebeat.service
    systemctl restart filebeat.service
    systemctl is-active filebeat.service
    [ $? -eq 0 ] && color "filebeat安装成功" 0 || { color "filebeat安装失败!" 1; exit 1; }

}

Install_Filebeat