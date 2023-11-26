#!/bin/sh

# This script mounts a USB thumb drive and copies important files and directories

# Hidden site configuration 
# This is a list of hidden sites that I'm currently hosting (one per line)
HIDDEN="/etc/hosting/hidden/hsites.conf"

# Backup configuration directory
CONFBKP=/etc/backupconf

# Backup configs (you may or may not have all these files)
set -A CONFIGS	\
	"installurl"		\
	"pf.conf"		\
	"httpd.conf"		\
	"php-8.2.ini"		\
	"php-fpm.conf"		\
	"rc.conf.local"		\
	"resolv.conf"		\
	"sysctl.conf"		\
	"mygate"		\
	"myname"		\
	"minute.local"		\
	"daily.local"		\
	"weekly.local"		\
	"monthly.local"		\
	"newsyslog.conf"	\
	"acme-client.conf"

# Create a folder for configuration backup
mkdir -p $CONFBKP/hkeys

# Copy to backupconf folder
for CONFIG in "${CONFIGS[@]}"; do 
	cp -r /etc/$CONFIG $CONFBKP$CONFIG
done

# Copy hidden site keys
for TOR in `cat  $HIDDEN`; do
	cp -r /var/tor/$TOR $CONFBKP/hkeys/$TOR
done

# Path to backup destination
ROOT=/mnt/pen

# Directories and mountpoints to backup
SOURCES="/etc/backupconf /etc/hosting /etc/mail /etc/tor /etc/ssl /etc/pftables /etc/scripts /var/www/sites /var/www/errdocs"

mkdir -p $ROOT
mount -t msdos /dev/sd1i $ROOT
#mount /dev/sd1i $ROOT

# check free space
USED=`df $ROOT|awk '/^\// { print substr($5, 0, length($5) - 1) }'`
if [ $USED -gt 75 ]; then
	echo "-------------------------------------------------------------------"
	echo "INSUFFICIENT DISK SPACE"
	echo "-------------------------------------------------------------------"
	df -h $ROOT
	umount $ROOT
    exit
fi

DATE="`date +%Y%m%d`"
TARGET="$ROOT/$DATE/"
mkdir -p "$TARGET"

for i in $SOURCES; do
    cp -r $i $TARGET
done
df -h $ROOT

umount $ROOT

