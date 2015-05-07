# Install Kibana as a local web server

class elk::kibana {

  # Set our global variables for Kibana
  # -----------------------------------
  # Affects the version of Kibana downloaded and the corresponding folder names that get created for it
  $kibana_version = "4.0.0"
  # -----------------------------------

  # Add a Linux User and Group for the Kibana web server
  group { 'kibana':
    ensure => present,
  }

  user { 'kibana':
    ensure => present,
    gid    => 'kibana',
    shell  => '/sbin/nologin'
  }

  # Download kibana as a tgz file and extract the archive
  archive { 'download_and_extract_kibana':
    source => "https://download.elasticsearch.org/kibana/kibana/kibana-$kibana_version-linux-x64.tar.gz",
    archive_type => "tgz",
    extract_dir => "/kibana",
    owner => "kibana",
    group => "kibana",
    require => User['kibana']
  }

  # Overwrite the default Kibana config file with ours
  # For now, we actually don't change any defaults, but this makes it easy to update in the future
  file { "/kibana/kibana-$kibana_version-linux-x64/config/kibana.yml":
    owner  => "kibana",
    group  => "kibana",
    mode   => 744,
    content => template('elk/kibana/kibana.yml.erb'),
    require => Archive['download_and_extract_kibana']
  }

  # Create a log folder for kibana
  file { "/var/log/kibana":
      ensure => "directory",
      owner  => "kibana",
      group  => "kibana",
      mode   => 777,
      recurse => true,
      require => Archive['download_and_extract_kibana']
  }

  # Run the kibana service on boot by first defining an init.d script
  # NOTE: See the init.d script to see where logs are output.
  file { "/etc/init.d/kibana":
    owner  => "root",
    group  => "root",
    mode   => 755,
    content => template('elk/kibana/kibana-init.d.erb'),
    require => User['kibana']
  }

  # Now set the Kibana to run automatically at boot time
  exec { 'kibana_run_on_boot':
    command => '/sbin/chkconfig --add kibana',
    require => File['/etc/init.d/kibana']
  }

  # Create a folder for our app-specific log rotations
  file { "/etc/logrotate":
      ensure => "directory",
      owner  => "root",
      group  => "root",
      mode   => 755,
      recurse => true,
  }

  # Setup logrotation by placing the "logrotate" conf file on the server
  file { "/etc/logrotate/kibana.conf":
    owner  => "root",
    group  => "root",
    mode   => 755,
    source => "puppet:///modules/elk/kibana/logrotate.conf"
  }

  # Set permissions on a logrotate "state file" used to track the state of log files
  file { "/var/lib/logrotate-kibana.status":
    owner  => "root",
    group  => "root",
    mode   => 755,
    content => ""
  }

  # Set up a cron job to run logrotate every day
  # Note that commented out cron properties (e.g. daymonth) default to '*'
  # This specifies that logs should be rotated once a day at 8:15am UTC (1:15am MST)
  cron { "logrotate_for_kibana":
    command => "/usr/sbin/logrotate --state /var/lib/logrotate-kibana.status /etc/logrotate/kibana.conf",
    user    => root,
    hour    => 8,
    minute  => 15
  }

}
