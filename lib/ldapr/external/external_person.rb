module LDAPR
  module External

    class ExternalPerson < LDAP::Model::ISDS::Person
      establish_connection(LDAP::Config.read_conf('external'))

      scope Net::LDAP::SearchScope_WholeSubtree

      base C_.external_ldap_people_base

      def self.default_filter
        valid_account  = Net::LDAP::Filter.eq('uid', '*')

        with_email = Net::LDAP::Filter.present('mail')

        filter_only_person & valid_account & with_email
      end

      alias :login  :uid
      alias :account_name :uid

      def active?
        true
      end
    end

  end
end
