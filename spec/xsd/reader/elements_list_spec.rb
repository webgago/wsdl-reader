require "spec_helper"

describe XSD::ElementsList do
  before do
    @xml = <<-XML
<xs:schema targetNamespace="http://www.example.com/common"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cm="http://www.example.com/common">

  <xs:complexType name="Sequence">
    <xs:sequence>
      <xs:sequence minOccurs="0" maxOccurs="1">
        <xs:element name="first" type="xs:string" minOccurs="0"/>
        <xs:element name="second" type="xs:string" minOccurs="0"/>
      </xs:sequence>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="Choice">
    <xs:sequence>
      <xs:choice>
        <xs:element name="first" type="xs:string" minOccurs="0"/>
        <xs:element name="second" type="xs:string" minOccurs="0"/>
      </xs:choice>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="All">
    <xs:sequence>
      <xs:all>
        <xs:element name="first" type="xs:string" minOccurs="0"/>
        <xs:element name="second" type="xs:string" minOccurs="0"/>
      </xs:all>
    <xs:sequence>
  </xs:complexType>
</xs:schema>
    XML
  end

  it "should be kind of Array" do
    described_class.new(stub(elements: [], :[] => nil), double).should be_kind_of Array
  end

  let(:reader) { create_reader(@xml) }

  subject { XSD::ComplexType.new(type, reader.schemas.first).elements.first }

  context "XSD::Sequence" do
    let(:type) { node(@xml).search('./xs:complexType')[0] }

    it { should be_a XSD::Sequence }
    it { should be_kind_of XSD::ElementsList }
    its(:inspect_name_type) { should eql 'Sequence[first:"string", second:"string"]'}
    its(:min) { should be 0 }
    its(:max) { should be 1 }
    its(:instance) { "<cm:first></cm:first><cm:second></cm:second>" }
  end

  context "XSD::Choice" do
    let(:type) { node(@xml).search('./xs:complexType')[1] }

    it { should be_a XSD::Choice }
    its(:inspect_name_type) { should eql 'Choice[first:"string", second:"string"]'}
    its(:instance) { "<!-- Choice start --><cm:first></cm:first><cm:second></cm:second><!-- Choice end -->" }
  end

  context "XSD::All" do
    let(:type) { node(@xml).search('./xs:complexType')[2] }

    it { should be_a XSD::All }
    its(:inspect_name_type) { should eql 'All[first:"string", second:"string"]'}
    its(:instance) { "<cm:first></cm:first><cm:second></cm:second>" }
  end
end