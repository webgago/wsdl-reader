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
      operations.should eq %w{getFirstName getLastName}
    end

    it "#get_binding_for_operation_name with binding = UserServicePortBinding and operation = getFirstName" do
      bindings_array = subject.get_binding_for_operation_name "UserServicePortBinding", "getFirstName"

      bindings_array.should have(1).binding
      bindings_array.first.should be_a WSDL::Reader::Binding
      bindings_array.first.name.should eq "UserServicePortBinding"
      bindings_array.first.operations.keys.should include "getFirstName"
    end

    it "#get_binding_for_operation_name operation = getFirstName but without binding" do
      bindings_array = subject.get_binding_for_operation_name "getFirstName"

      bindings_array.should have(1).binding
      bindings_array.first.should be_a WSDL::Reader::Binding
      bindings_array.first.name.should eq "UserServicePortBinding"
      bindings_array.first.operations.keys.should include "getFirstName"
    end

    it "#all_operations should eql to #get_operations(nil)" do
      subject.get_operations.should eql subject.all_operations
    end
  end

  context "WSDL::Reader::Binding" do

    def operations
      { "getFirstName" => { :name       => "getFirstName",
                            :soapAction => "",
                            :input      => { :body => { :use => "literal" } },
                            :output     => { :body => { :use => "literal" } } },

        "getLastName"  => { :name       => "getLastName",
                            :soapAction => "",
                            :input      => { :body => { :use => "literal" } },
                            :output     => { :body => { :use => "literal" } } }
      }
    end

    subject do
      WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl').bindings.values.first
    end

    its(:operations) { should eq operations }
    its(:name) { should eq "UserServicePortBinding" }
    its(:type) { should eq "tns:UserService" }
    its(:style) { should eq "document" }
    its(:transport) { should eq "http://schemas.xmlsoap.org/soap/http" }
  end

end