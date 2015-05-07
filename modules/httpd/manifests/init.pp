class httpd {
  package { 'httpd24':
    ensure => installed,
  }
  
  file { "/etc/httpd/conf/httpd.conf":
    replace => true,
    source => "puppet:///modules/httpd/httpd.conf",
    mode => "644",
    owner => "root",
    group => "root",
  }

  file { "/etc/httpd/conf.d/proxy.conf":
    replace => true,
    source => "puppet:///modules/httpd/proxy.conf",
    mode => "644",
    owner => "root",
    group => "root",
  }

  file { "/etc/httpd/conf.d/localhost.conf":
    replace => true,
    source => "puppet:///modules/httpd/localhost.conf",
    mode => "644",
    owner => "root",
    group => "root",
  }

  file { "/var/www":
    ensure => "directory",
    mode => "755",
    owner => "root",
    group => "root",
  }

  file { "/var/www/html":
    ensure => "directory",
    mode => "755",
    owner => "root",
    group => "root",
  }

  file { "/var/log/httpd":
    ensure => "directory",
    mode => "755",
    owner => "root",
    group => "root",
  }

  package { 'mod24_ssl':
    ensure => installed,
  }

  file { "/etc/httpd/conf.d/ssl.conf":
    replace => true,
    source => "puppet:///modules/httpd/ssl.conf",
    mode => "644",
    owner => "root",
    group => "root",
  }

  package { 'mod24_security':
    ensure => installed,
  }

  package { 'mod_security_crs':
    ensure => installed,
  }

  file { "/etc/httpd/conf.d/mod_security.conf":
    replace => true,
    source => "puppet:///modules/httpd/mod_security.conf",
    mode => "644",
    owner => "root",
    group => "root",
  }

  file { "/var/modsecurity":
    ensure => "directory",
    mode => "750",
    owner => "root",
    group => "apache",
  }

  file { "/var/modsecurity/audit":
    ensure => "directory",
    mode => "750",
    owner => "root",
    group => "apache",
  }

  file { "/var/modsecurity/data":
    ensure => "directory",
    mode => "750",
    owner => "root",
    group => "apache",
  }

  file { "/var/modsecurity/log":
    ensure => "directory",
    mode => "750",
    owner => "root",
    group => "apache",
  }

  file { "/var/modsecurity/tmp":
    ensure => "directory",
    mode => "750",
    owner => "root",
    group => "apache",
  }

  file { "/var/modsecurity/upload":
    ensure => "directory",
    mode => "750",
    owner => "root",
    group => "apache",
  }

  file { "/etc/httpd/conf.d/choice-infosec.conf":
    replace => true,
    source => "puppet:///modules/httpd/choice-infosec.conf",
    mode => "644",
    owner => "root",
    group => "root",
  }

  exec { "start_enable httpd":
    command => "/etc/init.d/httpd start; /sbin/chkconfig --levels 2345 httpd on",
  }

}
