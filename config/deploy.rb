# =========================================================================
# Global Settings
# =========================================================================

set :application, 'ldapr'

require 'infrad'

Infrad.deploy(self, app: application)

set(:rails_env) { stage }

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
    desc '[internal] Symlink ruby version'
    task :symlink_ruby_version, :except => { :no_release => true } do
      run "ln -s #{deploy_to}/.ruby-version #{release_path}"
    end
    after 'deploy:update_code', 'deploy:ifad:symlink_ruby_version'
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
