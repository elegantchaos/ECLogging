#!/usr/bin/env python
# -*- coding: utf8 -*-

import json
import hipchat
import urllib2
import sys
import dateutil.parser
import shell
import os
import datetime


def add_item(item, messages):
    person = item["from"]
    dateString = item["date"]
    date = dateutil.parser.parse(dateString)
    key = "{0}-{1}-{2}".format(date.year, date.month, date.day)
    dayItems = messages.get(key)
    if not dayItems:
        dayItems = []
        messages[key] = dayItems

    dayItems += [item]

    #print u"{0} {1}: {2}".format(dateString, person["name"], item["message"])

def process_person_date(person, token, startDate, messages):
    startIndex = 0
    pageSize = 100
    endDate = startDate - datetime.timedelta(1)
    print startDate

    while True:
        request = hipchat.private_history_request2(person, token, startIndex = startIndex, maxResults = pageSize, startDate = startDate, endDate = endDate)
        response = urllib2.urlopen(request)
        output = response.read()
        info = json.loads(output)
        items = info['items']
        itemCount = len(items)
        if itemCount == 0:
            print info.keys()
            print info['startIndex']
            print info['maxResults']
            print info['links']
            break
        for item in items:
            add_item(item, messages)
        print itemCount
        startIndex += itemCount

def process_person(person, token):
    messages = {}
    outputPath = os.path.join('conversations', person)
    if not os.path.exists(outputPath):
        os.mkdir(outputPath)

    startDate = datetime.datetime.now()
    earliestDate = datetime.datetime(2015, 9, 1)

    while startDate > earliestDate:
        process_person_date(person, token, startDate, messages)
        startDate = startDate - datetime.timedelta(1)

    for key in messages:
        data = messages[key]
        encoded = json.dumps(data, indent=1)
        path = os.path.join(outputPath, key + ".json")
        shell.write_text(path, encoded)

person = sys.argv[1]
(user, token) = hipchat.get_token()
process_person(person, token)
