class XSD::ComplexType
  attr_reader :name, :elements, :type

  def initialize(node, schema)
    @schema = schema
    @name     = node.attr('name') || "<<annonimus>>"
    @elements = context(node).search('./xs:element').map { |n| schema.create_element(n) }
    @type = context_type(node)
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


  private

  def context(node)
    node.search('./xs:sequence|./xs:complexContent|./xs:choice|./xs:all').first ||
        raise("ComplexType must have one of: xs:sequence, xs:complexContent, xs:chose")
  end

  def context_type(node)
    context(node).name.underscore.to_sym
  end

end