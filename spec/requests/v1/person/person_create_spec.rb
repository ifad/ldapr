require 'spec_helper'

describe LDAPR::Application do
  context "create an entry on AD" do
    it "returns a successful response" do
      post '/v1/ifad/persons'

      expect(response.status).to eq 201
    end

    it 'adds and entry to ldap' do
      expect { post '/v1/ifad/persons' }
        .to change { LDAPR::LDAP.servers['ifad'].person_class.all.count }
        .by(1)
    end
  end
end
