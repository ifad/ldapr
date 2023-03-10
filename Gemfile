source 'https://rubygems.org'

ruby '2.6.10'

gem 'sinatra'
gem 'omniauth'
gem 'omniauth-cas'
gem 'net-ldap'
gem 'activesupport'
gem 'i18n', :require => false

group :development do
  gem 'byebug'
  gem 'infrad', git: 'git@github.com:ifad/infrad.git'
  gem 'capistrano', '~> 3.16.0', require: false
  gem 'capistrano-bundler', '~> 2.1.0', require: false

  gem 'net-ssh', '>= 5'
  gem 'ed25519'
  gem 'bcrypt_pbkdf'
end

group :staging, :production do
  gem 'unicorn'
end
