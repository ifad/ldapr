require 'spec_helper'

describe LDAPR::Application do

  describe "Attempting to get an ldap entry" do
    context "without authentication parameters" do
      it "responds with 400" do
        get(entry_url("ou=org"))

        expect(response.status).to eq 400
      end
    end

    context "with invalid authentication parameters" do
      it "responds with error" do
        get(entry_url("ou=org"), username: "test", password: "test")

        expect(response.status).to eq 401
      end
    end
  end
end
