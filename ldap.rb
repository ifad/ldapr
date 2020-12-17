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

  def self.environment
    ENV['RACK_ENV'] || 'development'
  end

  def self.config
    @@config ||= YAML.load_file('config/ldap.yml').fetch(environment)
  end

  def self.connection
    @connection ||= Net::LDAP.new(connection_spec)
  end

  # Difference in seconds between the UNIX Epoch (1970-01-01)
  # and the AD Epoch (1601-01-01)
  AD_EPOCH_OFFSET = 11644477200

  def self.now
    to_ad_ts(Time.now)
  end

  def self.to_ad_ts(timestamp)
    (timestamp.to_i + AD_EPOCH_OFFSET) * 10_000_000
  end

  def self.at(timestamp)
    # number of nanosec / 100, i.e. 10 times the number of microsec,
    # divide by 10_000_000 so it becomes number of seconds
    Time.at(timestamp.to_i / 10_000_000 - AD_EPOCH_OFFSET)
  end

  class Result < Array
    def initialize(*args)
      if args.first.respond_to?(:key?)
        options = args.shift
        @filter, @scope, @base =
          options.values_at(:filter, :scope, :base)
      end
      super
    end

    attr_reader :filter, :base

    def scope
      case @scope
      when Net::LDAP::SearchScope_BaseObject   then :base
      when Net::LDAP::SearchScope_SingleLevel  then :single
      when Net::LDAP::SearchScope_WholeSubtree then :subtree
      end
    end
  end

  class Person
    UTF8_ATTRIBUTES = %w(
      givenName
      sn
      displayName
      sAMAccountName
      accountExpires
      mail
      otherMailbox
      telephoneNumber
      roomNumber
      mobile
      otherMobile
      division
      employeeType
      employeeId
      employeeNumber
      lockoutTime
      whenCreated
      whenChanged
    ).freeze

    ATTRIBUTES = UTF8_ATTRIBUTES + %w(
      objectGUID
      thumbnailPhoto
      memberOf
    ).freeze

    def self.base_dn
      @_base_dn ||= LDAP.config['base']
    end

    def self.branches
      @_branches ||= LDAP.config['branches']
    end

    def self.attributes
      ATTRIBUTES
    end

    def self.utf8_convert_attributes
      UTF8_ATTRIBUTES
    end

    def self.export_attributes
      @export_attributes ||= attributes \
        - %w( objectGUID ) \
        + %w(active? created_at updated_at locked_out_at locked_out? extension expiration guid)
    end


    def self.phone_prefix
      '+39065459'
    end

    def self.filter_for(options)
      filter = case options.delete(:active)
      when false
        Net::LDAP::Filter.le('accountExpires', LDAP.now.to_s)
      when :any, 'any'
        Net::LDAP::Filter.eq('accountExpires', '*')
      else
        Net::LDAP::Filter.ge('accountExpires', LDAP.now.to_s)
      end

      filter &= Net::LDAP::Filter.eq('objectClass', 'person')

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
        Net::LDAP::SearchScope_SingleLevel      :
        Net::LDAP::SearchScope_WholeSubtree

      filter = filter_for(options)

      result = Result.new(filter: filter, base: branches, scope: scope)

      branches.each do |dn|
        result.concat LDAP.connection.search(
          base:       dn,
          filter:     filter,
          attributes: attributes,
          scope:      scope
        ).map! {|entry| new(entry)}
      end

      result.compact!

      return result.freeze
    end

    def initialize(entry)
      @dn = entry.dn.dup.force_encoding('utf-8').freeze
      @attributes = self.class.attributes.inject({}) do |h, attr|
        h.update(attr => entry[attr].reject(&:blank?))
      end.freeze
    end
    attr_reader :attributes, :dn

    def memberOf
      attributes.fetch('memberOf').map(&:upcase)
    end

    def extension
      # Extract the extension from the given full number
      self['telephoneNumber'].gsub(self.class.phone_prefix, '')
    end

    def created_at
      Time.parse(self['whenCreated'])
    end

    def updated_at
      Time.parse(self['whenChanged'])
    end

    def active?
      expiration.future?
    end

    def expiration
      LDAP.at(self['accountExpires'])
    end

    def guid
      b = self['objectGUID'].unpack('C*')

      return unless b.size == 16

      guid_bytes = [b[3], b[2], b[1], b[0], b[5], b[4], b[7], b[6], b[8], b[9], *b[10..15]]
      guid_fmt = ['%02x'*4, '%02x'*2, '%02x'*2, '%02x'*2, '%02x'*6].join('-')

      (guid_fmt % guid_bytes).upcase
    end

    def locked_out_at
      return if self['lockoutTime'].nil? || self['lockoutTime'] == '0' # Not Locked Out

      LDAP.at(self['lockoutTime'])
    end

    def locked_out?
      !locked_out_at.nil?
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
      (attrs || self.class.export_attributes).inject({'dn' => dn}) do |h, attr|
        value = self.respond_to?(attr) ? self.public_send(attr) : self[attr]
        h.update(attr => value)
      end
    end

    def as_json(options)
      return to_hash if options.blank?

      options.symbolize_keys!
      attrs = self.class.export_attributes
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

  end
end

