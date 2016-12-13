require 'spec_helper'

def make_request
  post("/v1/test/persons")
end

describe LDAPR::Application do

  before(:each) { LDAPR::LDAP.clean_up_ldap }

  describe "create an entry on AD" do
    it "returns a successful response" do
      make_request

      expect(response.status).to eq 201
    end

    it 'adds and entry to ldap' do
      expect { make_request }
        .to change { LDAPR::LDAP.servers['test'].person_class.all.count }
        .by(1)
    end
  end
end
