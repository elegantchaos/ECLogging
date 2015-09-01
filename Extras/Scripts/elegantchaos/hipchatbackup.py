#!/usr/bin/env python
# -*- coding: utf8 -*-

import json
import hipchat
import urllib2
import sys

person = sys.argv[1]

(user, token) = hipchat.get_token()
request = hipchat.private_history_request(person, token, maxResults = 500)
response = urllib2.urlopen(request)
output = response.read()
info = json.loads(output)
print info.keys()
print info['startIndex']
print info['maxResults']
items = info['items']
for item in items:
    person = item["from"]
    print u"{0}: {1}".format(person["name"], item["message"])
