module LDAPR
  module LDAP
    module AD
      class Person
        validates :sn, presence: true, unless: :generic?

        alias :login  :account_name
        alias :groups :member_of

        def self.default_filter
          valid_account  = Net::LDAP::Filter.eq('sAMAccountName', '*')

          with_firstname = Net::LDAP::Filter.present('givenName')

          filter_only_person & valid_account & with_firstname
        end
      end
    end
  end
end
