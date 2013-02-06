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

    CSV.generate :encoding => 'utf-8' do |csv|
      csv << attributes

      people.each do |p|
        values = attributes.map do |attr|
          value = p.public_send(attr)
          value.respond_to?(:force_encoding) ?
            value.dup.force_encoding('utf-8') : value
        end

        csv << values
      end
    end
  end
end
