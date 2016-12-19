require 'spec_helper'

describe LDAPR::Application do

  before(:each) { clean_up_ldap }

  let(:account_name) { "test.account1" }
  describe "create an entry on AD" do
    it "returns a successful response" do
      create_person_request(account_name: account_name )

      expect(response.status).to eq 201
    end

    it 'adds and entry to ldap' do
      expect { create_person_request(account_name: account_name) }
        .to change { LDAPR::LDAP.connection.search(base: dn_for_account_name(account_name), return_result: true) }
        .from(nil)
    end
  end
end
