#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2017 Elegant Chaos Limited. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

for FOLDER in "Source/"* "Tests"
do
	echo "Formatting $FOLDER"
	clang-format -style=file -i "$FOLDER"/*.h 2> /dev/null
	clang-format -style=file -i "$FOLDER"/*.m 2> /dev/null
done	
