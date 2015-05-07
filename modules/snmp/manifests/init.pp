# snmp module based on snmp salt state 
class snmp {

  package { 'net-snmp':
    ensure => installed
  }
  
  service { 'snmpd':
    name => "snmpd",
    enable => true,
    ensure => running
  }

  file { "/etc/snmp/snmpd.conf":
    notify  => Service["snmpd"],
    replace => true,
    source => "puppet:///modules/snmp/snmpd.conf",
    mode => "0644",
    owner => "root",
    group => "root"
  }

  file { "/etc/snmp/snmpd.local.conf":
    notify  => Service["snmpd"],
    replace => true,
    source => "puppet:///modules/snmp/snmpd.local.conf",
    mode => "0644",
    owner => "root",
    group => "root"
  }

}
