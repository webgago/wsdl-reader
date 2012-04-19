require "spec_helper"

describe "WSDL Messages" do

  context "WSDL::Reader::Messages" do
    let(:parser) { WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl') }
    subject { parser.messages }

    it "should be kind of WSDL::Reader::Messages" do
      subject.should be_kind_of WSDL::Reader::Messages
    end

    it "should be kind of Hash" do
      subject.should be_kind_of Hash
    end

    it "#lookup_messages_by_element should return operation name by given element name" do
      messages = subject.lookup_messages_by_element("GetFirstName")
      messages.count.should eq 1
      messages.first.name.should eq "getFirstNameRequest"
    end

    it "#lookup_operations_by_element should return operation name by given element name" do
      operations = subject.lookup_operations_by_element(:input, "GetFirstName", parser.port_types)
      operations.count.should eq 1
      operations.first.should eq "getFirstNameOperation"
    end

  end

  context "WSDL::Reader::Message" do
    subject do
      parser = WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl')
      parser.messages.first.last
    end

    its(:parts) { should eq "parameters" => { name: "parameters", element: "tns:GetFirstName", mode: :element } }
    its(:name) { should eq "getFirstNameRequest" }
  end

end