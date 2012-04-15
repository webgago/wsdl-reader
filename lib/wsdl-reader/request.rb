require 'wsdl-reader/core_ext'

require 'wsdl-reader/xsd'
require 'wsdl-reader/response'

module SOAP
  class Request
    def initialize(wsdl, binding = nil) #:nodoc:
      @wsdl = wsdl
      @binding = binding
      @request = nil
    end

    # Call a method for the current Request and get a SOAP::Response
    #
    # Example:
    #   wsdl = SOAP::LC.new.wsdl("http://...")
    #   request = wsdl.request
    #   response = request.myMethod(:param1 => "hello")
    #     # => #<SOAP::Response:0xNNNNNN>
    def method_missing(id, *args)
      call(id.id2name, args[0])
    end

    # Create a new SOAP::Request with the given envelope, uri and headers
    #
    # Example:
    #   e = '<SOAP-ENV:Envelope 
    #                    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    #                    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    #                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    #                    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    #                    SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    #          <SOAP-ENV:Header/>
    #            <SOAP-ENV:Body>
    #              <HelloWorld xmlns="urn:MyWebService">
    #                <from>Greg</from>
    #              </HelloWorld>
    #            </SOAP-ENV:Body>
    #          </SOAP-ENV:Envelope>'
    #   r = SOAP::Request.request(e, "http://localhost:3000/hello/wsdl", "SOAPAction" => "my.soap.action")
    def self.request(envelope, uri, headers = {})
      req = new(nil, nil)
      req.r(envelope, uri, headers)
      return req
    end
    def r(envelope, uri, headers) #:nodoc:
      @request = {
        :headers  => make_header(envelope, headers),
        :envelope => envelope,
        :uri      => uri,
        :wsdl     => nil,
        :response => nil,
        :binding  => @binding,
        :method   => nil
      }
    end

    # Return available SOAP actions
    def operations
      @wsdl.bindings.getOperations(@binding)
    end
    
    # Call a method for the current Request
    #
    # Example:
    #   wsdl = SOAP::LC.new.wsdl("http://...")
    #   request = wsdl.request
    #   response = request.call("myMethod", :param1 => "hello")
    #     # => #<SOAP::Response:0xNNNNNN>
    def call(method_name, args)
      args = (args || {}).keys_to_sym!

      # Get Binding
      binding = @wsdl.bindings.getBindingForOperationName(@binding, method_name)
      if binding.size == 0
        raise SOAP::LCNoMethodError, "Undefined method `#{method_name}'"
      elsif binding.size > 1
        raise SOAP::LCError, "Ambigous method name `#{method_name}', please, specify a binding name"
      else
        binding = binding[0]
        @binding = binding.name
      end

      # Get Binding Operation
      binding_operation = binding.operations[method_name]

      # Get PortType
      port_type = @wsdl.port_types[binding.type.nns]
      port_type_operation = port_type.operations[method_name]

      # Get message for input operation
      input_message = @wsdl.messages[port_type_operation[:input][:message].nns]

      # Create method
      soap_method = "<#{method_name} xmlns=\"#{@wsdl.target_namespace}\">\n"
      input_message.parts.each do |_, attrs|
        case attrs[:mode]
          when :type
            if SOAP::XSD::ANY_SIMPLE_TYPE.include?(attrs[attrs[:mode]].nns)
              # Part refer to a builtin SimpleType
              soap_method << SOAP::XSD.displayBuiltinType(attrs[:name], args, 1, 1)
            else
              # Part refer to an XSD simpleType or complexType defined in types
              element = @wsdl.types[attrs[attrs[:mode]].nns][:value]
              case element[:type]
                when :simpleType
                  soap_method << "<#{attrs[:name]}>\n#{element.display(@wsdl.types, args)}\n</#{attrs[:name]}>\n" # MAYBE ##########
                when :complexType
                  soap_method << "<#{attrs[:name]}>\n#{element.display(@wsdl.types, args)}\n</#{attrs[:name]}>\n" # MAYBE ##########
                else
                  raise SOAP::LCWSDLError, "Malformated part #{attrs[:name]}"
              end
            end
          when :element
            # Part refer to an XSD element
            element = @wsdl.types[attrs[attrs[:mode]].nns][:value]
            case @wsdl.types[attrs[attrs[:mode]].nns][:type]
              when :simpleType
                soap_method << element[element[:type]].display(@wsdl.types, args)
              when :complexType
                soap_method << element[element[:type]].display(@wsdl.types, args)
              else
                raise SOAP::LCWSDLError, "Malformed element `#{attrs[attrs[:mode]]}'"
            end
        
            ## TODO ---------- USE element[:key]
          else 
            raise SOAP::LCWSDLError, "Malformed part #{attrs[:name]}"
        end
      end
      soap_method += "</#{method_name}>\n"

      # Create SOAP Envelope
      envelope = soap_envelop { soap_header + soap_body(soap_method) }

      # Create headers
      headers = Hash.new

      # Add SOAPAction to headers (if exist)
      action = binding_operation[:soapAction] rescue nil

      headers['SOAPAction'] = action unless action.nil? || action.length == 0

      # Search URI
      service_port = @wsdl.services.getServicePortForBindingName(binding.name)
      address = service_port[:address]

      # Complete request
      @request = {
        :headers  => make_header(envelope, headers),
        :envelope => envelope,
        :uri      => address,
        :wsdl     => @wsdl,
        :response => @wsdl.messages[port_type_operation[:output][:message].nns].name,
        :binding  => @binding,
        :method   => method_name
      }
      
      self
    end

    # Get the SOAP Body for the request
    def soap_body(soap_method)
      "<SOAP-ENV:Body>\n" + soap_method + "</SOAP-ENV:Body>\n"
    end

    # Send request to the server and get a response (SOAP::Response)
    def response
      SOAP::Response.new(@request)
    end
    alias_method :result, :response

    # Get the SOAP Envelope for the request
    def envelope
      @request[:envelope] || nil
    end

    # Get request headers
    def headers
      @request[:headers] || nil
    end
    
    # Get request URI
    def uri
      @request[:uri] || nil
    end

    private
    def make_header(e, h = {}) #:nodoc:
      {
        'User-Agent' => "SOAP::LC (#{SOAP::LC::VERSION}); Ruby (#{VERSION})",
        'Content-Type' => 'text/xml', #'application/soap+xml; charset=utf-8',
        'Content-Length' => "#{e.length}"
      }.merge(h)
    end

    def soap_envelop(&b) #:nodoc:
      "<SOAP-ENV:Envelope 
          xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"
          xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\"
          xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" 
          xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
          SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n" +
        yield +
      '</SOAP-ENV:Envelope>'
    end

    def soap_header
      "<SOAP-ENV:Header/>\n"
    end    
  end
end
