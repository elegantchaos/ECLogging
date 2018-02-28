#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

## Runs the merge-latest.sh script for each submodule in the current project.
##
## Used internally.

base=`dirname $0`
pushd "$base" > /dev/null
full="$PWD"
popd > /dev/null

git submodule foreach "git checkout develop; git pull --ff-only"
