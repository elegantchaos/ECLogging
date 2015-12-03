#!/usr/bin/env python
# -*- coding: utf8 -*-

import subprocess
import shutil
import shell
import re
import errors
import os
import fnmatch

RE_TEST_RAN = re.compile("(.) -\[(\w+) (\w+)\] \((\d+) ms\)")
RE_TEST_FAILED = re.compile("TEST FAILED: (\d+) passed, (\d+) failed, (\d+) errored, (\d+) total \*\*.*?\((\d+)", re.DOTALL)
RE_WARNINGS = re.compile("(\w+\.\w+):(\d+):(\d+): warning: (.*)")
RE_LINKER_WARNINGS = re.compile("ld: warning: (.*)")
RE_LINKER_WARNINGS2 = re.compile("WARNING: (.*)")
RE_ERRORS = re.compile(":( fatal)* error:", re.DOTALL)
RE_CODESIGNING = re.compile("codesign failed with exit code", re.DOTALL)
RE_PLATFORM_SCHEME = re.compile("(.*)-(.*)")
RE_ARCHIVE_FAILED = re.compile("ARCHIVE FAILED", re.DOTALL)
RE_IB_WARNINGS = re.compile("ibtoold\[\d*:\d*]", re.DOTALL)

def root_path():
    return os.path.join(os.getcwd(), 'test-build')

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
                symPath = os.path.join(paths['SYMROOT'], 'Release', "{0}.app.dSYM".format(name))
                return (appPath, symPath)

def zip_built_application(appPath, symPath):
    (result, output) = (errors.ERROR_FILE_NOT_FOUND, "Can't find built application.")
    if os.path.exists(appPath):
        (appFolder, app) = os.path.split(appPath)
        (name,ext) = os.path.splitext(app)
        zipPath = os.path.join(appFolder, "{0}.zip".format(name))
        (result, output) = shell.zip(appPath, zipPath)
        if result == 0:
            symZipPath = os.path.join(appFolder, "{0}.dSYM.zip".format(name))
            (result, output) = shell.zip(symPath, symZipPath)
            if result == 0:
                return (zipPath, symZipPath)

    if result != 0:
        shell.log_verbose(output)

def run_unit_tests(scheme = 'Sketch Jenkins', jobName = 'tests'):
    return build('Sketch.xcworkspace', scheme, actions = ['test'], jobName = jobName, cleanAll = False)

def build_variant(variant, actions = ['archive']):
    configsPath = shell.script_relative('../../../Sketch/Configs')
    configPath = os.path.join(configsPath, "{0}.xcconfig".format(variant))
    extraArgs = [ '-xcconfig', configPath ]
    return build('Sketch.xcworkspace', 'Sketch', actions = actions, jobName = variant, extraArgs = extraArgs)

def summarise_test_runs(log):
    passes = []
    failures = []
    errors = []
    suites = {}
    tests = RE_TEST_RAN.findall(log)
    for (type, suite, test, time) in tests:
        suiteSummary = suites.get(suite)
        if not suiteSummary:
            suiteSummary = {}
            suites[suite] = suiteSummary
        suitePasses = suiteSummary.get('passes') or 0
        suiteFailures = suiteSummary.get('failures') or 0
        suiteErrors = suiteSummary.get('errors') or 0
        if type == '~':
            passes += [(suite, test)]
            suitePasses += 1
            status = 'passed'

        elif type == 'x':
            failures += [(suite, test)]
            suiteFailures += 1
            status = 'failed'

        elif type == 'X':
            errors += [(suite, test)]
            suiteErrors += 1
            status = 'error'

        else:
            status = 'unknown'

        suiteTests = suiteSummary.get('tests')
        if not suiteTests:
            suiteTests = {}
            suiteSummary['tests'] = suiteTests
        suiteTests[test] = {'time' : time, 'status' : status}
        suiteSummary['passes'] = suitePasses
        suiteSummary['failures'] = suiteFailures
        suiteSummary['errors'] = suiteErrors
        suiteSummary['runs'] = len(suiteTests)

    return { 'passes' : passes, 'failures' : failures, 'errors' : errors, 'runs' : len(tests), 'suites' : suites }

def summarise_build_log(result, jobName):
    logPaths = log_paths(jobName)
    log = shell.read_text(logPaths['output'])

    summary = { 'result' : result}

    if result != 0:
        status = 'failed'
    else:
        status = 'succeeded'

    summary['tests'] = summarise_test_runs(log)

    summary['status'] = status
    return summary

def build(workspace, scheme, platform = 'macosx', configuration = 'Release', actions = ['build'], jobName = None, cleanAll = True, extraArgs = []):
    args = ['xctool', '-workspace', workspace, '-scheme', scheme, '-sdk', platform, '-configuration', configuration]

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
