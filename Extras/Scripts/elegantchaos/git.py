#!/usr/bin/env python
# -*- coding: utf8 -*-

import subprocess
import shell
import re
import errors

RE_ENTRIES = re.compile("^.(\w+) (.*) .*$", re.MULTILINE)

def status():
    status = subprocess.check_output(["git", "status", "--porcelain"])
    return status
    
def got_changes():
    return status() != ""

def exit_if_changes():
    if got_changes():
    	shell.exit_with_message("You have changes. Commit them first.", errors.ERROR_GIT_CHANGES_PENDING)

def checkout(ref):
    return shell.call_output_and_result(["git", "checkout", ref])
    
def checkout_detached():
    return shell.call_output_and_result(["git", "checkout", "--detach"])
    
def submodule_update():
    return subprocess.check_output(["git", "submodule", "update"])
    
def checkout_and_update(ref):
    checkout(ref)
    submodule_update()
    
def submodule():
    return subprocess.check_output(["git", "submodule"])

        
def merge(ref, options = None):
    cmd = ["git", "merge"]
    if options:
        cmd += options
    cmd += [ref]
    return subprocess.check_output(cmd)
    
def submodules():
    raw = subprocess.check_output(["git", "submodule"])
    entries = RE_ENTRIES.findall(raw)
    result = dict()
    for ref,name in entries:
        result[name] = ref
    
    return result

def make_branch(name, ref = None):
    cmd = ["git", "checkout", "-b", name]
    if ref:
        cmd = cmd + [ref]
    return shell.call_output_and_result(cmd)
        
def branches():
    output = subprocess.check_output(["git", "branch", "-a"])
    lines = output.split("\n")
    branches = map(str.strip, lines)
    return branches

def delete_branch(branch):
    return shell.call_output_and_result(["git", "branch", "-d", branch])
