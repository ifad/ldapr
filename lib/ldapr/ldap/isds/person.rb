module LDAPR
  module LDAP
    module ISDS
      class Person
        def self.default_filter
          valid_account  = Net::LDAP::Filter.eq('uid', '*')

          with_email = Net::LDAP::Filter.present('mail')

          filter_only_person & valid_account & with_email
        end

        alias :login  :uid
        alias :account_name :uid
      end
    end
  end
end
