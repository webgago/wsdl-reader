require "xsd/reader/simple_type"
require "xsd/reader/complex_type"
require "xsd/reader/simple_type_factory"

class XSD::Element
  attr_reader :name, :type, :min_occurs, :max_occurs
  attr_reader :node, :elements_registry, :schema

  def initialize(node, schema)
    raise "node must be a <element>" unless node.name == 'element'
    @node       = node
    @name       = node.attr('name')
    @min_occurs = node.attr('minOccurs').to_i
    @max_occurs = node.attr('maxOccurs')
    @max_occurs = @max_occurs.to_i if @max_occurs
    @schema = schema
    @elements_registry = schema.elements_registry
  end

  def type
    @type ||= begin
      schema.find(node.attr('type')) || parse_simple_type || parse_complex_type || raise("could not parse type: \n#{node}")
    end
  end

  def inspect
    "<Element #{inspect_name_type}>"
  end

  def inspect_name_type
    if type.complex?
      "#{name}:#{type.name.inspect}(#{type.elements.map(&:inspect_name_type).join(', ')})"
    else
      "#{name}:#{type.name.inspect}"
    end
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
    XSD::SimpleTypeFactory.create(simple_type) unless simple_type.empty?
  end

  def parse_complex_type
    complex_type = node.search('./xs:complexType')
    XSD::ComplexType.new(complex_type, schema) unless complex_type.empty?
  end

  def inner_complex_type?
    node.search('./xs:complexType').length > 0
  end

end