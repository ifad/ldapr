module LDAPR
  module Helpers
    def test_server_name
      LDAPR::LDAP.ldap_server_names.first
    end

    def test_server
      LDAPR::LDAP.servers[test_server_name]
    end

    def clean_up_ldap
      test_server.person_class.all.each(&:destroy)
    end

    def create_person_request(server_name: 'test', account_name: 'test.account', first_name: 'first', last_name: 'last')
      post("/v1/#{server_name}/people", account_name: account_name, first_name: first_name, last_name: last_name)
    end
  end

  RSpec.configure do |config|
    config.include LDAPR::Helpers
  end

end
