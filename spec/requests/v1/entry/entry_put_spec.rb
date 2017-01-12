require 'spec_helper'

describe LDAPR::Application do

  before(:each) { clean_up_ldap }

  let(:account_name) { "test.234" }

  let(:dn) { dn_for_account_name(account_name) }

  subject do
    put_request(dn: dn, attributes: { mail: updated_mail, proxyAddresses: updated_proxy_addresses})
  end

  context "when the entry already exists" do
    before(:each) do
      create_request(account_name: account_name, mail: original_mail, proxyAddresses: original_proxy_addresses)
    end

    it_behaves_like "updating entry attributes"

  end

  context "when the entry does not exist" do

    before(:each) do
      get_request(dn: dn)
      expect_json_sizes(entries: 0)
    end

    context "when providing all required attributes" do
      let(:account_name) { 'test.account' }
      let(:objectClass) { ["top", "person", "organizationalPerson", "user"] }
      let(:proxyAddresses) { ["address1", "address2"] }
      let(:mail) { "#{account_name}@ifad.org" }

      subject do
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

        put_request(dn: dn, attributes: attributes)
      end

      it "returns a successful response" do
        subject

        expect(response.status).to eq 201
      end

      it "creates the entry" do
        subject
        get_request(dn: dn)
        expect_json_sizes(entries: 1)
      end
    end
  end
end
