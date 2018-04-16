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

define setup_lv(
  $vg_name,
  $lv_name,
){
  exec { "lvcreate -l 100%FREE -n ${lv_name} ${vg_name}":
    path        => ['/bin','/usr/bin','/sbin','/usr/sbin'],
    onlyif      => "vgdisplay | grep ${vg_name}",
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

define append_if_no_such_line($file, $line){
  exec { "echo '$line' >> '$file'":
    path        => ['/bin','/usr/bin','/sbin','/usr/sbin'],
    unless => "grep -Fx '$line' '$file'",
  }
}

define move_folder($old_pos, $new_pos){
  exec { "mv $old_pos $new_pos":
    path        => ['/bin','/usr/bin','/sbin','/usr/sbin'],
    unless => "test -d $new_pos",
  }
}


define new_folder(
  $path,
  $user,
  $group,
  $type
){
  exec { "mkdir $path && chown $user:$group $path && chcon -u system_u -r object_r -t $type -l s0 $path":
    path        => ['/bin','/usr/bin','/sbin','/usr/sbin'],
    unless => "test -d $path",
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
        $instance_vg_name = "instance_vg"
        $instance_lv_name = "instance_lv"
        $instance_mount_point = "/var/lib/nova/instances"
        setup_vg{"instance": vg_name => "${instance_vg_name}", dev_path => "${hdd1}1"}
        setup_lv{"instance-lv": vg_name => "${instance_vg_name}", lv_name => $instance_lv_name}
	append_if_no_such_line{"instance-lv": file => "/etc/fstab", line => "/dev/mapper/${instance_vg_name}-${instance_lv_name}	${instance_mount_point}  xfs     defaults        0       0"}
        move_folder{"instance-lv": old_pos => "${instance_mount_point}", new_pos => "${instance_mount_point}_1"}
        new_folder{"instance-lv": path => "${instance_mount_point}", user => "nova", group => "nova", type => "nova_var_lib_t"}
        $image_vg_name = "image_vg"
        $image_lv_name = "image_lv"
        $image_mount_point = "/var/lib/glance/images"
        setup_vg{"image": vg_name => "${image_vg_name}", dev_path => "${hdd1}2"}
        setup_lv{"image-lv": vg_name => "${image_vg_name}", lv_name => "image-lv"}
	append_if_no_such_line{"image-lv": file => "/etc/fstab", line => "/dev/mapper/${image_vg_name}-${image_lv_name}	${image_mount_point}  xfs     defaults        0       0"}
        move_folder{"image-lv": old_pos => "${image_mount_point}", new_pos => "${image_mount_point}_1"}
        new_folder{"image-lv": path => "${image_mount_point}", user => "glance", group => "glance", type => "glance_var_lib_t"}
        add_hdd_to_vg{"volume": vg_name => "cinder-volumes", dev_path => "${hddlist[1]}" }
      }
    8: {}
  }

  #exec { "/root/lvm_setup_script/part_disk.sh ${hddlist[0]} ${partition1_sector_num}":
  #  logoutput => true,
  #}


}



class { 'setup_lvm': }
