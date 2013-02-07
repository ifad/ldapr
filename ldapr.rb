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

use Rack::Session::Cookie, :expire_after => 300, :path => ROOT

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

  format = params['format'] || 'csv'
  query  = params.inject({}) do |h, (k,v)|
    %w( splat captures format ).include?(k) ? h : h.update(k => v)
  end

  if query.empty?
    erb :index

  else
    result, type, disposition = Export.process(query, format)

    halt 400, 'Invalid format' if result.blank?

    filename = "#{Time.now.strftime('%Y%m%d-%H%I')}.#{format}"
    headers \
      'Content-Type' => type,
      'Content-Disposition' => "#{disposition}; filename=\"ldapr-export-#{filename}"
    body result
  end
end

get "#{ROOT}/cas/callback" do
  auth = request.env['omniauth.auth']

  session[:user] = auth.uid
  redirect session.delete(:req) || ROOT
end

get "#{ROOT}/logout" do
  session[:user] = nil
end

get "#{ROOT}/failure" do
  halt 403, 'Unauthorized'
end
