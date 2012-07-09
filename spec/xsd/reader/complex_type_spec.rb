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
  its(:namespace) { should eql "http://www.example.com/common" }

  it "should have parsed element names" do
    subject.elements.map(&:name).should eql %w(userIdentifier userIdentifier2)
  end

  it 'should have parsed element types' do
    subject.elements.map(&:type).map(&:name).should eql %w(string integer)
  end

  context "when xs:choice" do
    before do
      @xml = <<-XML
<xs:schema targetNamespace="http://www.example.com/common"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cm="http://www.example.com/common">
  <xs:complexType name="GetLastName">
    <xs:annotation>
      <xs:documentation>Foo Bar</xs:documentation>
    </xs:annotation>
    <xs:choice>
      <xs:element name="userIdentifier" type="xs:string" minOccurs="0"/>
      <xs:element name="userIdentifier2" type="xs:integer" minOccurs="0"/>
    </xs:choice>
  </xs:complexType>
</xs:schema>
      XML
    end

    let(:reader) { create_reader(@xml) }
    let(:type) { node(@xml).search('./xs:complexType').first }

    subject { described_class.new(type, reader.schemas.first) }

    its(:type) { should eql :choice }

    it "should have parsed element names" do
      subject.elements.map(&:name).should eql %w(userIdentifier userIdentifier2)
    end

    it 'should have parsed element types' do
      subject.elements.map(&:type).map(&:name).should eql %w(string integer)
    end
  end

  context "when xs:all" do
    before do
      @xml = <<-XML
<xs:schema targetNamespace="http://www.example.com/common"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cm="http://www.example.com/common">
  <xs:complexType name="GetLastName">
    <xs:annotation>
      <xs:documentation>Foo Bar</xs:documentation>
    </xs:annotation>
    <xs:all>
      <xs:element name="userIdentifier" type="xs:string" minOccurs="0"/>
      <xs:element name="userIdentifier2" type="xs:integer" minOccurs="0"/>
    </xs:all>
  </xs:complexType>
</xs:schema>
      XML
    end

    let(:reader) { create_reader(@xml) }
    let(:type) { node(@xml).search('./xs:complexType').first }

    subject { described_class.new(type, reader.schemas.first) }

    its(:type) { should eql :all }

    it "should have parsed element names" do
      subject.elements.map(&:name).should eql %w(userIdentifier userIdentifier2)
    end

    it 'should have parsed element types' do
      subject.elements.map(&:type).map(&:name).should eql %w(string integer)
    end
  end


  context "when extension" do
    before do
      @xml = <<-XML
<xs:schema targetNamespace="http://www.example.com/common"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cm="http://www.example.com/common">
  <xs:complexType name="GetLastName">
    <xs:annotation>
      <xs:documentation>Foo Bar</xs:documentation>
    </xs:annotation>
    <xs:all>
      <xs:element name="userIdentifier" type="xs:string" minOccurs="0"/>
      <xs:element name="userIdentifier2" type="xs:integer" minOccurs="0"/>
    </xs:all>
  </xs:complexType>

  <xs:complexType name="GetOtherFirstName">
    <xs:extension base="cm:GetLastName"/>
  </xs:complexType>

  <xs:complexType name="GetFirstNameWithChoice">
    <xs:sequence>
      <xs:choice>
        <xs:element name="first" type="xs:string" minOccurs="0"/>
        <xs:element name="second" type="xs:string" minOccurs="0"/>
      </xs:choice>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="GetFirstName">
    <xs:extension base="cm:GetLastName">
      <xs:all>
        <xs:element name="other" type="xs:string" minOccurs="0"/>
      </xs:all>
    </xs:extension>
  </xs:complexType>
</xs:schema>
      XML
    end

    let(:reader) { create_reader(@xml) }
    let(:type) { node(@xml).search('./xs:complexType').last }

    subject { described_class.new(type, reader.schemas.first) }

    its(:type) { should eql :all }
    its(:inspect) { should eql '<ComplexType::GetFirstName(userIdentifier:"string", userIdentifier2:"integer", other:"string") base="GetLastName">' }

    it "should have parsed element names" do
      subject.elements.map(&:name).should eql %w(userIdentifier userIdentifier2 other)
    end

    it 'should have parsed element types' do
      subject.elements.map(&:type).map(&:name).should eql %w(string integer string)
    end

    context "with out any elements" do
      let(:type) { node(@xml).search('./xs:complexType')[1] }

      it "should have parsed element names" do
        subject.elements.map(&:name).should eql %w(userIdentifier userIdentifier2)
      end

      it 'should have parsed element types' do
        subject.elements.map(&:type).map(&:name).should eql %w(string integer)
      end
    end

    context "with choice" do
      let(:type) { node(@xml).search('./xs:complexType')[2] }

      it "should have parsed choice in elements" do
        subject.elements.first.should be_a XSD::Choice
        subject.elements.first.map(&:name).should eql %w(first second)
      end

      it 'should have parsed element types' do
        subject.elements.first.should be_a XSD::Choice
        subject.elements.first.map(&:type).map(&:name).should eql %w(string string)
      end
    end
  end
end