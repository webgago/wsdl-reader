require "wsdl-reader/version"
require "wsdl-reader/error"
require "wsdl-reader/parser"
require "wsdl-reader/request"

module WSDL
  module Reader
    def debugging?
      false
    end

    module_function :debugging?
  end
end
