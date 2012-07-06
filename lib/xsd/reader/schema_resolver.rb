require "uri"
require "pathname"

class XSD::SchemaResolver
  attr_reader :base

  def initialize(location)
    @base_uri  = URI.parse(location)
    @base_path = Pathname.new(location)
  end

  def resolve(location)
    if local?(location)
      resolve_on_local(location)
    else
      resolve_url(location)
    end
  end

  def resolve_node(location)
    Nokogiri::XML(resolve(location)).root
  end

  private

  def local?(location)
    true
  end

  def resolve_on_local(location)
    location = Pathname.new(location)

    if location.absolute?
      File.read(location.to_s)
    else
      require "pathname"
      File.read(location.expand_path(@base_path.dirname).to_s)
    end
  end

end