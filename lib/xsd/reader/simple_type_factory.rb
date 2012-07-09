class XSD::SimpleTypeFactory
  def self.create(node, schema)
    if node.search('./restriction')
      XSD::SimpleType::Restriction.new(node, schema)
    end
  end
end