#!/bin/bash
# written by Tomasz Klim, 2015-10-11
# main algorithm inspired by http://serverfault.com/a/673368/293005


extract_date() {
	tail -n 1 $1 |awk "{ print \$1 \" \" \$2 }"
}

if [ "$1" = "" ]; then
	echo "usage: $0 <directory>"
	exit 1
fi

cd $1
gzip -d *.gz
mkdir _delete_after_verification

for LOG in syslog *.log; do
	(
		for i in {100..1}; do
			PART=$LOG.${i}
			[ -f $PART ] && cat $PART && mv $PART _delete_after_verification
		done
	) > $LOG.prev

	if [ -s $LOG.prev ]; then
		dt=`extract_date $LOG.prev`
		ext=`date -d "$dt" +%Y%m%d`
		mv $LOG.prev $LOG.$ext
		gzip -9 $LOG.$ext
	else
		rm -f $LOG.prev
	fi
done
