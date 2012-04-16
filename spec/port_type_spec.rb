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

  let(:parser) {  WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl') }
  let(:messages) { parser.messages }
  let(:operation) { parser.bindings.values.first.operations.values.first }

  context "WSDL::Reader::PortTypes" do
    it "child of Hash" do
      WSDL::Reader::PortTypes.superclass.should be Hash
    end

    it "should lookup operation message in all port types" do
      message = parser.port_types.lookup_operation_message :input, operation, messages
      message.should be_a WSDL::Reader::Message
      message.name.should eq "getFirstName"
    end
  end

  context "WSDL::Reader::PortType" do

    subject do
      parser.port_types.values.first
    end

    its(:operations) { should eq user_service_port_type }
    its(:name) { should eq "UserService" }

    it "#lookup_operation_message should lookup message in messages for given type and operation" do
      message = subject.lookup_operation_message :input, operation, messages
      message.should be_a WSDL::Reader::Message
      message.name.should eq "getFirstName"
    end
  end
end
