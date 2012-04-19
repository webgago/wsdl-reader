module WSDL
  module Reader
    class Bindings < Hash
      def get_binding_for_operation_name(binding_name = nil, operation_name)
        if binding_name.nil?
          self.map do |_, binding|
            binding if binding.operation?(operation_name)
          end.flatten
        else
          [self[binding_name]] if self[binding_name].operation?(operation_name)
        end
      end

      def get_operations(binding_name = nil)
        if binding_name.nil?
          all_operations
        else
          self[binding_name].operations.keys
        end
      end

      def all_operations
        self.map { |_, binding| binding.operations.values }.flatten
      end

      def operations(binding=nil)
        bindings = binding.nil? ? self : ({ a: self[binding] })
        bindings.inject({ }) do |hash, (_, b)|
          hash.merge b.operations
        end
      end

      def operation?(operation_name)
        any? { |_, binding| binding.operation? operation_name }
      end
    end

    class Binding
      attr_reader :operations
      attr_reader :name
      attr_reader :type
      attr_reader :type_nns
      attr_reader :style
      attr_reader :transport

      def initialize(element)
        @operations = Operations.new
        @name       = element.attributes['name']
        @type       = element.attributes['type'] # because of Object#type
        @type_nns   = @type.split(':').last rescue @type
        @style      = nil
        @transport  = nil

        # Process all binding and operation
        element.find_all { |e| e.class == REXML::Element }.each do |operation_element|
          case operation_element.name
            when "binding" # soap:binding
              store_style_and_transport(operation_element)

            when "operation"
              append_operation(operation_element)
            else
              warn "Ignoring element `#{operation.name}' in binding `#{element.attributes['name']}'"
          end
        end
      end

      def operation?(name)
        operations.include? camelize_operation(name)
      end

      def lookup_port_type(port_types)
        port_types[type.split(':').last]
      end

      protected

      def append_operation(operation_element)
        @operations << Operation.new(operation_element, self)
      end

      def store_style_and_transport(operation_element)
        operation_element.attributes.each do |name, value|
          case name
            when 'style'
              @style = value
            when 'transport'
              @transport = value
          end
        end
      end

      def camelize_operation(name)
        name.to_s.tap do |name_string|
          return name_string.camelize :lower if name_string.underscore == name_string
        end
      end

      def store_operation_name(element, operation)
        operation.attributes.each do |name, value|
          case name
            when 'name'
              current_operation(operation)[:name] = value
            else
              warn "Ignoring attribute `#{name}' for operation `#{operation.attributes['name']}' in binding `#{element.attributes['name']}'"
          end
        end
      end

      def fill_action(action, operation, element)
        filling_action = { }

        action.attributes.each do |name, value|
          case name
            when 'name'
              filling_action[:name] = value
            else
              warn "Ignoring attribute `#{name}' in #{action.name} `#{action.attributes['name']}' in operation `#{operation.attributes['name']}' for binding `#{element.attributes['name']}'"
          end
        end

        # Store body
        action.find_all { |e| e.class == REXML::Element }.each do |body|
          case body.name
            when "body"
              filling_action[:body] = { }

              body.attributes.each { |name, value| filling_action[:body][name.to_sym] = value }

            when "fault"
              filling_action[:body] = { }

              body.attributes.each { |name, value| filling_action[:body][name.to_sym] = value }

            else
              warn "Ignoring element `#{body.name}' in #{action.name} `#{action.attributes['name']}' in operation `#{operation.attributes['name']}' for binding `#{element.attributes['name']}'"
          end
        end
        filling_action
      end

      def store_action(action, element, operation)
        case action.name
          when "operation" # soap:operation
            action.attributes.each do |name, value|
              case name
                when 'soapAction'
                  current_operation(operation)[:soapAction] = value
                when 'style'
                  current_operation(operation)[:style] = value
                else
                  warn "Ignoring attribut `#{name}' for wsdlsoap:operation in operation `#{operation.attributes['name']}' in binding `#{element.attributes['name']}'"
              end
            end
          when "input"
            current_operation(operation)[:input] = fill_action(action, operation, element)

          when "output"
            current_operation(operation)[:output] = fill_action(action, operation, element)

          when "fault"
            current_operation(operation)[:fault] = fill_action(action, operation, element)

          else
            warn "Ignoring element `#{action.name}' in operation `#{operation.attributes['name']}' for binding `#{element.attributes['name']}'"
        end
      end

      def current_operation(operation)
        @operations[operation.attributes['name']] ||= { }
      end

    end
  end
end
