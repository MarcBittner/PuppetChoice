class cis (
            $arg1, 
            $arg2, 
            $arg3,
            $use_local = true
          ) {
  
       
       Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin/" ], 
              logoutput => on_failure,  
              }
                    
       include 'stdlib'
       include 'git'
       include 'wget'
 
#  $nexus_artifact_url     = "http://nexus.chotel.com/nexus/service/local/repositories/infrastructure/content/org/apache/cassandra/${version}/cassandra-${version}.rpm"
       $user_name              = 'cassandra'
       $group_name             = 'cassandra'
       $git_repo_url           = 'http://stash.chotel.com:8080/scm/cis'
       $cis_repo               = "${git_repo_url}/cis.git"
       $cis_mock_repo          = "${git_repo_url}/cis-mock.git"
       $git_command            = "/usr/bin/git"
       $path_to_cwd            = '/tmp'
       $path_to_cis            = "${path_to_cwd}/cis"
       $path_to_cisinstall     = "${path_to_cis}/cisenv/src/main/resources/scripts/cisinstall"
    
  package { ['ksh', 'dos2unix']:
    ensure => installed,
  } ->
    
    
#    exec { $cis_repo:
#        command => "${git_command} clone ${cis_repo}",
#        cwd     => $path_to_cwd,
#        require => Class["git"],
#    } ->
    
#    if ($use_local) {
       file { [ 
           "${path_to_cwd}",
           "${path_to_cwd}/cis/",
           "${path_to_cwd}/cis/cisenv/",
           "${path_to_cwd}/cis/cisenv/src/",
           "${path_to_cwd}/cis/cisenv/src/main/",
           "${path_to_cwd}/cis/cisenv/src/main/resources/",   
           "${path_to_cwd}/cis/cisenv/src/main/resources/scripts/"
                ]:
                  ensure => "directory",
#                  require => $cis_repo,
        } ->
            
        file { $path_to_cisinstall:
           replace => true,
           source => $use_local ? { 
             true => "puppet:///modules/cis/cisinstall",
             false => $path_to_cisinstall,
             default => $path_to_cisinstall,
           },
           mode => "755",
           owner => "root",
           group => "root",
        } ->
#    }
    
     exec { "Exec dos2unix cisinstall:":
      command => "dos2unix $path_to_cisinstall",
    } ->
 
   
    exec { "Exec cisinstall:":
      command => "$path_to_cisinstall ${arg1} ${arg2} ${arg3}",
    }
}