require "spec_helper"

describe "WSDL PortType" do

  def user_service_port_type
    { "getFirstNameOperation" => { :name   => "getFirstNameOperation",
                                   :input  => { :message => "tns:getFirstNameRequest" },
                                   :output => { :message => "tns:userNameResponse" } },

      "getLastNameOperation"  => { :name   => "getLastNameOperation",
                                   :input  => { :message => "tns:getLastNameRequest" },
                                   :output => { :message => "tns:userNameResponse" } }
    }
  end

  let(:parser) { WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl') }
  let(:messages) { parser.messages }
  let(:operation) { parser.bindings.operations['getFirstNameOperation'] }

  context "WSDL::Reader::PortTypes" do
    it "child of Hash" do
      WSDL::Reader::PortTypes.superclass.should be Hash
    end

    it "should lookup operation message in all port types" do
      message = parser.port_types.lookup_operation_message :input, operation, messages
      message.should be_a WSDL::Reader::Message
      message.name.should eq "getFirstNameRequest"
    end
  end

  context "WSDL::Reader::PortType" do

    subject do
      parser.port_types.values.first
    end

    its(:operations) { should eq user_service_port_type }
    its(:name) { should eq "UserService" }

    it "#operation_message? should check message in operation" do
      operation = { input: { message: 'getFirstNameRequest' } }
      subject.operation_message?(:input, operation, messages.values.first).should be_true

      operation = { input: { message: 'getLastNameRequest' } }
      subject.operation_message?(:input, operation, messages.values.first).should be_false
    end

    it "#lookup_operation_message should lookup message in messages for given type and operation" do
      message = subject.lookup_operation_message :input, operation, messages
      message.should be_a WSDL::Reader::Message
      message.name.should eq "getFirstNameRequest"
    end

  end
end
