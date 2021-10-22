#!/bin/sh

# This helper converts .webp images into another image format
# (.png, .jpg etc...)
# 
# This assumes you already have libwebp installed
# The converted files are stored in the same folder unless another is given
# 
# Usage: 
#	sh webpc.sh /path/to/files
# 
# Or a different extension: 
#	sh webpc.sh /path/to/files jpg
# 
# Different destination (creates the folder if it doesn't exist): 
#	sh webpc.sh /path/to/files png /destination/path

# Source folder of all your .webp images
SRC="$1"

if [ ! -d "$SRC" ]; then
	echo "Source directory needed"
	exit 1
fi

# Preferred output extension (defaults to png)
EXT="${2:-png}"

# Remove extra dots and convert to lowercase
EXT=$(echo ".${EXT//.}" | tr '[:upper:]' '[:lower:]')

# Destination (defaults to source)
DST=$(realpath ${3:-$SRC})
DST="${DST%/}/"

# All webp
FLD="${SRC%/}/*.webp"

mkdir -p $DST

for FILE in $FLD; do
	if [ -f "$FILE" ]; then
		# Swap out source for destination and add extension
		OUT=${FILE#$SRC}
		OUT="$DST${OUT%.webp}$EXT"
		
		# Avoid overwriting
		if [ -f "$OUT" ]; then
			echo "File $OUT already exists. Skipping."
		else
			dwebp "$FILE" -o "$OUT"
		fi
	fi
done

echo "Conversion complete"
exit 0


