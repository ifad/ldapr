require './ldap'
require 'csv'

module Export
  def self.process(params)
    people = LDAP::Person.search(params)
    people.to_json(except: 'thumbnailPhoto')
  end
end
