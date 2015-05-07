# Install the appdynamics plugin to the server

class appdynamics {

  # Create the directories where AppDynamics plugins will live
  file { ["/opt/appdyn", "/opt/appdyn/appserveragent"]:
      ensure => "directory",
      owner  => "ec2-user",
      group  => "ec2-user",
      mode   => 755,
  }

  file { "/opt/appdyn/machineagent":
      ensure => "directory",
      owner  => "ec2-user",
      group  => "ec2-user",
      mode   => 755,
  }

  # Download the AppDynamics APP agent and extract
  archive { 'download_and_extract_app_agent':
    source => "http://nexus.chotel.com/nexus/service/local/repositories/infrastructure/content/com/appdynamics/agents/appserveragent/4.0.2.0/appserveragent-4.0.2.0.zip",
    archive_type => "zip",
    extract_dir => "/opt/appdyn/appserveragent",
    owner => "ec2-user",
    group => "ec2-user",
    require => File['/opt/appdyn/appserveragent']
  }

  # Place the bash script on the server that enables the AppDynamics APP agent to be installed
  file { '/home/ec2-user/enable_appdynamics_app.sh':
    owner  => "ec2-user",
    group  => "ec2-user",
    mode   => 744,
    source => "puppet:///modules/appdynamics/enable_appdynamics_app.sh"
  }

  # Download the AppDynamics MACHINE agent and extract
  archive { 'download_and_extract_machine_agent':
    source => "http://nexus.chotel.com/nexus/service/local/repositories/infrastructure/content/com/appdynamics/agents/machineagent/4.0.2.0/machineagent-4.0.2.0.zip",
    archive_type => "zip",
    extract_dir => "/opt/appdyn/machineagent",
    owner => "ec2-user",
    group => "ec2-user",
    require => File['/opt/appdyn/machineagent']
  }

  # Place the bash script on the server that enables the AppDynamics MACHINE agent to be installed
  file { '/home/ec2-user/enable_appdynamics_machine.sh':
    owner  => "ec2-user",
    group  => "ec2-user",
    mode   => 744,
    source => "puppet:///modules/appdynamics/enable_appdynamics_machine.sh"
  }

}
