require "spec_helper"

describe XSD::Element do
  context "with defined complex type" do
    before do
      @xml = <<-XML
<xs:schema targetNamespace="http://www.example.com/common"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cm="http://www.example.com/common">
  <xs:complexType name="Options">
    <xs:sequence>
      <xs:element name="one" type="xs:string"/>
      <xs:element name="two" type="xs:string"/>
    </xs:sequence>
  </xs:complexType>

  <xs:element name="options" type="cm:Options" minOccurs="1" maxOccurs="1"/>
</xs:schema>
      XML
      File.stub(:read).with('file_path').and_return(@xml)
    end

    let(:xsd) { node(@xml) }
    let(:element) { xsd.search('./xs:element').first }
    let(:reader) { XSD::Reader.new('file_path').parse }
    let(:schema) { XSD::Schema.new(xsd, reader) }

    subject { described_class.new(element, schema) }

    its(:name) { should eql 'options' }
    its(:qname) { should eql XSD::QName.new('options', "http://www.example.com/common", schema.namespaces) }
    its(:type) do
      subject.name.should eql 'Options'
      subject.elements.map(&:name).should eql %w{one two}
      subject.elements.map(&:type).map(&:name).should eql %w{string string}
    end
    its(:min_occurs) { should eql 1 }
    its(:max_occurs) { should eql 1 }
    its(:inspect) { should eql '<Element options:"Options"(one:"string", two:"string")>' }
    its(:inspect_name_type) { should eql 'options:"Options"(one:"string", two:"string")' }
  end

  context "with inner complex type" do
    before do
      @xml = <<-XML
<xs:schema targetNamespace="http://www.example.com/common"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cm="http://www.example.com/common">
  <xs:element name="options"
    minOccurs="1" maxOccurs="1">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="one" type="xs:string"/>
        <xs:element name="two" type="xs:string"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>
      XML
      File.stub(:read).with('file_path').and_return(@xml)
    end

    let(:xsd) { node(@xml) }
    let(:element) { xsd.search('/xs:schema/xs:element').first }
    let(:inner_element) { 'element'.tap { |s| s.stub(:inspect_name_type).and_return('element:xs:string') } }
    let(:reader) { XSD::Reader.new('file_path').parse }
    let(:schema) { XSD::Schema.new(xsd, reader) }

    subject { described_class.new(element, schema) }
    its(:name) { should eql 'options' }
    its('type.name') { should eql '<<annonimus>>' }
    its(:min_occurs) { should eql 1 }
    its(:max_occurs) { should eql 1 }
    its(:inspect) { should eql '<Element options:"<<annonimus>>"(one:"string", two:"string")>' }
    its(:inspect_name_type) { should eql 'options:"<<annonimus>>"(one:"string", two:"string")' }
    its(:instance) { should eql "<cm:options><cm:one></cm:one><cm:two></cm:two></cm:options>" }

    it "instance with value" do
      instance = subject.instance do |name|
        case name
        when 'one'
          1
        when 'two'
          2
        end
      end
      instance.should eql "<cm:options><cm:one>1</cm:one><cm:two>2</cm:two></cm:options>"
    end
  end

  context "with ref" do
    before do
      @xml = <<-XML
<xs:schema targetNamespace="http://www.example.com/common"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cm="http://www.example.com/common" xmlns:tp="http://www.example.com/type">

  <xs:element name="options"
    minOccurs="1" maxOccurs="1">
    <xs:complexType>
      <xs:sequence>
        <xs:element ref="tp:one"/>
        <xs:element ref="tp:two"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>

  <xs:schema targetNamespace="http://www.example.com/type"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tp="http://www.example.com/type">

    <xs:element name="one" type="xs:string"/>
    <xs:element name="two" type="xs:string"/>
  </xs:schema>
</xs:schema>
      XML
      File.stub(:read).with('file_path').and_return(@xml)
    end

    let(:xsd) { node(@xml) }
    let(:element) { xsd.search('/xs:schema/xs:element').first }
    let(:reader) { XSD::Reader.new('file_path').parse }
    let(:schema) { XSD::Schema.new(xsd, reader) }

    subject { described_class.new(element, schema) }
    its(:name) { should eql 'options' }
    its('type.name') { should eql '<<annonimus>>' }
    its(:min_occurs) { should eql 1 }
    its(:max_occurs) { should eql 1 }
    its(:inspect) { should eql '<Element options:"<<annonimus>>"(one:"string", two:"string")>' }
    its(:inspect_name_type) { should eql 'options:"<<annonimus>>"(one:"string", two:"string")' }
    its(:instance) { should eql "<cm:options><tp:one></tp:one><tp:two></tp:two></cm:options>" }
  end
end