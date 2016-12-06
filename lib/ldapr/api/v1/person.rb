module LDAPR
  module API
    module V1
      class Person < Grape::API
        include API::V1::Defaults
        include LDAPR::LDAP

        resource :persons do
          desc "Return a list of ldap entries"
          get do
            ::IFAD::Person.active
          end
        end
      end
    end
  end
end
