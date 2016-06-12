#!/usr/bin/env python
# -*- coding: utf8 -*-

import os
import keychain
import requests  # see http://docs.python-requests.org/en/latest/user/quickstart/#quickstart for docs
import json

def get_token():
    return keychain.get_or_set_token("api.hockeyapp.net", "Please enter your Hockey API token")



def hockey_request(command, token, data = None, files = None, mode = None):
    url = "https://rink.hockeyapp.net/api/2/" + command
    headers = { 'X-HockeyAppToken' : token }
    if data:
        if mode == 'put':
            request = requests.put(url, data = data, headers = headers, files = files)
        else:
            request = requests.post(url, data = data, headers = headers, files = files)
    else:
        request = requests.get(url, headers = headers)
    return request



def response_as_json(request):
    output = request.json()
    return output



def get_apps(token):
    request = hockey_request('apps', token)
    return response_as_json(request)



def get_app_versions(token, appID):
    request = hockey_request('apps/' + appID + "/app_versions", token)
    return response_as_json(request)



def get_app_statistics(token, appID):
    request = hockey_request('apps/' + appID + "/statistics", token)
    return response_as_json(request)



def release_version(token, appID, versionID):
    # http://support.hockeyapp.net/kb/api/api-versions#-u-put-api-2-apps-app_id-app_versions-id-u-

    parameters = {
    'status' : 2,
    'notify' : True,
    }

    command = "apps/{0}/app_versions/{1}".format(appID, versionID)
    request = hockey_request(command, token, data = parameters, mode = 'put')
    response = request.text
    if request.status_code == 201:
        result = 0
    else:
        result = 1

    return (request.status_code, (request.status_code, response))



def upload_version(token, appID, appZip, dsymZip, notes = "", notes_type = 1, notify = False, status = 1):
    # http://support.hockeyapp.net/kb/api/api-versions#-u-post-api-2-apps-app_id-app_versions-upload-u-

    parameters = {
    'status' : status,
    'notify' : notify,
    'notes' : notes,
    'notes_type' : notes_type
    }
    files = {
    'ipa' : open(appZip, 'rb'),
    'dsym' : open(dsymZip, 'rb'),
    }

    command = "apps/{0}/app_versions/upload".format(appID)
    request = hockey_request(command, token, data = parameters, files = files)
    response = response_as_json(request)
    result = 0
    if response.get('errors'):
        result = 1

    return (result, response)




if __name__ == '__main__':
    token = get_token()

    print get_apps(token)

    # # Test list versions (https://rink.hockeyapp.net/manage/apps/258698/app_versions)
    # appID = '1ee03b2c845f45f7b7564123f5283409'
    # print get_app_versions(token, appID)

    # # Test upload for app version:
    # print upload_version(token, , 'fake.zip', 'fake.app.dSYM.zip')
