class 389server-postbake {

  file {"/etc/hosts":
    replace => true,
    content => template('389server-postbake/hosts.erb'),
    mode => "644",
    owner => "root",
    group => "root",
  } ->

  file {"/home/ec2-user/setup.inf":
    replace => true,
    content => template('389server-postbake/setup.erb'),
    mode => "644",
    owner => "ec2-user",
    group => "ec2-user",
  } ->
 
  exec {"setup_ds_server":
    command => "/usr/sbin/setup-ds-admin.pl -s -f /home/ec2-user/setup.inf",
    user => root,
    timeout => 900,
  }
}
