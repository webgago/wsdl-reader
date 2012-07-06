require 'wsdl-reader/error'
require 'wsdl-reader/core_ext'

require 'wsdl-reader/xsd/complextype'
require 'wsdl-reader/xsd/convert'
require 'wsdl-reader/xsd/element'
require 'wsdl-reader/xsd/enumeration'
require 'wsdl-reader/xsd/restriction'
require 'wsdl-reader/xsd/sequence'
require 'wsdl-reader/xsd/simpletype'

module SOAP
  class XSD
    include Comparable
    attr_reader :elements
    attr_reader :simpleTypes
    attr_reader :complexTypes

    ANY_SIMPLE_TYPE = %w(duration dateTime time date gYearMonth gYear gMonthDay gDay gMonth 
      boolean base64Binary hexBinary float double anyURI QName NOTATION string normalizedString 
      token language Name NMTOKEN NCName NMTOKENS ID IDREF ENTITY IDREFS ENTITIES
      decimal integer nonPositiveInteger long nonNegativeInteger negativeInteger int unsignedLong positiveInteger
      short unsignedInt byte unsignedShort unsignedByte)

    def initialize()
      @elements = Hash.new
      @simpleTypes = Hash.new
      @complexTypes = Hash.new
      @types = Hash.new
    end

    def <=>(other)
      @types <=> other.instance_variable_get(:@types)
    end

    def add_schema(types)
      # Process all schema
      types.children.find_all { |e| e.class == REXML::Element }.each { |schema|
        schema.find_all { |e| e.class == REXML::Element }.each { |type|
          processType type
        }
      }
    end

    def any_defined_type
      @types.keys
    end

    def [](name)
      @types[name]
    end

    def self.displayBuiltinType(name, args, min = 1, max = 1)
      r = ""

      if args.keys.include?(name.to_sym)
        args[name.to_sym] = [args[name.to_sym]] unless args[name.to_sym].class == Array
        if args[name.to_sym].size < min or args[name.to_sym].size > max
          raise SOAP::LCArgumentError, "Wrong number or values for parameter `#{name}'"
        end
        args[name.to_sym].each { |v|
          r << "<#{name}>#{v}</#{name}>\n"
        }
      elsif min > 0
        raise SOAP::LCArgumentError, "Missing parameter `#{name}'" if min > 0
      end

      return r
    end

    private

    def processType(type)
      case type.name
        when "element"
          @elements[type.attributes['name']] = SOAP::XSD::Element.new(type)
          @types[type.attributes['name']] = {
              :type => :element,
              :value => @elements[type.attributes['name']]
          }
        when "complexType"
          @complexTypes[type.attributes['name']] = SOAP::XSD::ComplexType.new(type)
          @types[type.attributes['name']] = {
              :type => :complexType,
              :value => @complexTypes[type.attributes['name']]
          }
        when "simpleType"
          @simpleTypes[type.attributes['name']] = SOAP::XSD::SimpleType.new(type)
          @types[type.attributes['name']] = {
              :type => :simpleType,
              :value => @simpleTypes[type.attributes['name']]
          }
        else
          warn "Ignoring type '#{type.name}' in #{__FILE__}:#{__LINE__}" if ::WSDL::Reader.debugging?
      end
    end
  end
end