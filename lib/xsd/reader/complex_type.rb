class XSD::ComplexType
  attr_reader :name, :elements

  def initialize(node, schema)
    @schema = schema
    @name     = node.attr('name') || "<<annonimus>>"
    @elements = node.search('./xs:sequence|./xs:complexContent').search('./xs:element').map { |n| schema.create_element(n) }
  end

  def inspect
    "<ComplexType::#{name}(#{elements.map(&:inspect_name_type).join(', ')})>"
  end

  def to_s
    inspect
  end

  def complex?
    true
  end
end