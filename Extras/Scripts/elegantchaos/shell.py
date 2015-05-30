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
        return (0, subprocess.check_output(cmd))
    except subprocess.CalledProcessError as e:
        return (e.returncode, e.output)