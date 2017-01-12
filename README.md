# pckls-puppetoss

This is a module to manage Puppet OSS following the Puppet Enterprise LTS component versions.

Currently the only supported LTS is 2016.4 - https://puppet.com/misc/puppet-enterprise-lifecycle

Including this module will install the agent only by default, repos are not managed at this stage.

```
include puppetoss
```

You can configure puppet.conf via Hiera.

```
puppetoss::config:
  main:
    environment: 'my_environment'
    server: 'puppet.example.com'
```

To install additional components (like puppetserver) just use the booleans in the main class.

```
puppetoss::puppetserver: true
```

More documentation to follow.
