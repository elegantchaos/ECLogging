#!/usr/bin/env python
# -*- coding: utf8 -*-

# --------------------------------------------------------------------------
#  Copyright 2017 Elegant Chaos Limited. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

import subprocess
import shutil
import shell
import re
import errors
import os
import fnmatch

RE_TEST_RAN = re.compile("(.) -\[(\w+) (\w+)\] \((\d+) ms\)")
RE_WARNINGS = re.compile("\n(.*):(\d+):(\d+): warning: (.*?)( \[-(.*)\])*\n(.*)\n")
RE_ERRORS = re.compile("\n(.*):(\d+):(\d+):( fatal)* error: (.*?)( \[-(.*)\])*\n(.*)\n")
RE_LINKER_WARNINGS = re.compile("ld: warning: (.*)")
RE_LINKER_WARNINGS2 = re.compile("WARNING: (.*)")
RE_CODESIGNING = re.compile("codesign failed with exit code", re.DOTALL)
RE_PLATFORM_SCHEME = re.compile("(.*)-(.*)")
RE_ARCHIVE_FAILED = re.compile("ARCHIVE FAILED", re.DOTALL)
RE_IB_WARNINGS = re.compile("ibtoold\[\d*:\d*]", re.DOTALL)

def root_path():
    return os.path.join(os.getcwd(), 'test-build')

def log_paths(jobName):
    root = root_path()
    logs = ['output', 'errors', 'pretty', 'compilation']
    if jobName:
        prefix = jobName + '-'
    else:
        prefix = ''

    logsPath = os.path.join(root, 'logs')
    if not os.path.exists(logsPath):
        os.makedirs(logsPath)

    full = {}
    for log in logs:
        path = os.path.join(logsPath, "{0}{1}.log".format(prefix, log))
        full[log] = path

    return full

def derived_path():
    root = root_path()
    return os.path.join(root, 'derived')

def archive_path():
    root = root_path()
    return os.path.join(root, 'archive.xcarchive')

def built_archive():
    archive = archive_path()
    appFolder = os.path.join(archive, 'Products', 'Applications')
    if os.path.exists(appFolder):
        for item in os.listdir(appFolder):
            (itemName,itemExt) = os.path.splitext(item)
            if itemExt == ".app":
                app = os.path.join(appFolder, item)
                sym = os.path.join(archive, 'dSYMS', "{0}.dSYM".format(item))
                return (archive, app, sym)

def first_built_application(name, configuration):
    derived = derived_path()
    appFolder = os.path.join(derived, 'Build', 'Products', configuration)
    if os.path.exists(appFolder):
        for item in os.listdir(appFolder):
            (itemName,itemExt) = os.path.splitext(item)
            if (itemExt == ".app") and (name in itemName):
                appPath = os.path.join(appFolder, item)
                symPath = os.path.join(appFolder, "{0}.dSYM".format(item))
                return (appPath, symPath)

def zip_built_application(appPath, symPath, zipRoot = None):
    (result, output) = (errors.ERROR_FILE_NOT_FOUND, "Can't find built application.")
    if os.path.exists(appPath):
        (appFolder, app) = os.path.split(appPath)
        (name,ext) = os.path.splitext(app)
        if not zipRoot:
            zipRoot = appFolder
        zipPath = os.path.join(zipRoot, "{0}.zip".format(name))
        (result, output) = shell.zip(appPath, zipPath)
        if result == 0:
            symZipPath = os.path.join(zipRoot, "{0}.dSYM.zip".format(name))
            (result, output) = shell.zip(symPath, symZipPath)
            if result == 0:
                return (zipPath, symZipPath)

    if result != 0:
        shell.log_verbose(output)

def run_unit_tests(workspace, scheme, jobName = 'tests'):
    return build(workspace, scheme, actions = ['test'], jobName = jobName)

def build_variant(variant, workspace, scheme, actions = ['archive'], jobName = None):
    configsPath = shell.script_relative('../../../Sketch/Configs')
    configPath = os.path.join(configsPath, "{0}.xcconfig".format(variant))
    extraArgs = [ '-xcconfig', configPath ]
    if not jobName:
        jobName = variant
    return build(workspace, scheme, actions = actions, jobName = jobName, extraArgs = extraArgs)

def summarise_warnings(log):
    result = {}
    errors = RE_WARNINGS.findall(log)
    for (file, line, length, warning, switch, switchInner, text) in errors:
        key = file+line+length
        result[key] = {'file' : file, 'line' : line, 'length' : length, 'fatal' : False, 'reason' : warning, 'text' : text, 'switch' : switchInner}

    return result.values()


def summarise_errors(log):
    result = {}
    errors = RE_ERRORS.findall(log)
    for (file, line, length, fatal, error, switch, switchInner, text) in errors:
        isFatal = fatal != ''
        key = file+line+length
        result[key] = {'file' : file, 'line' : line, 'length' : length, 'fatal' : isFatal, 'reason' : error, 'text' : text, 'switch' : switchInner}

    return result.values()

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
    summary['errors'] = summarise_errors(log)
    summary['warnings'] = summarise_warnings(log)

    summary['status'] = status
    return summary

def clean():
    root = root_path()
    try:
        shutil.rmtree(root)
    except Exception as e:
        pass

def build(workspace, scheme, platform = 'macosx', configuration = 'Release', actions = ['build'], jobName = None, extraArgs = []):
    args = ['xctool', '-workspace', workspace, '-scheme', scheme, '-sdk', platform, '-configuration', configuration]

    for action in actions:
        args += [action]
        if action == 'archive':
            args += ["-archivePath", archive_path()]

    args += ['-derivedDataPath', derived_path()]

    logPaths = log_paths(jobName)
    args += ['-reporter', "pretty:{0}".format(logPaths['pretty'])]
    args += ['-reporter', "plain:{0}".format(logPaths['output'])]
    args += ['-reporter', "json-compilation-database:{0}".format(logPaths['compilation'])]
    args += extraArgs

    (result, output) = shell.call_output_and_result(args)
    return (result, output)


if __name__ == "__main__":
    print build('Sketch.xcworkspace', 'ECLogging Mac', jobName = 'framework')
    print build('Sketch.xcworkspace', 'ECLogging Mac Static', jobName = 'static')
