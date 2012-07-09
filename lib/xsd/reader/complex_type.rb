class XSD::ComplexTypeError < StandardError
end

class XSD::ComplexType
  attr_reader :name, :schema, :node

  def initialize(node, schema)
    @schema                 = schema
    @name                   = node.attr('name') || "<<annonimus>>"
    @extending_type, node   = extract_extending_type!(node)
    @restricting_type, node = extract_restricting_type!(node)
    @node                   = node
  end

  def inspect
    base_name = base ? " base=#{base.name.inspect}" : ""
    "<ComplexType::#{name}(#{elements.map(&:inspect_name_type).join(', ')})#{base_name}>"
  end

  def namespace
    @schema.target_namespace
  end

  def to_s
    inspect
  end

  def complex?
    true
  end

  def type
    context_type(@node)
  end

  def base
    @schema.find(@extending_type || @restricting_type)
  end

  def elements
    @all_elements ||= extending_type_elements + self_elements
  end

  def self_elements
    context(@node).children.map do |node|
      case node.name
      when 'element'
        @schema.create_element(node)
      when 'text'
      else
        @schema.create_list(node)
      end
    end.compact

  rescue XSD::ComplexTypeError => e
    if @extending_type
      return []
    else
      raise e
    end
  end

  def extending_type_elements
    type = @schema.find(@extending_type)
    type ? type.elements : []
  end

  private

  def extract_extending_type!(node)
    extension_node = node.search('./xs:extension|./xs:complexContent/xs:extension').first
    if extension_node
      [extension_node['base'], extension_node]
    else
      [nil, node]
    end
  end

  def extract_restricting_type!(node)
    restriction_node = node.search('./xs:restriction|./xs:complexContent/xs:restriction').first
    if restriction_node
      [restriction_node['base'], restriction_node]
    else
      [nil, node]
    end
  end

  def context(node)
    node.search('./xs:sequence|./xs:complexContent|./xs:choice|./xs:all').first ||
        raise(XSD::ComplexTypeError, "ComplexType [#{name}] must have one of: xs:sequence, xs:complexContent, xs:chose, xs:all. got: \n#{node}")
  end

  def context_type(node)
    context(node).name.underscore.to_sym
  end

end