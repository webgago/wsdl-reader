require "xsd/reader/simple_type"
require "xsd/reader/complex_type"
require "xsd/reader/simple_type_factory"

class XSD::Element
  attr_reader :name, :qname, :type, :min_occurs, :max_occurs, :ref_qname
  attr_reader :node, :schema, :value

  attr_writer :ref

  def initialize(node, schema)
    raise "node must be a <element>" unless node.name == 'element'
    @node       = node
    @name       = node.attr('name')
    @ref_qname  = node.attr('ref')
    @min_occurs = (node.attr('minOccurs') || 1).to_i
    @max_occurs = node.attr('maxOccurs')
    @schema     = schema
    @value      = nil
  end

  def parse(node)
    if type.complex?
      elements.each do |e|
        e.parse(node.search("./#{e.qname}").first)
      end
    else
      if node.elements.empty?
        @value = type.parse(node)
      else
        raise("#{name} must be simple type, but given: \n#{node}")
      end
    end
    self
  end

  def max_occurs
    case @max_occurs
    when 'unbounded'
      Float::INFINITY
    when nil
      1
    else
      @max_occurs.to_i
    end
  end

  def name
    if @ref_qname && !@name
      ref        = schema.find(@ref_qname)
      @namespace = ref.namespace
      @name      = ref.name
      @type      = ref.type
      @qname     = nil
    end
    @name
  end

  def ref_type
    if @ref_qname
      schema.find(@ref_qname).type
    end
  rescue NoMethodError
    raise("could not find ref: #@ref_qname, node:\n#{node}")
  end

  def ref?
    @ref || @ref_qname
  end

  def qname
    @qname ||= XSD::QName.new(name, namespace, @schema.namespaces)
  end

  def namespace
    @namespace ||= if ref? && type.namespace
                     type.namespace
                   else
                     @schema.target_namespace
                   end
  end

  def type
    @type ||= begin
      schema.find_type(node.attr('type')) || schema.find(node.attr('type')) ||
          ref_type ||
          parse_simple_type || parse_complex_type || raise("could not parse type: \n#{node}")
    end
  end

  def find(name)
    elements.find { |e| e.name == name }
  end

  def inspect
    "<Element #{inspect_name_type}>"
  end

  def instance(parent=nil, &block)
    if type.complex?
      inner = type.elements.map { |e| e.instance(self, &block) }.join("")
      "<#{qname}>" << inner << "</#{qname}>"
    else
      val = block_given? ? yield(name) : ""
      "<#{qname}>#{val}</#{qname}>"
    end
  end

  def inspect_name_type
    if type.complex?
      "#{name}:#{type.name.inspect}(#{type.elements.map(&:inspect_name_type).join(', ')})"
    else
      "#{name}:#{type.name.inspect}"
    end
  end

  def elements
    type.respond_to?(:elements) ? type.elements : []
  end

  def to_s
    inspect
  end

  private

  def parse_simple_type
    simple_type = node.search('./xs:simpleType')
    XSD::SimpleTypeFactory.create(simple_type, schema) unless simple_type.empty?
  end

  def parse_complex_type
    complex_type = node.search('./xs:complexType')
    XSD::ComplexType.new(complex_type, schema) unless complex_type.empty?
  end

  def inner_complex_type?
    node.search('./xs:complexType').length > 0
  end

end