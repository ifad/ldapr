require 'spec_helper'

describe LDAPR::Application do

  before(:each) { clean_up_ldap }

  let!(:account_name) do
    account_name = "test.234"
    create_person_request(account_name: account_name)
    account_name
  end

  let(:dn) { dn_for_account_name(account_name) }

  subject(:get_request) { get "/v1/ldap/#{CGI::escape(dn)}" }

  context "when using a leaf dn" do

    it "returns a successful response" do
      get_request

      expect(response.status).to eq 200
    end

    it "returns one entry" do
      get_request

      expect_json_sizes(entries: 1)
    end

    it "returns the ldap entry with account_name as display name" do
      get_request

      expect_json('entries.0.entry', displayname: account_name)
    end

    it "concatenates multivalue attributes separated by comma" do
      get_request

      expect_json('entries.0.entry', objectclass: "top, person, organizationalPerson, user")
    end
  end

  context "when querying with a base dn that has multiple nodes under" do
    let(:dn) { LDAPR::LDAP.connection.base }

    before(:each) do
      (1...9).each do |i|
        expect(create_person_request(account_name: "test account #{i}")).to eq 201
      end
    end

    context  "without specifying the scope" do
      it "returns the whole subtree" do
        get_request

        expect_json_sizes(entries: 10)
      end
    end
  end
end
