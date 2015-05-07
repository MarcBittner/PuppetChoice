# ntp module based on ntp salt state 
class ntp {

  package { 'ntp':
    ensure => installed
  }
  
  service { 'ntpd':
    name => "ntpd",
    enable => true,
    ensure => running
  }

  file { "/etc/ntp.conf":
    notify  => Service["ntpd"],
    source => "puppet:///modules/ntp/ntp.conf",
    replace => true,
    mode => "0640",
    owner => "root",
    group => "root"
  }

}
