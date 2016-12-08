module LDAPR
  module LDAP

    class Server
      def initialize(name)
        @name = name
        add_person_class
        add_group_class unless type == 'ISDS'
      end

      def person_class
        LDAP.const_get(person_class_name)
      end

      def group_class
        LDAP.const_get(group_class_name)
      end

      protected
        def name
          @name
        end

        def type
          config['type'].upcase
        end

        def config
          prefix = "LDAP_SERVER_#{name.upcase}_"
          config = Hash.new
          %w(type hostname port encryption username password base).each do |param|
            config[param] = ENV[prefix + param.upcase]
          end
          config
        end

        def add_person_class
          klass = Class.new(::LDAP::Model.const_get(type)::Person)
          LDAP.const_set(person_class_name, klass)

          person_class.establish_connection(config)
          person_class.scope Net::LDAP::SearchScope_WholeSubtree
          person_class.base config['base']
        end

        def add_group_class
          klass = Class.new(::LDAP::Model.const_get(type)::Group)
          LDAP.const_set(group_class_name, klass)

          group_class.establish_connection(config)

        end

        def person_class_name
          "#{name.capitalize}Person"
        end

        def group_class_name
          "#{name.capitalize}Group"
        end
    end
  end
end
