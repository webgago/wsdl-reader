require "spec_helper"

describe "WSDL Messages" do

  context "WSDL::Reader::Messages" do
    it "child of Hash" do
      WSDL::Reader::Messages.superclass.should be Hash
    end
  end

  context "WSDL::Reader::Message" do
    subject do
      parser = WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl')
      element = parser.document.root.children.find { |e| e.class == REXML::Element && e.name == 'message' }
      WSDL::Reader::Message.new(element)
    end

    its(:parts) { should eq "parameters" => { name: "parameters", element: "tns:GetFirstName", mode: :element } }
    its(:name) { should eq "getFirstName" }
  end

end