module LDAPR
  module LDAP
    def self.test_server_name
      ldap_server_names.first
    end

    def self.test_server
      servers[test_server_name]
    end

    def self.clean_up_ldap
      test_server.person_class.all.each(&:destroy)
    end

  end
end
