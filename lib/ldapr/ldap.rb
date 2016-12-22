module LDAPR
  module LDAP
    class Error < StandardError
    end

    require 'net/ldap'

    def self.connection
      @connection ||= initialize_connection
    end

    def self.authenticate(username, password)
      connection.authenticate(username, password)

      unless connection.bind
        reason = connection.get_operation_result.message
        return [false, reason]
      end

      [true, nil]
    end

    private

      def self.config
        @config ||= {
          host:         ENV['LDAP_SERVER_HOSTNAME'],
          port:         (ENV['LDAP_SERVER_PORT'] || 389).to_i,
          base:         ENV['LDAP_SERVER_BASE'],
          encryption:   ENV['LDAP_SERVER_ENCRYPTION'],
        }
      end

      def self.initialize_connection
        @connection = Net::LDAP.new(
          base:       config[:base],
          host:       config[:host],
          port:       config[:port],
          encryption: config[:encryption],
          auth:       {
            method:   :simple
          }
        )

        true
      end
  end
end
