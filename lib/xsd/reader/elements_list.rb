class XSD::ElementsList < Array
  def self.create(list_node, schema)
    case list_node.name
    when 'choice'
      XSD::Choice.new(list_node, schema)
    when 'sequence'
      XSD::Sequence.new(list_node, schema)
    when 'all'
      XSD::All.new(list_node, schema)
    else
      raise("not supported node on create_list:\n#{list_node.name}")
    end
  end

  attr_reader :min, :max, :schema

  def initialize(list_node, schema)
    @min, @max = list_node['minOccurs'], list_node['maxOccurs']
    @min = @min.to_i if @min
    @max = @max.to_i if @max

    list = list_node.elements.map do |node|
      case node.name
      when 'element'
        XSD::Element.new(node, schema)
      when 'choice', 'sequence', 'all'
        schema.create_list(node)
      else
        raise("not supported node on create_list:\n#{node.name}: #{node.inspect}")
      end
    end
    self.concat list.compact
  end

  def inspect_name_type
    "#{self.class.name.demodulize}[#{map(&:inspect_name_type).join(', ')}]"
  end

  def instance(parent=nil, &block)
    map { |e| e.instance(parent, &block) }.join
  end
end

class XSD::Choice < XSD::ElementsList
  def inspect
    "Choice:#{super}"
  end

  def instance(parent=nil, &block)
    "<!-- Choice start -->#{super}<!-- Choice end -->"
  end
end

class XSD::Sequence < XSD::ElementsList
  def inspect
    "Sequence:#{super}"
  end
end

class XSD::All < XSD::ElementsList
  def inspect
    "All:#{super}"
  end
end