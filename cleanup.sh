#!/bin/bash

umount /var/lib/glance/images
umount /var/lib/nova/instances
wipefs -af /dev/instance_vg/instance_lv
wipefs -af /dev/image_vg/image_lv
lvremove /dev/instance_vg/instance_lv
lvremove /dev/image_vg/image_lv
vgremove instance_vg
vgremove image_vg
pvremove /dev/sda1
pvremove /dev/sda2
vgreduce cinder-volumes /dev/sdb
pvremove /dev/sdb
fdisk /dev/sda <<EOF
d

d

w
EOF
rm -r -f /var/lib/glance/images
mv /var/lib/glance/images_1 /var/lib/glance/images
rm -r -f /var/lib/nova/instances
mv /var/lib/nova/instances_1 /var/lib/nova/instances

