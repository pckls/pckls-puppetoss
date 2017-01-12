# TODO: Write some doco
class puppetoss::lts_2016::puppetagent (
  $version = '1.7.1',
) {

  package { 'puppet-agent':
    ensure => $version,
  }

  service { 'puppet':
    ensure  => 'running',
    require => Package['puppet-agent'],
    enable  => true,
  }

  # I think there is a symlink needed here

}
