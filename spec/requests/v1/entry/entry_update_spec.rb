require 'spec_helper'

describe LDAPR::Application do

  before(:each) { clean_up_ldap }

  let(:account_name) { "test.234" }

  let(:dn) { dn_for_account_name(account_name) }

  let(:original_mail) { "test@test.com" }

  let(:original_proxy_addresses) { ["address2", "address1"] }

  before(:each) do
    create_request(account_name: account_name, mail: original_mail, proxyAddresses: original_proxy_addresses)
  end

  context "when updating an existing entry" do
    context "and an existing" do
      context "single value attribute" do
        let(:updated_mail) { "updated@test.com" }

        it "returns a successful response" do
          update_request(dn: dn, attributes: { mail: updated_mail})

          expect(response.status).to eq 200
        end

        it "updates the attribute value" do
          get_request(dn: dn)
          expect_json('entries.0.entry', mail: original_mail)

          update_request(dn: dn, attributes: { mail: updated_mail})

          get_request(dn: dn)
          expect_json('entries.0.entry', mail: updated_mail)
        end
      end

      context "multivalue attribute" do
        let(:updated_proxy_addresses) { ["test", "updated"] }

        it "updates the attribute value" do
          get_request(dn: dn)

          original_proxy_addresses.each do |address|
            expect_json('entries.0.entry', proxyaddresses: regex(address))
          end

          update_request(dn: dn, attributes: { proxyAddresses: updated_proxy_addresses })

          get_request(dn: dn)

          updated_proxy_addresses.each do |address|
            expect_json('entries.0.entry', proxyaddresses: regex(address))
          end
        end
      end
    end
  end
end
