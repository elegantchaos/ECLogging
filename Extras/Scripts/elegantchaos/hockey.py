#!/usr/bin/env python
# -*- coding: utf8 -*-

import os
import keychain
import requests
import json

def set_token(token):
    keychain.set_internet_password("hockey-api-key", token, "api.hockeyapp.net")

def get_token():
    return keychain.get_internet_password("api.hockeyapp.net")

def hockey_request(command, token, data = None):
    url = "https://rink.hockeyapp.net/api/2/" + command
    headers = { 'X-HockeyAppToken' : token }
    if data:
        request = requests.post(url, data = data, headers = headers)
    else:
        request = requests.get(url, headers = headers)
    return request

def response_as_json(request):
    outputJSON = request.text
    output = json.loads(outputJSON)
    return output

def get_apps(token):
    request = hockey_request('apps', token)
    return response_as_json(request)

def get_app_versions(token, appid):
    request = hockey_request('apps/' + appid + "/app_versions", token)
    return response_as_json(request)

def get_app_statistics(token, appid):
    request = hockey_request('apps/' + appid + "/statistics", token)
    return response_as_json(request)

def upload_version(token, appid, appZip, dsymZip):
    appData = open(appZip, 'rb')
    dsymData = open(dsymZip, 'rb')
    parameters = {
    'ipa' : appData,
    'dsym' : dsymData
    }
    request = hockey_request('apps/' + appid + '/app_versions/upload', token, parameters)
    return response_as_json(request)

if __name__ == '__main__':
    (user, token) = get_token()

    print upload_version(token, '1ee03b2c845f45f7b7564123f5283409', 'Vault/staging/sketch-3.5-18401.zip', 'Vault/staging/sketch-3.5-18401.dSYM.zip')
