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

DAYS_WITHOUT_MESSAGE_BEFORE_GIVING_UP = 30
PAGE_SIZE = 1000

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
    endDate = startDate - datetime.timedelta(1)
    messages = []
    while True:
        time.sleep(4) # requests are rate limited, so pause for a bit
        request = hipchat.private_history_request2(person, token, startIndex = startIndex, maxResults = PAGE_SIZE, startDate = startDate, endDate = endDate)
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

    return messageCount

def process_person(person, token):
    personName = person['name']
    personID = person['id']

    print "Fetching chat log for {0}".format(personName)
    home = os.path.expanduser('~')
    outputPath = os.path.join(home, 'Dropbox/Personal/Chat/HipChat/Conversations', personName)
    if not os.path.exists(outputPath):
        os.makedirs(outputPath)

    startDate = datetime.datetime.now() + datetime.timedelta(1)
    startDate = datetime.datetime(startDate.year, startDate.month, startDate.day)
    earliestDate = datetime.datetime(2014, 10, 1)

    consecutiveFailureCount = 0
    while startDate > earliestDate:
        messageCount = process_person_date(personID, token, startDate, outputPath)
        if messageCount > 0:
            consecutiveFailureCount = 0
        else:
            consecutiveFailureCount += 1

        # if we get more than a given number of days with no messages, we assume we've hit the
        # earliest message and give up
        if consecutiveFailureCount > DAYS_WITHOUT_MESSAGE_BEFORE_GIVING_UP:
            exit

        startDate = startDate - datetime.timedelta(1)

def get_user(user, token):
    request = hipchat.user_request(user, token)
    info = hipchat.fetch_as_json(request)
    return info

def get_user_list(token):
    request = hipchat.users_request(token)
    info = hipchat.fetch_as_json(request)
    people = info['items']
    return people

def main():
    (user, token) = hipchat.get_token()

    if len(sys.argv) == 2:
        email = sys.argv[1]
        people = [get_user(email, token)]
    else:
        people = get_user_list(token)

    for person in people:
        process_person(person, token)


main()
