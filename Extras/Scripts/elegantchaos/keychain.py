#!/usr/bin/env python
# -*- coding: utf8 -*-

# --------------------------------------------------------------------------
#  Copyright 2017 Elegant Chaos Limited. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

import re
import sys
from subprocess import check_output, STDOUT

RE_FIND_PASSWORD = re.compile('password: "([^"]+)"').search
RE_FIND_USER = re.compile('"acct"<blob>="([^"]+)"').search

def find_key(fn, out):
    match = fn(out)
    return match and match.group(1)



def set_token(token, server):
    set_internet_password('api-token', token, server)



def set_internet_password(user, password, server):
    cmd = [
        'security',
        'add-internet-password',
        '-a', user,
        '-s', server,
        '-w', password,
        '-U'
    ]

    try:
        check_output(cmd, stderr=STDOUT)
    except:
        print "set password failed"



def get_token(server):
    result = get_internet_password(server)
    if result:
        (user, result) = result

    return result


def get_internet_password(server, prompt = None):
    cmd = [
       'security',
       'find-internet-password',
       '-g',
       '-s', server
    ]
    try:
        out = check_output(cmd, stderr=STDOUT)
        user = find_key(RE_FIND_USER, out)
        password = find_key(RE_FIND_PASSWORD, out)
        result = (user, password)
    except:
        result = None

    return result



def get_or_set_token(server, prompt = None):
    result = get_or_set_password(server, prompt, 'api-token')
    if result:
        (user, result) = result

    return result



def get_or_set_password(server, prompt, user = None):
    result = get_internet_password(server)
    if (not result) and sys.__stdin__.isatty():
        if not user:
            user = raw_input("{0}.\nuser:".format(prompt))
            password = raw_input("password:")
        else:
            password = raw_input("{0}\n".format(prompt))
        set_internet_password(user, password, server)
        result = (user, password)

    return result



if __name__ == "__main__":
    #print get_or_set_password('test-api', "Test prompt", 'sam')
    print get_or_set_token('test-api5', "Test prompt")
