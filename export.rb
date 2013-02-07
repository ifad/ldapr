require 'csv'

class Export
  def initialize(people, app)
    @people = people
    @app    = app
  end
  attr_reader :people, :app

  def process(format)
    return nil unless self.respond_to?(format)
    self.public_send(format)
  end

  def json
    [people.to_json(except: 'thumbnailPhoto'), 'application/json', 'inline']
  end
  alias :js :json

  def csv

    data = CSV.generate :encoding => 'utf-8' do |csv|
      csv << self.class.tabular_attributes

      people.each do |p|
        csv << self.class.tabular_attributes.map {|attr| p.public_send(attr)}
      end
    end

    [data, 'text/csv', 'attachment']
  end

  def html
    locals = {:people => people, :attributes => self.class.tabular_attributes}
    [app.erb(:people, :locals => locals), 'text/html', 'inline']
  end

  def self.tabular_attributes
    @tabular_attributes ||= %w( dn ) + LDAP::Person.export_attributes - %w( thumbnailPhoto memberOf )
  end
end
