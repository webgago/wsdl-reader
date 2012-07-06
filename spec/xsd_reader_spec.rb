require "spec_helper"

describe XSD::Reader do
  context "parse xsd" do
    let(:reader) { XSD::Reader.new('spec/fixtures/UserService.xsd').parse }
    subject { reader }

    its(:namespaces) { should eql tns: 'http://example.com/UserService/type/', xs: 'http://www.w3.org/2001/XMLSchema', com: "http://example.com/common/" }

    context "#elements" do
      subject { reader.elements }
      its('keys') { should eql ['http://example.com/UserService/type/',  "http://example.com/common/"] }
      its('values.first') { should have(4).elements }
      its(:namespaces) { should eql tns: 'http://example.com/UserService/type/', xs: 'http://www.w3.org/2001/XMLSchema', com: "http://example.com/common/" }

      context "find global elemnt by name with NS" do
        it "should found [tns:age] element and return instance of XSD::Reader::Element" do
          subject.find('tns:age').should be_a XSD::Reader::Element
        end

        it "should raise error if ns prefix [example] not found" do
          expect { subject.find('example:age') }.to raise_error "namespace [example] not found"
        end

        it "should raise error if elements in given namespace [example] not found" do
          subject.stub(:namespaces).and_return({ :example => 'http://example.com/type' })
          expect { subject.find('example:age111') }.to raise_error "elements in namespace [http://example.com/type] not found"
        end

        it "should return nil if [tns:age1] not found" do
          subject.find('tns:age1').should be_nil
        end

      end

    end

    context "#complex_types" do
      subject { reader.complex_types }
      it { should have_key 'http://example.com/UserService/type/' }
      its(['http://example.com/UserService/type/']) { should have(2).elements }

      context "#values" do
        subject { reader.complex_types['http://example.com/UserService/type/'].first }

        it { should be_a XSD::Reader::ComplexType }
        it "should be a GetFirstName" do
          subject.name.should eql 'GetFirstName'
        end

        it "should have 4 right elements" do
          subject.should have(5).elements
          subject.elements.map(&:name).should eql ['userIdentifier', 'filter',  "isOut", "zone", "options"]
          complex = '<ComplexType::<<annonimus>> ["age:<SimpleType::<<annonimus>> base=xs:integer>", "gender:<SimpleType::<<annonimus>> base=xs:string>"]>'
          subject.elements.map(&:type).map(&:to_s).should eql ["xs:string", complex, "com:ZONE", "cm:ZONE", "com:Options"]
        end

        it "filter should have 2 inner elements" do
          subject.elements[1].elements.map(&:name).should eql ['age', 'gender']
        end
      end
    end

    context "Simple type" do

      subject { reader.complex_types['http://example.com/UserService/type/'].first.elements[1] }

      context "restriction" do
        it "should parse enumeration" do
          subject.elements.last.type.should be_a XSD::Reader::SimpleType::Restriction
          subject.elements.last.type.base.should eql 'xs:string'
          subject.elements.last.type.enumeration.should eql %w{male female}
        end

        it "should parse minInclusive" do
          subject.elements.first.type.should be_a XSD::Reader::SimpleType::Restriction
          subject.elements.first.type.base.should eql 'xs:integer'
          subject.elements.first.type.min.should eql 0
        end

        it "should parse maxInclusive" do
          subject.elements.first.type.should be_a XSD::Reader::SimpleType::Restriction
          subject.elements.first.type.base.should eql 'xs:integer'
          subject.elements.first.type.max.should eql 100
        end
      end

    end

    context "SchemaResolver" do
      context "when xsd file on local filesystem" do
        subject { XSD::Reader::SchemaResolver.new("/tmp/xsd/files/Local.xsd") }

        it "should resolve schema on absolute location" do
          File.stub(:read).with('/tmp/absolute/path/common.xsd').and_return("xml")

          xml = subject.resolve '/tmp/absolute/path/common.xsd'
          xml.should eql "xml"
        end

        it "should resolve schema on relative location" do
          File.stub(:read).with('/tmp/common.xsd').and_return("xml")

          xml = subject.resolve '../../../common.xsd'
          xml.should eql "xml"
        end
      end
    end

  end
end