class elk::elasticsearch {

  # Set our global variables for Elasticsearch
  # - These may be used in the puppet module, or templates.
  $elasticsearch_cluster_name = "logger"

  # Setup the ElasticSearch RPM repo for Yum
  yumrepo { 'elasticsearch_repo':
    baseurl => 'http://packages.elasticsearch.org/elasticsearch/1.4/centos',
    descr => "Elasticsearch yum repository for 1.4.x packages",
    enabled => 1,
    gpgcheck => 1,
    gpgkey => 'https://packages.elasticsearch.org/GPG-KEY-elasticsearch'
  }

  # Update the package list
  exec { 'yum_update_elasticsearch_repo':
    command => '/usr/bin/yum update',
    require => Yumrepo['elasticsearch_repo']
  }

  # Install the ElasticSearch RPM
  package { 'elasticsearch':
    ensure => '1.4.4-1',
    require => Exec['yum_update_elasticsearch_repo']
  }

  # Install ElasticSearch plugin: aws
  exec { 'elasticsearch_plugin aws':
    command => '/usr/share/elasticsearch/bin/plugin --install elasticsearch/elasticsearch-cloud-aws/2.4.1',
    unless => "/usr/bin/test -e /usr/share/elasticsearch/plugins/cloud-aws",
    require => Package['elasticsearch']
  }

  # Install ElasticSearch plugin: kopf
  exec { 'elasticsearch_plugin kopf':
    command => '/usr/share/elasticsearch/bin/plugin --install lmenezes/elasticsearch-kopf/v1.4.6',
    unless => "/usr/bin/test -e /usr/share/elasticsearch/plugins/kopf",
    require => Package['elasticsearch']
  }

  # Install ElasticSearch plugin: elasticsearch_head
  exec { 'elasticsearch_plugin elasticsearch_head':
    command => '/usr/share/elasticsearch/bin/plugin --install mobz/elasticsearch-head',
    unless => "/usr/bin/test -e /usr/share/elasticsearch/plugins/head",
    require => Package['elasticsearch']
  }

  # Install ElasticSearch plugin: bigdesk
  exec { 'elasticsearch_plugin bigdesk':
    command => '/usr/share/elasticsearch/bin/plugin --install lukas-vlcek/bigdesk',
    unless => "/usr/bin/test -e /usr/share/elasticsearch/plugins/bigdesk",
    require => Package['elasticsearch']
  }

  # Install ElasticSearch plugin: paramedic
  exec { 'elasticsearch_plugin paramedic':
    command => '/usr/share/elasticsearch/bin/plugin --install karmi/elasticsearch-paramedic',
    unless => "/usr/bin/test -e /usr/share/elasticsearch/plugins/paramedic",
    require => Package['elasticsearch']
  }

  # Install ElasticSearch plugin: elastichq
  exec { 'elasticsearch_plugin elastichq':
    command => '/usr/share/elasticsearch/bin/plugin --install royrusso/elasticsearch-HQ',
    unless => "/usr/bin/test -e /usr/share/elasticsearch/plugins/HQ",
    require => Package['elasticsearch']
  }

  # Declare a path where index data will be stored for this ElasticSearch node
  file { "/data":
      ensure => "directory",
      owner  => "elasticsearch",
      group  => "elasticsearch",
      mode   => 755,
      require => Package['elasticsearch']
  }

  # Setup the ElasticSearch config
  file { '/etc/elasticsearch/elasticsearch.yml':
    owner  => "elasticsearch",
    group  => "elasticsearch",
    mode   => 644,
    content => template('elk/elasticsearch/elasticsearch.yml.erb'),
    require => File['/data']
  }


  # added custom tunings to up HEAP size for the JVM after finding frequent OOMs in elasticsearch logs
  file { "/etc/sysconfig/elasticsearch":
    owner  => "root",
    group  => "root",
    mode   => 0644,
    source => "puppet:///modules/elk/etc/sysconfig/elasticsearch",
    require => Package['elasticsearch']
  }

  # makes elk AMIs portable across regions and fixes race condition on kibana startup timing after elasticsearch starts
  file { "/usr/bin/postboot.sh":
    owner  => "root",
    group  => "root",
    mode   => 0755,
    source => "puppet:///modules/elk/usr/bin/postboot.sh",
    require => Package['elasticsearch']
  }

  # Run script at boot time to region set elasticsearch config and delay starting kibana until elasticsearch has time to come up
  file_append { 'Run postboot.sh':
    path => '/etc/rc.local',
    line => 'bash /usr/bin/postboot.sh 2> /var/log/postboot.log 1>&2',
    require => File['/usr/bin/postboot.sh']
  }

}
