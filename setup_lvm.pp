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

class setup_lvm{

  exec { "gethddlist":
    command => "/root/lvm_setup_script/gethddlist.py",
    logoutput => true,
  }  


  setup_vg{"instance": vg_name => "instance-vg", dev_path => "/dev/sdd"}

  setup_vg{"image": vg_name => "image-vg", dev_path => "/dev/md126"}
}



class { 'setup_lvm': }
