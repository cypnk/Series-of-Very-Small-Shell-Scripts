#!/bin/sh

# Web access and error log rotator

# Current date
DT=`date '+%Y-%m'`

# Primary domain list
DOMAINS="/etc/hosting/domains.conf"

# Rotate access and error logs
for DOMAIN in `cat $DOMAINS`; do
	# Copy over and refresh
	cp "/var/www/logs/sites/${DOMAIN}/access.log" "/var/www/logs/sites/${DOMAIN}/access-${DT}.log"
	echo "" > "/var/www/logs/sites/$DOMAIN/access.log"
	
	cp "/var/www/logs/sites/${DOMAIN}/error.log" "/var/www/logs/sites/${DOMAIN}/error-${DT}.log"
	echo "" > "/var/www/logs/sites/$DOMAIN/error.log"
done


exit 0
