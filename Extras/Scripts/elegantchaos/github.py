#!/usr/bin/env python
# -*- coding: utf8 -*-

# --------------------------------------------------------------------------
#  Copyright 2017 Elegant Chaos Limited. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

import keychain
import requests

try:
    import github3
except:
    print("You need to install github3 with: sudo pip install --pre github3.py")
    print("You may also need to install pip first with: sudo easy_install pip")
    exit(1)

def login_using_keychain():
    info = keychain.get_or_set_password("github.com", "Please enter your github details")
    if info:
        (user, password) = info
        gh = github3.login(user, password=password)
        return gh

def issue_with_number(number, session, organisation, repo):
    try:
        result = session.issue(organisation, repo, number)
        return result
    # except requests.NewConnectionError as e:
    #     print e
    except Exception as e:
        print e
        pass

def milestone_with_title(repo, title):
    # try open milestones
    milestones = repo.milestones()
    for milestone in milestones:
        if (milestone.title == title):
            return milestone

    # try closed ones
    milestones = repo.milestones(state = 'closed')
    for milestone in milestones:
        if (milestone.title == title):
            return milestone

if __name__ == '__main__':

    gh = login_using_keychain()

    issue = gh.issue("BohemianCoding", "Sketch", "3444")
    print issue.as_dict().keys()
    print issue.title
