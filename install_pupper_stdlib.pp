class install_lib{

  $module_stdlib = 'puppetlabs-stdlib'
  exec { 'puppet_module_stdlib':
    command => "puppet module install ${module_stdlib}",
    unless  => "puppet module list | grep ${module_stdlib}",
    path    => ['/bin','/usr/bin','/sbin','/usr/sbin', '/opt/puppetlabs/bin'],
    logoutput => true
  }
}

class { 'install_lib': }
