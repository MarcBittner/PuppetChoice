# rsyslog module based on rsyslog salt state 
class rsyslog {

  package { 'rsyslog':
    ensure => installed
  }
  
  service { 'rsyslog':
    name => "rsyslog",
    enable => true,
    ensure => running
  }

  file { "/etc/rsyslog.conf":
    notify  => Service["rsyslog"],
    replace => true,
    source => "puppet:///modules/rsyslog/rsyslog.conf",
    mode => "0644",
    owner => "root",
    group => "root"
  }

}
