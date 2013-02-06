require 'active_support/core_ext'

module LDAP
  def self.options
    Hash[
      host:       config['hostname'],
      port:       config['port'],
      encryption: nil,
      auth:       {
        method:   :simple,
        username: config['username'],
        password: config['password']
      }
    ]
  end

  def self.config
    @@config ||= YAML.load_file('config/ldap.yml').fetch(ENV['RACK_ENV'] || 'development')
  end

  def self.connection
    @connection ||= Net::LDAP.new(options)
  end

  # Difference in seconds between the UNIX Epoch (1970-01-01)
  # and the AD Epoch (1601-01-01)
  AD_EPOCH_OFFSET = 11644477200

  def self.ldap_now
    (Time.now.to_i + AD_EPOCH_OFFSET) * 10_000_000
  end

  def self.ldap_at(timestamp)
    Time.at(timestamp / 10_000_000 - AD_EPOCH_OFFSET)
  end

  Person = Struct.new(:login, :email, :other_email, :first_name, :last_name, :active, :extension, :room, :avatar, :division, :mobiles, :groups) unless defined?(Person)

  Person.class_eval do

    def self.base_dn
      'ou=People,dc=IFAD,dc=ORG'
    end

    def self.branches
      [ base_dn, 'ou=People-NALO,ou=People,dc=IFAD,dc=ORG' ]
    end

    def self.attributes
      [
        'accountexpires',
        'givenname',
        'samaccountname',
        'sn',
        'mail',
        'otherMailbox',
        'telephoneNumber',
        'roomNumber',
        'thumbnailPhoto',
        'othermobile',
        'memberof',
        'division'
      ]
    end

    def self.phone_prefix
      '+39065459'
    end

    def self.filter_for(options)
      filter = case options[:active]
      when false
        Net::LDAP::Filter.le('accountExpires', parent.ldap_now.to_s)
      when :any
        Net::LDAP::Filter.eq('accountExpires', '*')
      else
        Net::LDAP::Filter.ge('accountExpires', parent.ldap_now.to_s)
      end

      filter &= Net::LDAP::Filter.eq('objectClass', 'person')
      filter &= Net::LDAP::Filter.eq('sAMAccountName', '*.*')

      options[:attr].try(:each) do |key, val|
        filter &= val.present? ?
          Net::LDAP::Filter.eq(key.to_s, val.to_s) :
          Net::LDAP::Filter.ne(key.to_s, '*')
      end

      return filter
    end

    def self.search(options)
      scope = options[:scope] == :single ?
        Net::LDAP::SearchScope_SingleLevel :
        Net::LDAP::SearchScope_WholeSubtree

      filter = filter_for(options)

      entries = branches.inject([]) do |result, dn|
        result.concat LDAP.connection.search(
          base:       dn,
          filter:     filter,
          attributes: attributes,
          scope:      scope
        )
      end

      entries.map! {|entry| parse(entry)}.compact
    end

    def self.parse(entry)
      # number of nanosec / 100, i.e. 10 times the number of microsec,
      # divide by 10_000_000 so it becomes number of seconds
      expiration = parent.ldap_at(entry[:accountexpires].first.to_i).to_date

      # Extract the extension from the given full number
      entry[:extension] = Array( entry[:telephonenumber].first.to_s.gsub(phone_prefix, '') )

      new(
        entry[:samaccountname].first.presence,
        entry[:mail].first.presence,
        entry[:othermailbox].first.presence,
        entry[:givenname].first.to_s.force_encoding('utf-8').presence,
        entry[:sn].first.to_s.force_encoding('utf-8').presence,
        expiration.future?,
        entry[:extension].first.presence,
        entry[:roomnumber].first.presence,
        entry[:thumbnailphoto].first.presence,
        entry[:division].first.presence,
        entry[:othermobile].map(&:presence).compact,
        entry[:memberof].map(&:upcase)
      )
    end
  end

end

