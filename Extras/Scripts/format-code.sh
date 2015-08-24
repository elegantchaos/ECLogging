#!/usr/bin/env bash

for FOLDER in "Source/"* "Tests"
do
	echo "Formatting $FOLDER"
	clang-format -style=file -i "$FOLDER"/*.h 2> /dev/null
	clang-format -style=file -i "$FOLDER"/*.m 2> /dev/null
done	