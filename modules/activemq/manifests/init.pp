class activemq {

  # activemq template variables for future automation use
  $activemq_host = "localhost"
  $activemq_url_path = "http://nexus.chotel.com/nexus/service/local/repositories/infrastructure/content/org/apache/activemq/apache-activemq/5.9.1-2"
  $activemq_rpm_file = "apache-activemq-5.9.1-2.rpm"

  exec { "activemq_install rpm":
    command => "/usr/bin/wget $activemq_url_path/$activemq_rpm_file -O /tmp/$activemq_rpm_file; /bin/rpm -Uvh /tmp/$activemq_rpm_file"
  }

  exec { "start enable activemq":
    command => "/etc/init.d/activemq start; /sbin/chkconfig --levels 2345 activemq on",
    require => Exec['activemq_install rpm']
  }

  file { "/etc/activemq/activemq.xml":
    replace => true,
    source => "puppet:///modules/activemq/activemq.xml",
    mode => "644",
    owner => "root",
    group => "root",
    require => Exec['start enable activemq']
  }

}
