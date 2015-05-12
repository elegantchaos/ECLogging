#!/usr/bin/env bash

clang-format -style=file -i Source/Generic/*.h
clang-format -style=file -i Source/Generic/*.m

for FOLDER in "Source/"*
do
	echo "Formatting $FOLDER"
	clang-format -style=file -i "$FOLDER"/*.h 2> /dev/null
	clang-format -style=file -i "$FOLDER"/*.m 2> /dev/null
done	