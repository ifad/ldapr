module LDAPR
  module LDAP
    require 'ldap_model'

    def establish_ldap_connections
      ldap_server_names.each do |server_name|
        define_ldap_server_classes(server_name)
      end
    end

    protected

    def ldap_server_names
      ENV['LDAP_SERVER_NAMES'].split(/,\s/)
    end

    def ldap_server_config(server_name)
      prefix = "LDAP_SERVER_#{server_name.upcase}_"
      config = Hash.new
      %w(type hostname port encryption username password base).each do |param|
        config[param] = ENV[prefix + param.upcase]
      end
      config
    end

    def define_ldap_server_classes(server_name)
      config = ldap_server_config(server_name)
      type = config['type'].upcase
      person_class = Class.new(::LDAP::Model.const_get(type)::Person)
      class_name = person_class_name(server_name)
      LDAP.const_set(class_name, person_class)

      person_class(server_name).establish_connection(config)
    end

    def person_class(server_name)
      LDAP.const_get(person_class_name(server_name))
    end

    def person_class_name(server_name)
      "#{server_name.capitalize}Person"
    end
  end
end
