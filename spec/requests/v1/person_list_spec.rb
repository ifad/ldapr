require 'spec_helper'

describe LDAPR::Application do
  context "get all ifad ldap entries" do
    it "returns a successful response" do
      get '/v1/persons', server_name: 'ifad'

      expect(response.status).to eq 200
    end
  end
end
