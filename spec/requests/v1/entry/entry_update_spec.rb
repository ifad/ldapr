require 'spec_helper'

describe LDAPR::Application do

  before(:each) { clean_up_ldap }

  let(:account_name) { "test.234" }

  let(:dn) { dn_for_account_name(account_name) }

  let(:original_mail) { "test@test.com" }

  let(:updated_mail) { "updated@test.com" }

  def get_request
    get "/v1/ldap/#{CGI::escape(dn)}"
  end

  def update_request(attributes: {})
    patch "/v1/ldap/#{CGI::escape(dn)}", attributes: attributes
  end

  context "when updating an existing entry" do
    before(:each) do
      create_person_request(account_name: account_name, mail: original_mail)
    end

    context "and an existing " do
      context "single value attribute" do
        it "returns a successful response" do
          update_request(attributes: { mail: updated_mail})

          expect(response.status).to eq 200
        end

        it "updates the attribute value" do
          get_request
          expect expect_json('entries.0.entry', mail: original_mail)

          update_request(attributes: { mail: updated_mail})

          get_request
          expect expect_json('entries.0.entry', mail: updated_mail)
        end
      end

      context "multivalue attribute" do

      end
    end
  end
end
