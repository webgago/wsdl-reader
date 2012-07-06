require "nokogiri"

module XSD
end

require "xsd/reader/element"
require "xsd/reader/schema"
require "xsd/reader/schema_resolver"
require "xsd/reader/elements_registry"
require "xsd/reader/complex_registry"

module XSD
  class Reader
    attr_reader :xml, :schemas
    attr_reader :elements, :complex_types
    attr_reader :namespaces

    def initialize(file)
      @xml  = Nokogiri::XML(File.read(file))
      @file = file
      process_import!
      @schemas                  = xml.search('.//xs:schema').map { |s| Schema.new(s) }
      @namespaces               = @schemas.inject({ }) { |hash, s| hash.merge s.namespaces }
      @elements, @complex_types = ElementsRegistry.new, ComplexRegistry.new
      @elements.namespaces      = namespaces
    end

    def find(name_with_ns)
      ns, name = name_with_ns.split(':')
      ns_href  = namespaces[ns.to_sym]
      raise "namespace [#{ns}] not found" unless ns_href
      elements[ns_href].find { |e| e.name == name }
    end

    def parse
      @elements      = schemas.inject(@elements) { |hash, s| hash.merge s.target_namespace => s.parse_elements(hash) }
      @complex_types = schemas.inject(@complex_types) { |hash, s| hash.merge s.target_namespace => s.parse_complex(@elements) }
      self
    end

    private

    def process_import!
      resolver = SchemaResolver.new(@file)
      @xml.search('/xs:schema/xs:import').each do |i|
        i.swap resolver.resolve_node(i['schemaLocation'])
      end
    end
  end
end