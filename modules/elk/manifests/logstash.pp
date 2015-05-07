class elk::logstash {

  # Setup the ElasticSearch RPM repo for Yum
  yumrepo { 'logstash_repo':
    baseurl => 'http://packages.elasticsearch.org/logstash/1.4/centos',
    descr => "Logstash yum repository",
    enabled => 1,
    gpgcheck => 1,
    gpgkey => 'https://packages.elasticsearch.org/GPG-KEY-elasticsearch'
  }

  # Update the package list
  exec { 'yum_update_logstash_repo':
    command => '/usr/bin/yum update',
    require => Yumrepo['logstash_repo']
  }

  # Install the ElasticSearch RPM
  package { 'logstash':
    ensure => '1.4.2-1_2c0f5a1',
    require => Exec['yum_update_logstash_repo']
  }

  # Create a directory where our PUBLIC SSL certs will be stored (may already exist)
  file { "/etc/pki/tls/certs":
      ensure => "directory",
      owner  => "root",
      group  => "root",
      mode   => 755,
  }

  # Place the PUBLIC SSL certificate on the server
  # The public SSL cert is distributed to all "logstash forwarders" and can be freely distributed
  file { '/etc/pki/tls/certs/log-courier.crt':
    owner  => "root",
    group  => "root",
    mode   => 644,
    source => "puppet:///modules/elk/logstash/log-courier.crt",
    require => File['/etc/pki/tls/certs']
  }

  # Create a directory where our PRIVATE SSL key will be stored
  # The private SSL key is what the ELK server uses to prove its identity (it's acting as its own CA)
  # If this key were to be compromised any other server could masquerade as the real Logstash server
  file { "/etc/pki/tls/private":
      ensure => "directory",
      owner  => "root",
      group  => "root",
      mode   => 755,
  }

  # Modify the /etc/rc.local script to place the PRIVATE SSL key on the server
  # The private SSL key is what the ELK server uses to prove its identity (it's acting as its own CA)
  # Note that we can't just use Puppet to download this b/c otherwise a secret would be baked into the image
  # meaning anyone with access to an AMI can get access to this secret.  So instead we write a script that runs
  # at boot time to download from S3.

  # Place the script on the server
  file { '/usr/bin/get-private-key.sh':
    owner  => "ec2-user",
    group  => "ec2-user",
    mode   => 755,
    source => "puppet:///modules/elk/logstash/get-private-key.sh",
    require => File['/etc/pki/tls/private']
  }

  # Run the script at boot time (note that it will run about 5 - 10 seconds after booting)
  file_append { 'Run get-private-key.sh at boot':
    path => '/etc/rc.local',
    line => 'bash /usr/bin/get-private-key.sh 2> /var/log/rc.local.log 1>&2'
  }

  # This script will keep trying to start LogStash until it succeeds (poor man's supervisord).
  # Place it on the server.
  # JSM: wasn't testing correctly but don't think this is needed now see postboot.sh instead
  #file { '/usr/bin/keep-trying-to-start-logstash.sh':
  #  owner  => "ec2-user",
  #  group  => "ec2-user",
  #  mode   => 755,
  #  source => "puppet:///modules/elk/logstash/keep-trying-to-start-logstash.sh",
  #}

  ## Append the keep-trying-tostart script to rc.local so that it runs at boot-time
  #file_append { 'Run keep-trying-to-start-logstash.sh at boot':
  #  path => '/etc/rc.local',
  #  line => 'bash /usr/bin/keep-trying-to-start-logstash.sh',
  #}

  # Configure Logstash to accept log files of various formats
  file { "/etc/logstash/conf.d":
      ensure => "directory",
      owner  => "logstash",
      group  => "logstash",
      mode   => 755,
      source => "puppet:///modules/elk/logstash/config",
      recurse => true
  }

  # Install the "contrib" module, which enables us to install logstash plugins
  # See http://logstash.net/docs/1.4.2/contrib-plugins
  # Note that we use the manual install because of https://github.com/elasticsearch/logstash/issues/1658

  # Fix the Logstash version issue that prevents the contrib plugin from being installed
  exec { 'fix_logstash_version':
    command => "/bin/sed -i '/1.4.2-modified/c\\LOGSTASH_VERSION = \"1.4.2\"' /opt/logstash/lib/logstash/version.rb",
    require => Package['logstash']
  }

  # Install the logstash contrib plugin
  exec { 'install_logstash_contrib_plugin':
    command => "/opt/logstash/bin/plugin install contrib",
    unless => "/usr/bin/test -e /opt/logstash/lib/logstash/codecs/cloudtrail.rb",
    require => Exec['fix_logstash_version']
  }

  # Install the log-courier plugin
  # See https://github.com/driskell/log-courier/blob/develop/docs/LogstashIntegration.md#manual-installation
  archive { 'download_and_extract_log_courier':
    source => "https://github.com/driskell/log-courier/archive/v1.3.zip",
    archive_type => "zip",
    extract_dir => "/home/ec2-user/log-courier-1.3",
    owner => "logstash",
    group => "logstash"
  }

  exec { 'log_courier_make_gem_for_server':
    cwd => "/home/ec2-user/log-courier-1.3/log-courier-1.3",
    command => "/usr/bin/make gem",
    require => Archive['download_and_extract_log_courier']
  }

  exec { 'log_courier_install_gem_for_server':
    cwd => "/opt/logstash",
    environment => ["GEM_HOME=vendor/bundle/jruby/1.9"],
    command => "/usr/bin/java -jar vendor/jar/jruby-complete-1.7.11.jar -S gem install /home/ec2-user/log-courier-1.3/log-courier-1.3/log-courier-1.3.gem && touch /opt/logstash/log-courier-1.3.gem-installed",
    creates => "/opt/logstash/log-courier-1.3.gem-installed",
    require => Exec['log_courier_make_gem_for_server']
  }

  exec { 'log_courier_manual_plugin_install_for_server':
    cwd => "/home/ec2-user/log-courier-1.3/log-courier-1.3",
    environment => ["GEM_HOME=vendor/bundle/jruby/1.9"],
    command => "/bin/cp -rvf lib/logstash /opt/logstash/lib",
    require => Exec['log_courier_install_gem_for_server']
  }

  # Replace logstash's default grok-patterns with our updated one
  # Note that I obtained this from https://gist.githubusercontent.com/LanyonM/8390458/raw/a2604fd3d688b10bbfada21a8ff28f20746d19ae/grok-patterns
  file { "/opt/logstash/patterns/grok-patterns":
      owner  => "logstash",
      group  => "logstash",
      mode   => 755,
      source => "puppet:///modules/elk/logstash/grok-patterns"
  }

}
