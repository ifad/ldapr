require 'grape'
require_relative 'api'

module LDAPR
  class Application < Grape::API
    mount API::V1::Person
    mount API::V1::Group
  end
end
