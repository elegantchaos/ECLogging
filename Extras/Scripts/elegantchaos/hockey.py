#!/usr/bin/env python
# -*- coding: utf8 -*-

import os
import keychain

from hockeylib import app, crash


def set_token(token):
    keychain.set_internet_password("hockey-api-key", token, "api.hockeyapp.net")

def get_token():
    return keychain.get_internet_password("api.hockeyapp.net")

if __name__ == '__main__':
    (user, token) = get_token()

    os.environ['HOCKEY_API_KEY'] = token

    apps = app.get_all_apps()
    for app in apps:
        print "Found app {0}".format(app.title())
