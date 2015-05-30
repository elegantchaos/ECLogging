#!/usr/bin/env python
# -*- coding: utf8 -*-

import os
import subprocess
import sys
import errors

def exit_with_message(message, error):
    print(message)
    exit(error)
    
def check_arguments(count, usage):
    argc = len(sys.argv)
    if (argc <= count):
        name = os.path.basename(sys.argv[0])
        message = "Usage {0} {1}.".format(name, usage)
        message = message.format(name) # usage can contain {0} itself
        exit_with_message(message, errors.ERROR_WRONG_ARGUMENTS)

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
    
def got_tool(tool):
    try:
        subprocess.check_output(["/usr/bin/which", tool])
        return True
    except subprocess.CalledProcessError:
        return False
