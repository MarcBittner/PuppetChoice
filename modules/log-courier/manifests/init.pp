# log-courier module based on log-courier salt state

class log-courier {

  $logcourier_dir = "log-courier-1.3"
  $logcourier_url_path = "https://github.com/driskell/log-courier/archive/"
  $logcourier_zip = "v1.3.zip"

  group {'log-courier':
    ensure => present,
  }

  user {'log-courier':
    ensure => present,
    gid => 'log-courier',
    shell => '/bin/bash',
    home => '/home/log-courier',
    managehome => 'true'
  }

  package { 'golang':
    ensure => installed
  }

  exec { "log-courier_install archive":
    command => "/bin/mkdir /sbin/log-courier; /usr/bin/wget $logcourier_url_path/$logcourier_zip -O /sbin/log-courier/$logcourier_zip; /usr/bin/unzip -d /sbin/log-courier /sbin/log-courier/$logcourier_zip; /bin/chown -R root:root /sbin/log-courier",
    unless => "/usr/bin/test -e /sbin/log-courier/$logcourier_zip"
  }

  file { "/sbin/log-courier/$logcourier_dir":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 0755,
    require => Exec["log-courier_install archive"]
  }

  exec { "make_log-courier compile":
    command => "/bin/bash -c 'cd /sbin/log-courier/$logcourier_dir; make && touch /sbin/log-courier/make_success'",
    require => Exec["log-courier_install archive"]
  }

  exec { "etc_log-courier directories":
    command => "/bin/bash -c 'mkdir /etc/log-courier; mkdir /etc/log-courier/config; mkdir /etc/log-courier/config/webserver; mkdir /etc/log-courier/config/appserver; mkdir /etc/log-courier/config/cassandra; mkdir /etc/log-courier/config/activemq; chmod -R 0755 /etc/log-courier; chown -R log-courier:log-courier /etc/log-courier'",
    require => Exec["make_log-courier compile"]
  }

 file { "/etc/log-courier/log-courier.crt":
    replace => true,
    source => "puppet:///modules/log-courier/log-courier.crt",
    mode => "0755",
    owner => "log-courier",
    group => "log-courier",
    require => Exec["etc_log-courier directories"]
  }

 file { "/etc/log-courier/config/webserver/log-courier.conf":
    replace => true,
    source => "puppet:///modules/log-courier/config/webserver/log-courier.conf",
    mode => "0755",
    owner => "log-courier",
    group => "log-courier",
    require => Exec["etc_log-courier directories"]
  }

 file { "/etc/log-courier/config/appserver/log-courier.conf":
    replace => true,
    source => "puppet:///modules/log-courier/config/appserver/log-courier.conf",
    mode => "0755",
    owner => "log-courier",
    group => "log-courier",
    require => Exec["etc_log-courier directories"]
  }

 file { "/etc/log-courier/config/cassandra/log-courier.conf":
    replace => true,
    source => "puppet:///modules/log-courier/config/cassandra/log-courier.conf",
    mode => "0755",
    owner => "log-courier",
    group => "log-courier",
    require => Exec["etc_log-courier directories"]
  }

 file { "/etc/log-courier/config/activemq/log-courier.conf":
    replace => true,
    source => "puppet:///modules/log-courier/config/activemq/log-courier.conf",
    mode => "0755",
    owner => "log-courier",
    group => "log-courier",
    require => Exec["etc_log-courier directories"]
  }

 file { "/etc/init.d/log-courier":
    replace => true,
    source => "puppet:///modules/log-courier/log-courier",
    mode => "0755",
    owner => "root",
    group => "root",
    require => Exec["make_log-courier compile"]
  }

}
