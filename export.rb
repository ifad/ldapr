require './ldap'
require 'csv'

module Export
  extend self

  def process(query, format)
    people = LDAP::Person.search(query)

    case format
    when /^js/ then [json(people), 'application/json', 'inline']
    when /csv/ then [csv(people),  'text/csv',         'attachment']
    else nil
    end
  end

  def json(people)
    people.to_json(except: 'thumbnailPhoto')
  end

  def csv(people)
    attributes = %w( dn ) + LDAP::Person.export_attributes - %w( thumbnailPhoto memberOf )

    CSV.generate do |csv|
      csv << attributes

      people.each do |p|
        csv << attributes.map {|a| p.public_send(a)}
      end
    end
  end
end
