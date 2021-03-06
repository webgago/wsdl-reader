# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper.rb"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

CURRENT_DIR=File.dirname(__FILE__)
$: << File.expand_path("../lib")

require "wsdl-reader"
require "xsd-reader"

module XmlHelper
  def clean_xml(xml)
    xml.gsub(/\n/,"").gsub(/\r/,"").gsub(/'/,'"')
  end

  def node(xml)
    Nokogiri.XML(xml).root
  end
end

module XSDReaderHelper
  def create_reader(xml)
    File.stub(:read).with('file_path').and_return(xml)
    XSD::Reader.new('file_path').parse
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include XmlHelper
  config.include XSDReaderHelper
end
