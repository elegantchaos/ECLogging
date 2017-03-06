#!/usr/bin/env python
# -*- coding: utf8 -*-

# --------------------------------------------------------------------------
#  Copyright 2017 Elegant Chaos Limited. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

import os
import subprocess
import sys
import errors
import getopt
import re
import webbrowser

RE_XCODE_VERSION = re.compile('Xcode ([\d.]+).*')



PROCESSED_ARGUMENTS = []
PROCESSED_OPTIONS = {}
DOCOPT_ARGUMENTS = {}

def open_url(url):
    return call_output_and_result(['open', url])

def application_info(applicationPath):
	return {
	'version' : application_version_number(applicationPath),
	'build' : application_build_number(applicationPath),
    'variant' : application_info_for_key(applicationPath, 'Sketch Variant'),
    'xcode' : application_info_for_key(applicationPath, 'DTXcode'),
    'xcode build' : application_info_for_key(applicationPath, 'DTXcodeBuild'),
    'sdk' : application_info_for_key(applicationPath, 'DTSDKName'),
    'sdk build' : application_info_for_key(applicationPath, 'DTSDKBuild'),
    'sdks supported' : application_info_for_key(applicationPath, 'Supported SDKs'),
    'commit' : application_info_for_key(applicationPath, 'ECVersionCommit')
	}

def application_info_for_key(applicationPath, key):
    plistPath = os.path.join(applicationPath, 'Contents', 'Info.plist')
    (result, output) = call_output_and_result(['/usr/libexec/PlistBuddy', '-c', "Print :'{0}'".format(key), plistPath])
    if result == 0:
        return output.strip()


def application_build_number(applicationPath):
    return application_info_for_key(applicationPath, 'CFBundleVersion')

def application_version_number(applicationPath):
    return application_info_for_key(applicationPath, 'CFBundleShortVersionString')


def system_version():
    (result, output) = call_output_and_result(['sw_vers', '-productVersion'])
    return output.strip()

def xcode_version():
    (result, output) = call_output_and_result(['xcodebuild', '-version'])
    match = RE_XCODE_VERSION.match(output)
    if match:
        return match.group(1)
    else:
        return output.strip()

def log(message):
    print message

def log_verbose(message):
	if get_option('verbose'):
		print message

def exit_with_message(message, error):
    print(message)
    exit(error)

def exit_if_failed_with_message(result, output, message, showOutput = None):
    if result != 0:
        if not showOutput:
            showOutput = get_option('verbose')
        if showOutput:
            message = "{0}\n\n{1}".format(message, output)

        exit_with_message(message, result)

def getopt_options_from_options(options): # TODO: old API; remove
    global PROCESSED_OPTIONS
    options["debug-args"] = { "default" : False }
    optkeys = []
    for key in options.keys():
        defaultValue = options[key].get("default")
        getoptkey = key
        if  (defaultValue != None) and (defaultValue != True) and (defaultValue != False):
            getoptkey += "="
        optkeys += [getoptkey]
        PROCESSED_OPTIONS[key] = defaultValue

    return optkeys

def option_name_from_getopt_name(optname): # TODO: old API; remove
    if optname[:2] == "--":
        cleanName = optname[2:]
    elif optname[0] == "-":
        cleanName = optname[1:]
    else:
        cleanName = optname

    return cleanName

def exit_if_too_few_arguments(args, count, usage): # TODO: old API; remove
        argc = len(args)
        if (argc < count):
            name = os.path.basename(sys.argv[0])
            message = "Error: too few arguments were supplied.\n\nUsage {0} {1}.".format(name, usage)
            message = message.format(name) # usage can contain {0} itself
            exit_with_message(message, errors.ERROR_WRONG_ARGUMENTS)

def check_arguments_docopt(main):
    global DOCOPT_ARGUMENTS

    DOCOPT_ARGUMENTS = docopt(main, version="1.0")
    return DOCOPT_ARGUMENTS

def process_options(options): # TODO: old API; remove
    global PROCESSED_OPTIONS
    argv = sys.argv
    try:
        optkeys = getopt_options_from_options(options)

        (optlist, args) = getopt.gnu_getopt(argv[1:], "", optkeys)
        for optname, optvalue in optlist:
            cleanName = option_name_from_getopt_name(optname)

            if optvalue:
            	PROCESSED_OPTIONS[cleanName]=optvalue
            else:
                defaultValue = options[cleanName].get("default")
                if (defaultValue == True) or (defaultValue == False):
                    PROCESSED_OPTIONS[cleanName]=True

        return args

    except getopt.GetoptError as e:
        print "Error: {0}".format(e)
        exit(errors.ERROR_UNKNOWN_OPTION)

def check_arguments(count, usage, options = {}): # TODO: old API; remove
    global PROCESSED_ARGUMENTS

    if options:
        args = process_options(options)
    else:
        args = sys.argv[1:]

    PROCESSED_ARGUMENTS += args
    exit_if_too_few_arguments(args, count, usage)

    if PROCESSED_OPTIONS.get("debug-args"):
        print "Arguments: {0}".format(PROCESSED_ARGUMENTS)
        print "Options: {0}".format(PROCESSED_OPTIONS)

def get_argument(key):
    if isinstance(key, basestring):
        return DOCOPT_ARGUMENTS.get("<{0}>".format(key))
    else:
        return PROCESSED_ARGUMENTS[key - 1]

def get_option(key):
    result = DOCOPT_ARGUMENTS.get("--{0}".format(key))
    if not result:
        result = PROCESSED_OPTIONS.get(key)
    return result

def all_arguments():
    global DOCOPT_ARGUMENTS

    return DOCOPT_ARGUMENTS

def expand_directory(path):
    path = os.path.expanduser(path)
    if not os.path.exists(path):
	   	os.makedirs(path)

    return path

def read_text(path):
    text = ""
    with open(path, "r") as inputFile:
        text = inputFile.read()
    return text

def write_text(path, text):
	with open(path, "w") as outputFile:
	    outputFile.write(text.encode('utf8'))

def view_file(path):
    subprocess.call(["open", path])

def view_url(url):
	webbrowser.open(url)

def got_tool(tool):
    try:
        subprocess.check_output(["/usr/bin/which", tool])
        return True
    except subprocess.CalledProcessError:
        return False

def html_link_attributes(text, attributes):
       return "<a " + " ".join(attributes) + ">" + text + "</a>"

def html_link(text, url):
       attributes = [ "href=\"" + url + "\""]
       return html_link_attributes(text, attributes)

def script_name():
    return os.path.basename(sys.argv[0])

def script_base():
    cmd = os.path.realpath(sys.argv[0])
    path = os.path.dirname(cmd)
    return path

def script_relative(path):
    result = os.path.join(script_base(), path)
    return os.path.abspath(result)

def zip(source, destination):
    args = ['ditto', '-c', '-k', '--sequesterRsrc', '--keepParent', source, destination]
    result = call_output_and_result(args)
    return result

def call_output_and_result(cmd):
    try:
        return (0, subprocess.check_output(cmd, stderr = subprocess.STDOUT))
    except subprocess.CalledProcessError as e:
        return (e.returncode, e.output)



try:
    from docopt import docopt
except:
    exit_with_message("This script requires docopt. You can install it with: pip install docopt.", errors.ERROR_REQUIRED_MODULE_MISSING)
