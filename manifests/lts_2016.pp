# Entry point for Puppet OSS managed similar to Puppet Enterprise LTS 2016.4
class puppetoss::lts_2016 (
  $puppetagent    = true,
  $puppetdb       = false,
  $puppetexplorer = false,
  $puppetserver   = false,
) {

  if $puppetagent    { contain ::puppetoss::lts_2016::puppetagent }
  if $puppetdb       { contain ::puppetoss::lts_2016::puppetdb }
  if $puppetexplorer { contain ::puppetoss::lts_2016::puppetexplorer }
  if $puppetserver   { contain ::puppetoss::lts_2016::puppetserver }

}
