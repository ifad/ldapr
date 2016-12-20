module LDAPR
  module API
    module V1
      module Defaults

        def self.included(base)
          base.class_eval do
            require 'rollbar'
            require 'grape-rabl'

            version 'v1'

            format :json

            formatter :json, Grape::Formatter::Rabl

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
