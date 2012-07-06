class XSD::SimpleType
  class Base
    attr_reader :name

    def initialize(node)
      @name = node.attr('name') || '<<annonimus>>'
    end

    def inspect
      "<SimpleType::#{name}#{yield}>"
    end

    def to_s
      inspect
    end
  end

  class Restriction < Base
    attr_reader :base

    def initialize(node)
      super
      @node = node.search('./xs:restriction')
      @base = @node.attr('base').value rescue nil
      raise "restriction should have 'base' attribute: \n#{node.inspect}" unless @base
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