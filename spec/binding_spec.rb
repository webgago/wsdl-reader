require "spec_helper"

describe "WSDL Binding" do

  context "WSDL::Reader::Bindings" do
    subject { WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl').bindings }

    it "child of Hash" do
      subject.class.superclass.should be Hash
    end

    it "#get_operations with binding UserServicePortBinding" do
      operations = subject.get_operations "UserServicePortBinding"
      operations.should have(2).operation
      operations.should eq %w{getFirstNameOperation getLastNameOperation}
    end

    it "#get_binding_for_operation_name with binding = UserServicePortBinding and operation = getFirstName" do
      bindings_array = subject.get_binding_for_operation_name "UserServicePortBinding", "getFirstNameOperation"

      bindings_array.should have(1).binding
      bindings_array.first.should be_a WSDL::Reader::Binding
      bindings_array.first.name.should eq "UserServicePortBinding"
      bindings_array.first.operations.keys.should include "getFirstNameOperation"
    end

    it "#get_binding_for_operation_name operation = getFirstName but without binding" do
      bindings_array = subject.get_binding_for_operation_name "getFirstNameOperation"

      bindings_array.should have(2).binding
      bindings_array.first.should be_a WSDL::Reader::Binding
      bindings_array.first.name.should eq "UserServicePortBinding"
      bindings_array.first.operations.keys.should include "getFirstNameOperation"
    end

    it "#all_operations should eql to #get_operations(nil)" do
      subject.get_operations.should eql subject.all_operations
    end

    it "#operation? should return true if any binding include is operation_name" do
      subject.operation?("getFirstNameOperation").should be_true
    end

    it "#operation? should return false if all bindings dont include is operation_name" do
      subject.operation?("not_existing_operation").should be_false
    end
  end

  context "WSDL::Reader::Binding" do

    def operations
      %w{getFirstNameOperation getLastNameOperation}
    end

    let(:parser) {  WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl') }
    subject do
      parser.bindings.values.first
    end

    its('operations.keys') { should eq operations }
    its(:name) { should eq "UserServicePortBinding" }
    its(:type) { should eq "tns:UserService" }
    its(:style) { should eq "document" }
    its(:transport) { should eq "http://schemas.xmlsoap.org/soap/http" }

    it "#operation? should find for operation name" do
      subject.operation?("getFirstNameOperation").should be_true
    end

    it "#lookup_port_type should lookup port_type from given port_types" do
      subject.lookup_port_type(parser.port_types).name.should eq "UserService"
    end
  end

end
