module WSDL
  module Reader
    class Messages < Hash
    end

    class Message
      attr_reader :parts
      attr_reader :name

      def initialize(element)
        @parts = Hash.new
        @name = element.attributes['name']

        process_all_parts element
      end

      def element
        warn "More than one parts!" if parts.size > 1
        parts.map { |name, hash| hash[:element] }.first
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
              current_part[:mode] = :element
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
