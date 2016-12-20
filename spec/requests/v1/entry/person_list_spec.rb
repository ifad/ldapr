require 'spec_helper'

describe LDAPR::Application do
  context "get all ldap entries" do
    xit "returns a successful response" do
      get '/v1/test/people'

      expect(response.status).to eq 200
    end
  end
end
