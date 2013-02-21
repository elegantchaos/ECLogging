#!/usr/bin/env bash

## Pushes all branches of all submodules in the current project to a remote called "backup".
##
## Used internally.

git submodule foreach 'git push backup --all'
