class XSD::SimpleTypeFactory
  def self.create(node)
    if node.search('./restriction')
      XSD::SimpleType::Restriction.new(node)
    end
  end
end