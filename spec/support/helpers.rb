module LDAPR
  module Helpers

    def clean_up_ldap
      LDAP.connection.search( :return_result => true).each do |entry|
        puts "DN: #{entry.dn}"
        LDAP.connection.delete(dn: entry.dn)
      end
    end

    def dn_for_account_name(account_name)
      "CN=#{account_name},#{LDAP.connection.base}"
    end

    def create_person_request(account_name: 'test.account')
      dn = dn_for_account_name(account_name)

      attributes = {
        "givenName"=>"first",
        "sn"=>"last",
        "displayName"=>account_name,
        "mail"=>"#{account_name}@ifad.org",
        "sAMAccountName"=>account_name,
        "userPrincipalName"=>"#{account_name}@ifad.org",
        "userAccountControl"=>"544",
        "objectClass"=>["top", "person", "organizationalPerson", "user"],
        "cn"=>account_name
      }

      post("/v1/ldap/#{dn}", attributes: attributes)
    end
  end

  RSpec.configure do |config|
    config.include LDAPR::Helpers
  end

end
