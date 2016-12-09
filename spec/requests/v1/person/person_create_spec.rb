require 'spec_helper'

describe LDAPR::Application do
  context "create an entry on AD" do
    it "returns a successful response" do
      post '/v1/ifad/persons'

      expect(response.status).to eq 201
    end
  end
end
