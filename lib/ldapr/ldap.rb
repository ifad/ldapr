module LDAPR
  module LDAP
    require 'ldap_model'
    require_relative 'ldap/server'

    def self.servers
      @@servers ||= establish_ldap_connections
    end

    protected

      def self.establish_ldap_connections
        servers = Hash.new
        ldap_server_names.each do |server_name|
          servers[server_name] = Server.new(server_name)
        end
        servers
      end

      def self.ldap_server_names
        ENV['LDAP_SERVER_NAMES'].split(/,\s/)
      end

  end
end
