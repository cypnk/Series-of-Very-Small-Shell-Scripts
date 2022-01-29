#!/bin/sh

# Web access and error log rotator

# Current date
DT=`date '+%Y-%m'`

# Primary domain list
DOMAINS="/etc/hosting/domains.conf"

# Archives
SYSLOGS="/var/log/archive-${DT}"
WEBLOGS="/var/www/logs/archive-${DT}"

# Rotate access and error logs
for DOMAIN in `cat $DOMAINS`; do
	# Copy over and refresh
	cp "/var/www/logs/sites/${DOMAIN}/access.log" "/var/www/logs/sites/${DOMAIN}/access-${DT}.log"
	echo "" > "/var/www/logs/sites/$DOMAIN/access.log"
	
	cp "/var/www/logs/sites/${DOMAIN}/error.log" "/var/www/logs/sites/${DOMAIN}/error-${DT}.log"
	echo "" > "/var/www/logs/sites/$DOMAIN/error.log"
done

mkdir -p "${SYSLOGS}"
mkdir -p "${WEBLOGS}"

mv /var/log/*.gz "${SYSLOGS}/"

mv /var/www/logs/access-* "${WEBLOGS}/"
mv /var/www/logs/error-* "${WEBLOGS}/"
mv /var/www/logs/*.gz "${WEBLOGS}/"

exit 0
