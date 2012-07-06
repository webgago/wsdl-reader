require "spec_helper"

describe XSD::SchemaResolver do
  context "when xsd file on local filesystem" do
    subject { described_class.new("/tmp/xsd/files/Local.xsd") }

    it "should resolve schema on absolute location" do
      File.stub(:read).with('/tmp/absolute/path/common.xsd').and_return("xml")

      xml = subject.resolve '/tmp/absolute/path/common.xsd'
      xml.should eql "xml"
    end

    it "should resolve schema on relative location" do
      File.stub(:read).with('/tmp/common.xsd').and_return("xml")

      xml = subject.resolve '../../common.xsd'
      xml.should eql "xml"
    end

    it "should resolve schema if location is filename" do
      File.stub(:read).with('/tmp/xsd/files/common.xsd').and_return("xml")

      xml = subject.resolve 'common.xsd'
      xml.should eql "xml"
    end
  end
end