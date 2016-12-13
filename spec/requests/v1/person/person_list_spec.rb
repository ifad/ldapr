require 'spec_helper'

describe LDAPR::Application do
  context "get all ldap entries" do
    it "returns a successful response" do
      get '/v1/test/persons'

      expect(response.status).to eq 200
    end
  end
end
