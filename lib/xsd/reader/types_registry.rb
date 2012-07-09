class XSD::TypeNotFound < StandardError
end

class XSD::TypesRegistry < Hash
  attr_reader :namespaces

  def initialize(namespaces)
    @namespaces = namespaces
  end

  def find(ns, name)
    raise XSD::TypeNotFound.new("types in namespace [#{ns}] not found") unless self[ns]
    self[ns].find { |e| e.name == name }
  end

  def find_by_name(name)
    self.map { |_, array| array.find { |e| e.name == name } }.flatten.compact
  end
end