module WSDL
  module Reader
    class Messages < Hash

      def lookup_operations_by_element(type, element_name, port_types)
        messages = lookup_messages_by_element(element_name)
        messages.map do |message|
          port_types.lookup_operations_by_message(type, message)
        end.flatten
      end

      def lookup_operation_by_element! (type, element_name, port_types)
        messages = lookup_operations_by_element type, element_name, port_types
        case messages.size
          when 1
            messages.first
          when 0
            raise OperationNotFoundError.new type, element_name
          else
            raise ManyOperationsFoundError.new type, element_name
        end
      end

      def lookup_messages_by_element(element_name)
        values.select do |message|
          message.parts.values.find { |part| part[:element].split(':').last == element_name }
        end
      end

    end

    class Message
      attr_reader :parts
      attr_reader :name

      def initialize(element)
        @parts = Hash.new
        @name  = element.attributes['name']

        process_all_parts element
      end

      def element
        parts.map { |_, hash| hash[:element] }.first
      end

      protected

      def process_all_parts(element)
        element.select { |e| e.class == REXML::Element }.each do |part|
          case part.name
            when "part"
              @parts[part.attributes['name']] = Hash.new
              store_part_attributes(part)
            else
              warn "Ignoring element `#{part.name}' in message `#{element.attributes['name']}'"
          end
        end
      end

      def store_part_attributes(part)
        current_part = @parts[part.attributes['name']]
        part.attributes.each do |name, value|
          case name
            when 'name'
              current_part[:name] = value
            when 'element'
              current_part[:element] = value
              current_part[:mode]    = :element
            when 'type'
              current_part[:type] = value
              current_part[:mode] = :type
            else
              warn "Ignoring attribute `#{name}' in part `#{part.attributes['name']}' for message `#{element.attributes['name']}'"
          end
        end
      end
    end
  end
end
