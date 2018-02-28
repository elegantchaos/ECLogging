#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

## This script is used in iOS targets that are packaged up as "pseudo" frameworks.
##
## The script is called from a Run Script phase, like this:
##
## "${ECLOGGING_SCRIPTS_PATH}/package-pseudo-framework.sh"
##
## It performs various linking and copying operations to lay out the framework bundle correctly.

FRAMEWORK_ROOT="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}"

mkdir -p "${FRAMEWORK_ROOT}/Versions"
mkdir -p "${FRAMEWORK_ROOT}/Versions/A/Modules"

cp "${MODULEMAP_FILE}" "${FRAMEWORK_ROOT}/Versions/A/Modules/module.modulemap"

cd "$FRAMEWORK_ROOT"
/bin/ln -sfh A "${FRAMEWORK_ROOT}/Versions/Current"
/bin/ln -sfh Versions/Current/Headers "${FRAMEWORK_ROOT}/Headers"
/bin/ln -sfh Versions/Current/Resources "${FRAMEWORK_ROOT}/Resources"
/bin/ln -sfh Versions/Current/Modules "${FRAMEWORK_ROOT}/Modules"
/bin/ln -sfh "Versions/Current/${PRODUCT_NAME}" "${FRAMEWORK_ROOT}/${PRODUCT_NAME}"

