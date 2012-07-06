require "xsd/reader/element"

class XSD::Schema
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
      XSD::ComplexType.new node, elements_registry
    end
  end

  def parse_elements(elements_registry)
    node.search('./xs:element').map do |node|
      XSD::Element.new(node, elements_registry)
    end
  end
end