#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

MAPSRC="${MODULEMAP_FILE}"
MAPDST="${BUILT_PRODUCTS_DIR}/${PUBLIC_HEADERS_FOLDER_PATH}/../module.modulemap"

MAP=$(cat "${MAPSRC}")

if [[ -e "${MAPDST}" ]]
then
    CURRENT=$(cat "${MAPDST}")
else
    CURRENT=""
fi

if [[ "$MAP" != "$CURRENT" ]]
then
    cp -p "${MAPSRC}" "${MAPDST}"
fi