#!/usr/bin/env bash

## Runs the merge-latest.sh script for each submodule in the current project.
##
## Used internally.

base=`dirname $0`
pushd "$base" > /dev/null
full="$PWD"
popd > /dev/null

git submodule foreach "\"$full\"/merge-latest.sh"
