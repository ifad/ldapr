require 'rubygems'
require 'bundler/setup'

$: << File.expand_path("../lib", __FILE__)

require File.expand_path('../config/environment', __FILE__)
require 'ldapr'

run LDAPR::Application
