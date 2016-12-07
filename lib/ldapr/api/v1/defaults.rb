module LDAPR
  module API
    module V1

      module Defaults
        def self.included(base)
          base.class_eval do
            require 'ldap_model'
            require 'rollbar'

            # common Grape settings
            version 'v1'
            format :json

            # global exception handler, used for error notifications
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
