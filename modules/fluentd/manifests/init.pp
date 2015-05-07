class fluentd {

  $url_path = "https://nexus.chotel.com/nexus/service/local/repositories/thirdparty/content/com/fluentd/fluentd/2.2.0"
  $rpm_file = "fluentd-2.2.0.rpm"

  exec { "fluentd install":
    command => "/usr/bin/wget --no-check-certificate $url_path/$rpm_file -O /tmp/$rpm_file; /bin/rpm -Uvh /tmp/$rpm_file"
  }

  exec { "fluentd-plugin-elasticsearch install":
    command => "/usr/sbin/td-agent-gem install fluent-plugin-elasticsearch",
    require => Exec['fluentd install']
  }

  file { "/etc/sysctl.conf":
    replace => true,
    source => "puppet:///modules/fluentd/sysctl.conf",
    mode => "644",
    owner => "root",
    group => "root",
    require => Exec['fluentd-plugin-elasticsearch install']
  }

  file { "/etc/security/limits.conf":
    replace => true,
    source => "puppet:///modules/fluentd/limits.conf",
    mode => "644",
    owner => "root",
    group => "root",
    require => File['/etc/sysctl.conf']
  }

  file { "/etc/td-agent/td-agent.conf":
    replace => true,
    source => "puppet:///modules/fluentd/td-agent.conf",
    mode => "644",
    owner => "root",
    group => "root",
    require => File['/etc/security/limits.conf']
  }

  exec { "start fluentd":
    command => "/etc/init.d/td-agent start; /sbin/chkconfig --levels 2345 td-agent on",
    require => File['/etc/td-agent/td-agent.conf']
  }

}
