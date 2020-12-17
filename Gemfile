source 'https://rubygems.org'

ruby '2.6.6'

gem 'sinatra'
gem 'omniauth'
gem 'omniauth-cas'
gem 'net-ldap'
gem 'activesupport'
gem 'i18n', :require => false

group :development do
  gem 'infrad', git: 'git@code.ifad.org:infrad.git'
  gem 'byebug'
  gem 'capistrano', '~> 2.15.9'
end

group :staging, :production do
  gem 'unicorn'
end
