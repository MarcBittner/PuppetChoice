# remove module based on remove salt state 
class remove {

  package { 'nc':
    ensure => "purged" 
  }
  
  package { 'wireshark':
    ensure => "purged" 
  }
  
  package { 'cups':
    ensure => "purged" 
  }
  
  package { 'foomatic':
    ensure => "purged" 
  }
  
  package { 'foomatic-db':
    ensure => "purged" 
  }
  
  package { 'foomatic-db-ppds':
    ensure => "purged" 
  }
  
  package { 'redhat-lsb-printing':
    ensure => "purged" 
  }
  
  package { 'autofs.x86_64':
    ensure => "purged" 
  }
  
  package { 'telnet-server.x86_64':
    ensure => "purged" 
  }
  
}
