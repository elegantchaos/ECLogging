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
RE_ISSUE_NUMBER = re.compile("^.*feature/(\d+).*$", re.MULTILINE)

def repo_root_path():
    (result, output) = shell.call_output_and_result(['git', 'rev-parse',  '--show-toplevel'])
    if result == 0:
        return output.strip()

def repo_name():
    path = repo_root_path()
    if path:
        name = os.path.basename(path)
        return name

def status():
    status = subprocess.check_output(["git", "status", "--porcelain"])
    return status

def got_changes():
    return status() != ""

def ensure_running_at_root_of_repo(root):
    path = repo_root_path()
    workspace = os.path.join(path, "{0}.xcworkspace".format(root))
    if not os.path.exists(workspace):
        message = "You need to run this command from the root of the {0} repo.".format(root)
        shell.exit_with_message(message, errors.ERROR_NOT_AT_ROOT)
    else:
        os.chdir(repo_root_path())

def exit_if_changes():
    if got_changes():
        shell.exit_with_message("You have changes. Commit them first.", errors.ERROR_GIT_CHANGES_PENDING)

def checkout(ref):
    return shell.call_output_and_result(["git", "checkout", ref])

def clone(repo, name = None):
    args = ['git', 'clone', repo]
    if name:
        args += [name]

    return shell.call_output_and_result(args)

def checkout_detached():
    return shell.call_output_and_result(["git", "checkout", "--detach"])

def checkout_recursive_helper(module, expectedCommit, checkoutRef):
    checkoutCommit = commit_for_ref("origin/" + checkoutRef)
    if checkoutCommit:
        if checkoutCommit != expectedCommit:
            print "Branch {0} for submodule {1} wasn't at the commit that the parent repo expected: {2} instead of {3}.".format(checkoutRef, module, checkoutCommit, expectedCommit)
        else:
            (result, output) = checkout(checkoutRef)
            if result == 0:
                merge(fastForwardOnly = True)
            else:
                print "Error checking out {0}: {1}".format(module, output)


def checkout_recursive(ref, pullIfSafe = False):
    (result, output) = checkout(ref)
    if (result == 0) and pullIfSafe:
        (result, moreOutput) = pull(fastForwardOnly = True)
        output += moreOutput

    if result == 0:
        (result, moreOutput) = submodule_update()
        output += moreOutput

    if result == 0:
        enumerate_submodules(checkout_recursive_helper, ref)

    return (result, output)


def add(path):
    return shell.call_output_and_result(["git", "add", path])

def commit(path, message): # TODO: is anything using this? remove it and rename commit2
    return subprocess.check_output(["git", "commit", path, "-m", message])

def commit2(path, message):
    return shell.call_output_and_result(["git", "commit", path, "-m", message])

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

def tags():
    tags = []
    (result, output) = shell.call_output_and_result(['git', 'tag'])
    if result == 0:
        tags = output.strip().split('\n')

    return tags

def add_tag(tag, ref, push = False, force = False, message = None):
    cmd = ['git', 'tag']
    if force:
        cmd += ['-f']
    cmd += [tag, ref]
    if message:
        cmd += ['-m', message]
    (result, output) = shell.call_output_and_result(cmd)
    if push and (result == 0):
        (result, output) = shell.call_output_and_result(['git', 'push', 'origin', tag])

    return (result, output)

def delete_tag(tag, fromRemote = True):
    (result, output) = shell.call_output_and_result(['git', 'tag', '-d', tag])
    if (result == 0) and fromRemote:
        (result, output) = shell.call_output_and_result(['git', 'push', 'origin', ':refs/tags/' + tag])

    return (result, output)

def push_tags():
    return shell.call_output_and_result(['git', 'push', '--tags'])

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

def set_branch(branch, commit = None, forced = False):
    cmd = ["git", "branch"]
    if forced:
        cmd += ['-f']

    cmd += [branch]
    if commit:
        cmd += [commit]

    return shell.call_output_and_result(cmd)

def fetch():
    cmd = ["git", "fetch"]
    return shell.call_output_and_result(cmd)

def pull(fastForwardOnly = False):
    cmd = ["git", "pull"]
    if fastForwardOnly:
        cmd += ["--ff-only"]
    return shell.call_output_and_result(cmd)

def push(branch = None, upstream = None):
    cmd = ['git', 'push']
    if upstream:
        cmd += ['--set-upstream', upstream]
    if branch:
        cmd += [branch]

    return shell.call_output_and_result(cmd)

def commit_for_ref(ref):
    (result, output) = shell.call_output_and_result(["git", "log", "-1", "--oneline", "--no-abbrev-commit", ref])
    if result == 0:
        words = output.split(" ")
        if len(words) > 0:
            return words[0]
    # else:
    #     print output

def ref_exists(ref):
    commit = commit_for_ref(ref)
    return commit != None

def top_level():
    (result, output) = shell.call_output_and_result(["git", "rev-parse", "--show-toplevel"])
    return output.strip()

def remote_url():
    (result, output) = shell.call_output_and_result(["git", "remote", "-v"])
    if result == 0:
        match = RE_REMOTE.search(output)
        if match:
            return match.group(2)
    else:
        print result, output

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
    if not ((branch == "develop") or (branch == "HEAD") or ("detached " in branch)):
        localCommit = commit_for_ref(branch)
        remoteCommit = commit_for_ref("remotes/origin/" + branch)
        if not remoteCommit:
            remoteCommit = commit_for_ref("origin/" + branch)

        match = RE_ISSUE_NUMBER.search(branch)
        if match:
            closedTag = "refs/tags/issues/closed/" + match.group(1)
            deletedCommit = commit_for_ref(closedTag)
        else:
            deletedCommit = None

        if (localCommit == remoteCommit) or (localCommit == deletedCommit) or forced: # TODO: should really check if remoteCommit or deletedCommit *contain* the localCommit, rather than just if they are equal
            (result, output) = delete_branch(branch)
            print output
        # else:
        #     print "Local commit {0} didn't match remote commit {1} or deleted commit {2} for branch {3}".format(localCommit, remoteCommit, deletedCommit, branch)

def enumerate_submodules(cmd, args = None):
    currentDir = os.getcwd()
    basePath = top_level()
    modules = submodules()
    for module in modules.keys():
        modulePath = os.path.join(basePath, module)
        os.chdir(modulePath)
        cmd(module, modules[module], args)

    os.chdir(currentDir)


def first_matching_branch_for_issue(issueNumber, remote = False, branchType = "feature", stripPrefix = False, preferStable = False):
    remotePrefix = ""
    if remote:
        remotePrefix = "origin/"
        gitType = "remote"
    else:
        gitType = "local"

    gitBranches = branches(gitType)

    # if there's a branch that just has the passed issue number as its whole name, return it
    # similarly if there's a release or hotfix
    # (this allows things like 'develop', '3,4', '3.3.3' to be passed in, instead of an issue number)
    simpleBranch = remotePrefix + issueNumber
    releaseBranch = remotePrefix + "release" + "/" + issueNumber
    hotFixBranch = remotePrefix + "hotfix" + "/" + issueNumber

    if simpleBranch in gitBranches:
        branch = simpleBranch

    elif releaseBranch in gitBranches:
        branch = releaseBranch

    elif hotFixBranch in gitBranches:
        branch = hotFixBranch

    else:
        # otherwise try to match a branch with the number and type, eg feature/1234
        branch = remotePrefix + branchType + "/" + issueNumber
        niceBranchStart = branch + "-"
        for possibleBranch in gitBranches:
            if possibleBranch.startswith(niceBranchStart):
                branch = possibleBranch
                break

    stripped = branch
    if remote and branch.startswith(remotePrefix):
        stripped = branch[len(remotePrefix):]

    if preferStable:
        stableStripped = "stable/" + stripped
        stable = remotePrefix + stableStripped
        if stable in gitBranches:
            branch = stable
            stripped = stableStripped

    if stripPrefix:
        branch = stripped

    return branch


def enumerate_test(module, ref, args):
    print module, ref, args

if __name__ == "__main__":
    print top_level()
    # enumerate_submodules(enumerate_test, "arguments")
    print remote_url()
    print github_info()
    print main_github_info()
