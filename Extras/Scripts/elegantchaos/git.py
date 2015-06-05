#!/usr/bin/env python
# -*- coding: utf8 -*-

import subprocess
import shell
import re
import errors
import os

RE_ENTRIES = re.compile("^.(\w+) (.*) .*$", re.MULTILINE)
RE_BRANCH = re.compile("^[\* ] (.*)$", re.MULTILINE)

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
        
def branches(type="all"):
    cmd = ["git", "branch"]
    if type == "all":
        cmd += [ "-a" ]
    elif type == "remote":
        cmd += [ "-r" ]
        
    output = subprocess.check_output(cmd)
    branches = RE_BRANCH.findall(output)
    return branches

def delete_branch(branch):
    return shell.call_output_and_result(["git", "branch", "-d", branch])

def pull(fastForwardOnly = False):
    cmd = ["git", "pull"]
    if fastForwardOnly:
        cmd += ["--ff-only"]
    return shell.call_output_and_result(cmd)
    
def commit_for_ref(ref):
    (result, output) = shell.call_output_and_result(["git", "log", "-1", "--oneline", ref])
    if result == 0:
        words = output.split(" ")
        if len(words) > 0:
            return words[0]
            
def cleanup_local_branch(branch, forced = False):
	if not ((branch == "develop") or (branch == "HEAD") or ("(detached from" in branch)):
		localCommit = commit_for_ref(branch)
		remoteCommit = commit_for_ref("remotes/origin/" + branch)
		possibleIssueNumber = os.path.basename(branch)
		deletedCommit = commit_for_ref("issues/closed/" + possibleIssueNumber)
		if (localCommit == remoteCommit) or (localCommit == deletedCommit) or forced:
			(result, output) = delete_branch(branch)
			print output

def enumerate_submodules(cmd, args = None):
    currentDir = os.getcwd()
    basePath = os.path.realpath(shell.script_relative("../../.."))
    modules = submodules()
    for module in modules.keys():
    	modulePath = os.path.join(basePath, module)
    	os.chdir(modulePath)
        cmd(module, modules[module], args)
    
    os.chdir(basePath)	


def first_matching_branch_for_issue(issueNumber, remote = False, branchType = "feature"):
    if remote:
    	branchType = "remotes/origin/" + branchType
    	gitType = "remote"
    else:
    	gitType = "local"
        	
    gitBranches = branches(gitType)
    
    branch = branchType + "/" + issueNumber
    niceBranchStart = branch + "-"
    for possibleBranch in gitBranches:
        if possibleBranch.startswith(niceBranchStart):
        	branch = possibleBranch
        	break
            
    return branch
