#!/usr/bin/env bash

## Extract any comments prefixed with "##" (like this one) in a file, and write them out to
## a -template.md for inclusion in an appledoc documentation bundle.

output=$1
mkdir -p "$output"

shift
prefix=$1

index=`cat "$prefix"`

while :; do
	shift
	file=$1
	if [[ "$file" == "" ]]; then
		break
	fi
	
 
	comments=`grep "^##" "$file"`

	base=`basename "$file"`
	name=${base%.*}

	echo "${comments//##/}" > "$output/$base-template.markdown"
	echo "" >> "$output/$base-template.markdown"
	echo "### $base:" >> "$output/$base-template.markdown"
	awk '{print "    "$0}' $file >> "$output/$base-template.markdown"
	index=`echo "$index"; echo "- [$base]($base.html)"`
done

echo "$index" > "$output/Scripts-template.markdown"