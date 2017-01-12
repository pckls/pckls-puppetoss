# Entry point for Puppet OSS managed similar to Puppet Enterprise LTS 2016.4
class puppetoss::lts_2016 (
  $puppetagent    = $puppetoss::puppetagent,
  $puppetdb       = $puppetoss::puppetdb,
  $puppetexplorer = $puppetoss::puppetexplorer,
  $puppetserver   = $puppetoss::puppetserver,
) {

  if $puppetagent    { contain ::puppetoss::lts_2016::puppetagent }
  if $puppetdb       { contain ::puppetoss::lts_2016::puppetdb }
  if $puppetexplorer { contain ::puppetoss::lts_2016::puppetexplorer }
  if $puppetserver   { contain ::puppetoss::lts_2016::puppetserver }

}
