class collectd {

  package { 'collectd':
    ensure => installed,
  }

  file { 'collectd.conf':
    name => '/etc/collectd.conf',
    source  => 'puppet:///modules/collectd/collectd.conf',
    replace => true,
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    require => Package['collectd'],
  }

  service { 'collectd':
    enable  => false,
    ensure  => stopped,
    require => File['collectd.conf'],
  }

}
