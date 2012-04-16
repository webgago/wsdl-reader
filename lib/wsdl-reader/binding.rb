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

      def operation?(operation_name)
        any? { |_, binding| binding.operation? operation_name }
      end
    end

    class Binding
      attr_reader :operations
      attr_reader :name
      attr_reader :type
      attr_reader :style
      attr_reader :transport

      def initialize(element)
        @operations = Operations.new
        @name       = element.attributes['name']
        @type       = element.attributes['type'] # because of Object#type
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
        operations.include? name
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

    end
  end
end
