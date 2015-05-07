
class hosts {

  file { "/usr/sbin/update-hosts.sh":
    replace => true,
    source  => "puppet:///modules/hosts/update-hosts.sh",
    mode    => "0700",
    owner   => "root",
    group   => "root",
  }

}
