# authconfig module based on authconfig salt state 
class authconfig {

  package { 'authconfig':
    ensure => installed,
  }
  
  file { "/etc/pam.d/system-auth-ac":
    replace => true,
    source => "puppet:///modules/authconfig/system-auth-ac",
    mode => "0644",
    owner => "root",
    group => "root",
  }

  file { "/etc/pam.d/password-auth-ac":
    replace => true,
    source => "puppet:///modules/authconfig/password-auth-ac",
    mode => "0644",
    owner => "root",
    group => "root",
  }

}
