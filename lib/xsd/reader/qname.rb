class XSD::QName
  attr_reader :name, :namespace

  def initialize(name, namespace, namespaces)
    @namespaces       = namespaces
    @name, @namespace = name, namespace
  end

  def prefix(namespaces=nil)
    (namespaces || @namespaces).invert[@namespace]
  end

  def to_s(namespaces=nil)
    if prefix(namespaces)
      "#{prefix(namespaces)}:#@name"
    else
      "#@name"
    end
  end

  def inspect
    "{#{namespace}}:#{name}"
  end

  def eql?(other)
    name == other.name && namespace == other.namespace
  end
end