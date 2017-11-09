#!/bin/sh
. /etc/farmconfig
. /opt/farm/scripts/functions.custom

backup="`local_backup_directory`/custom/farm-strip-backup.tgz"
if [ ! -f $backup ]; then
	tar czf $backup /opt/farm 2>/dev/null
fi

rm -f /opt/farm/* 2>/dev/null
rm -f /opt/farm/.* 2>/dev/null
rm -rf /opt/farm/.git \
	/opt/farm/scripts/config \
	/opt/farm/scripts/setup
rm -f /opt/farm/scripts/init \
	/opt/farm/scripts/functions.dialog \
	/opt/farm/scripts/functions.install \
	/opt/farm/scripts/functions.uid \
	/opt/farm/ext/.gitignore

sed -i -e "s/^#.*//" /opt/farm/scripts/functions.custom

for EXT in `ls -1 /opt/farm/ext/`; do
	EP=/opt/farm/ext/$EXT
	rm -rf $EP/.git
	rm -f $EP/LICENSE $EP/README.md $EP/setup.sh $EP/uninstall.sh

	if [ "$EXT" = "ip-fw" ]; then
		rm -rf $EP/config $EP/service
	elif [ "$EXT" = "firewall" ]; then
		rm -rf $EP/generator
	elif [ "$EXT" = "backup" ]; then
		rm -f $EP/cron/push-to-collector.sh
	elif [ ! -d $EP/cron ] && [ "$EXT" != "ip-allocs" ]; then
		rm -rf $EP
	fi
done

if [ -f /etc/ec2_version ] && [ -f /etc/cloud/build.info ]; then
	for SUB in `ls /opt/farm/ext/firewall/hosts/ |grep -v $HOST`; do
		rm -rf /opt/farm/ext/firewall/hosts/$SUB
	done

	if [ -d /opt/farm/ext/firewall/links ]; then
		find -L /opt/farm/ext/firewall/links -maxdepth 1 -type l -delete
	fi
fi
