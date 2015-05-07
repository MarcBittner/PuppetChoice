class tomcat {
  $tomcat_name                  = "apache-tomcat"
  $tomcat_version               = "7.0.55"
  $tomcat_home                  = "/usr/share/tomcat"
  $jmxtrans_agent_name          = "jmxtrans-agent"
  $jmxtrans_agent_version       = "1.0.8"
  $jmxtrans_agent_path          = "${tomcat_home}/${jmxtrans_agent_name}"
  $jmxtrans_agent_jar_target    = "${jmxtrans_agent_path}/${jmxtrans_agent_name}-${jmxtrans_agent_version}.jar"
  $jmxtrans_agent_config_target = "${jmxtrans_agent_path}/${jmxtrans_agent_name}.xml"


  group { "tomcat_group":
    name => "tomcat",
    ensure => present,
    gid => 91,
  } ->

  user { "tomcat":
    ensure => "present",
    comment => "Apache Tomcat",
    shell => "/bin/false",
    home => $tomcat_home,
    uid => "91",
    gid => "91",
    groups => "tomcat",
  } ->

  archive { $tomcat_name:
    source => "http://nexus.chotel.com/nexus/service/local/repositories/infrastructure/content/org/apache/tomcat/apache-tomcat/$tomcat_version/$tomcat_name-$tomcat_version.tgz",
    extract_dir => "/usr/share",
    archive_type => "tgz",
    owner => "tomcat",
    group => "tomcat"
  } ->

  file { $tomcat_home:
    ensure => "link",
    target => "$tomcat_name-$tomcat_version",
    force => "true",
  } ->

  file { "${tomcat_home}/conf/context.xml":
    replace => true,
    source => "puppet:///modules/tomcat/conf/context.xml",
    mode => "640",
    owner => "tomcat",
    group => "tomcat",
  } ->

  file { "/etc/init.d/prep-for-launch":
    replace => true,
    source => "puppet:///modules/tomcat/prep-for-launch",
    mode => "755",
    owner => "root",
    group => "root",
  } ->

  file { "${tomcat_home}/bin/setenv.sh":
    replace => true,
    content => template('tomcat/setenv.sh.erb'),
    mode => "755",
    owner => "tomcat",
    group => "tomcat",
  } ->

  file { $jmxtrans_agent_path:
    ensure  => "directory",
    owner   => "tomcat",
    group   => "tomcat",
    require => [ File[$tomcat_home],
                 User["tomcat"] ],
  }

  file { $jmxtrans_agent_config_target:
    source  => "puppet:///modules/tomcat/${jmxtrans_agent_name}/${jmxtrans_agent_name}.xml",
    mode    => "640",
    owner   => "tomcat",
    group   => "tomcat",
    require => [ File[$jmxtrans_agent_path],
                 User["tomcat"] ],
  }

  exec { $jmxtrans_agent_jar_target:
    command => "/usr/bin/curl -sO http://nexus.chotel.com/nexus/service/local/repositories/infrastructure/content/org/jmxtrans/agent/${jmxtrans_agent_name}/${jmxtrans_agent_version}/${jmxtrans_agent_name}-${jmxtrans_agent_version}.jar",
    cwd     => $jmxtrans_agent_path,
    require => File[$jmxtrans_agent_path],
  }

  file { $jmxtrans_agent_jar_target:
    ensure  => present,
    mode    => "640",
    owner   => "tomcat",
    group   => "tomcat",
    require => [ Exec[$jmxtrans_agent_jar_target],
                 User["tomcat"] ],
  }

  file { "/etc/init.d/tomcat":
    replace => true,
    source => "puppet:///modules/tomcat/tomcat",
    mode => "755",
    owner => "root",
    group => "root",
  } ->

  file { "/usr/bin/deploy.sh":
    replace => true,
    source => "puppet:///modules/tomcat/deploy.sh",
    mode => "755",
    owner => "root",
    group => "root",
  } ->

  file { "/var/log/tomcat":
    ensure => "link",
    target => "${tomcat_home}/logs",
    force => "true",
  } ->

  file { "/etc/tomcat":
    ensure => "link",
    target => "${tomcat_home}/conf",
    force => "true",
  } ->

  service { 'tomcat':
    name => "tomcat",
    enable => true,
    ensure => running,
    require => [ File[$jmxtrans_agent_jar_target],
                 File[$jmxtrans_agent_config_target] ],
  }
}
