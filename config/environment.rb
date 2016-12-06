ENV['RACK_ENV'] ||= 'development'

def env
  ENV['RACK_ENV']
end

# Load initializers in config/initializers
Dir["#{File.dirname(__FILE__)}/initializers/*.rb"].sort.each {|f| require f}
