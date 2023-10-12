#!/bin/sh
eval $(dbus export ddnsgo_)
source /koolshare/scripts/base.sh

if [ "$lookcat_enable" == "1" ];then
	echo_date "先关闭LookCat插件！"
	sh /koolshare/scripts/lookcat_config.sh stop
fi

find /koolshare/init.d/ -name "*lookcat*" | xargs rm -rf
rm -rf /koolshare/res/icon-lookcat.png 2>/dev/null
rm -rf /koolshare/scripts/lookcat*.sh 2>/dev/null
rm -rf /koolshare/webs/Module_lookcat.asp 2>/dev/null
rm -rf /koolshare/scripts/lookcat_install.sh 2>/dev/null
rm -rf /koolshare/scripts/uninstall_lookcat.sh 2>/dev/null
rm -rf /tmp/upload/lookcat* 2>/dev/null

dbus remove lookcat_addr
dbus remove lookcat_enable
dbus remove lookcat_sleep
dbus remove lookcat_start
dbus remove softcenter_module_lookcat_name
dbus remove softcenter_module_lookcat_install
dbus remove softcenter_module_lookcat_version
dbus remove softcenter_module_lookcat_title
dbus remove softcenter_module_lookcat_description