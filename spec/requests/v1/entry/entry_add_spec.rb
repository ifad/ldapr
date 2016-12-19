require 'spec_helper'

describe LDAPR::Application do

  before(:each) { clean_up_ldap }

  describe "create an entry on AD" do
    it "returns a successful response" do
      create_person_request

      expect(response.status).to eq 201
    end

    it 'adds and entry to ldap' do
      expect { create_person_request }
        .to change { LDAPR::LDAP.servers['test'].person_class.all.count }
        .by(1)
    end
  end
end
