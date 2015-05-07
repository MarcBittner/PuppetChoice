# /etc/puppet/modules/sudo/manifests/init.pp

class sudo {

  package { 'sudo':
    ensure => installed,
  }
  
  file { "/etc/sudoers":
    replace => true,
    source => "puppet:///modules/sudo/sudoers",
    mode  => '0440',
    owner => "root",
    group => "root",
  }

  file { "/etc/sudoers.d/developer":
    replace => true,
    source => "puppet:///modules/sudo/developer",
    mode  => '0440',
    owner => "root",
    group => "root",
  }

}
