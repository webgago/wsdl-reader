module WSDL
  module Reader
    class ParserError < StandardError
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