require 'spec_helper'

describe LDAPR::Application do

  before(:each) { clean_up_ldap }

  let(:account_name) { "test234" }

  let(:dn) { dn_for_account_name(account_name) }

  context "when the entry exists" do
    before(:each) do
      create_request(account_name: account_name)
    end

    it "returns a successful response" do
      delete_request(dn)

      expect(response.status).to eq 200
    end

    it "removes the entry from ldap" do
      get_request(dn)
      expect_json_sizes(entries: 1)

      delete_request(dn)

      get_request(dn)

      expect_json_sizes(entries: 0)
    end
  end

  context "when the entry does not exist" do
    it "returns a successful response" do
      delete_request(dn)

      expect(response.status).to eq 422
    end
  end
end
