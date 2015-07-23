#!/usr/bin/env python
# -*- coding: utf8 -*-

import subprocess
import shell
import re
import errors
import os

RE_ENTRIES = re.compile("^.(\w+) (.*) .*$", re.MULTILINE)
RE_BRANCH = re.compile("^[\* ] (.*)$", re.MULTILINE)
RE_REMOTE = re.compile("^(.*)\t(.*) (.*)$", re.MULTILINE)
RE_GITHUB_REMOTE = re.compile("^(.*)\tgit@github.com\:(.*?)\/(.*) (.*)$", re.MULTILINE)

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

def checkout_recursive_helper(module, expectedCommit, checkoutRef):
    checkoutCommit = commit_for_ref("origin/" + checkoutRef)
    if checkoutCommit:
        if checkoutCommit != expectedCommit:
            print "Branch {0} for submodule {1} wasn't at the commit that the parent repo expected: {2} instead of {3}.".format(checkoutRef, module, checkoutCommit, expectedCommit)
        else:
            checkout(checkoutRef)
            merge(fastForwardOnly = True)


def checkout_recursive(ref, pullIfSafe = False):
    checkout(ref)
    if pullIfSafe:
        pull(fastForwardOnly = True)
    submodule_update()
    enumerate_submodules(checkout_recursive_helper, ref)

def submodule_update():
    return shell.call_output_and_result(["git", "submodule", "update"])

def checkout_and_update(ref):
    (result, output) = checkout(ref)    
    if result == 0:
        (result, output) = submodule_update()
        
    return (result, output)

def submodule():
    return subprocess.check_output(["git", "submodule"])

def merge(ref = None, options = None, fastForwardOnly = False):
    cmd = ["git", "merge"]
    if not options:
        options = []
    if fastForwardOnly:
        options += ['--ff-only']
        cmd += options
    if ref:
        cmd += [ref]
    return shell.call_output_and_result(cmd)

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
    (result, output) = shell.call_output_and_result(["git", "log", "-1", "--oneline", "--no-abbrev-commit", ref])
    if result == 0:
        words = output.split(" ")
        if len(words) > 0:
            return words[0]

def top_level():
    (result, output) = shell.call_output_and_result(["git", "rev-parse", "--show-toplevel"])
    return output.strip()

def remote_url():
    (result, output) = shell.call_output_and_result(["git", "remote", "-v"])
    if result == 0:
        match = RE_REMOTE.search(output)
        if match:
            return match.group(2)

def github_info():
    (result, output) = shell.call_output_and_result(["git", "remote", "-v"])
    if result == 0:
        remotes = {}
        for match in RE_GITHUB_REMOTE.findall(output):
            remote = match[0]
            info = remotes.get(remote)
            if not info:
                info = {}
            info["owner"] = match[1]
            info["name"] =  os.path.splitext(match[2])[0]
            info[match[3]] = os.path.join(match[1], match[2])
            remotes[remote] = info
        return remotes

def main_github_info():
    info = github_info()
    result = info.get("origin")
    if not result:
        result = info.values()[0]
    return result

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
    basePath = top_level()
    modules = submodules()
    for module in modules.keys():
    	modulePath = os.path.join(basePath, module)
    	os.chdir(modulePath)
        cmd(module, modules[module], args)

    os.chdir(currentDir)


def first_matching_branch_for_issue(issueNumber, remote = False, branchType = "feature"):
    remotePrefix = ""
    if remote:
        remotePrefix = "origin/"
    	gitType = "remote"
    else:
    	gitType = "local"

    gitBranches = branches(gitType)
    
    # if there's a branch that just has the passed issue number
    # as it's whole name, reutrn it
    # (this allows things like 'develop' to be passed in, instead of an issue number)
    simpleBranch = remotePrefix + issueNumber
    if simpleBranch in gitBranches:
        return simpleBranch

    # otherwise try to match a branch with the number and type, eg feature/1234
    branch = remotePrefix + branchType + "/" + issueNumber
    niceBranchStart = branch + "-"
    for possibleBranch in gitBranches:
        if possibleBranch.startswith(niceBranchStart):
        	branch = possibleBranch
        	break

    return branch


def enumerate_test(module, ref, args):
    print module, ref, args

if __name__ == "__main__":
    print top_level()
    # enumerate_submodules(enumerate_test, "arguments")
    print remote_url()
    print github_info()
    print main_github_info()
