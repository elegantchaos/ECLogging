#!/usr/bin/env python
# -*- coding: utf8 -*-

import subprocess
import shutil
import shell
import re
import errors
import os
import fnmatch

# tagBuildInGit() {
#     if [[ -e "test-build/dst/Applications" ]]
#     then
#         echo "Tagging build"
#         APPTOTAG="$1"
#         VARIANT="$2"
#         VERSION_NO=`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "test-build/dst/Applications/$APPTOTAG.app/Contents/Info.plist"`
#         BUILD_NO=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "test-build/dst/Applications/$APPTOTAG.app/Contents/Info.plist"`
#         git tag -a -f "builds/$VARIANT/$VERSION_NO/$BUILD_NO" -m "Automatic build of $APPTOTAG"
#         git push --force origin "builds/$VARIANT/$VERSION_NO/$BUILD_NO"
#     fi
# }
#


# copyAppToDrobox() {
#     DEBUG_PATH="$1"
#     APPTOCOPY="$2"
#     DROPBOXFOLDER="$3"
#     LONGNAME="$4"
#
#     if [[ -e "$DEBUG_PATH/$APPTOCOPY" ]]
#     then
#         echo "Copying $APPTOCOPY to upload folder"
#         BUILD_NO=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${DEBUG_PATH}/$APPTOCOPY/Contents/Info.plist"`
#         ZIP_NAME="$LONGNAME $BUILD_NO.zip"
#         APP_NAME="$LONGNAME $BUILD_NO.app"
#         LATEST_FOLDER="$DROPBOXFOLDER/Builds/Latest"
#         mkdir -p "${LATEST_FOLDER}"
#         rm -rf "${LATEST_FOLDER}/${ZIP_NAME}"
#         pushd "${DEBUG_PATH}"
#         mv "$APPTOCOPY" "$APP_NAME"
#         zip -q -r "$LATEST_FOLDER/$ZIP_NAME" "$APP_NAME"
#         popd
#     fi
# }
#
# copyToDropbox() {
#     DROPBOXFOLDER="$1"
#     DEBUGAPPNAME="$2"
#     LONGAPPNAME="$3"
#
#     if [[ -e "$DROPBOXFOLDER" ]]
#
#     then
#         copyAppToDrobox "test-build/sym/Debug" "$DEBUGAPPNAME" "$DROPBOXFOLDER" "$LONGAPPNAME Debug"
#         copyAppToDrobox "test-build/dst/Applications" "SketchApp.app" "$DROPBOXFOLDER" "$LONGAPPNAME"
#     fi
# }

def root_path():
    return os.path.join(os.getcwd(), 'build')

def log_paths(jobName):
    root = root_path()
    logs = ['output', 'errors', 'pretty']
    if jobName:
        prefix = jobName + '-'
    else:
        prefix = ''

    full = {}
    for log in logs:
        full[log] = os.path.join(root, 'logs', "{0}{1}.log".format(prefix, log))

    return full

def build_paths():
    root = root_path()
    paths = {
        'SYMROOT' : 'sym',
        'OBJROOT' : 'obj',
        'DSTROOT' : 'dst',
        'CACHE_ROOT' : 'cache',
        'SHARED_PRECOMPS_DIR' : 'precomp'
    }

    full = {}
    for key in paths:
        full[key] = os.path.join(root, paths[key])

    return full

def first_built_application():
    paths = build_paths()
    appFolder = os.path.join(paths['DSTROOT'], 'Applications')
    if os.path.exists(appFolder):
        for app in os.listdir(appFolder):
            (name,ext) = os.path.splitext(app)
            if ext == ".app":
                appPath = os.path.join(appFolder, app)
                return appPath

def zip_built_application():
    paths = build_paths()
    appFolder = os.path.join(paths['DSTROOT'], 'Applications')
    (result, output) = (errors.ERROR_FILE_NOT_FOUND, "Can't find built application.")
    if os.path.exists(appFolder):
        for app in os.listdir(appFolder):
            (name,ext) = os.path.splitext(app)
            if ext == ".app":
                appPath = os.path.join(appFolder, app)
                zipPath = os.path.join(appFolder, "{0}.zip".format(name))
                (result, output) = shell.zip(appPath, zipPath)
                if result == 0:
                    symPath = os.path.join(paths['SYMROOT'], 'Release', "{0}.app.dSYM".format(name))
                    symZipPath = os.path.join(appFolder, "{0}.dSYM.zip".format(name))
                    (result, output) = shell.zip(symPath, symZipPath)
                    if result == 0:
                        return (zipPath, symZipPath)

    if result != 0:
        shell.log_verbose(output)


def build_variant(variant, actions = ['archive']):
    configsPath = shell.script_relative('../../../Sketch/Configs')
    configPath = os.path.join(configsPath, "{0}.xcconfig".format(variant))
    extraArgs = [ '-xcconfig', configPath ]
    return build('Sketch.xcworkspace', 'Sketch', actions = actions, jobName = variant, extraArgs = extraArgs)

def build(workspace, scheme, platform = 'macosx', actions = ['build'], jobName = None, cleanAll = True, extraArgs = []):
    args = ['xctool', '-workspace', workspace, '-scheme', scheme, '-sdk', platform]

    if cleanAll:
        root = root_path()
        try:
            shutil.rmtree(root)
        except Exception as e:
            pass

    paths = build_paths()
    pathArgs = []
    for key in paths:
        pathArgs += ["{0}={1}".format(key, paths[key])]

    args += actions
    args += pathArgs

    logPaths = log_paths(jobName)
    args += ['-reporter', "pretty:{0}".format(logPaths['pretty'])]
    args += ['-reporter', "plain:{0}".format(logPaths['output'])]
    args += extraArgs

    (result, output) = shell.call_output_and_result(args)
    return (result, output)


if __name__ == "__main__":
    print build('Sketch.xcworkspace', 'ECLogging Mac', jobName = 'framework')
    print build('Sketch.xcworkspace', 'ECLogging Mac Static', jobName = 'static', cleanAll = False)
