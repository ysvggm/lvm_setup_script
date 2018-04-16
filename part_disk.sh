#!/bin/bash


fdisk $1 <<EOF
n
p
1

+$2
n
p
2


w
EOF

