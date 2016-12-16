require 'spec_helper'

describe LDAPR::Application do
  let(:account_name) do
    account_name = "test.234"
    create_person_request(account_name: account_name)
    account_name
  end

  subject(:get_request) { get "/v1/test/people/#{account_name}" }

  context "get all ldap entries" do
    it "returns a successful response" do
      get_request
      expect(response.status).to eq 200
    end

    it "returns the ldap entry" do
      get_request
      expect(response.body).first_name to eq 'test'
    end
  end
end
