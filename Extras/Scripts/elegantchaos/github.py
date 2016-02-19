#!/usr/bin/env python
# -*- coding: utf8 -*-

# --------------------------------------------------------------------------
#  Copyright 2015-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

import keychain

try:
    import github3
except:
    print("You need to install github3 with: sudo pip install --pre github3.py")
    print("You may also need to install pip first with: sudo easy_install pip")
    exit(1)

def login_using_keychain():
    (user, password) = keychain.get_internet_password("github.com")
    gh = github3.login(user, password=password)
    return gh


def milestone_with_title(repo, title):
    milestones = repo.milestones()
    for milestone in milestones:
        if (milestone.title == title):
            return milestone

if __name__ == '__main__':

    gh = login_using_keychain()

    issue = gh.issue("BohemianCoding", "Sketch", "3444")
    print issue.as_dict().keys()
    print issue.title
