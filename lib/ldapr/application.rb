require 'grape'
require_relative 'api'

module LDAPR
  class Application < Grape::API
    mount API::V1::Person
  end
end
