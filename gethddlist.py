#!/usr/bin/python
import subprocess
import json
import sys
from StringIO import StringIO
from socket import inet_aton,inet_ntoa
import struct
import re

import argparse
import os
import sys

if __name__ == "__main__":
	p = subprocess.Popen("lsscsi -v", stdout=subprocess.PIPE, stderr=subprocess.PIPE ,shell=True)
	out, err = p.communicate()
        out_stringio = StringIO(out)
        out_string = out_stringio.read()
        err_stringio = StringIO(err)
        err_string = err_stringio.read()
	if len(out_string) > 0:
		out_lines = out_string.splitlines(False)
		i = 0
		hdd_count = 0
		while i < len(out_lines):
			device_strs = out_lines[i].split('  ')
			dir_strs = out_lines[i+1].split('  ')
			if dir_strs[2].find("0000:00:17") > 0:
				hdd_count += 1
				print device_strs[len(device_strs)-1]
			i += 2
	if len(err_string) > 0:
		print err_string
