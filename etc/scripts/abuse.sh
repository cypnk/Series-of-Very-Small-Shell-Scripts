#!/bin/sh

# This is an OpenBSD compatible shell script using the ftp utility 
# to download the latest abuse lists IP ranges and create a
# pf compatible IP list

# Abuse drop table
PFDROP=/etc/pftables/abuse

# Make sure drop table exits
touch $PFDROP

# Lists
set -A BLOCKLISTS \
	"https://lists.blocklist.de/lists/all.txt" \
	"https://raw.githubusercontent.com/ejrv/VPNs/master/vpn-ipv4.txt" \
	"https://raw.githubusercontent.com/ejrv/VPNs/master/vpn-ipv6.txt"


# Create tempfiles
TMP1=`mktemp -t dropraw.XXXXXXXXXX` || exit 1
TMP2=`mktemp -t dropcom.XXXXXXXXXX` || exit 1

# Download and process each blocklist
for URL in "${BLOCKLISTS[@]}"; do 
	
	# Blocklist header
	echo -e "\n\n# Blocklist: $URL\n" >>$TMP2
	
	# Fetch the drop list and store in temp file
	ftp -r 3 -w 10 -M -V -S do -o $TMP1 $URL || rm $TMP1
	
	# If you're on Linux, comment the above line and uncomment this line
	# wget -q -O $TMP1 $URL || rm $TMP1
	
	# Clean up the list into pf digestible format (and remove comments)
	#cut -d ';' -f 1 $TMP1 | cut -d '/' -f 1 | cut -d '#' -f 1 | sed -e '/^$/d' >>$TMP2
	if [ -f $TMP1 ]; then
		if grep -i "500\|504\|Sorry\|service\|default\|error" $TMP1; then
			rm $TMP1
			TMP1=`mktemp -t dropraw.XXXXXXXXXX` || exit 1
			echo -e "# Error downloading: $URL\n" >>$TMP2
			continue
		fi
		cut -d ';' -f 1 $TMP1 | cut -d '#' -f 1 | grep -v '// ' |  sed -e '/^$/d' >>$TMP2
	else
		echo -e "# Error downloading: $URL\n" >>$TMP2
		TMP1=`mktemp -t dropraw.XXXXXXXXXX` || exit 1
	fi
done

# Comment header (starts by overwriting)
echo "# Combined blocklist " >$PFDROP
echo "# Generated for `hostname` on `date`" >>$PFDROP


# Remove any duplicates (preserving whitespaces)
awk '!a[$0]++' $TMP2 > $TMP1

# Append compiled list
cat $TMP1 >>$PFDROP

# Clean up temp files
rm -f $TMP1
rm -f $TMP2

#echo "Generated abuse blocklist on `date`"


# To use this, first make sure the following 3 lines are in your pf.conf :

# table <abuse> persist file "/etc/blocklists/abuse"
# block in quick on egress from <abuse> to any
# block return out quick on egress from any to <abuse>


exit
