#!/usr/bin/env python
# -*- coding: utf8 -*-

import urllib
import urllib2
import keychain
import json
import datetime

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

def private_history_request2(user, token, startIndex = 0, maxResults = 200, startDate = datetime.datetime.now(), endDate = None):
    history_command = "user/{0}/history".format(user)
    startDateString = startDate.strftime('%Y-%m-%dT%H:%M')
    if endDate:
        endDateString = endDate.strftime('%Y-%m-%dT%H:%M')
    else:
        endDateString = "null"

    parameters = "reverse=false&start-index={0}&max-results={1}&date={2}&end-date={3}".format(startIndex, maxResults, startDateString, endDateString) #
    request = hipchat_request(history_command, token, None, parameters)
    return request
