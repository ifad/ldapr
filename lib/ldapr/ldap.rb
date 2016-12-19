module LDAPR
  module LDAP
    class Error < StandardError
    end

    require 'net/ldap'

    def self.connection
      raise Error, "Connection not established" unless connected?
      @connection
    end

    def self.config
      @config ||= {
        host:         ENV['LDAP_SERVER_HOSTNAME'],
        port:         (ENV['LDAP_SERVER_PORT'] || 389).to_i,
        base:         ENV['LDAP_SERVER_BASE'],
        encryption:   ENV['LDAP_SERVER_ENCRYPTION'],
        username:     ENV['LDAP_SERVER_USERNAME'],
        password:     ENV['LDAP_SERVER_PASSWORD']
      }
    end

    def self.establish_connection
      @connection = Net::LDAP.new(
        base:       config[:base],
        host:       config[:host],
        port:       config[:port],
        encryption: config[:encryption],
        auth:       {
          method:   :simple,
          username: config[:username],
          password: config[:password]
        }
      )

      unless @connection.bind
        reason = @connection.get_operation_result.message
        @connection = nil
        raise Error, "LDAP bind to #{config[:hostname]} failed: #{reason}"
      end

      true
    end

    def self.connected?
      !!@connection
    end
  end
end
