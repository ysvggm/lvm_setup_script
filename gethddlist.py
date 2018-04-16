#!/usr/bin/python
import subprocess
import json
import sys
from StringIO import StringIO
from socket import inet_aton,inet_ntoa
import struct
import re
from decimal import Decimal
import argparse
import os
import sys

def get_sata_hdd_list():
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
                str_hddlist = "hddlist:\n"
		hdd_list = []
                while i < len(out_lines):
                        device_strs = out_lines[i].split('  ')
                        dir_strs = out_lines[i+1].split('  ')
                        if dir_strs[2].find("0000:00:17") > 0:
                                hdd_count += 1
                                str_hddlist += "  - \"" + device_strs[len(device_strs)-1].strip() + "\"\n"
				hdd_list.append(device_strs[len(device_strs)-1])
                        i += 2
                print str_hddlist
		return hdd_list
        if len(err_string) > 0:
                print err_string
		return ""

def get_hdd_sector_number(hdd):
	p = subprocess.Popen("fdisk -l  " + hdd + " | grep -m 1 Disk | cut -d',' -f3 | cut -d' ' -f2", stdout=subprocess.PIPE, stderr=subprocess.PIPE ,shell=True)
        out, err = p.communicate()
        out_stringio = StringIO(out)
        out_string = out_stringio.read()
        err_stringio = StringIO(err)
        err_string = err_stringio.read()
        if len(out_string) > 0:
                sector_num = Decimal(out_string)
                print "hdd1_sector_num: " + str(sector_num)
        if len(err_string) > 0:
                print err_string

if __name__ == "__main__":
	hdd_list = get_sata_hdd_list()
	get_hdd_sector_number(hdd_list[0])
	
