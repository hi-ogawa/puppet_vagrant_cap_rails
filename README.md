### Purpose

Experiments on those deployment tools:

- Vagrant
- Puppet
  - Librarian Puppet
  - Hiera
- Capistrano

and those system stack:

- Postgresql
- Passenger integrated with Nginx

### Run staging rails app in Vagrant

__Files to set up manually_

- config/database.staging.yml
- config/secrets.staging.yml
- puppet/hieradata/common.yaml

__Commands to run__

```
$ bundle install # to install `capistrano`, `puppet`, `librarian-puppet`, etc ...
$ (cd puppet && bundle exec librarian-puppet install) # to install puppet modules
$ vagrant up staging
$ ON_VAGRANT=192.168.50.4 bundle exec cap staging deploy
```

### TODO

- Change some parameters (host name/ip, rails application location) in nginx.conf file via hiera configs.
- A cleaner way of masterless puppet bootstrap on real VPS.
