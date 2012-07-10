class XSD::SimpleType
  attr_reader :name, :schema

  def initialize(node, schema)
    @schema = schema
    @name   = node.attr('name') || '<<annonimus>>'
  end

  def complex?
    false
  end

  def klass
    Object
  end

  def namespace
    schema.target_namespace
  end

  def parse(node)
    val       = node.text
    converter = { String  => -> { val },
                  Integer => -> { val.to_i }, Float => -> { val.to_f }
    }[klass]

    if converter
      converter.call
    else
      raise(NotImplementedError, "not implemented type parsing: #{klass}")
    end
  end

  class Builtin < self
    def initialize(ns, name, schema)
      @schema = schema
      @name   = name
      @ns     = ns
    end

    def klass
      case name
      when 'string'
        String
      when 'integer'
        Integer
      else
        raise "do not know mapping for builtin type '#{name}'"
      end
    end

    def inspect
      klass.inspect
    end

    def namespace
      nil
    end
  end

  class Base < self
    attr_reader :name, :schema

    def inspect
      "<SimpleType::#{name}#{yield}>"
    end

    def to_s
      inspect
    end
  end

  class Restriction < Base
    attr_reader :base

    def initialize(node, schema)
      super
      @node = node.search('./xs:restriction')
      @base = @node.attr('base').value rescue nil
      raise "restriction should have 'base' attribute: \n#{node.inspect}" unless @base
      @base = schema.find(@base)
    end

    def klass
      @base.klass
    end

    def enumeration
      @node.search('./xs:enumeration').map do |e|
        e.attr('value')
      end
    end

    def min
      @node.search('./xs:minInclusive').first.attr('value').to_i
    end

    def max
      @node.search('./xs:maxInclusive').first.attr('value').to_i
    end

    def inspect
      super do
        " base=#{base}"
      end
    end
  end
end