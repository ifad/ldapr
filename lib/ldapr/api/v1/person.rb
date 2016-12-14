module LDAPR
  module API
    module V1
      class Person < Grape::API
        include API::V1::Defaults

        helpers do
          def person_class
            LDAP.servers[server_name].person_class
          end

          def server_name
            params[:server_name]
          end
        end

        route_param :server_name do
          resource :people do

            desc "Get by account name"
            params do
              optional :account_name, type: String
            end
            get do
              if params[:account_name]
                person_class.find_by_account(params[:account_name]) || error!(:not_found, 404)
              else
                person_class.all
              end
            end

            desc 'Create a person on ldap.'
            params do
              #requires :status, type: String, desc: 'Your status.'
            end
            post do
              person = person_class.new({
                :account_name     => 'asdfame',
                :first_name       => 'givenNasdfame',
                :last_name        => 'snasdf',
                :dn               => "CN=Jsadfdf121 Frupper 121,ou=Test,ou=People,dc=IFAD,dc=ORG"
              })

              person.save!
            end

          end
        end
      end
    end
  end
end
