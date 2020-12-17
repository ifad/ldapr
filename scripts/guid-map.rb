#!/usr/bin/env ruby

require 'net/ldap'
require '../ldap'
require 'yaml'

filter  = Net::LDAP::Filter.eq('objectClass', 'person')
filter &= Net::LDAP::Filter.eq('objectClass', 'organizationalPerson')
filter &= Net::LDAP::Filter.eq('objectClass', 'user')

people = LDAP.connection.search(
  attributes: %w( sAMAccountName objectGUID ),
  base:   'ou=people,dc=ifad,dc=org',
  filter: filter,
  scope:  Net::LDAP::SearchScope_WholeSubtree
).map {|entry| LDAP::Person.new(entry) }

puts '---'
puts

people.each do |person|
  puts [person.guid, person.account_name].join(': ')
end
