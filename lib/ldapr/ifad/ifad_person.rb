module LDAPR
  module LDAP

    module IFAD
      class IfadPerson < ::Model::AD::Person
        require 'active_model'

        establish_connection(LDAP::Config.read_conf('ifad'))

        validates :sn, presence: true, unless: :generic?

        scope Net::LDAP::SearchScope_WholeSubtree

        base C_.ldap_people_base

        def self.default_filter
          valid_account  = Net::LDAP::Filter.eq('sAMAccountName', '*')

          with_firstname = Net::LDAP::Filter.present('givenName')

          filter_only_person & valid_account & with_firstname
        end

        def self.find_by_employee_id(id)
          id = id.to_s.gsub(/\AF|\s/, '')

          base.each do |branch|
            if result = find_one(base: branch, filter: Net::LDAP::Filter.eq('employeeNumber', id))
              return result
            end
          end
          nil
        end

        def self.root
          LDAP::IFAD::Root.find
        end

        def employee_id
          super.try(:gsub, /\s/, '')
        end

        def employee_id=(eid)
          super(eid.to_s.gsub(/\s/, ''))
        end

        ########################################################################
        #
        alias :login  :account_name
        alias :groups :member_of

        def department
          Department.lookup_with_legacy(self.division)
        end

        # Extracts the extension from the given full number
        def extension
          @extension ||= official_phone.try(:sub, C_.ifad_phone_prefix, '')
        end

        def personal_mobile
          @personal_mobile ||= normalize_phone_number(super)
        end

        def official_mobile
          @official_mobile ||= normalize_phone_number(super)
        end

        def self.real_people_dns
          @real_people_dns = C_.ldap_people_real.map {|dn| dn.downcase.split(',').freeze}.freeze
        end

        # Generic accounts are located in OUs outside the ones that are configured
        # to contain real people. However, because our AD is dirty now, there's a
        # "Reception" user in one of these OUs, that's the reason of the he second
        # check against the login below. FIXME until we have Infrastructure clean
        # up Active Directory.
        # Moreover, Marcello, there are some CNs that contain '\,' in the value and
        # we have to ignore them when splitting.
        def generic?
          @generic ||= begin
                         !self.dn.downcase.split(/(?<!\\),/).slice(1..-1).
                           in?(self.class.real_people_dns) || self.login !~ /\./
                       end
        end

        private
        def normalize_phone_number(number)
          return unless number

          number = number.gsub(/\s/, '') # Remove all spaces

          case number
          when /^\+/      then number  # If starting with + it's OK
          when /^00(\d+)/ then "+#$1"  # Replace leading 00 with +
          else
            # If the number starts with the allocated prefixes in the
            # ITU numbering plan http://www.itu.int/oth/T020200006B/en
            # for Italy, then add the +39 prefix; else just add a +
            # in front of it.
            cc = 39 if (9..10).include?(number.size) && number =~ /^3[2-9]/

            ['+', cc, number].join
          end
        end

      end
    end
  end
end
