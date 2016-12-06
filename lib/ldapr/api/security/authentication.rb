module LDAPR
  module API
    module Security

      module Authentication
        def self.included(base)
          base.class_eval do
            include Helpers

            # HTTP header based authentication
            before { authenticate  if requires_authentication? }
          end
        end

        module Helpers
          def authenticate
            return true
            if (credentials = basic_auth_credentials)
              user, password = credentials
              error! 'Forbidden', 403 unless user.present? && password.present?

              application_tokens.key?(password) || error!('Forbidden', 403)
            else
              error! 'Authentication required', 401, 'WWW-Authenticate' => 'Basic realm="LDAPR"'
            end
          end

          protected

          def tokens
            @_tokens ||= YAML.load_file('config/api-tokens.yml')
          end

          def application_tokens
            tokens['applications']
          end

          def authentication_data
            @_auth_data ||= Rack::Auth::Basic::Request.new(env)
          end

          def basic_auth?
            authentication_data.provided? && authentication_data.basic?
          end

          def requires_authentication?
            request.request_method != 'OPTIONS'
          end

          def basic_auth_credentials
            authentication_data.credentials if basic_auth?
          end

        end
      end
    end
  end
end
