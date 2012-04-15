require "spec_helper"

describe "WSDL PortType" do

  def user_service_port_type
    {"getFirstName" => { :name    => "getFirstName",
                         :input   => { :message => "tns:getFirstName" },
                         :output  => { :message => "tns:UserNameResponse" } },

     "getLastName"  => { :name    => "getLastName",
                         :input   => { :message => "tns:getLastName" },
                         :output  => { :message => "tns:UserNameResponse" } }
    }
  end

  context "WSDL::Reader::PortTypes" do
    it "child of Hash" do
      WSDL::Reader::PortTypes.superclass.should be Hash
    end
  end

  context "WSDL::Reader::PortType" do
    subject do
      parser = WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl')
      element = parser.document.root.children.find { |e| e.class == REXML::Element && e.name == 'portType' }
      WSDL::Reader::PortType.new(element)
    end

    its(:operations) { should eq user_service_port_type }
    its(:name) { should eq "UserService" }
  end
end