class 389server {

  user { "ds-user":
    ensure => "present",
    comment => "383server User",
    shell => "/bin/false",
    home => "/usr/share/ds-user",
  } ->

  file { "/etc/sysctl.conf":
    replace => true,
    source => "puppet:///modules/389server/sysctl.conf",
    mode => "644",
    owner => "root",
    group => "root",
  } ->

  file { "/etc/security/limits.conf":
    replace => true,
    source => "puppet:///modules/389server/limits.conf",
    mode => "644",
    owner => "root",
    group => "root",
  } ->

  file { "/etc/profile":
    replace => true,
    source => "puppet:///modules/389server/profile",
    mode => "644",
    owner => "root",
    group => "root",
  } ->

  file { "/etc/pam.d/login":
    replace => true,
    source => "puppet:///modules/389server/login",
    mode => "644",
    owner => "root",
    group => "root",
  } ->

  package { '389-ds':
    name => "389-ds",
    ensure => installed,
  }

}
