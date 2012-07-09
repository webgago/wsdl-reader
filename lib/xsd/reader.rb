require "xsd/reader/element"
require "xsd/reader/schema"
require "xsd/reader/schema_resolver"
require "xsd/reader/elements_registry"
require "xsd/reader/types_registry"
require "xsd/reader/qname"
require "xsd/reader/elements_list"

module XSD
  class Reader
    attr_reader :xml, :schemas
    attr_reader :types_registry, :elements_registry
    attr_reader :namespaces

    def initialize(file)
      @file       = file
      @namespaces = { }
    end

    def find(qname)
      return if qname.nil?
      ns, name = qname.split(':')
      ns_href  = namespaces[ns.to_sym]
      raise "namespace [#{ns}] not found" unless ns_href

      find_element(ns_href, name) || find_type(ns_href, name)
    end

    def find_element(ns_href, name)
      begin
        elements_registry.find(ns_href, name)
      rescue XSD::ElementsNotFound
        nil
      end
    end

    def find_type(ns_href, name)
      types_registry.find(ns_href, name)
    end

    def parse
      read!
      process_import!
      parse_schemas!
      @types_registry    = XSD::TypesRegistry.new(namespaces)
      @elements_registry = XSD::ElementsRegistry.new(namespaces)
      parse_simple
      parse_elements
      parse_complex
      self
    end

    def inspect
      ""
    end

    private

    def read!
      @xml = Nokogiri::XML(File.read(@file))
    end

    def process_import!
      resolver = SchemaResolver.new(@file)
      @xml.search('/xs:schema/xs:import').each do |i|
        ns = resolver.resolve_node(i['schemaLocation']).namespaces
        ns.each { |n, href| @xml.root.add_namespace(n.gsub('xmlns:', ''), href) }
        i.swap resolver.resolve_node(i['schemaLocation'])
      end
    end

    def parse_schemas!
      @schemas = xml.search('.//xs:schema').map do |s|
        Schema.new(s, self).tap do |schema|
          @namespaces.merge! schema.namespaces
        end
      end
    end

    def parse_elements
      schemas.each do |s|
        @elements_registry.merge! s.target_namespace => s.parse_elements
      end
    end

    def parse_simple
      schemas.each do |s|
        @types_registry.merge! s.target_namespace => s.parse_simple
      end
    end

    def parse_complex
      schemas.each do |s|
        if @types_registry[s.target_namespace].is_a? Array
          @types_registry[s.target_namespace].concat s.parse_complex
        else
          @types_registry.merge! s.target_namespace => s.parse_complex
        end
      end
    end

  end
end