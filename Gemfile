source 'https://rubygems.org'

ruby '2.6.10'

gem 'sinatra'
gem 'omniauth'
gem 'omniauth-cas'
gem 'net-ldap'
gem 'activesupport'
gem 'i18n', :require => false

group :development do
  gem 'infrad', git: 'git@github.com:ifad/infrad.git', ref: 'capistrano2'
  gem 'byebug'
  gem 'capistrano', '~> 2.15.9'

  gem 'net-ssh'
  gem 'ed25519'
  gem 'bcrypt_pbkdf'
end

group :staging, :production do
  gem 'unicorn'
end
