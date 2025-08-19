#!/bin/bash

. /etc/os-release

RED="\E[1;31m"
GREEN="echo -e \E[1;32m"
END="\E[0m"

check_sys () {

    ${GREEN}----------------------- sysinfo begin --------------------------------${END}
    echo -e  "HOSTNAME:      ${RED}`hostname`${END}"
    echo -e  "IPADDR:        ${RED}` hostname -I`${END}"
    echo -e  "OSVERSION:     ${RED}${PRETTY_NAME}${END}"
    echo -e  "KERNEL:        ${RED}`uname -r`${END}"
    echo -e  "CPU:          ${RED}`lscpu|grep '^Model name'|tr -s ' '|cut -d : -f2`${END}"
    echo -e  "MEMORY:        ${RED}`free -h|grep Mem|tr -s ' ' : |cut -d : -f2`${END}"
    echo -e  "DISK:          ${RED}`lsblk |grep -E "^(sd|nvme0n1)" |tr -s ' ' |cut -d " " -f4`${END}"
    ${GREEN}----------------------- sysinfo end ----------------------------------${END}

}

check_sys