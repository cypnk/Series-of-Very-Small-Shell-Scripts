#!/bin/sh

# Bulk download helper. Reads URLS in a text file, one per line, and 
# downloads them one by one to an optional given directory.
# Note: Destination folder will be created if it doesn't exist

# URL source file
SRC="$@"

if [ ! -f $SRC ]; then
	echo "No source file found"
	exit 1
fi

# Preferred output folder, defaults to source folder
DST=$(realpath ${2:-"$(dirname SRC)"})

if [ ! -d "$DST" ]; then
	mkdir -p $DST
fi

for URL in `cat $SRC`; do
	SAVE=$DST/$(basename $URL)
	
	if [ -f $SAVE ]; then
		echo "File $SAVE exists. Skipping..."
	else
		# On OpenBSD
		ftp -r 3 -w 10 -M -V -S do -o $SAVE $URL
		
		# Use this on Linux
		#wget --tries=3 --timeout=10 --waitretry=1 -q -O $SAVE $URL
	fi
	
done

exit 0

# Usage syntax:
# sh download.sh /path/to/urls.txt /path/to/destination

