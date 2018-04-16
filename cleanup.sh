#!/bin/bash

lvremove /dev/instance-vg/instance-lv
vgremove instance-vg
vgremove image-vg
pvremove /dev/sda1
pvremove /dev/sda2
vgreduce cinder-volumes /dev/sdb
pvremove /dev/sdb
fdisk /dev/sda <<EOF
d

d

w
EOF



