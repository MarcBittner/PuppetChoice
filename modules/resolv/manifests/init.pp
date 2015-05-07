# resolv module based on resolv salt state 
class resolv {

  file { "/etc/resolv.conf":
    replace => true,
    source => "puppet:///modules/resolv/resolv.conf",
    mode => "0644",
    owner => "root",
    group => "root",
  }

}
