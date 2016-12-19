module LDAPR
  module Helpers

    def clean_up_ldap
      LDAP.connection.search( :return_result => true).each do |entry|
        puts "DN: #{entry.dn}"
        LDAP.connection.delete(dn: entry.dn)
        byebug
      end
    end

    def create_person_request(account_name: 'test.account')
      dn = "CN=#{account_name},ou=test,OU=People,DC=ifad,DC=org"

      attributes = {
        objectClass: ['top', 'person', 'organizationalPerson', 'user'],
        cn: account_name,
        sn: 'account',
        givenName: 'test',
        displayName: account_name,
        name: account_name,
        userAccountControl: 546,
        employeeID: 'G00680',
        sAMAccountName: account_name,
        #sAMAccountType: '805306368',
        otherMobile: '+393286171666',
        otherMailbox: "#{account_name}@gmail.com",
        #userPrincipalName: "#{account_name}s.trochon@ifad.org"
      }

      post("/v1/ldap/#{dn}", attributes: attributes)
    end
  end

  RSpec.configure do |config|
    config.include LDAPR::Helpers
  end

end
