require 'spec_helper'

describe LDAPR::Application do

  before(:each) { clean_up_ldap }

  let(:account_name) { "test.account1" }

  describe "create an entry on AD" do
    it "returns a successful response" do
      create_request(account_name: account_name )

      expect(response.status).to eq 201
    end

    it 'adds and entry to ldap' do
      expect { create_request(account_name: account_name) }
        .to change { LDAPR::LDAP.connection.search(base: dn_for_account_name(account_name), return_result: true) }
        .from(nil)
    end

    context 'when an entry with the same account_name already exists' do
      before(:each) { create_request(account_name: account_name) }

      it "returns an unprocessable entity status code" do
        expect(
          create_request(account_name: account_name)
        ).to eq 422
      end
    end
  end
end
