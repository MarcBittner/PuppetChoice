class profiles::base {
  include resolv
  include ntp
  include rsyslog
  include remove
  include sudo
  include audit
  include authconfig
  include java
  include ssh
  include snmp
  include users
  include log-courier
  include appdynamics
  include choice
  include collectd
  include hosts
  include cis
}
