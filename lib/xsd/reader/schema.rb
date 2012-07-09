require "xsd/reader/element"

class XSD::Schema
  attr_reader :node, :target_namespace, :reader
  delegate :elements_registry, :complex_registry, :to => :reader

  def initialize(node, reader)
    @reader           = reader
    @node             = node
    @target_namespace = node.attr('targetNamespace')
  end

  def create_element(node)
    XSD::Element.new(node, self)
  end

  def create_list(list_node)
    XSD::ElementsList.create(list_node, self)
  end

  def find(qname)
    return if qname.nil?
    ns, name = qname.split(':')
    ns_href  = namespaces[ns.to_sym]
    raise "namespace [#{ns}] not found" unless ns_href

    if builtin_types?(ns_href)
      create_builtin_type(ns_href, name)
    else
      reader.find(qname)
    end
  end

  def find_type(qname)
    return if qname.nil?
    ns, name = qname.split(':')
    ns_href  = namespaces[ns.to_sym]
    raise "namespace [#{ns}] not found" unless ns_href

    if builtin_types?(ns_href)
      create_builtin_type(ns_href, name)
    else
      reader.find_type(ns_href, name)
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
      XSD::SimpleTypeFactory.create(node, self)
    end
  end

  def parse_elements
    node.search('./xs:element').map do |node|
      XSD::Element.new(node, self)
    end
  end

  private

  def builtin_types?(ns)
    ns == 'http://www.w3.org/2001/XMLSchema'
  end

  def create_builtin_type(ns, name)
    XSD::SimpleType::Builtin.new(ns, name, self)
  end
end