class cassandra ( $version = '2.1.2-2', $package_name = 'cassandra21' ) {

  $nexus_artifact_url     = "http://nexus.chotel.com/nexus/service/local/repositories/infrastructure/content/org/apache/cassandra/${version}/cassandra-${version}.rpm"
  $mount_point            = '/mnt/RAID0'
  $user_name              = 'cassandra'
  $group_name             = 'cassandra'
  $git_repo_url           = 'http://stash.chotel.com:8080/scm/dev'
  $aeneas_repo            = "${git_repo_url}/aeneas.git"
  $chelydra_repo          = "${git_repo_url}/chelydra.git"
  $python_command         = "/usr/bin/python"
  $git_command            = "/usr/bin/git"
  $cassandra_lib_path     = '/var/lib/cassandra'
  $chelydra_snap          = '/usr/sbin/chelydra_snap.sh'
  $chelydra_loadtest_snap = '/usr/sbin/chelydra_loadtest_snap.sh'

  group { $group_name:
     ensure => present,
  }

  user { $user_name:
    ensure => present,
    gid    => $group_name,
    shell  => '/bin/bash',
    home   => '/usr/share/cassandra',
  }

  package { 'python27-pip':
    ensure => installed,
  }

  package { 'python27-devel':
    ensure => installed,
  }

  package { 'cassandra-driver':
    ensure   => installed,
    provider => pip,
    require  => Package['python27-pip'],
  }

  file { $mount_point:
    ensure  => directory,
    group   => $group_name,
    owner   => $user_name,
    mode    => 755,
    require => User[$user_name],
  }

  mount { $mount_point:
    ensure  => mounted,
    device  => '/dev/sdb',
    fstype  => auto,
    options => "defaults,nofail,comment=cloudconfig",
    dump    => 0,
    pass    => 2,
    require => File[$mount_point],
  }

  file { $cassandra_lib_path:
    ensure  => directory,
    group   => $group_name,
    owner   => $user_name,
    require => User[$user_name],
  }

  $cassandra_paths = [ 'data', 'commitlog' ]
  define cassandra::path {

    file { "${cassandra::mount_point}/${name}":
      ensure  => directory,
      group   => $cassandra::group_name,
      owner   => $cassandra::user_name,
      mode    => 755,
      require => [ User[$cassandra::user_name],
                   Mount[$cassandra::mount_point] ],
    }

    file { "/var/lib/cassandra/${name}":
      ensure  => link,
      target  => "${cassandra::mount_point}/${name}",
      require => [ File["${cassandra::mount_point}/${name}"],
                   File[$cassandra::cassandra_lib_path] ],
    }

  }

  cassandra::path { $cassandra_paths: }

  exec { $aeneas_repo:
    command => "${git_command} clone ${aeneas_repo}",
    cwd     => '/tmp',
  }

  file { '/usr/sbin/aeneas.py':
    source  => '/tmp/aeneas/aeneas.py',
    mode    => 755,
    require => Exec[$aeneas_repo],
  }

  exec { $chelydra_repo:
    command => "${git_command} clone ${chelydra_repo}",
    cwd     => '/tmp',
  }

  package { 'gcc':
    ensure => installed
  }

  exec { 'chelydra_install':
    command   => "${python_command} setup.py install",
    cwd       => '/tmp/chelydra',
    logoutput => true,
    require   => [ Exec[$chelydra_repo],
                   Package['gcc'],
                   Package['python27-devel'] ],
  }

  file { $chelydra_snap:
    source => "puppet:///modules/cassandra/chelydra_snap.sh",
    owner  => $user_name,
    group  => $group_name,
    mode   => 755,
  }

  file { $chelydra_loadtest_snap:
    source => "puppet:///modules/cassandra/chelydra_loadtest_snap.sh",
    owner  => $user_name,
    group  => $group_name,
    mode   => 755,
  }

  cron { 'chelydra_snap':
    command => $chelydra_snap,
    user    => $user_name,
    hour    => '*/7',
    minute  => 13,
    require => File[$chelydra_snap],
  }

  package { $package_name:
    ensure   => installed,
    provider => rpm,
    source   => $nexus_artifact_url,
    require  => [ User[$user_name],
                  Cassandra::Path['data'],
                  Cassandra::Path['commitlog'],
                  Class['Java']  ]
  }

  file { "/etc/cassandra/default.conf/cassandra.yaml":
    source  => "puppet:///modules/cassandra/cassandra.yaml",
    owner   => $cassandra::user_name,
    group   => $cassandra::group_name,
    mode    => 755,
    require => Package[$package_name],
  }

  file { '/etc/init.d/prep-for-launch':
    source => 'puppet:///modules/cassandra/prep-for-launch',
    mode   => 755,
  }

  service { 'prep-for-launch':
    ensure  => stopped,
    enable  => true,
    pattern => 'prep-for-launch',
    require => File['/etc/init.d/prep-for-launch'],
  }

  service { 'cassandra':
    ensure  => stopped,
    enable  => false,
    require => Package[$package_name],
  }

  file { "/opt/deploy.sh":
    source => "puppet:///modules/cassandra/deploy.sh",
    mode   => 777,
  }

  service { 'log-courier':
    ensure  => stopped,
    enable  => false,
    require => File['/etc/init.d/log-courier'],
  }

}
