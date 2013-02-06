source :rubygems

gem 'sinatra'
gem 'omniauth'
gem 'omniauth-cas'
gem 'net-ldap', '0.2.2'
gem 'active_support'
gem 'i18n', :require => false

group :development do
  gem 'debugger'
  gem 'capistrano'
  gem 'capistrano-ext'
end

group :staging, :production do
  gem 'unicorn'
end
