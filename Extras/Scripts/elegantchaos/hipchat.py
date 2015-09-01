#!/usr/bin/env python
# -*- coding: utf8 -*-

import urllib
import urllib2
import keychain
import json

def set_token(token):
    keychain.set_internet_password("hipchat-script", token, "api.hipchat.com")

def get_token():
    return keychain.get_internet_password("api.hipchat.com")

def hipchat_request(command, token, data, parameters = None):
    url = "https://api.hipchat.com/v2/" + command + "?auth_token=" + token
    if parameters:
        url += "&" + parameters
    request = urllib2.Request(url, data)
    return request

def hipchat_room_request(command, room, token, data):
    room_command = "room/" + room + "/" + command
    return hipchat_request(room_command, token, data)

def hipchat_message_request(message, color, room, token, mode):
    data = urllib.urlencode({ "message" : message, "color" : color, "message_format" : mode})
    return hipchat_room_request("notification", room, token, data)

def hipchat_message(message, colour, room, token, mode):
    request = hipchat_message_request(message, colour, room, token, mode)
    response = urllib2.urlopen(request)
    return response.read()

def private_history_request(user, token, maxResults = 200):
    history_command = "user/{0}/history/latest".format(user)
    request = hipchat_request(history_command, token, None, "max-results={0}".format(maxResults))
    return request

if __name__ == '__main__':
    (user, token) = get_token()
    request = private_history_request("ale@bohemiancoding.com", token)
    response = urllib2.urlopen(request)
    output = response.read()
    info = json.loads(output)
    print info.keys()
    print info['startIndex']
    items = info['items']
    for item in items:
        print item["message"]
