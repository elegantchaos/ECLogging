#!/usr/bin/env python
# -*- coding: utf8 -*-

import keychain

try:
    import github3
except:
    print("You need to install github3 with: pip install --pre github3.py")

def login_using_keychain():
    (user, password) = keychain.get_internet_password("github.com")
    gh = github3.login(user, password=password)
    return gh


if __name__ == '__main__':

    gh = login_using_keychain()    
    
    issue = gh.issue("BohemianCoding", "Sketch", "3444")
    print issue.as_dict().keys()
    print issue.title