#!/usr/bin/env python
# -*- coding: utf8 -*-

import subprocess
import shell
import re
import errors
import os

def root_path():
    return os.path.join(os.getcwd(), 'build')

def log_paths():
    root = root_path()
    logs = ['output', 'errors', 'pretty']

    full = {}
    for log in logs:
        full[log] = os.path.join(root, 'logs', "{0}.log".format(log))

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

def build(workspace, scheme, platform = 'macosx', actions = ['build']):
    args = ['xctool', '-workspace', workspace, '-scheme', scheme, '-sdk', platform]

    paths = build_paths()
    pathArgs = []
    for key in paths:
        pathArgs += ["{0}={1}".format(key, paths[key])]

    args += actions
    args += pathArgs

    logPaths = log_paths()
    args += ['-reporter', "pretty:{0}".format(logPaths['pretty'])]
    args += ['-reporter', "plain:{0}".format(logPaths['output'])]

    (result, output) = shell.call_output_and_result(args)
    return (result, output)


if __name__ == "__main__":
    print build_paths()
    print log_paths()
    print build('Sketch.xcworkspace', 'ECLogging Mac')
