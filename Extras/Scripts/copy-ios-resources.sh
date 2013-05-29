#!/usr/bin/env bash

# Run this script as part of the application build, to copy the ECLogging resources into the application's resources folder


if [[ -e "${PROJECT_TEMP_ROOT}/UninstalledProducts/ECLogging.bundle" ]] ; then
    cp -Rf "${PROJECT_TEMP_ROOT}/UninstalledProducts/ECLogging.bundle" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/ECLogging.bundle"
else
    cp -Rf "${TARGET_BUILD_DIR}/ECLogging.bundle" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/ECLogging.bundle"
fi