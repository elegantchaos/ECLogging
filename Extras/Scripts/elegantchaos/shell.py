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
    
def check_arguments(count, usage, options = {}):
    global PROCESSED_OPTIONS
    global PROCESSED_ARGUMENTS
       
    argv = sys.argv
    try:
        optkeys = []
        for key in options.keys():
            defaultValue = options[key] 
            if  (defaultValue != None) and (defaultValue != True) and (defaultValue != False):
                key += "="
            optkeys += [key]
        
        PROCESSED_OPTIONS = options
        (optlist, args) = getopt.gnu_getopt(argv[1:], "", optkeys)
        for optname, optvalue in optlist:
            if optname[:2] == "--":
                cleanName = optname[2:]
            elif optname[0] == "-":
                cleanName = optname[1:]
            else:
                cleanName = optname
            
            if optvalue:
            	PROCESSED_OPTIONS[cleanName]=optvalue
            else:
                defaultValue = options[cleanName]
                if (defaultValue == True) or (defaultValue == False):
                    PROCESSED_OPTIONS[cleanName]=True 

        PROCESSED_ARGUMENTS += args
        argc = len(args)
        if (argc < count):
            name = os.path.basename(argv[0])
            message = "Error: too few arguments were supplied.\n\nUsage {0} {1}.".format(name, usage)
            message = message.format(name) # usage can contain {0} itself
            exit_with_message(message, errors.ERROR_WRONG_ARGUMENTS)
    
    except getopt.GetoptError as e:
        print "Error: {0}".format(e)
        exit(errors.ERROR_UNKNOWN_OPTION)
    
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
    return os.path.dirname(sys.argv[0])

def script_relative(path):
    return os.path.join(script_base(), path)

def call_output_and_result(cmd):
    try:
        return (0, subprocess.check_output(cmd, stderr = subprocess.STDOUT))
    except subprocess.CalledProcessError as e:
        return (e.returncode, e.output)