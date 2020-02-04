#!/bin/sh

# Distribute mail from collective recipient to mail domain users
MDIR=/home/admin/Maildir/

# Receive log
MLOG=/etc/mail/maildelivery.log

# Primary domain list
DOMAINS="/etc/hosting/domains.conf"

# Avoid these subdomains for mail
SKIP='^(mail|live|api|portal|static|boards|cam|shop|gallery)\.*'

touch $MLOG

# Check mail
for DOMAIN in `cat $DOMAINS`; do 		
	# Check if these don't need mail or static directories
	TEST=$(echo $DOMAIN | egrep -o $SKIP)
	
	if [[ $TEST != '' ]]; then
		 continue
	fi
	
	# Search mail delivery domains
	RC=$MDIR$DOMAIN/
	MD=/var/www/sites/$DOMAIN/mail	
	mkdir -p "$MD"
	
	# Skip if no mail dir
	if [[ ! -d "$RC" ]]; then
		continue
	fi
	
	# Iterate and parse maildir
	for MAIL in $(find $RC -type d -name "new" ); do	
		if [[ $MAIL == *".Junk"* ]]; then
			# Destination junk
			mkdir -p "$MD/junk"
			
			# User junk dir
			DR="${MAIL%/*/*}"
			US=`basename $DR`
			
			# Junkmail and count
			ML="$DR/.Junk/new/*.local"
			FL=`ls -l $ML 2>/dev/null | wc -l` || continue
			
			if [ $FL != 0 ]; then
				mv $ML "${MD}/junk/"
				echo "`date` - $FL junkmail for $US@$DOMAIN" >> $MLOG
			fi
		else
			# Destination new mail
			mkdir -p "$MD/new"
			
			# User mail dir
			DR="${MAIL%/*}"
			US=`basename $DR`
			
			# Mail and count
			ML="$DR/new/*.local"
			FL=`ls -l $ML 2>/dev/null | wc -l`
			
			# Update log
			if [ $FL != 0  ]; then
				mv $ML "${MD}/new/"
				echo "`date` - $FL mail for $US@$DOMAIN" >> $MLOG
			fi
		fi
	done
done


exit 0
