#!/bin/bash
./gethddlist.py >> ./hieradata/defaults.yaml
sed -i 's/.*:datadir:.*/  :datadir: \/root\/lvm_setup_script\/hieradata/g' /etc/puppet/hiera.yaml
systemctl restart puppet.service
systemctl restart puppetagent.service
puppet apply -v setup_lvm.pp
ifconfig enp5s0 | grep -e '\w\w:\w\w:\w\w:\w\w:\w\w:\w\w' -o | xargs -i sed -i 's/hwaddr=\w\w:\w\w:\w\w:\w\w:\w\w:\w\w/hwaddr={}/g' /etc/sysconfig/network-scripts/ifcfg-br-ex
