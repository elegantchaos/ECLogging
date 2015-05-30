#!/usr/bin/env python
# -*- coding: utf8 -*-

import urllib
import urllib2
import keychain

def set_token(token):
    keychain.set_internet_password("hipchat-script", token, "api.hipchat.com")

def get_token():
    return keychain.get_internet_password("api.hipchat.com")

def hipchat_request(command, token, data):
    url = "https://api.hipchat.com/v2/" + command + "?auth_token=" + token
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

