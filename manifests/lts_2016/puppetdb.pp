# TODO: Write some doco
class puppetoss::lts_2016::puppetdb {

  contain ::puppetdb
  contain ::puppetdb::master::config

  # I think there are some PostgreSQL issues here such as repo...

}
