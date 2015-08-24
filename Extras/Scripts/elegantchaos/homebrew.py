#!/usr/bin/env python
# -*- coding: utf8 -*-

import subprocess
import shell

def install_if_missing(tool):
    ok = shell.got_tool(tool)
    if not ok:
        print("Installing the {0} command line tool...".format(tool))    
        subprocess.call(["brew", "install", tool])