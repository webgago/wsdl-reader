module WSDL
  module Reader
    class ParserError < StandardError
    end

    class LookupError < StandardError
    end

    class ManyOperationsFoundError < LookupError
      def initialize(type, element_name)
        @type, @element_name = type, element_name
      end


      def message
        "More than one operations found for element: [#@element_name]"
      end
    end

    class OperationNotFoundError < LookupError
      def initialize(type, element_name)
        @type, @element_name = type, element_name
      end

      def message
        "No operation matches for element: [#@element_name]"
      end
    end

    class FileOpenError < ParserError
    end
  end
end

module SOAP
  class LCError < RuntimeError
  end

  class LCWSDLError < NameError
  end

  class LCNoMethodError < NoMethodError
  end

  class LCArgumentError < ArgumentError
  end

  class LCElementError < NameError
  end

  class LCTypeError < NameError
  end
end