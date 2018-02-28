#!/usr/bin/env python
# -*- coding: utf8 -*-

# --------------------------------------------------------------------------
#  Copyright 2017 Elegant Chaos Limited. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

import urllib
import urllib2
import keychain
import json
import datetime

def get_token():
    return keychain.get_or_set_token("api.hipchat.com", "Please enter your hipchat token")

def hipchat_request(command, token, data, parameters = None):
    url = "https://api.hipchat.com/v2/" + command + "?auth_token=" + token
    if parameters:
        url += "&" + parameters
    request = urllib2.Request(url, data)
    return request

def hipchat_room_request(command, room, token, data):
    room_command = "room/" + room + "/" + command
    return hipchat_request(room_command, token, data)

def hipchat_message_request(message, color, room, token, mode, notify):
    info = { "message" : message, "color" : color, "message_format" : mode, "notify" : notify }
    data = urllib.urlencode(info)
    return hipchat_room_request("notification", room, token, data)

def hipchat_message(message, colour, room, token, mode, notify = "true"):
    request = hipchat_message_request(message, colour, room, token, mode, notify)
    response = urllib2.urlopen(request)
    return response.read()

def private_history_latest_request(user, token, maxResults = 200):
    history_command = "user/{0}/history/latest".format(user)
    request = hipchat_request(history_command, token, None, "max-results={0}&timezone=GB".format(maxResults))
    return request

def private_history_request(user, token, startIndex = 0, maxResults = 200, startDate = datetime.datetime.now(), endDate = None):
    history_command = "user/{0}/history".format(user)
    if startDate == 'recent':
        startDateString = startDate
    else:
        startDateString = startDate.strftime('%Y-%m-%dT%H:%M:%S+00:00')

    if endDate:
        endDateString = endDate.strftime('%Y-%m-%dT%H:%M:%S+00:00')
    else:
        endDateString = 'null'

    parameters = "reverse=false&start-index={0}&max-results={1}&date={2}&end-date={3}&timezone=GB".format(startIndex, maxResults, startDateString, endDateString) #
    request = hipchat_request(history_command, token, None, parameters)
    return request

def user_request(user, token):
    user_command = "user/{0}".format(user)
    print user_command
    request = hipchat_request(user_command, token, None, None)
    return request

def users_request(token):
    request = hipchat_request('user', token, None, None)
    return request

def fetch_as_json(request):
    response = urllib2.urlopen(request)
    output = response.read()
    processed = json.loads(output)
    return processed




if __name__ == '__main__':
    print get_token()
