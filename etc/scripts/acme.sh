#!/bin/sh

# Update the Let's Encrypt certificates with acme-client

# Configuration file
CONF="/etc/hosting/acme-domains.conf"

# Temp file for domains
TMP=`mktemp -t domains.XXXXXXXXXX` || exit 1

# Extract domain name from conf file
sed -n '/^domain/p' $CONF | cut -d ' ' -f 2 > $TMP

# Get certs for each domain
for DOMAIN in `cat $TMP`; do 
	# Force update
	#acme-client -vFAD $DOMAIN
	
	# Update if needed
	acme-client $DOMAIN
done

# Reload config
rcctl reload httpd

# Cleanup
rm $TMP

exit 0
