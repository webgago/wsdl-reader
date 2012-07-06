require "active_support/core_ext/hash/keys"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/string/inflections"
require "wsdl-reader/version"
require "wsdl-reader/error"
require "wsdl-reader/parser"
require "wsdl-reader/request"

require "xsd-reader"

module WSDL
  module Reader
    def debugging?
      false
    end

    module_function :debugging?
  end
end
