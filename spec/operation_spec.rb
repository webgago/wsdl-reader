require "spec_helper"

describe "WSDL Operation" do
  let(:parser) { WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl') }
  let(:binding) { parser.bindings.values.first }
  let(:messages) { parser.messages }
  subject { binding.operations.values.first  }

  it "should be WSDL::Reader::Operation instance" do
    should be_a WSDL::Reader::Operation
  end

  its :name do
    should eql "getFirstName"
  end

  its :binding do
   should be binding
  end

  its :soap_action do
    should eq ""
  end

  its :style do
    should eq nil
  end

  it "should lookup message from given messages" do
    element = subject.lookup_element(parser.port_types, parser.messages)
    element.should eq "GetFirstName"
  end

end
