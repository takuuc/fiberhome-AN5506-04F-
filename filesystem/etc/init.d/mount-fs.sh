#!/bin/sh

case "$1" in
	start)
		echo "Mounting filesystems..."
		/bin/mount -a
		source /etc/init.d/makeDevs
		mknod /var/fuse c 10 229
		chmod a+rw /var/fuse
		mkdir -p /var/log /var/run /var/state/dhcp /var/ppp /var/udhcpd /var/zebra /var/siproxd /var/cache /var/tmp /var/samba /var/samba/share /var/samba/homes /var/samba/private /var/samba/locks /var/fyi/sys
		cp  /etc/smb.conf /var/samba/ 2>/dev/null
		touch /var/fyi/sys/dns
		echo "root:W/xa5OyC3jjQU:0:0:root:/:bin/sh" > /etc/passwd
		echo "nobody:x:99:99:Nobody:/:/bin/false" >> /etc/passwd
		exit 0
		;;

	stop)
		sync
		echo "Unmounting filesystems..."
		/bin/umount -a
		exit 0
		;;

	*)
		echo "$0: unrecognized option $1"
		;;

esac

