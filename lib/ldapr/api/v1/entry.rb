module LDAPR
  module API
    module V1
      class Entry < Grape::API
        include API::V1::Defaults

        resource :ldap do

          route_param :dn, requirements: { dn: /.*/ }, type: String,
            desc: 'The ldap Distinguished Name, for example: uid=mreynolds,dc=example,dc=com' do

            before do
              params['dn'] = CGI::unescape(params['dn'])
            end

            desc 'Search for an ldap entry'
            get rabl: "entries.rabl" do
              @entries = LDAP.connection.search(
                base: params['dn'], return_result: true
              )
            end

            desc 'Add an ldap entry'
            params do
              requires :attributes, type: Hash
            end
            post do
              result = LDAP.connection.add(dn: params['dn'], attributes: params['attributes'])

              error!("Create failed: #{LDAP.connection.get_operation_result.message}", 422) unless result
              status 201
            end

            desc 'Mofidy an entry'
            patch do

            end

            desc 'Delete an entry'
            delete do
              result = LDAP.connection.delete(dn: params['dn'])

              error!("Delete failed: #{LDAP.connection.get_operation_result.message}", 422) unless result
              status 200
            end
          end
        end
      end
    end
  end
end
