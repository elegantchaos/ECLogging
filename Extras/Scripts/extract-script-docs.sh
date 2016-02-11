#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

## Extract any comments prefixed with two hashes (like this one) in a file, and write them out to
## a -template.md for inclusion in an appledoc documentation bundle.

output=$1
mkdir -p "$output"
echo "Output directory: $output"

shift
prefix=$1
echo "Prefix file: $prefix"

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

	index=`echo "$index"; echo "## $base:"; echo "${comments//##/}"; echo ""; echo ""; awk '{print "    "$0}' $file; echo ""`
done

echo "$index" > "$output/Scripts-template.markdown"