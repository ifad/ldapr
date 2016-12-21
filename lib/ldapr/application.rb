require 'grape'
require_relative 'api'

require 'byebug' if development?

module LDAPR
  class Application < Grape::API
    mount API::V1::Entry
  end
end
