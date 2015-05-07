# ssh module based on ssh salt state 
class ssh {

  package { 'openssh-server':
    ensure => "installed"
  }
  
  package { 'openssh-clients':
    ensure => "installed"
  }
  
  service { 'sshd':
    name => "sshd",
    enable => true,
    ensure => "running",
    require => Package["openssh-server"]
  }

  file { "/etc/ssh/ssh_config":
    notify  => Service["sshd"],
    replace => true,
    source => "puppet:///modules/ssh/ssh_config",
    mode => "0644",
    owner => "root",
    group => "root",
    require => Package["openssh-server"]
  }

  file { "/etc/ssh/sshd_config":
    notify  => Service["sshd"],
    replace => true,
    source => "puppet:///modules/ssh/sshd_config",
    mode => "0644",
    owner => "root",
    group => "root",
    require => Package["openssh-server"]
  }

  file { "/etc/ssh/sshd-banner":
    notify  => Service["sshd"],
    replace => true,
    source => "puppet:///modules/ssh/sshd-banner",
    mode => "0644",
    owner => "root",
    group => "root",
    require => Package["openssh-server"]
  }

  file { "/root/.ssh":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 0700,
  }

  file { "/root/.ssh/authorized_keys":
    replace => true,
    source => "puppet:///modules/ssh/authorized_keys",
    mode => "0400",
    owner => "root",
    group => "root",
    require => File["/root/.ssh"]
  }

}
