#!/usr/bin/env python
# -*- coding: utf8 -*-

import re
from subprocess import check_output, STDOUT

RE_FIND_PASSWORD = re.compile('password: "([^"]+)"').search
RE_FIND_USER = re.compile('"acct"<blob>="([^"]+)"').search

def find_key(fn, out):
    match = fn(out)
    return match and match.group(1)


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

def get_internet_password(server):
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
   