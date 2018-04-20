#!/bin/bash
echo "version 1.1"
./gethddlist.py >> ./hieradata/defaults.yaml
sed -i 's/.*:datadir:.*/  :datadir: \/root\/lvm_setup_script\/hieradata/g' /etc/puppet/hiera.yaml
systemctl restart puppet.service
systemctl restart puppetagent.service
puppet apply -v setup_lvm.pp 2>err.txt
size="$(wc -c < err.txt)"
echo $size
if [ $size -gt 0 ]; then
        echo "Errors are detected. Please check err.txt"
        exit 1
fi

ifconfig enp5s0 | grep -e '\w\w:\w\w:\w\w:\w\w:\w\w:\w\w' -o | xargs -i sed -i 's/hwaddr=\w\w:\w\w:\w\w:\w\w:\w\w:\w\w/hwaddr={}/g' /etc/sysconfig/network-scripts/ifcfg-br-ex
