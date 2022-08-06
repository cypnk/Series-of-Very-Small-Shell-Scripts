#!/bin/sh

# Hosting configuration generator
# This script uses templates stored in /etc/hosting/templates to create:
# - An initial web hosting configuration
# - A post TLS certificate generated hosting configuration
# - A mail domain for email hosting
# - Email hosting and forwarding
# - DNS settings for DKIM and the private/public keys

# Primary domain list (one domain per line)
DOMAINS="/etc/hosting/domains.conf"

# Configuration files

# Let's Encrypt hosting configuration (generated)
CONF="/etc/hosting/acme-domains.conf"

# Mail hosting settings (generated)
MAIL="/etc/hosting/mail-domains.conf"
MPKI="/etc/hosting/mail-pki.conf"

# Generated configs per domain for for httpd(8)
DGEN="/etc/hosting/generated/"
# Use the include directive to add these to httpd.conf as needed

# Mail default virtual user
VUSR="/etc/mail/vusers"

# Mail HELO and other delivery settings
MHEL="/etc/mail/helosrc"

# DKIM generated keys
DKIM="/etc/mail/dkim/"

# DKIM info for DNS hosting purposes
DPUB="/etc/mail/dkim/dns.txt"

# Domain templates 
# STPL = domain hosting, DTPL = Let's Encrypt mail domain config
STPL="/etc/hosting/templates/domain.tpl"
DTPL="/etc/hosting/templates/mdomain.tpl"

# Mail domain hosting template for httpd
MTPL="/etc/hosting/templates/mail.tpl"

# Mail PKI cert setting template for smtpd
PTPL="/etc/hosting/templates/mail-pki.tpl"

# SMTP mail delivery and sorting template
HELO="/etc/hosting/templates/smtpd.tpl"

# Initial hosting configuration (before TLS cert)
ITPL="/etc/hosting/templates/hosting-init.tpl"

# Post TLS cert hosting template
HTPL="/etc/hosting/templates/hosting.tpl"

# Generated 

typeset -Z6 IDX
IDX=0

# Temp file for domains
TMP1=`mktemp -t domains.XXXXXXXXXX` || exit 1
TMP2=`mktemp -t domains.XXXXXXXXXX` || exit 1
TMP3=`mktemp -t domains.XXXXXXXXXX` || exit 1
TMP4=`mktemp -t domains.XXXXXXXXXX` || exit 1
TMP5=`mktemp -t domains.XXXXXXXXXX` || exit 1
TMP6=`mktemp -t domains.XXXXXXXXXX` || exit 1

# Skip patterns (these subdomains don't need email addresses of their own)
SKIP='^(mail|live|api|portal|static|boards|cam|shop|gallery)\.*'

# Create DKIM stuff, if they don't exist
mkdir -p $DKIM
touch $DPUB

# Fresh
echo "" > $DPUB

# Generate domain config block from template
for DOMAIN in `cat $DOMAINS`; do 		
	sed -e s/example/$DOMAIN/g $HTPL > $DGEN$DOMAIN.conf
	sed -e s/example/$DOMAIN/g $ITPL > $DGEN$DOMAIN-initial.conf
	
	# Hosting web root and log locations
	DOMWEB="/var/www/sites/$DOMAIN"
	DOMLOG="/var/www/logs/sites/$DOMAIN"
	
	# Create log directory
	mkdir -p $DOMLOG
	
	# Create access and error logs
	touch $DOMLOG/access.log
	touch $DOMLOG/error.log
	
	# Set ownership and permissions on these logs
	chown -R www $DOMLOG/access.log
	chmod -R 755 $DOMLOG/access.log
	
	chown -R www $DOMLOG/error.log
	chmod -R 755 $DOMLOG/error.log
	
	# Create domain hosting template for use with httpd
	sed -e s/example/$DOMAIN/g $STPL >> $TMP1
	
	# Setup the main web hosting root 
	mkdir -p "$DOMWEB/htdocs"
	
	if [ ! -f "$DOMWEB/htdocs/index.html" ]; then
		# Create the default index
		touch $DOMWEB/htdocs/index.html
		echo "$DOMAIN" >> $DOMWEB/htdocs/index.html
	fi
	
	# Mail stuff
	
	# Check if these don't need mail or static directories
	TEST=$(echo $DOMAIN | egrep -o $SKIP)
	
	# Don't need static and mail subdomains on these?
	if [[ $TEST != '' ]]; then
		 continue
	else
		# Setup the static. and mail. subdomain directories
		mkdir -p "$DOMWEB/static"
		mkdir -p "$DOMWEB/mail"
		
		# Create the static default index
		touch $DOMWEB/static/index.html
		
		# Create default users if users doesn't exist yet
		if [ ! -f "$DOMWEB/mail/users" ]; then
			# Users table file used by smtpd
			touch $DOMWEB/mail/users
			
			# Default users (postmaster is required)
			echo "admin@$DOMAIN		admin" >> $DOMWEB/mail/users
			echo "postmaster@$DOMAIN	admin" >> $DOMWEB/mail/users
			echo "robot@$DOMAIN		admin" >> $DOMWEB/mail/users
		fi
		
		# Set permissions appropriate for the static folder
		chown -R www $DOMWEB/static
		chmod -R 744 $DOMWEB/static
	fi
	
	
	# Generate DKIM private keys (if they don't exist)
	if [ ! -f "$DKIM$DOMAIN.key" ]; then
		/usr/bin/openssl genrsa -out $DKIM$DOMAIN.key 1024 2>/dev/null
	fi
	
	# Get public key from private key
	/usr/bin/openssl rsa -in $DKIM$DOMAIN.key -pubout -out $DKIM$DOMAIN.pub 2>/dev/null
	
	# Format DKIM public keys into TXT string
	DKDATA="$(cat $DKIM$DOMAIN.pub | sed -e '/-----/d' | grep -vx '\s*\$\s*' | tr -d '\n');"
	echo "dkim._domainkey.$DOMAIN v=DKIM1;k=rsa;p=$DKDATA" >> $DPUB
	echo "_dmarc.$DOMAIN v=DMARC1;p=none;pct=100;rua:mailto:postmaster@$DOMAIN;" >> $DPUB
	echo "" >> $DPUB
	echo "" >> $DPUB
	
	# Generate email delivery template
	sed -e s/example/$DOMAIN/g $MTPL >> $TMP2
	sed -e s/example/$DOMAIN/g $PTPL >> $TMP3
	
	# Action indexes (replace "actionindex" with "act000001" etc...)
	sed -e s/example/$DOMAIN/g $HELO >> $TMP4
	sed -i "s/actionindex/act$IDX/g" $TMP4
	
	# Default catch-all user is admin
	# Remove this if you don't want a catch-all email
	echo "@$DOMAIN	admin" >> $TMP5
	
	# Create the mail subdomain for Let's Encrypt
	sed -e s/example/$DOMAIN/g $DTPL >> $TMP6
		
	# Increment index
	IDX=$((IDX+1))
done

# Get rid of www. lines for mail/portal/api/static etc..., if any
sed -i '/www.mail./d' $TMP1
sed -i '/www.portal./d' $TMP1
sed -i '/www.api./d' $TMP1
sed -i '/www.static./d' $TMP1
sed -i '/www.boards./d' $TMP1
sed -i '/www.live./d' $TMP1
sed -i '/www.shop./d' $TMP1
sed -i '/www.cam./d' $TMP1
sed -i '/www.gallery./d' $TMP1

# Overwrite domains
cat $TMP6 >> $TMP1
mv $TMP1 $CONF
mv $TMP2 $MAIL
mv $TMP3 $MPKI
mv $TMP4 $MHEL
mv $TMP5 $VUSR

rm $TMP6

exit 0
