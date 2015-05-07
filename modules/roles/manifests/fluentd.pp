class roles::fluentd {
  include profiles::base
  include profiles::webserver
  include profiles::fluentd
}
