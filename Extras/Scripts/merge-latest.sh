#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

## This script is an attempt to automate picking up the latest version of the "develop" branch for a module, given that it might be on a detatch HEAD at the time.
##
## It performs the following steps:
##
## - rebase on the local develop branch
## - save this to a temporary branch
## - switch to the local develop branch
## - merge in the temporary branch - this should be a fast forward
## - remove the temporary branch
## - rebase on the remote "develop" from origin
## - push the resulting changed branch back to origin

check() {
    if [[ $1 != 0 ]]; then
      echo "failed: $2"
      exit $1
    fi
}

status=`git status --porcelain`

if [[ "$status" != "" ]]; then
    echo "You have local changes. Commit them first."
    exit 1
fi

# we may start on something that isn't the develop branch
# possibly a detached HEAD

# try to apply any changes on top of our local develop

git rebase develop
check $? "rebasing on develop"

# now fast forward develop to the merged place

git checkout -b develop-temp
check $? "making temp branch"

git checkout develop
check $? "switching back to develop"

git merge develop-temp
check $? "merging local changes"

git branch -d develop-temp
check $? "removing temp branch"

# we should now be on a local develop branch incorporating any local changes
echo fetching latest revisions
git fetch

# try to rebase again on top of any remote changes

git rebase
check $? "rebasing on origin/develop"

# if that worked, push back the merged version

git push
check $? "pushing"


