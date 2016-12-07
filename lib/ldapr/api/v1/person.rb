module LDAPR
  module API
    module V1
      class Person < Grape::API
        include API::V1::Defaults

        resource :persons do
          desc "Return a list of ldap entries"
          get do
            server_name = params[:server_name]

            person_class(server_name).all
          end
        end
      end
    end
  end
end
