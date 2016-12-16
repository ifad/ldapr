module LDAPR
  module API
    module Presenters
      require 'grape-entity'

      class Person < Grape::Entity
        expose :dn,                documentation: { type: 'String', desc: 'Ldap distinguished name' }
        expose :email,             documentation: { type: 'String', desc: 'Email address'  } do |person, _|
          person.email.present? ? ldap_user.email.downcase.to_s : nil
        end

        expose :first_name,        documentation: { type: 'String', desc: 'First name' }
        expose :last_name,         documentation: { type: 'String', desc: 'Ldap distinguished name' } do |person, _|
          person.last_name.presence || 'User' # For generic accounts
        end

        expose :extension,         documentation: { type: 'String', desc: 'Extension' }
        expose :generic,           documentation: { type: 'Boolean', desc: 'True when user is generic' } do |person, _|
          person.generic?
        end

        expose :department,        documentation: { type: 'String', desc: 'Department' }
        expose :employee_id,       documentation: { type: 'String', desc: 'Employee ID number' }
        expose :employee_type,     documentation: { type: 'String', desc: 'Employee type' }
        expose :personal_email,    documentation: { type: 'String', desc: 'Employee type' } do |person, _|
          person.personal_email.try(:strip)
        end

        expose :active,           documentation: { type: 'Boolean', desc: 'True when user is generic' } do |person, _|
          person.active?
        end
      end
    end
  end
end
