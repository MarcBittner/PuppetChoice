# creates a directory for choice things
class choice {
  file { "/var/lib/choice":
    ensure => "directory",
  }
}