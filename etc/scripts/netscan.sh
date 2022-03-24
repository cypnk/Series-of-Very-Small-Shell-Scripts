#!/bin/sh

# Nmap slow scan helper
# Results dumped to a timestamped file in the given directory or /netscans in the user's home directory
# The scan type is between 1-6 with varying levels of detail

# Timestamp
DATE=`date +%Y-%m-%d-%H-%M-%S`

# Current user's home
HOME=$( getent passwd "$USER" | cut -d: -f6 )

# Test IP or domain, defaults to generic LAN subnet
SRC=${1:-"192.168.1.0/24"}

# Destination or default to HOME/netscans
DEST=${2:-"$HOME/netscans"}

# Testing level 1-6, defaults to 1
TEST=${3:-1};

# Check test for number
[[ $TEST =~ ^[[:digit:]]+$ ]] || exit 1

# Make destination directory if it doesn't exist
if [ ! -d $DEST ]; then
	mkdir -p $DEST
fi

# Init
case $TEST in
	1) nmap -sS -v $SRC > "$DEST/scanresult-$DATE.txt";;
	2) nmap -sn -v $SRC > "$DEST/scanresult-$DATE.txt";;
	3) nmap -sU -v $SRC > "$DEST/scanresult-$DATE.txt";;
	4) nmap -T2 -v $SRC > "$DEST/scanresult-$DATE.txt";;
	5) nmap -sO -v $SRC > "$DEST/scanresult-$DATE.txt";;
	*) nmap -A -v $SRC > "$DEST/scanresult-$DATE.txt";;
esac

# Usage OpenBSD:
# doas ksh netscan.sh 192.168.1.1
# doas ksh netscan.sh 192.168.1.1 /home/user/Downloads/
# doas ksh netscan.sh 192.168.1.1 /home/user/Downloads/ 2

# Usage Linux:
# sudo sh netscan.sh 192.168.1.1
# sudo sh netscan.sh 192.168.1.1 /home/user/Downloads/
# sudo sh netscan.sh 192.168.1.1 /home/user/Downloads/ 2

