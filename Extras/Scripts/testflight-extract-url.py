#!/usr/bin/env python

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

## Python script to extract the URL from the json results returned by TestFlight

import json
import sys

result = json.load(sys.stdin)
url = result['config_url']

print url
