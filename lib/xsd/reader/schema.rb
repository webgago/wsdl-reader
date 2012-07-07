require "xsd/reader/element"

class XSD::Schema
  attr_reader :node, :target_namespace, :reader
  delegate :elements_registry, :complex_registry, :find, :to => :reader

  def initialize(node, reader=nil)
    @reader           = reader
    @node             = node
    @target_namespace = node.attr('targetNamespace')
  end

  def create_element(node)
    if (ref = node.attr('ref'))
      find(ref)
    else
      XSD::Element.new(node, self)
    end
  end

  def namespaces
    @namespaces ||= Hash[node.namespaces.map { |key, value| [key.gsub('xmlns:', '').to_sym, value] }]
  end

  def parse_complex
    node.search('./xs:complexType').map do |node|
      XSD::ComplexType.new(node, self)
    end
  end

  def parse_simple
    node.search('./xs:simpleType').map do |node|
      XSD::SimpleTypeFactory.create(node)
    end
  end

  def parse_elements
    node.search('./xs:element').map do |node|
      XSD::Element.new(node, self)
    end
  end
end