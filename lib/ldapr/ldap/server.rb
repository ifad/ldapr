module LDAPR
  module LDAP

    class Server
      def initialize(name)
        @name = name
        add_module
        add_person_class
        add_root_class unless type == 'ISDS'
        add_group_class unless type == 'ISDS'
      end

      def person_class
        server_module.const_get(:Person)
      end

      def group_class
        server_module.const_get(:Group)
      end

      def root_class
        server_module.const_get(:Root)
      end

      def server_module
        LDAPR::LDAP.const_get(server_module_name)
      end

      protected
        def server_module_name
          name.capitalize.to_sym
        end

        def name
          @name
        end

        def type
          config['type'].upcase
        end

        def config
          prefix = /^LDAP_SERVER_#{name.upcase}_/
          config = Hash.new
          params = ENV.select { |key, _| key.to_s.match(prefix) }

          params.each do |param, value|
            config[param.split(prefix)[1].downcase] = value
          end

          config
        end

        def add_person_class
          klass = Class.new(::LDAP::Model.const_get(type)::Person)
          server_module.const_set(:Person, klass)
          person_class.base config['base']
          person_class.establish_connection(config)
          person_class.scope Net::LDAP::SearchScope_WholeSubtree
        end

        def add_module
          LDAPR::LDAP.const_set(server_module_name, Module.new)
          m = Module.new
        end

        def add_root_class
          klass = Class.new(::LDAP::Model.const_get(type)::Root)
          server_module.const_set(:Root, klass)

          root_class.establish_connection(config)
          root_class.base config['base']

          root = root_class
          person_class.define_singleton_method(:root) do
            root.find
          end
        end

        def add_group_class
          klass = Class.new(::LDAP::Model.const_get(type)::Group)
          server_module.const_set(:Group, klass)

          group_class.establish_connection(config)
        end
    end
  end
end
