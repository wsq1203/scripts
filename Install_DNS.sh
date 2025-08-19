#!/bin/bash

. /etc/os-release

# 需要解析的域名
YM=www
WZ=wang.org
IPADDR=10.0.0.13
NET_NAME=`ip a | grep "^[0-9]" | grep -v "lo" | tr -s ':' ' '|awk '{print $2}'`

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

Install_DNS () {

    if [[ ${ID} =~ centos|rocky|rhel ]];then
        yum  -y install bind bind-utils
        cat >> /etc/named.conf <<EOF
zone "${WZ}" IN {
       type master;
       file "/etc/named/${WZ}.zone";
};
EOF
        cat > /etc/named/${WZ}.zone <<EOF
\$TTL    604800
@       IN     SOA     ${WZ}. admin (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
        IN     NS     master
master  IN     A       ${HOST}
www     IN     A       ${IPADDR}
EOF
        systemctl restart named
        systemctl enable named
        rdnc reload
        
        sed -i '/DNS/d' /etc/sysconfig/network-scripts/ifcfg-${NET_NAME}
        echo "DNS=${HOST}" >> /etc/sysconfig/network-scripts/ifcfg-${NET_NAME}
        nmcli connection reload 
        nmcli connection up ${NET_NAME}

        ping -c 3 ${YM}.${WZ}
        if [ $? -eq 0 ];then
            color "DNS配置完成" 0
        else
            color "DNS配置失败" 1
            exit 1
        fi

    else
        apt update
        apt -y install bind9 bind9-utils bind9-host bind9-dnsutils
        cat >> /etc/bind/named.conf.default-zones <<EOF
zone "${WZ}" IN {
       type master;
       file "/etc/bind/${WZ}.zone";
};
EOF
        cat > /etc/bind/${WZ}.zone <<EOF
\$TTL    604800
@       IN     SOA     ${WZ}. admin (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
        IN     NS     master
master  IN     A       ${HOST}
www     IN     A       ${IPADDR}
EOF
        rndc reload
        color "DNS配置完成" 0
    # network:
    #   ethernets:
    #     ens32:
    #       addresses:
    #       - 10.0.0.101/8
    #       gateway4: 10.0.0.2
    #       nameservers:
    #         addresses:
    #         - 10.0.0.101
    #         search: [wang.org]
    #   version: 2
    fi

}

Install_DNS