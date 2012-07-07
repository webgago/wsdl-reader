class XSD::ElementsNotFound < StandardError
end

class XSD::ElementsRegistry < Hash
  attr_reader :namespaces

  def initialize(namespaces)
    @namespaces = namespaces
  end

  def find(ns, name)
    raise XSD::ElementsNotFound.new("elements in namespace [#{ns}] not found") unless self[ns]
    self[ns].find { |e| e.name == name }
  end
end