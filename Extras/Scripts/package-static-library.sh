#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

# Work out where we're building to. This can be different if we're archiving.
DST="${PROJECT_TEMP_ROOT}/UninstalledProducts/${PLATFORM_NAME}"
if [[ ! -e "$DST" ]]
then
    DST="${PROJECT_TEMP_ROOT}/UninstalledProducts"
fi

if [[ ! -e "$DST" ]]
then
    DST="${BUILT_PRODUCTS_DIR}"
fi



# Copy module map into the right place if it's not already there
MAPSRC="${MODULEMAP_FILE}"
MAPDST="${DST}/${PUBLIC_HEADERS_FOLDER_PATH}/module.modulemap"
MAP=$(cat "${MAPSRC}")

if [[ -e "${MAPDST}" ]]
then
    CURRENT=$(cat "${MAPDST}")
else
    echo "Couldn't find existing module map in built products."
    CURRENT=""
fi

if [[ "$MAP" != "$CURRENT" ]]
then
    echo "Copying module map into built products."
    cp -p "${MAPSRC}" "${MAPDST}"
fi
