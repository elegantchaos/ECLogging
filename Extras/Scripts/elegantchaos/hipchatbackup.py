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
import time

def text_transcript(messages):
    transcript = u""
    for item in messages:
        person = item["from"]
        dateString = item["date"]
        date = dateutil.parser.parse(dateString)
        transcript = u"{0} {1}: {2}\n".format(date.strftime('%H:%m.%S'), person["name"], item["message"]) + transcript

    return transcript

def process_person_date(person, token, startDate, outputPath):
    startIndex = 0
    pageSize = 1000
    endDate = startDate - datetime.timedelta(1)
    messages = []
    while True:
        time.sleep(4) # requests are rate limited, so pause for a bit
        request = hipchat.private_history_request2(person, token, startIndex = startIndex, maxResults = pageSize, startDate = startDate, endDate = endDate)
        try:
            response = urllib2.urlopen(request)
            output = response.read()
            info = json.loads(output)
            items = info['items']
            itemCount = len(items)
            if itemCount == 0:
                break

            messages += items
            startIndex += itemCount

        except urllib2.HTTPError as e:
            print e
            break

    messageCount = len(messages)
    key = endDate.strftime('%Y-%m-%d')
    print "Found {0} messages for {1}".format(messageCount, key)
    if messageCount > 0:
        encoded = json.dumps(messages, indent=1)
        path = os.path.join(outputPath, key + ".json")
        shell.write_text(path, encoded)

        transcript = text_transcript(messages)
        path = os.path.join(outputPath, key + ".txt")
        shell.write_text(path, transcript)


def process_person(person, token):
    home = os.path.expanduser('~')
    outputPath = os.path.join(home, 'Dropbox/Personal/Chat/HipChat/Conversations', person)
    if not os.path.exists(outputPath):
        os.makedirs(outputPath)

    startDate = datetime.datetime.now() + datetime.timedelta(1)
    startDate = datetime.datetime(startDate.year, startDate.month, startDate.day)
    earliestDate = datetime.datetime(2014, 1, 1)

    while startDate > earliestDate:
        process_person_date(person, token, startDate, outputPath)
        startDate = startDate - datetime.timedelta(1)

person = sys.argv[1]
(user, token) = hipchat.get_token()
process_person(person, token)
