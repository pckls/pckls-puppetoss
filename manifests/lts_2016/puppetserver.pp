# Manages puppet-server similar to Puppet Enterprise LTS 2016.4
class puppetoss::lts_2016::puppetserver (
  $enable_ca       = $puppetoss::puppetserver_enable_ca,
  $proxy_ca        = $puppetoss::puppetserver_proxy_ca,
  $puppetdb_config = $puppetoss::puppetserver_puppetdb_config,
  $serveralias     = $puppetoss::puppetserver_serveralias,
  $version         = '2.6.0',
) {

  # Dependencies
  ensure_packages(['git'])

  package { 'puppetserver':
    ensure => $version,
  }

  if $puppetdb_config {
    contain ::puppetdb::master::config
  }

  # Service is defined in puppetdb::master::config

  # service { 'puppetserver':
  #   ensure  => running,
  #   require => Package['puppetserver'],
  #   enable  => true,
  # }

  if $enable_ca {

    file_line { 'puppetlabs.services.ca.certificate-authority-service':
      ensure  => present,
      require => Package['puppetserver'],
      line    => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
      match   => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
      path    => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
    }

    file_line { 'puppetlabs.services.ca.certificate-authority-disabled-service':
      ensure  => present,
      require => Package['puppetserver'],
      line    => '#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
      match   => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
      path    => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
    }

  }
  else {

    file_line { 'puppetlabs.services.ca.certificate-authority-service':
      ensure  => present,
      require => Package['puppetserver'],
      line    => '#puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
      match   => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
      path    => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
    }

    file_line { 'puppetlabs.services.ca.certificate-authority-disabled-service':
      ensure  => present,
      require => Package['puppetserver'],
      line    => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
      match   => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
      path    => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
    }

    # This is how compile masters proxy CA requests to the MoM (puppetmm)
    if $proxy_ca {

      file_line { 'auth.conf-allow-header-cert-info':
        ensure  => present,
        notify  => Service['puppetserver'],
        require => Package['puppetserver'],
        after   => '    version',
        line    => '    allow-header-cert-info: true',
        match   => '    allow-header-cert-info:',
        path    => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
      }

      file_line { 'puppetserver.conf-use-legacy-auth-conf':
        ensure  => present,
        notify  => Service['puppetserver'],
        require => Package['puppetserver'],
        line    => '    use-legacy-auth-conf: false',
        match   => '    #use-legacy-auth-conf:',
        path    => '/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf',
      }

      file_line { 'webserver.conf-ssl-host':
        ensure  => absent,
        notify  => Service['puppetserver'],
        require => Package['puppetserver'],
        line    => '    ssl-host: 0.0.0.0',
        path    => '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
      }

      file_line { 'webserver.conf-ssl-port':
        ensure  => absent,
        notify  => Service['puppetserver'],
        require => Package['puppetserver'],
        line    => '    ssl-port: 8140',
        path    => '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
      }

      file_line { 'webserver.conf-host':
        ensure  => present,
        notify  => Service['puppetserver'],
        require => Package['puppetserver'],
        after   => '    client-auth: want',
        line    => '    host: 0.0.0.0',
        path    => '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
      }

      file_line { 'webserver.conf-port':
        ensure  => present,
        notify  => Service['puppetserver'],
        require => File_line['webserver.conf-host'],
        after   => '    host: 0.0.0.0',
        line    => '    port: 8139',
        path    => '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
      }

      file { '/usr/share/puppet':
        ensure => directory,
      }

      class { 'apache':
        default_vhost => false,
      }

      apache::listen { '8140': }

      apache::vhost { 'puppet-reverse-proxy':
        docroot                     => '/usr/share/puppet',
        port                        => '8140',
        proxy_pass_match            => [
          {
            'path'         => '^/.*/certificate.*/',
            'url'          => "https://${::fqdn}:8140",
            'reverse_urls' => "https://${::fqdn}:8140",
          },
          {
            'path'         => '^/.*/',
            'url'          => "http://${serveralias}:8139",
            'reverse_urls' => "http://${serveralias}:8139",
          },
        ],
        proxy_preserve_host         => true,
        request_headers             => [
          'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
          'set X-Client-DN %{SSL_CLIENT_S_DN}e',
          'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
        ],
        serveraliases               => [ $serveralias ],
        servername                  => $::fqdn,
        ssl                         => true,
        ssl_ca                      => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
        ssl_cert                    => "/etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem",
        ssl_cipher                  => 'ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP',
        ssl_crl                     => '/etc/puppetlabs/puppet/ssl/crl.pem',
        ssl_crl_check               => 'chain',
        ssl_crl_path                => '/etc/puppetlabs/puppet/ssl',
        ssl_key                     => "/etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem",
        ssl_options                 => [ '+StrictRequire', '+ExportCertData' ],
        ssl_protocol                => '-ALL +SSLv3 +TLSv1',
        ssl_proxy_check_peer_cn     => 'off',
        ssl_proxy_check_peer_expire => 'off',
        ssl_proxy_check_peer_name   => 'off',
        ssl_proxy_verify            => 'none',
        ssl_proxyengine             => true,
        ssl_verify_client           => 'optional',
        ssl_verify_depth            => '1',
        vhost_name                  => '*',
      }

    }

  }

}
