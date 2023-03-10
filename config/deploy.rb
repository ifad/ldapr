# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.16.0'

# Default Capistrano branch is master
# Deploy to another branch by using `BRANCH=develop cap stage deploy`
set :branch, ENV['BRANCH'] || ENV['BRANCH_NAME'] || fetch(:branch)
set :ssh_options, { :forward_agent => true }

set(:rails_env) { fetch(:stage).to_s.gsub(/_new$/, '').to_sym }

%w[log tmp/pids vendor/bundle].each do |linked_dir|
  append :linked_dirs, linked_dir
end

['config/ldap.yml'].each do |linked_file|
  append :linked_files, linked_file
end

# Default value for keep_releases is 5
# set :keep_releases, 5

set :bundle_config, { deployment: true, force_ruby_platform: true }

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:web) do
      execute 'sudo systemctl restart ldapr-unicorn'
    end
  end
end

set :rollbar_token, ''
set :rollbar_env, -> { fetch :stage }
set :rollbar_role, -> { :app }

set :assets_roles, %i[app web]
set :skip_migrations, false

after 'deploy', 'deploy:cleanup'
after 'deploy', 'deploy:restart'

set :bundle_flags, "--deployment --quiet --binstubs --path vendor/bundle"
set :rake,         "bundle exec rake"

