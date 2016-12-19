module LDAPR
  module API
    module V1
      class Entry < Grape::API
        include API::V1::Defaults

        helpers do

        end

        resource :ldap do

          route_param :dn, requirements: { dn: /.*/ }, type: String,
            desc: 'The ldap Distinguished Name, for example: uid=mreynolds,dc=example,dc=com' do

            desc 'Search for an ldap entry'
            get do
              LDAP.connection.search(base: params['dn'], return_result: false) do |entries|
                present entry, with: API::Presenters::Person
              end
            end

            desc 'Add an ldap entry'
            params do
              requires :attributes, type: Hash
            end
            post do
              success, message = LDAP.connection.add(dn: params['dn'], attributes: params['attributes'])
              raise Error, "Create failed: #{message}" unless success
              status 201
            end

            desc 'Mofidy an entry'
            patch do

            end

            desc 'Delete an entry'
            delete do

            end
          end
        end
      end
    end
  end
end
