define setup_vg(
  $vg_name,
  $dev_path,
){
  exec { "vgcreate ${vg_name} ${dev_path}":
    path        => ['/bin','/usr/bin','/sbin','/usr/sbin'],
    unless      => "vgdisplay | grep ${vg_name}",
    logoutput => true,
  }
}

define add_hdd_to_vg(
  $vg_name,
  $dev_path,
){
  exec { "vgextend ${vg_name} ${dev_path}":
    path        => ['/bin','/usr/bin','/sbin','/usr/sbin'],
    onlyif      => "vgdisplay | grep ${vg_name}",
    logoutput => true,
  }
}



class setup_lvm{

  $module_stdlib = 'puppetlabs-stdlib'
  exec { 'puppet_module_stdlib':
    command => "puppet module install ${module_stdlib}",
    unless  => "puppet module list | grep ${module_stdlib}",
    path    => ['/bin', '/opt/puppetlabs/bin']
  }

#  exec { "gethddlist":
#    command => "/root/lvm_setup_script/gethddlist.py",
#    logoutput => true,
#  }  

  $hddlist = hiera('hddlist')
  $total_num = $hddlist.length
  $partition1_sector_num = hiera('hdd1_sector_num')/2
  notify { "We have ${total_num} disks, hdd1 is ${hddlist[0]}, part1_sector_num is ${partition1_sector_num}":  }

  case $total_num {
    2:{
        exec { "/root/lvm_setup_script/part_disk.sh ${hddlist[0]} ${partition1_sector_num}":
          logoutput => true,
        }
        $hdd1 = $hddlist[0]
        setup_vg{"instance": vg_name => "instance-vg", dev_path => "${hdd1}1"}
        setup_vg{"image": vg_name => "image-vg", dev_path => "${hdd1}2"}
        add_hdd_to_vg{"volume": vg_name => "cinder-volumes", dev_path => "${hddlist[1]}" }
      }
    8: {}
  }

  #exec { "/root/lvm_setup_script/part_disk.sh ${hddlist[0]} ${partition1_sector_num}":
  #  logoutput => true,
  #}


}



class { 'setup_lvm': }
