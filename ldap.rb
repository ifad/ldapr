require 'active_support/core_ext'

module LDAP
  def self.connection_spec
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
    @connection ||= Net::LDAP.new(connection_spec)
  end

  # Difference in seconds between the UNIX Epoch (1970-01-01)
  # and the AD Epoch (1601-01-01)
  AD_EPOCH_OFFSET = 11644477200

  def self.now
    (Time.now.to_i + AD_EPOCH_OFFSET) * 10_000_000
  end

  def self.at(timestamp)
    # number of nanosec / 100, i.e. 10 times the number of microsec,
    # divide by 10_000_000 so it becomes number of seconds
    Time.at(timestamp.to_i / 10_000_000 - AD_EPOCH_OFFSET)
  end

  class Person
    UTF8_ATTRIBUTES = %w(
      givenName
      sn
      displayName
    ).freeze

    ATTRIBUTES = UTF8_ATTRIBUTES + %w(
      sAMAccountName
      accountExpires
      mail
      otherMailbox
      telephoneNumber
      roomNumber
      thumbnailPhoto
      othermobile
      memberOf
      division
      employeeType
    ).freeze

    def self.base_dn
      'ou=People,dc=IFAD,dc=ORG'
    end

    def self.branches
      [ base_dn, 'ou=People-NALO,ou=People,dc=IFAD,dc=ORG' ]
    end

    def self.attributes
      ATTRIBUTES
    end

    def self.utf8_convert_attributes
      UTF8_ATTRIBUTES
    end

    def self.phone_prefix
      '+39065459'
    end

    def self.filter_for(options)
      filter = case options.delete(:active)
      when false
        Net::LDAP::Filter.le('accountExpires', LDAP.now.to_s)
      when :any
        Net::LDAP::Filter.eq('accountExpires', '*')
      else
        Net::LDAP::Filter.ge('accountExpires', LDAP.now.to_s)
      end

      filter &= Net::LDAP::Filter.eq('objectClass', 'person')
      filter &= Net::LDAP::Filter.eq('sAMAccountName', '*.*')

      options.each do |key, val|
        filter &= val.present? ?
          Net::LDAP::Filter.eq(key.to_s, val.to_s) :
          Net::LDAP::Filter.ne(key.to_s, '*')
      end

      return filter
    end

    def self.search(options)
      options = options.symbolize_keys

      scope = options.delete(:scope) == :single ?
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

      entries.map! {|entry| new(entry)}.compact
    end

    def initialize(entry)
      @dn = entry.dn.dup.tap(&:freeze)
      @attributes = self.class.attributes.inject({}) do |h, attr|
        h.update(attr => entry[attr].reject(&:blank?))
      end.freeze
    end
    attr_reader :attributes, :dn

    def memberOf
      self['memberOf'].map(&:upcase)
    end

    def extension
      # Extract the extension from the given full number
      self['telephoneNumber'].gsub(self.class.phone_prefix, '')
    end

    def active?
      expiration.future?
    end

    def expiration
      LDAP.at(self['accountExpires']).to_date
    end

    def [](name)
      value = attributes.fetch(name)
      (value.size < 2 ? value.first.to_s : value).tap do |v|
        if self.class.utf8_convert_attributes.include?(name)
          v.force_encoding('utf-8')
        end
      end
    end

    def to_hash(attrs = nil)
      (attrs || default_export_attributes).inject({'dn' => dn}) do |h, attr|
        value = self.respond_to?(attr) ? self.public_send(attr) : self[attr]
        h.update(attr => value)
      end
    end

    def as_json(options)
      return to_hash if options.blank?

      options.symbolize_keys!
      attrs = default_export_attributes
      attrs &= Array.wrap(options[:only]).map(&:to_s)   if options.key?(:only)
      attrs -= Array.wrap(options[:except]).map(&:to_s) if options.key?(:except)

      to_hash(attrs)
    end

    protected
    def method_missing(name, *args, &block)
      self[name.to_s]
    rescue KeyError
      super
    end

    def default_export_attributes
      self.class.attributes + %w(active? extension expiration)
    end

  end
end

