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
  line => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVj+3Q6Y9MUmFiazMNf0+a/9ea1kr7fyK+Aj+OGR/1LN/ZqMLXhERmSb8wbbwrsJh9/p6lNzAG1Rlr/h8kkzAVxeVYBtE6vktlRvOGPgYXwVsxRVrFg7SsFqbCcS1F5iX0YDoK7DkMHUpMOeNjqWAvvmTbvaAV9y3QPdI0F5v17oWMP1fimU6MxOp3T4Jczx4k7jIP4ODE0unGgbW4ZUE3Htmit0eFM7xlxUnZxLMIoA7IGDJbZ+L8XwIyCMOxoACRhADCnf6cGcJDswV+/EH41MX4/EBv0y4lF+pG92z/ce9edrQBjWfbXrOaxdPaC2PeGq8fJO3FPdFDVsd1FUvTpmZ+0vVlj3ojxfm2TLc8adV+l49GcYwBlgl8m6PozQ+4sqNwKdMDDkd+ys+PueMHXM4PIpRqc9r/GaO+x6AwHPgAYJalZ+lNSKLqDjlEH5e/InSPdu3vUqwSO2qZp3sO6TBc6FAoDO9eoz0p3KLshHE7Plkth5eHHOEGgpgXFh4QLWEqgHcdrrW1C/gerv7Yjt9vDUaewOTmPwhbJT8TsxElb3CgrF0d04ms6gCLWSD9G87wTkXcA6+OHoO1vGL7HbXT8nfgdCG3QAYldY2eHgil1A6Y2QHV2xpIIrHJWaAWNJOxy1oRsEx4pVSxXfqzPu7WuYAMLbE2/WzGFuHLpw=="
}

file_line { 'sudo_rule_nopw':
  ensure => present,
  path => '/etc/sudoers',
  line => '%sudonopw ALL=(ALL) NOPASSWD: ALL',
}


## install/run packages

class { 'nginx': }

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

# # NOTE: debug code to show the path of conf file
# info $postgresql::params::pg_hba_conf_path
# info $postgresql::params::postgresql_conf_path

class {'monit': }
class {'git': }
package { 'nodejs':
  ensure => installed
}

# Nokogiri dependencies.
package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
  ensure => installed
}

package { 'imagemagick':
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
