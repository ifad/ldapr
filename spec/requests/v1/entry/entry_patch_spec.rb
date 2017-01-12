require 'spec_helper'

describe LDAPR::Application do

  before(:each) { clean_up_ldap }

  let(:account_name) { "test.234" }

  let(:dn) { dn_for_account_name(account_name) }

  subject do
    patch_request(dn: dn, attributes: { mail: updated_mail, proxyAddresses: updated_proxy_addresses})
  end

  before(:each) do
    create_request(account_name: account_name, mail: original_mail, proxyAddresses: original_proxy_addresses)
  end

  it_behaves_like "updating entry attributes"

end
