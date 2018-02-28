#!/usr/bin/env python
# -*- coding: utf8 -*-

# --------------------------------------------------------------------------
#  Copyright 2017 Elegant Chaos Limited. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

# pytest tests: run with py.test (install pytest with: pip install pytest) 

import keychain
import string
import random

def id_generator(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

def test_get_set_token():
    passwordIn = id_generator()
    keychain.set_internet_password('test-user', passwordIn, 'test-site')
    (user, password) = keychain.get_internet_password('test-site')
    assert(user == 'test-user')
    assert(password == passwordIn)
