require 'spec_helper'

describe LDAPR::Application do
  before(:each) { clean_up_ldap }

  let(:account_name) do
    account_name = "test.234"
    create_person_request(account_name: account_name)
    account_name
  end

  subject(:get_request) { get "/v1/ldap/cn=#{account_name}" }

  context "get an ldap entry" do
    it "returns a successful response" do
      get_request
      expect(response.status).to eq 200
    end

    it "returns the ldap entry" do
      get_request
      expect(response.body).account_name to eq account_name
    end
  end
end
