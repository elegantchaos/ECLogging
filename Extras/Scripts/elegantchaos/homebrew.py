#!/usr/bin/env python
# -*- coding: utf8 -*-

# --------------------------------------------------------------------------
#  Copyright 2017 Elegant Chaos Limited. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

import subprocess
import shell

def install_if_missing(tool):
    ok = shell.got_tool(tool)
    if not ok:
        print("Installing the {0} command line tool...".format(tool))    
        subprocess.call(["brew", "install", tool])
