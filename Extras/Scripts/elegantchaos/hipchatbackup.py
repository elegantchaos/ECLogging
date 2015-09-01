#!/usr/bin/env python
# -*- coding: utf8 -*-

import json
import hipchat
import urllib2
import sys

person = sys.argv[1]

(user, token) = hipchat.get_token()
startIndex = 0
pageSize = 1000
while True:
    request = hipchat.private_history_request2(person, token, startIndex = startIndex, maxResults = pageSize)
    response = urllib2.urlopen(request)
    output = response.read()
    info = json.loads(output)
    print info.keys()
    print info['startIndex']
    print info['maxResults']
    items = info['items']
    if len(items) < pageSize:
        break
    startIndex += pageSize
# for item in items:
#     person = item["from"]
#     date = item["date"]
#     print u"{0} {1}: {2}".format(date, person["name"], item["message"])
