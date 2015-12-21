## Basic resources

$user = hiera('user')

user { $user['name']:
  ensure => present,
  shell => '/bin/bash',
  password => pw_hash($user['password'], 'SHA-512', 'blabla'),
  groups => ['www-data', 'sudonopw']
}

group { 'sudonopw':
  ensure => present
}

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}


## Basic configuration

include 'apt'

file_line { 'add_deploy_key':
  ensure => present,
  path => "/home/${user['name']}/.ssh/authorized_keys",
  line => hiera('pubkeys')
}

file_line { 'sudo_rule_nopw':
  ensure => present,
  path => '/etc/sudoers',
  line => '%sudonopw ALL=(ALL) NOPASSWD: ALL',
}


class passenger_nginx {

  file { 'install_script':
    ensure => 'file',
    source => 'file:///etc/puppet/files/nginx_passenger/install.sh',
    path => '/usr/local/bin/my_nginx_passenger_install.sh',
    mode  => '744',
    notify => Exec['run_install_script']
  }
  exec { 'run_install_script':
    command => '/usr/local/bin/my_nginx_passenger_install.sh',
    refreshonly => true,
    notify => [File['nginx_conf'], File['myapp_conf']]
  }

  file { 'nginx_conf':
    ensure => present,
    source => 'file:///etc/puppet/files/nginx_passenger/etc_nginx_nginx.conf',
    path => '/etc/nginx/nginx.conf'
  }

  file { 'myapp_conf':
    ensure => present,
    source => 'file:///etc/puppet/files/nginx_passenger/etc_nginx_sites_enabled_myapp.conf',
    path => '/etc/nginx/sites-enabled/myapp.conf'
  }
}

class { 'passenger_nginx': }

class { 'postgresql::server':
  ip_mask_deny_postgres_user => '0.0.0.0/32',
  ip_mask_allow_all_users => '0.0.0.0/0',
  listen_addresses => '*',
  ipv4acls => [
   'local all all ident',
   'host all all 0.0.0.0/0 md5'
  ],
  pg_hba_conf_defaults => false, # NOTE: since default includes `host all postgres 0.0.0.0/32 reject`
  postgres_password => 'postgres'
}

postgresql::server::db { 'puppet_vagrant_cap_rails_staging':
  user     => 'puppet_vagrant_cap_rails',
  password => postgresql_password('puppet_vagrant_cap_rails', hiera('postgres-password')),
}

class {'git': }
package { 'nodejs':
  ensure => installed
}

package { ['postgresql-contrib', 'libpq-dev']:
  ensure => installed
}

# ruby
class { '::rvm': }
rvm::system_user { $user['name']: ; }
rvm_system_ruby {
  'ruby-2.1.3':
    ensure      => 'present',
    default_use => true;
}
rvm_gem {
  'bundler':
    name         => 'bundler',
    ruby_version => 'ruby-2.1.3',
    ensure       => '1.10.6',
    require      => [Rvm_system_ruby['ruby-2.1.3']];
}
rvm_gem {
  'pg':
    name         => 'pg',
    ruby_version => 'ruby-2.1.3',
    ensure       => '0.18.4',
    require      => [Rvm_system_ruby['ruby-2.1.3'], Package['postgresql-contrib'], Package['libpq-dev']];
}
