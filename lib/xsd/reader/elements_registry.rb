class XSD::ElementsRegistry < Hash
  attr_accessor :namespaces

  def create(node)
    if (ref = node.attr('ref'))
      find(ref)
    else
      XSD::Element.new(node, self)
    end
  end

  def find(name_with_ns)
    return unless namespaces
    ns, name = name_with_ns.split(':')
    ns_href  = namespaces[ns.to_sym]
    raise "namespace [#{ns}] not found" unless ns_href
    raise "elements in namespace [#{ns_href}] not found" unless self[ns_href]
    self[ns_href].find { |e| e.name == name }
  end
end