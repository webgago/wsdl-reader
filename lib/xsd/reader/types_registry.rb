class XSD::TypeNotFound < StandardError
end

class XSD::TypesRegistry < Hash
  attr_reader :namespaces

  def initialize(namespaces)
    @namespaces = namespaces
  end

  def find(ns, name)
    return create_builtin_type(ns, name) if builtin_types?(ns)
    raise XSD::TypeNotFound.new("types in namespace [#{ns}] not found") unless self[ns]
    self[ns].find { |e| e.name == name }
  end

  def builtin_types?(ns)
    ns == 'http://www.w3.org/2001/XMLSchema'
  end

  def create_builtin_type(ns, name)
    XSD::SimpleType::Builtin.new(ns, name)
  end
end