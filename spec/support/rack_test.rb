require 'rack/test'

module RackTestMixin
  include Rack::Test::Methods

  alias :response :last_response

  def app
    described_class
  end
end

RSpec.configure do |config|
  config.include RackTestMixin
end
