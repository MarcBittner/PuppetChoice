# users module based on users salt state 
class users::qualys {

  group {'qualys':
    ensure => present,
  }

  user {'qualys':
    ensure => present,
    gid => 'qualys',
    shell => '/bin/false',
    home => '/home/qualys2',
    managehome => 'true'
  }


  exec { "qualys_mksshdir":
    command => "/bin/mkdir /home/qualys2/.ssh/; /bin/cp -a /etc/skel/. /home/qualys2",
    unless => "/usr/bin/test -e /home/qualys2/.ssh"
  }

  exec { "qualys_pubkey":
    command => "/bin/echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAs2lZVzplZjfwdt6AvBSHF/QPwGYvnMxFtqktaHYPvW56Rw0EgEI6oXYpleRtaVqiC8hmQcJ3plgueMlTBoe0NhHVYLAHpk85qyf7EJKgCtqpmneiV+RKRMYVMNiu8buLKEU7YhBlG28fU59ManjiUUHlh/1KpfzoNQqfZAf0DmDkKItJ9gRVs1NqmHbdkBlE5Dkv8+rjQVHaaDcP4DvlTnbtcYHSygtHEviEOjoJ5WKkjeL6bzzDmkhl6SmlxyXq88vhvAUPuXc7jKXJGP5ctTgUyQ2J2swJ8dfptvrU5VNuHEGlozVPbVwi3bGHwNVqv7YrWFoYglS2OzhsQPotnw== root@rhn.chotel.com' > /home/qualys2/.ssh/authorized_keys",
    require => Exec["qualys_mksshdir"]
  }

  exec { "qualys_chmod":
    command => "/bin/chmod 0700 /home/qualys2/.ssh; /bin/chmod 0700 /home/qualys2; /bin/chmod 0644 /home/qualys2/.ssh/authorized_keys",
    require => Exec["qualys_pubkey"]
  }

}
