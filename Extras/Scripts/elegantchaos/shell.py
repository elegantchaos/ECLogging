#!/usr/bin/env python
# -*- coding: utf8 -*-

import os
import subprocess
import sys
import errors
import getopt

PROCESSED_ARGUMENTS = []
PROCESSED_OPTIONS = {}

def exit_with_message(message, error):
    print(message)
    exit(error)

def exit_if_failed_with_message(result, output, message):
    if result != 0:
        exit_with_message(message, result)

def getopt_options_from_options(options):
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

def option_name_from_getopt_name(optname):
    if optname[:2] == "--":
        cleanName = optname[2:]
    elif optname[0] == "-":
        cleanName = optname[1:]
    else:
        cleanName = optname

    return cleanName

def exit_if_too_few_arguments(args, count, usage):
        argc = len(args)
        if (argc < count):
            name = os.path.basename(sys.argv[0])
            message = "Error: too few arguments were supplied.\n\nUsage {0} {1}.".format(name, usage)
            message = message.format(name) # usage can contain {0} itself
            exit_with_message(message, errors.ERROR_WRONG_ARGUMENTS)

def process_options(options):
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

def check_arguments(count, usage, options = {}):
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

def get_argument(index):
    return PROCESSED_ARGUMENTS[index - 1]

def get_option(key):
    return PROCESSED_OPTIONS.get(key)

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
	    outputFile.write(text)

def view_file(path):
    subprocess.call(["open", path])

def view_url(path):
    subprocess.call(["open", path])

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
    return os.path.join(script_base(), path)

def call_output_and_result(cmd):
    try:
        return (0, subprocess.check_output(cmd, stderr = subprocess.STDOUT))
    except subprocess.CalledProcessError as e:
        return (e.returncode, e.output)
