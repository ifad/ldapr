require 'spec_helper'

describe LDAPR::Application do
  context "get all ifad ldap entries" do
    it "returns a successful response" do
      get '/v1/ifad/persons'

      expect(response.status).to eq 200
    end
  end

  context "get all external ldap entries" do
    it "returns a successful response" do
      get '/v1/external/persons'

      expect(response.status).to eq 200
    end
  end
end
