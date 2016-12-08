module LDAPR
  module API
    module V1
      class Group < Grape::API
        include API::V1::Defaults

        # TODO validate param only ifad allowed
        route_param :server_name do
          resource :groups do
            desc "Return a list of ldap entries"
            get do
              server_name = params[:server_name]

              LDAP.servers[server_name].group_class.all
            end
          end
        end
      end
    end
  end
end
