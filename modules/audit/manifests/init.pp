# audit module based on audit salt state 
class audit {

  package { 'audit':
    ensure => installed,
  }
  
  service { 'auditd':
    name => "auditd",
    enable => true,
    ensure => running,
  }

  file { "/etc/audit/audit.rules":
    replace => true,
    source => "puppet:///modules/audit/audit.rules",
    mode => "0640",
    owner => "root",
    group => "root",
  }

}
