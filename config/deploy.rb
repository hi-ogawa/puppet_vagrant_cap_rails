# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'just_a_test'
set :repo_url, 'git@github.com:hi-ogawa/puppet_vagrant_cap_rails.git'

# Default branch is :master
set :branch, ENV["BRANCH"] || "master"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/ubuntu/app'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, false

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# Settings for capistrano-upload-config
set :config_files, fetch(:linked_files)
set :config_example_suffix, '.example'

before 'deploy:check:linked_files', 'config:push'

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

desc "Check that we can access everything"
task :check_write_permissions do
  on roles(:all) do |host|
    binding.pry
    execute "echo $PWD"
    if test("[ -w #{fetch(:deploy_to)} ]")
      info "#{fetch(:deploy_to)} is writable on #{host}"
    else
      error "#{fetch(:deploy_to)} is not writable on #{host}"
    end
  end
end
