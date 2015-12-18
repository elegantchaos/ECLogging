#!/usr/bin/env python
# -*- coding: utf8 -*-

import os
import keychain
import urllib2
import json

def set_token(token):
    keychain.set_internet_password("hockey-api-key", token, "api.hockeyapp.net")

def get_token():
    return keychain.get_internet_password("api.hockeyapp.net")

def hockey_request(command, token):
    url = "https://rink.hockeyapp.net/api/2/" + command
    request = urllib2.Request(url)
    request.add_header('X-HockeyAppToken', token)
    return request

def get_apps(token):
    request = hockey_request('apps', token)
    response = urllib2.urlopen(request)
    outputJSON = response.read()
    output = json.loads(outputJSON)
    return output

def get_app_versions(token, appid):
    request = hockey_request('apps/' + appid + "/app_versions", token)
    response = urllib2.urlopen(request)
    outputJSON = response.read()
    output = json.loads(outputJSON)
    return output

def get_app_statistics(token, appid):
    request = hockey_request('apps/' + appid + "/statistics", token)
    response = urllib2.urlopen(request)
    outputJSON = response.read()
    output = json.loads(outputJSON)
    return output

if __name__ == '__main__':
    (user, token) = get_token()

    print get_app_statistics(token, '1ee03b2c845f45f7b7564123f5283409')
    # print [(a['title'], a['id']) for a in get_apps(token).get('apps')]
