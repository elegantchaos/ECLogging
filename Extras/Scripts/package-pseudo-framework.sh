#!/usr/bin/env bash

## This script is used in iOS targets that are packaged up as "pseudo" frameworks.
##
## The script is called from a Run Script phase, like this:
##
## "${ECLOGGING_SCRIPTS_PATH}/package-pseudo-framework.sh"
##
## It performs various linking and copying operations to lay out the framework bundle correctly.

FRAMEWORK_ROOT="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}"

mkdir -p "${FRAMEWORK_ROOT}/Versions"
/bin/ln -sfh A "${FRAMEWORK_ROOT}/Versions/Current"
/bin/ln -sfh Versions/Current/Headers "${FRAMEWORK_ROOT}/Headers"
/bin/ln -sfh Versions/Current/Resources "${FRAMEWORK_ROOT}/Resources"
/bin/ln -sfh "Versions/Current/${PRODUCT_NAME}" "${FRAMEWORK_ROOT}/${PRODUCT_NAME}"
