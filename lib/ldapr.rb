module LDAPR
  require 'ldapr/application'
  require 'ldapr/ldap'

  def self.logger=(logger)
    @@logger = logger
  end

  def self.logger
    @@logger ||= Logger.new(STDOUT)
  end
end
