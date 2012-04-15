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
        self.map { |_, binding| binding.operations.keys }.flatten
      end
    end

    class Binding
      attr_reader :operations
      attr_reader :name
      attr_reader :type
      attr_reader :style
      attr_reader :transport

      def initialize(element)
        @operations = Hash.new
        @name       = element.attributes['name']
        @type       = element.attributes['type'] # because of Object#type
        @style      = nil
        @transport  = nil

        # Process all binding and operation
        element.find_all { |e| e.class == REXML::Element }.each { |operation|
          case operation.name
            when "binding" # soap:binding
              store_style_and_transport(element, operation)

            when "operation"
              store_operation_name(element, operation)

              operation.find_all { |e| e.class == REXML::Element }.each { |action|
                store_action(action, element, operation)
              }
            else
              warn "Ignoring element `#{operation.name}' in binding `#{element.attributes['name']}'"
          end
        }
      end

      def operation?(name)
        operations.include? name
      end

      protected

      def store_style_and_transport(element, operation)
        operation.attributes.each do |name, value|
          case name
            when 'style'
              @style = value
            when 'transport'
              @transport = value
            else
              warn "Ignoring attribute `#{name}' for wsdlsoap:binding in binding `#{element.attributes['name']}'"
          end
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

      def fill_action(action, operation)
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
            current_operation(operation)[:input] = fill_action(action, operation)

          when "output"
            current_operation(operation)[:output] = fill_action(action, operation)

          when "fault"
            current_operation(operation)[:fault] = fill_action(action, operation)

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