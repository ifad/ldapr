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

            desc "Get all"
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
              requires :account_name, type: String, desc: 'The account name'
              optional :first_name, type: String
              optional :last_name, type: String
            end
            post do
              cn = [params['first_name'], params['last_name']].join(' ').strip

              dn = "CN=#{cn},#{person_class.base.first}"
              person = person_class.new(dn: dn)

              person.last_name = params['last_name']
              person.first_name =   params['first_name']
              person.account_name = params['account_name']
              person.save!
            end

            route_param :account_name, requirements: { account_name: /.*/ } do
              desc 'Get by account name'
              params do
                requires :account_name, type: String
              end
              get do
                person = person_class.find_by_account(params['account_name'])
                present person, with: API::Presenters::Person
              end

              desc 'Update a person on ldap'
              params do
                requires :account_name, type: String
                optional :avatar, type: String
              end

              put do
                person_class.find_by_account(params['account_name'])
              end

            end
          end
        end
      end
    end
  end
end
