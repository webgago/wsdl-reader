class XSD::ComplexType
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