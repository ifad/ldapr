module LDAPR
  module Helpers

    def clean_up_ldap
      LDAP.connection.search( :return_result => true).each do |entry|
        LDAP.connection.delete(dn: entry.dn)
      end
    end

    def dn_for_account_name(account_name)
      "CN=#{account_name},#{LDAP.connection.base}"
    end

    def get_request(dn)
      get "/v1/ldap/#{CGI::escape(dn)}"
    end

    def update_request(dn: dn, attributes: {})
      patch "/v1/ldap/#{CGI::escape(dn)}", attributes: attributes
    end

    def delete_request(dn)
      delete "/v1/ldap/#{CGI::escape(dn)}"
    end

    def create_request(
          account_name: 'test.account',
          objectClass: ["top", "person", "organizationalPerson", "user"],
          proxyAddresses: ["address1", "address2"],
          mail: "#{account_name}@ifad.org")

      dn = dn_for_account_name(account_name)

      attributes = {
        "givenName":          account_name,
        "sn":                 "last",
        "displayName":        account_name,
        "mail":               mail,
        "sAMAccountName":     account_name,
        "userPrincipalName":  "#{account_name}@ifad.org",
        "userAccountControl": "544",
        "objectClass":        objectClass,
        "cn":                 account_name,
        "employeeNumber":     account_name,
        "proxyAddresses":     proxyAddresses
      }

      post("/v1/ldap/#{CGI::escape(dn)}", attributes: attributes)

      response.status
    end
  end

  RSpec.configure do |config|
    config.include LDAPR::Helpers
  end

end
