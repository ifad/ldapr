# =========================================================================
# Global Settings
# =========================================================================

# Base settings
set :application, 'ldapr'

# Stages settings
set :stages, %w( staging production )

require 'capistrano/ext/multistage'

# Repository settings
set :repository,    'git@mine.ifad.org:ldapr.git'
set :scm,           'git'
set :branch,        fetch(:branch, 'master')
set :deploy_via,    :remote_cache
set :deploy_to,     "/home/rails/apps/#{application}"
set :use_sudo,      false

# Account settings
set :user,          'ldapr'

ssh_options[:forward_agent] = true
ssh_options[:auth_methods]  = ['publickey']

# =========================================================================
# Dependencies
# =========================================================================
depend :remote, :command, 'gem'
depend :remote, :command, 'git'

def compile(template)
  location = fetch(:template_dir, File.expand_path('../deploy', __FILE__)) + "/#{template}"
  config   = ERB.new File.read(location)
  config.result(binding)
end

namespace :deploy do

  namespace :ifad do
    desc '[internal] Symlink rbenv version'
    task :symlink_rbenv_version, :except => { :no_release => true } do
      run "ln -s #{deploy_to}/.rbenv-version #{release_path}"
    end
    after 'deploy:update_code', 'deploy:ifad:symlink_rbenv_version'
  end

  desc 'Restarts the application.'
  task :restart do
    pid = "#{deploy_to}/.unicorn.pid"
    run "test -f #{pid} && kill -USR2 `cat #{pid}` || true"
  end

  desc "[internal] Updates the symlink for database configuration files to the just deployed release."
  task :symlink_config do
    configs = %w( ldap.yml ).map {|c| [shared_path, 'config', c].join('/') }
    run "ln -s #{configs.join(' ')} #{release_path}/config"
  end

  task :setup_config do
    run "mkdir -p #{shared_path}/{db,config}"
    put compile('ldap.yml.erb'),     "#{shared_path}/config/ldap.yml"
  end

end

after 'deploy', 'deploy:cleanup'
after 'deploy:setup', 'deploy:setup_config'
after 'deploy:update_code', 'deploy:symlink_config'

require 'bundler/capistrano'
set :bundle_flags, "--deployment --quiet --binstubs #{deploy_to}/bin"
set :rake,         'bundle exec rake'
