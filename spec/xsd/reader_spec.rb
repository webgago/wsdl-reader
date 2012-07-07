require "spec_helper"

describe XSD::Reader do
  context "parse xsd" do
    let(:reader) { XSD::Reader.new('spec/fixtures/UserService.xsd').parse }
    subject { reader }

    its(:namespaces) { should eql tns: 'http://example.com/UserService/type/', xs: 'http://www.w3.org/2001/XMLSchema',
                                  com: "http://example.com/common/", cm: "http://example.com/common/" }

    context "#elements_registry" do
      subject { reader.elements_registry }
      its('keys') { should eql ['http://example.com/UserService/type/',  "http://example.com/common/"] }
      its('values.first') { should have(4).elements }
      its(:namespaces) { should eql tns: 'http://example.com/UserService/type/', xs: 'http://www.w3.org/2001/XMLSchema',
                                    com: "http://example.com/common/", cm: "http://example.com/common/" }

      context "find global element by name with NS" do
        it "should found [tns:age] element and return instance of XSD::Reader::Element" do
          subject.find('http://example.com/UserService/type/', 'age').should be_a XSD::Element
        end

        it "should raise error if ns prefix [example] not found" do
          expect { subject.find('example', 'age') }.to raise_error XSD::ElementsNotFound, 'elements in namespace [example] not found'
        end

        it "should raise error if elements in given namespace [example] not found" do
          subject.stub(:namespaces).and_return({ :example => 'http://example.com/type' })
          expect { subject.find('example', 'age111') }.to raise_error XSD::ElementsNotFound, 'elements in namespace [example] not found'
        end

        it "should return nil if [tns:age1] not found" do
          subject.find('http://example.com/UserService/type/', 'age1').should be_nil
        end

      end
    end

    context "#types_registry" do
      subject { reader.types_registry }
      it { should have_key 'http://example.com/UserService/type/' }
      its(%w(http://example.com/UserService/type/)) { should have(2).elements }

      context "#values" do
        subject { reader.types_registry['http://example.com/UserService/type/'].first }

        it { should be_a XSD::ComplexType }
        it "should be a GetFirstName" do
          subject.name.should eql 'GetFirstName'
        end

        it "should have 4 elements" do
          subject.should have(5).elements
          subject.elements.map(&:name).should eql ['userIdentifier', 'filter',  "isOut", "zone", "options"]
          subject.elements.map(&:type).map(&:name).should eql ["string", '<<annonimus>>', "ZONE", "ZONE", "Options"]
        end

        it "filter should have 2 inner elements" do
          subject.elements[1].elements.map(&:name).should eql ['age', 'gender']
        end
      end
    end

    context "Simple type" do

      subject { reader.types_registry['http://example.com/UserService/type/'].first.elements[1] }

      context "restriction" do
        it "should parse enumeration" do
          subject.elements.last.type.should be_a XSD::SimpleType::Restriction
          subject.elements.last.type.base.should eql 'xs:string'
          subject.elements.last.type.enumeration.should eql %w{male female}
        end

        it "should parse minInclusive" do
          subject.elements.first.type.should be_a XSD::SimpleType::Restriction
          subject.elements.first.type.base.should eql 'xs:integer'
          subject.elements.first.type.min.should eql 0
        end

        it "should parse maxInclusive" do
          subject.elements.first.type.should be_a XSD::SimpleType::Restriction
          subject.elements.first.type.base.should eql 'xs:integer'
          subject.elements.first.type.max.should eql 100
        end
      end

    end

  end
end