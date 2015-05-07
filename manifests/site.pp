node default {
       include 'stdlib'
       include '::ntp'
       include 'git'
       include 'wget'
 
       class { 'firewall':  } -> class { 'jenkins_wrapper':  } 
			 
			        Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin/" ], 
              logoutput => on_failure,  
              }
       
			 
       class {'figlet_motd': motdText => "You are on the jenkins branch."} 
  
                    
			 
       logrotate::rule { 'syslog':
											path         => '/var/log/syslog',
											rotate       => 5,
											rotate_every => 'week',
											postrotate   => 'service rsyslog rotate >/dev/null 2>&1 || true',
				}	

}
