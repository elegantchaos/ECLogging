#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

MAP=$(cat "${MODULEMAP_FILE}")

if [[ -e "${BUILT_PRODUCTS_DIR}/${PUBLIC_HEADERS_FOLDER_PATH}/../module.modulemap" ]]
then
    CURRENT=$(cat "${BUILT_PRODUCTS_DIR}/${PUBLIC_HEADERS_FOLDER_PATH}/../module.modulemap")
else
    CURRENT=""
fi

if [[ "$MAP" != "$CURRENT" ]]
then
    cp -p "${MODULEMAP_FILE}" "${BUILT_PRODUCTS_DIR}/${PUBLIC_HEADERS_FOLDER_PATH}/../module.modulemap"
fi