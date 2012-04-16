module WSDL
  module Reader

    class Operations < Hash
      def <<(operation)
        self[operation.name] = operation
      end
    end

    class Operation
      attr_reader :soap_action, :style, :input, :output, :fault
      attr_reader :name, :binding

      def initialize(element, binding)
        @name = element.attributes['name']
        @binding = binding

        parse! element
      end

      def message
        @name
      end

      def lookup_element(port_types, messages)
        message = port_types.lookup_operation_message :input, self, messages
        message.element.split(':').last
      end

      private

      def parse!(operation_element)
        operation_element.find_all { |e| e.class == REXML::Element }.each do |action_element|
          store_action(action_element, operation_element)
        end
      end

      def store_action(action_element, operation_element)
        case action_element.name
          when "operation" # soap:operation
            action_element.attributes.each do |name, value|
              case name
                when 'soapAction'
                  @soap_action = value
                when 'style'
                  @style = value
              end
            end
          when "input"
            @input = fill_action(action_element, operation_element)

          when "output"
            @output = fill_action(action_element, operation_element)

          when "fault"
            @fault = fill_action(action_element, operation_element)
        end
      end

      def fill_action(action_element, operation_element)
        filling_action = { }

        filling_action[:name] = action_element.attributes['name']

        # Store body
        action_element.find_all { |e| e.class == REXML::Element }.each do |body|
          if body.name = "body"
            filling_action[:body] = { }

            body.attributes.each do |name, value|
              filling_action[:body][name.to_sym] = value
            end
          end
        end

        filling_action
      end

    end
  end
end
