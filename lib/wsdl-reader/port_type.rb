module WSDL
  module Reader
    class PortTypes < Hash
      def lookup_operation_message(type, operation, messages) # TODO: lookup_message_by_operation
        each do |_, port_type|
          message = port_type.lookup_operation_message type, operation, messages
          return message if message
        end
      end

      def lookup_operations_by_message(type, message)
        inject([]) do |array, (_, port_type)|
          array + port_type.lookup_operations_by_message(type, message)
        end
      end
    end

    class PortType
      attr_reader :operations
      attr_reader :name

      def initialize(element)
        @operations = Hash.new
        @name       = element.attributes['name']

        process_all_operations(element)
      end

      def lookup_operation_message(type, operation, messages)
        operation_name = operation.is_a?(Operation) ? operation.name : operation.to_s
        messages[@operations[operation_name][type][:message].split(':').last]
      end

      def lookup_operations_by_message(type, message)
        ops = @operations.values.select do |operation|
          operation_message? type, operation, message
        end
        ops.map do |operation_hash|
          operation_hash[:name]
        end
      end

      def operation_message?(type, operation, message)
        message_name = message.is_a?(Message) ? message.name : message.to_s
        operation[type][:message] == message_name ||
            operation[type][:message].split(':').last == message_name
      end

      protected

      def store_attributes(element, operation)
        operation.attributes.each { |name, value|
          case name
            when 'name'
              @operations[operation.attributes['name']][:name] = value
            else
              warn "Ignoring attribut '#{name}' in operation '#{operation.attributes['name']}' for portType '#{element.attributes['name']}'"
          end
        }
      end

      def store_input(action, element, operation)
        @operations[operation.attributes['name']][:input] = Hash.new
        action.attributes.each do |name, value|
          case name
            when 'name'
              @operations[operation.attributes['name']][:input][:name] = value
            when 'message'
              @operations[operation.attributes['name']][:input][:message] = value
            else
              warn_ignoring(action, element, name, operation)
          end
        end
      end

      def store_output(action, element, operation)
        @operations[operation.attributes['name']][:output] = Hash.new
        action.attributes.each { |name, value|
          case name
            when 'name'
              @operations[operation.attributes['name']][:output][:name] = value
            when 'message'
              @operations[operation.attributes['name']][:output][:message] = value
            else
              warn_ignoring(action, element, name, operation)
          end
        }
      end

      def store_fault(action, element, operation)
        @operations[operation.attributes['name']][:fault] = Hash.new
        action.attributes.each { |name, value|
          case name
            when 'name'
              @operations[operation.attributes['name']][:fault][:name] = value
            when 'message'
              @operations[operation.attributes['name']][:fault][:message] = value
            else
              warn_ignoring(action, element, name, operation)
          end
        }
      end

      def process_all_operations(element)
        element.find_all { |e| e.class == REXML::Element }.each do |operation|
          case operation.name
            when "operation"
              @operations[operation.attributes['name']] = Hash.new

              store_attributes(element, operation)

              operation.find_all { |e| e.class == REXML::Element }.each do |action|
                case action.name
                  when "input"
                    store_input(action, element, operation)

                  when "output"
                    store_output(action, element, operation)

                  when "fault"
                    store_fault(action, element, operation)

                  else
                    warn "Ignoring element '#{action.name}' in operation '#{operation.attributes['name']}' for portType '#{element.attributes['name']}'"
                end
              end
            else
              warn "Ignoring element '#{operation.name}' in portType '#{element.attributes['name']}'"
          end
        end
      end

      def warn_ignoring(action, element, name, operation)
        warn "Ignoring attribute '#{name}' in #{action.name} '#{action.attributes['name']}' in operation '#{operation.attributes['name']}' for portType '#{element.attributes['name']}'"
      end
    end
  end
end
