class cis (
            $arg1, 
            $arg2, 
            $arg3,
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
  $git_command            = "/usr/bin/git"
  $path_to_cwd            = '/tmp'
  $path_to_cisinstall     = "${path_to_cwd}/cisenv/src/main/resources/scripts/cisinstall"
    
  /* 
  exec { $cis_repo:
    command => "${git_command} clone ${$cis_repo}",
    cwd     => $path_to_cwd,
  } ->
  */
  
 file { $path_to_cisinstall:
    replace => true,
    source => "${path_to_cwd}",
    mode => "644",
    owner => "root",
    group => "root",
  } ->
 
  exec { "Exec cisinstall:":
             command => "$path_to_cisinstall ${arg1} ${arg2} ${arg3}",
        }
}