#!/usr/bin/env ruby
#
# LDAP data extraction tool.
#
#  - m.barnaba@ifad.org  Fri Feb  1 20:34:00 CET 2013
#
require 'rubygems' unless defined?(Gem)
require 'json'
require 'bundler/setup'
Bundler.require

require './export'

ROOT = ENV['RAILS_RELATIVE_URL_ROOT'] || '/l'

use Rack::Session::Cookie, :expire_after => 300

use OmniAuth::Builder do
  provider :cas, host: 'cas.ifad.org'
  configure {|c| c.path_prefix = ROOT}
end

get ROOT do
  if session[:user].blank?
    redirect "#{ROOT}/cas"
  elsif params.empty?
    erb :index
  else
    Export.process(params)
  end
end

get "#{ROOT}/cas/callback" do
  auth = request.env['omniauth.auth']

  session[:user] = auth.uid
  redirect ROOT
end

get "#{ROOT}/logout" do
  session[:user] = nil
end

get "#{ROOT}/failure" do
  halt 403
  'Unauthorized'
end
