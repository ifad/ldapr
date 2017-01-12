module LDAPR
  module Helpers
    BASE_URL="/v1/entries/"

    def entry_url(dn)
      BASE_URL + CGI::escape(dn)
    end

    def clean_up_ldap
      LDAP.authenticate(ENV['LDAP_SERVER_USERNAME'], ENV['LDAP_SERVER_PASSWORD'])
      LDAP.connection.search( :return_result => true).each do |entry|
        LDAP.connection.delete(dn: entry.dn)
      end
    end

    def dn_for_account_name(account_name)
      "CN=#{account_name},#{LDAP.connection.base}"
    end

    def get_request(dn:, username: ENV['LDAP_SERVER_USERNAME'], password: ENV['LDAP_SERVER_PASSWORD'])
      get(entry_url(dn), username: username, password: password)
    end

    def put_request(dn:, attributes: {}, username: ENV['LDAP_SERVER_USERNAME'], password: ENV['LDAP_SERVER_PASSWORD'])
      put(entry_url(dn), attributes: attributes, username: username, password: password)
    end


    def patch_request(dn:, attributes: {}, username: ENV['LDAP_SERVER_USERNAME'], password: ENV['LDAP_SERVER_PASSWORD'])
      patch(entry_url(dn), attributes: attributes, username: username, password: password)
    end

    def delete_request(dn:, username: ENV['LDAP_SERVER_USERNAME'], password: ENV['LDAP_SERVER_PASSWORD'])
      delete(entry_url(dn), username: username, password: password)
    end

    def thumbnaildata
      Base64.encode64(File.read("#{File.dirname(__FILE__)}/thumbnail.png"))
    end

    def create_request(
          account_name: 'test.account',
          objectClass: ["top", "person", "organizationalPerson", "user"],
          proxyAddresses: ["address1", "address2"],
          mail: "#{account_name}@ifad.org",
          username: ENV['LDAP_SERVER_USERNAME'],
          password: ENV['LDAP_SERVER_PASSWORD'])

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
        "proxyAddresses":     proxyAddresses,
        "thumbnailPhoto":     thumbnaildata
      }

      post(entry_url(dn), attributes: attributes, username: username , password: password)

      response.status
    end
  end

  RSpec.configure do |config|
    config.include LDAPR::Helpers
  end

end
