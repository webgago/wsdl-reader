require 'open-uri'
require 'rexml/document'

require 'wsdl-reader/message'
require 'wsdl-reader/portType'
require 'wsdl-reader/binding'
require 'wsdl-reader/service'
require 'wsdl-reader/xsd'

module WSDL
  module Reader
    class Parser
      attr_reader :types, :messages, :portTypes, :bindings, :services
      attr_reader :prefixes, :target_namespace
      attr_reader :document, :uri

      def initialize(uri)
        @uri = uri
        @types = SOAP::XSD.new()
        @messages = WSDL::Reader::Messages.new
        @portTypes = SOAP::WSDL::PortTypes.new
        @bindings = SOAP::WSDL::Bindings.new
        @services = SOAP::WSDL::Services.new

        @prefixes = Hash.new
        @target_namespace = ""

        @document = REXML::Document.new(get_wsdl_source)

        process_attributes @document.root.attributes
        process_content @document.root.children
      end

      private

      def get_wsdl_source
        # Get WSDL
        source = nil
        begin
          open(uri) { |f| source = f.read }
        rescue Errno::ECONNREFUSED, Errno::ENOENT, OpenURI::HTTPError => e
          raise WSDL::Reader::FileOpenError, "Can't open '#{uri}' : #{e.message}"
        end
        source
      end

      def process_attributes(attributes)
        @target_namespace = attributes["targetNamespace"]

        attributes.values.each do |attribute|
          if attribute.prefix == "xmlns" then
            @prefixes[attribute.name] = attribute.value
          end
        end

        if (default_namespace = attributes["xmlns"]) then
          @prefixes["__default__"] = default_namespace
        end
      end

      def process_content(elements)
        elements.find_all { |e| e.class == REXML::Element }.each do |element|
          case element.name
            when "types"
              process_types(element)
            when "message"
              process_message(element)
            when "portType"
              process_port_type(element)
            when "binding"
              process_binding(element)
            when "service"
              process_service(element)
            else
              warn "Ignoring #{element} in #{__FILE__}:#{__LINE__}"
          end
        end
      end

      def process_types(element)
        @types.add_schema(element)
      end

      def process_message(element)
        name = element.attributes['name']
        @messages[name] = WSDL::Reader::Message.new(element)
      end

      def process_port_type(element)
        name = element.attributes['name']
        @portTypes[name] = SOAP::WSDL::PortType.new(element)
      end

      def process_binding(element)
        name = element.attributes['name']
        @bindings[name] = SOAP::WSDL::Binding.new(element)
      end

      def process_service(element)
        name = element.attributes['name']
        @services[name] = SOAP::WSDL::Service.new(element)
      end
    end
  end
end