module LDAPR
  module API
    module V1
      class Entry < Grape::API
        include API::V1::Defaults

        resource :entries do
          params do
            requires :username, type: String, desc: "LDAP binding username"
            requires :password, type: String, desc: "LDAP binding password"
            requires :dn, type: String, desc: "LDAP entry Distinguished Name", documentation: { default: "uid=test,dc=example,dc=com" }
          end

          route_param :dn, requirements: { dn: /.*/ } do

            before do
              params['dn'] = CGI::unescape(params['dn'])

              result, message = LDAP.authenticate(params['username'], params['password'])
              unless result
                error!("LDAP authentication failed: #{message}", 401)
              end
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

            desc 'Update or create an entry, assuming nil for non given attributes'
            params do
              requires :attributes, type: Hash
            end
            put do
              entry = LDAP.connection.search(base: params[:dn], return_result: true, scope: Net::LDAP::SearchScope_BaseObject)
              if entry
                ops = params['attributes'].map do |name, value|
                  [:replace, name, value]
                end
                LDAP.connection.modify(dn: params[:dn], operations: ops)
              else
                result = LDAP.connection.add(dn: params['dn'], attributes: params['attributes'])

                error!("Create failed: #{LDAP.connection.get_operation_result.message}", 422) unless result
                status 201
              end
            end

            desc 'Mofidy an entry, updating only the attributes included in the request'
            params do
              requires :attributes, type: Hash
            end
            patch do
              params['attributes'].each do |name, value|
                result = LDAP.connection.replace_attribute(params['dn'], name, value)
                error!("Update failed: #{LDAP.connection.get_operation_result.message}", 422) unless result
              end

              status 200
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
