shared_examples "updating entry attributes" do
  let(:original_mail) { "test@test.com" }
  let(:original_proxy_addresses) { ["address2", "address1"] }

  let(:updated_mail) { "updated@test.com"}
  let(:updated_proxy_addresses) { ["up_address2", "up_address1"] }

  context "single value attribute" do
    it "returns a successful response" do
      subject

      expect(response.status).to eq 200
    end

    it "updates the attribute value" do
      get_request(dn: dn)
      expect_json('entries.0.entry', mail: original_mail)

      subject

      get_request(dn: dn)
      expect_json('entries.0.entry', mail: updated_mail)
    end
  end

  context "multivalue attribute" do
    it "updates the attribute value" do
      get_request(dn: dn)

      original_proxy_addresses.each do |address|
        expect_json('entries.0.entry', proxyaddresses: regex(address))
      end

      subject

      get_request(dn: dn)

      updated_proxy_addresses.each do |address|
        expect_json('entries.0.entry', proxyaddresses: regex(address))
      end
    end
  end
end
