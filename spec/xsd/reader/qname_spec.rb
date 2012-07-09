require "spec_helper"

describe XSD::QName do
  let(:namespaces) { { type: 'http://example.com/type' } }

  context "when given initialize by name and namespace href" do

    subject { described_class.new('name', 'http://example.com/type', namespaces) }

    its(:name) { should eql 'name' }
    its(:namespace) { should eql 'http://example.com/type' }
    its(:inspect) { should eql "{http://example.com/type}:name" }
    its(:to_s) { should eql "type:name" }
    it "should rewrite prefix of qname" do
      subject.to_s({ t: 'http://example.com/type' }).should eql "t:name"
    end

  end
end