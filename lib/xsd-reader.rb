require "active_support/core_ext/module/delegation"
require "nokogiri"

class XSD
  class Reader
    class Element
      attr_reader :name, :type, :min_occurs, :max_occurs
      attr_reader :node, :elements_registry

      def initialize(node, elements_registry)
        @node       = node
        @name       = node.attr('name')
        @min_occurs = node.attr('minOccurs').to_i
        @max_occurs = node.attr('maxOccurs')
        @max_occurs = @max_occurs.to_i if @max_occurs
        @elements_registry = elements_registry
      end

      def type
        @type ||= begin
          node.attr('type') || parse_simple_type || parse_complex_type || raise("could not parse type: \n#{node}")
        end
      end

      def inspect
        "<Element #{inspect_name_type}>"
      end

      def inspect_name_type
        "#{name}:#{type.inspect}"
      end

      def elements
        if inner_complex_type?
          type.elements
        else
          []
        end
      end

      def to_s
        inspect
      end

      private

      def parse_simple_type
        simple_type = node.search('./xs:simpleType')
        SimpleType.factory(simple_type) unless simple_type.empty?
      end

      def parse_complex_type
        complex_type = node.search('./xs:complexType')
        ComplexType.new(complex_type, elements_registry) unless complex_type.empty?
      end

      def inner_complex_type?
        node.search('./xs:complexType').length > 0
      end

    end

    class ComplexType
      attr_reader :name, :elements

      def initialize(node, elements_registry)
        @name     = node.attr('name') || "<<annonimus>>"
        @elements = node.search('./xs:sequence|./xs:complexContent').search('./xs:element').map { |n| elements_registry.create(n) }
      end

      def inspect
        "<ComplexType::#{name} #{elements.map(&:inspect_name_type)}>"
      end

      def to_s
        inspect
      end
    end

    class SimpleType
      def self.factory(node)
        if node.search('./restriction')
          Restriction.new(node)
        end
      end

      class Base
        attr_reader :name

        def initialize(node)
          @name = node.attr('name') || '<<annonimus>>'
        end

        def inspect
          "<SimpleType::#{name}#{yield}>"
        end

        def to_s
          inspect
        end
      end

      class Restriction < Base
        attr_reader :base

        def initialize(node)
          super
          @node = node.search('./xs:restriction')
          @base = @node.attr('base').value rescue nil
          raise "restriction should have 'base' attribute: \n#{node.inspect}" unless @base
        end

        def enumeration
          @node.search('./xs:enumeration').map do |e|
            e.attr('value')
          end
        end

        def min
          @node.search('./xs:minInclusive').first.attr('value').to_i
        end

        def max
          @node.search('./xs:maxInclusive').first.attr('value').to_i
        end

        def inspect
          super do
            " base=#{base}"
          end
        end
      end
    end

    class ElementsRegistry < Hash
      attr_accessor :namespaces

      def create(node)
        if (ref = node.attr('ref'))
          find(ref)
        else
          Element.new(node, self)
        end
      end

      def find(name_with_ns)
        return unless namespaces
        ns, name = name_with_ns.split(':')
        ns_href  = namespaces[ns.to_sym]
        raise "namespace [#{ns}] not found" unless ns_href
        raise "elements in namespace [#{ns_href}] not found" unless self[ns_href]
        self[ns_href].find { |e| e.name == name }
      end
    end

    class ComplexRegistry < Hash

    end

    class Schema
      attr_reader :node, :target_namespace

      def initialize(node)
        @node                            = node
        @global_elements, @complex_types = [], []
        @target_namespace                = node.attr('targetNamespace')
      end

      def namespaces
        @namespaces ||= Hash[node.namespaces.map { |key, value| [key.gsub('xmlns:', '').to_sym, value] }]
      end

      def parse_complex(elements_registry)
        node.search('./xs:complexType').map do |node|
          ComplexType.new node, elements_registry
        end
      end

      def parse_elements(elements_registry)
        node.search('./xs:element').map do |node|
          Element.new(node, elements_registry)
        end
      end
    end

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

    class SchemaResolver
      attr_reader :base

      def initialize(location)
        @base_uri = URI.parse(location)
        @base_path = Pathname.new(location)
      end

      def resolve(location)
        if local?(location)
          resolve_on_local(location)
        else
          resolve_url(location)
        end
      end

      def resolve_node(location)
        Nokogiri::XML(resolve(location)).root
      end

      private

      def local?(location)
        true
      end

      def resolve_on_local(location)
        location = Pathname.new(location)

        if location.absolute?
          File.read(location.to_s)
        else
          File.read(location.expand_path(@base_path).to_s)
        end
      end

      #base = URI.parse(@file)
      #location = i['schemaLocation']
      #location_uri = URI.parse(i['schemaLocation'])
      #
      #if location_uri.host
      #  resolve_from_host(location)
      #end
      #if base.host
      #  resolve_from_host(i, location, base)
      #else
      #
      #end
      #
      #if uri.host
      #else
      #end

    end
  end
end