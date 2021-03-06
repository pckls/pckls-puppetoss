# This module provisions Puppet OSS following the Puppet Enterprise LTS component versions.
class puppetoss (
  $config                       = {},
  $lts_version                  = '2016',
  $puppetagent                  = true,
  $puppetdb                     = false,
  $puppetexplorer               = false,
  $puppetserver                 = false,
  $puppetserver_enable_ca       = true,
  $puppetserver_proxy_ca        = false,
  $puppetserver_puppetdb_config = false,
  $puppetserver_serveralias     = 'puppet.example.org',
) {

  # Manage the Puppet configuration file
  $defaults = { path => '/etc/puppetlabs/puppet/puppet.conf' }
  create_ini_settings($config, $defaults)

  case $lts_version {
    default: { fail('Version unsupported!') }
    '2016':  { contain ::puppetoss::lts_2016 }
  }

}
