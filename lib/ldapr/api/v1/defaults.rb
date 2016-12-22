module LDAPR
  module API
    module V1
      module Defaults

        def self.included(base)
          base.class_eval do
            require 'rollbar'
            require 'grape-rabl'
            require 'net-ldap'

            version 'v1'

            format :json

            formatter :json, Grape::Formatter::Rabl

            rescue_from Net::LDAP::BindingInformationInvalidError do |e|
              error!(e, 400)
            end

            rescue_from Grape::Exceptions::ValidationErrors do |e|
              error!(e, 400)
            end

            rescue_from :all do |e|
              LDAPR.logger.error(e)
              error_response(message: "Internal server error", status: 500)
            end
          end
        end

      end
    end
  end
end
