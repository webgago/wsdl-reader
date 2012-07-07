require "spec_helper"

describe XSD::ComplexType do
  before do
    @xml = <<-XML
<xs:schema targetNamespace="http://www.example.com/common"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cm="http://www.example.com/common">
  <xs:complexType name="GetLastName">
    <xs:annotation>
      <xs:documentation>Foo Bar</xs:documentation>
    </xs:annotation>
    <xs:sequence>
      <xs:element name="userIdentifier" type="xs:string" minOccurs="0"/>
      <xs:element name="userIdentifier2" type="xs:integer" minOccurs="0"/>
    </xs:sequence>
  </xs:complexType>
</xs:schema>
    XML
  end

  let(:reader) { create_reader(@xml) }
  let(:type) { node(@xml).search('./xs:complexType').first }

  subject { described_class.new(type, reader.schemas.first) }

  it { should be_complex }
  its(:name) { should eql 'GetLastName' }
  its(:inspect) { should eql '<ComplexType::GetLastName(userIdentifier:"string", userIdentifier2:"integer")>' }
  its(:type) { should eql :sequence }

  it "parsed element names" do
    subject.elements.map(&:name).should eql %w(userIdentifier userIdentifier2)
  end

  it 'parsed element types' do
    subject.elements.map(&:type).map(&:name).should eql %w(string integer)
  end

end