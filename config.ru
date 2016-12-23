require 'rubygems'
require 'bundler/setup'

use Rack::Config do |env|
  env['api.tilt.root'] = File.expand_path("../lib/ldapr/api/v1/views", __FILE__)
end

$: << File.expand_path("../lib", __FILE__)

require File.expand_path('../config/environment', __FILE__)
require 'ldapr'

use Rack::Static, :urls => ["/docs/"], :root => 'public/api', :index =>
  'index.html'

run LDAPR::Application
