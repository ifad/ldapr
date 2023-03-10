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
require './ldap'

ROOT = ENV['RAILS_RELATIVE_URL_ROOT'] || '/l'

use Rack::Session::Cookie, :expire_after => 300,
  :key => '_ldapr', :secret => '874fmajr39jf&*H#jfb1!@'

use OmniAuth::Builder do
  provider :cas, host: 'cas.ifad.org'
  configure {|c| c.path_prefix = ROOT}
end

get "#{ROOT}.?:format?" do
  if session[:user].blank?
    if request.query_string.present?
      session[:req] = request.fullpath
    end
    redirect "#{ROOT}/cas"
  end

  format = params['format'] || 'html'
  query  = params.inject({}) do |h, (k,v)|
    v = %w( no false ).include?(v) ? false : v
    %w( splat captures format ).include?(k) ? h : h.update(k => v)
  end

  if query.empty?
    erb :index

  else
    people = LDAP::Person.search(query)
    result, type, disposition = Export.new(people, self).process(format)

    halt 400, 'Invalid format' if result.blank?

    filename = "#{Time.now.strftime('%Y%m%d-%H%I')}.#{format}"
    filename = "#{LDAP.environment}-ldapr-people-#{filename}"

    headers \
      'Content-Type' => type,
      'Content-Disposition' => "#{disposition}; filename=\"#{filename}\""
    body result
  end
end

get "#{ROOT}/cas/callback" do
  auth = request.env['omniauth.auth']

  session[:user] = auth.uid
  redirect session.delete(:req) || ROOT
end

get "#{ROOT}/sys/healthcheck" do
  'OK'
end

get "#{ROOT}/logout" do
  session[:user] = nil
end

get "#{ROOT}/failure" do
  halt 403, 'Unauthorized'
end
