require 'grape'
require 'grape-swagger'
require_relative 'api'

module LDAPR
  class Application < Grape::API
    mount API::V1::Entry

    add_swagger_documentation(base_path: "/", api_version:'v1', hide_documentation_path: true)
  end
end
