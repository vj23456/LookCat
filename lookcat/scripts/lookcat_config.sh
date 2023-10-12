#!/bin/sh

source /koolshare/scripts/base.sh
eval $(dbus export lookcat_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/lookcat_log.txt
LOCK_FILE=/var/lock/lookcat.lock
BASH=${0##*/}
ARGS=$@

catip="${lookcat_addr}"
wanip="${catip%.*}.111"
net="${catip%.*}.0/24"
wan0="`nvram get wan0_ifname`"

set_lock(){
	exec 999>${LOCK_FILE}
	flock -n 999 || {
		# bring back to original log
		http_response "$ACTION"
		exit 1
	}
}

unset_lock(){
	flock -u 999
	rm -rf ${LOCK_FILE}
}



close_lc_process(){
	ifconfig ${wan0}:0 down
	echo_date "🔺关闭网卡" | tee -a ${LOG_FILE}
	iptables -t nat -D POSTROUTING -o $wan0 -d $net -j MASQUERADE
	echo_date "🔺关闭防火墙端口！" | tee -a ${LOG_FILE}
	rm -rf /koolshare/init.d/S99lookcat.sh
	rm -rf /koolshare/init.d/N99lookcat.sh
}

start_lc_process(){
    ifconfig ${wan0}:0 $wanip netmask 255.255.255.0
    echo_date "🟢设置wan口IP为： $wanip ,子网掩码为： 255.255.255.0" | tee -a ${LOG_FILE}
    iptables -t nat -I POSTROUTING -o $wan0 -d $net -j MASQUERADE
    echo_date "🟢开启防火墙端口！" | tee -a ${LOG_FILE}
    if [ "${lookcat_start}" == "1" ]; then
    	[ ! -L "/koolshare/init.d/S99lookcat.sh" ] && ln -sf /koolshare/scripts/lookcat_config.sh /koolshare/init.d/S99lookcat.sh
	    [ ! -L "/koolshare/init.d/N99lookcat.sh" ] && ln -sf /koolshare/scripts/lookcat_config.sh /koolshare/init.d/N99lookcat.sh
	    echo_date "🟢设置开机启动！" | tee -a ${LOG_FILE}
	fi
}

close_lc(){
	close_lc_process
	echo_date "⛔️LookCat已经成功关闭！" | tee -a ${LOG_FILE}
}

start_lc (){
	start_lc_process
	echo_date "🟢LookCat已成功启动！" | tee -a ${LOG_FILE}
}

case $1 in
start)
	if [ "${lookcat_enable}" == "1" ]; then
		sleep ${lookcat_sleep}
		logger "[软件中心-开机自启]: 已经延迟${lookcat_sleep} 秒，LookCat开始启动！"
		start_lc
	else
		logger "[软件中心-开机自启]: LookCat未开启，不自动启动！"
	fi
	;;
start_nat)
	if [ "${lookcat_enable}" == "1" ]; then
	    logger "[软件中心]-[${0##*/}]: NAT重启触发重新设置Lookcat！"
		start_lc
	
	fi
	;;
stop)
	close_lc
	;;
esac

case $2 in
web_submit)
	set_lock
	true > ${LOG_FILE}
	http_response "$1"
	if [ "${lookcat_enable}" == "1" ]; then
		echo_date "▶️开启LookCat！" | tee -a ${LOG_FILE}
		start_lc
	else
		echo_date "ℹ️停止LookCat！" | tee -a ${LOG_FILE}
		close_lc
	fi
	echo LC01N05S | tee -a ${LOG_FILE}
	unset_lock
	;;

esac