# =========================================================================
# Global Settings
# =========================================================================

set :application, 'ldapr'

require 'infrad'

Infrad.deploy(self, app: application)

set(:rails_env) { fetch(:stage).to_s.sub('_new', '') }
set :branch, ENV['BRANCH'] || ENV['BRANCH_NAME'] || fetch(:branch)

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
    run 'sudo systemctl restart ldapr-unicorn'
  end

  desc "[internal] Updates the symlink for database configuration files to the just deployed release."
  task :symlink_config do
    configs = %w( ldap.yml ).map {|c| [shared_path, 'config', c].join('/') }
    run "ln -s #{configs.join(' ')} #{release_path}/config"
  end
end

after 'deploy', 'deploy:cleanup'
after 'deploy:setup', 'deploy:setup_config'
after 'deploy:update_code', 'deploy:symlink_config'

require 'bundler/capistrano'
set :bundle_flags, "--deployment --quiet --binstubs #{deploy_to}/bin"
set :rake,         'bundle exec rake'
