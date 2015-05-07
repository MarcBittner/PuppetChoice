class mcollective::agent {

  # mcollective template variables for future automation use
  $activemq_host = "mcollective.aws.chotel.com"
  $facts_environment = "dev"
  $facts_role = "appserver"
  $facts_farm = "blue"

  # Setup the PuppetLabs RPM repo for free OpenSource activemq and mcollective packages
  exec { 'yum install puppetlabs repo':
    command => '/usr/bin/yum erase puppetlabs-release -y; /bin/rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm'
  }

  exec { 'yum install mcollective agent':
    command => '/usr/bin/yum install mcollective mcollective-common  -y',
    require => Exec['yum install puppetlabs repo']
  }

  file { '/etc/mcollective/server.cfg':
    replace => true,
    mode => "0644",
    owner  => "root",
    group  => "root",
    content => template('mcollective/server.cfg.erb'),
    require => Exec['yum install mcollective agent']
  }

  file { "/etc/mcollective/facts.yaml":
    replace => true,
    mode => "0644",
    owner => "root",
    group => "root",
    content => template('mcollective/facts.yaml.erb'),
    require => Exec['yum install mcollective agent']
  }

  exec { "fix mcollective libs":
    command => "/bin/cp -R /usr/lib/ruby/site_ruby/1.8/* /usr/lib64/ruby/vendor_ruby/2.0/; /bin/rm -f /usr/libexec/mcollective; /bin/ln -s /usr/lib64/ruby/vendor_ruby/2.0/mcollective /usr/libexec/mcollective",
    require => Exec['yum install mcollective agent']
  }

  file { "/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 0755,
    require => Exec["fix mcollective libs"]
  }

  file { "/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/application":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 0755,
    require => File["/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective"]
  }

  file { "/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/application/shell.rb":
    replace => true,
    source => "puppet:///modules/mcollective/mcollective/application/shell.rb",
    owner  => "root",
    group  => "root",
    mode   => 0644,
    require => File["/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/application"]
  }

  file { "/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/application/shell":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 0755,
    require => File["/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/application"]
  }

  file { "/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/application/shell/watcher.rb":
    replace => true,
    source => "puppet:///modules/mcollective/mcollective/application/shell/watcher.rb",
    mode => "0644",
    owner => "root",
    group => "root",
    require => File["/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/application/shell"]
  }

  file { "/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/application/shell/prefix_stream_buf.rb":
    replace => true,
    source => "puppet:///modules/mcollective/mcollective/application/shell/prefix_stream_buf.rb",
    mode => "0644",
    owner => "root",
    group => "root",
    require => File["/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/application/shell"]
  }

  file { "/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/agent":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 0755,
    require => File["/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective"]
  }

  file { "/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/agent/shell.rb":
    replace => true,
    source => "puppet:///modules/mcollective/mcollective/agent/shell.rb",
    owner  => "root",
    group  => "root",
    mode   => 0644,
    require => File["/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/agent"]
  }

  file { "/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/agent/shell.ddl":
    replace => true,
    source => "puppet:///modules/mcollective/mcollective/agent/shell.ddl",
    owner  => "root",
    group  => "root",
    mode   => 0644,
    require => File["/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/agent"]
  }

  file { "/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/agent/shell":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 0755,
    require => File["/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/agent"]
  }

  file { "/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/agent/shell/job.rb":
    replace => true,
    source => "puppet:///modules/mcollective/mcollective/agent/shell/job.rb",
    mode => "0644",
    owner => "root",
    group => "root",
    require => File["/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/agent/shell"]
  }

  exec { 'gem install stomp':
    command => '/usr/bin/gem install stomp',
    require => File['/usr/lib64/ruby/vendor_ruby/2.0/mcollective/mcollective/agent/shell/job.rb']
  }

  exec { "start enable mcollective":
    command => "/etc/init.d/mcollective start; /sbin/chkconfig --levels 2345 mcollective on",
    require => Exec['gem install stomp']
  }


}
