require 'spec_helper'

describe LDAPR::Application do

  before(:each) { clean_up_ldap }

  let(:account_name) { "test.234" }

  let(:dn) { dn_for_account_name(account_name) }

  context "when querying a non existent entry" do
    it "returns a successful response" do
      get_request(dn)

      expect(response.status).to eq 200
    end

    it "returns one entry" do
      get_request(dn)

      expect_json_sizes(entries: 0)
    end
  end

  context "when using a leaf dn" do
    before(:each) do
      create_request(account_name: account_name)
    end

    it "returns a successful response" do
      get_request(dn)

      expect(response.status).to eq 200
    end

    it "returns one entry" do
      get_request(dn)

      expect_json_sizes(entries: 1)
    end

    it "returns the ldap entry with account_name as display name" do
      get_request(dn)

      expect_json('entries.0.entry', displayname: account_name)
    end

    it "concatenates multivalue attributes separated by comma" do
      get_request(dn)

      expect_json('entries.0.entry', objectclass: "top, person, organizationalPerson, user")
    end
  end

  context "when querying with a base dn that has multiple nodes under" do
    let(:dn) { LDAPR::LDAP.connection.base }

    before(:each) do
      (1...3).each do |i|
        expect(create_request(account_name: "test account #{i}")).to eq 201
      end
    end

    context  "without specifying the scope" do
      it "returns the whole subtree" do
        get_request(dn)

        expect_json_sizes(entries: 3)
      end
    end
  end
end
