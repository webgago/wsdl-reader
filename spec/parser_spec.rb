require "spec_helper"

describe "WSDL Parser" do

  it "parsing fake uri" do
    expect { WSDL::Reader::Parser.new('spec/fixtures/Fake.wsdl') }.to raise_error WSDL::Reader::FileOpenError
  end

  context "parsing 'spec/fixtures/UserService.wsdl'" do
    let(:parser) { WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl') }
    subject { parser }

    context "attributes types" do
      it { should be_kind_of WSDL::Reader::Parser }

      its(:document) { should be_kind_of REXML::Document }

      its(:prefixes) { should be_kind_of Hash }

      its(:target_namespace) { should be_kind_of String }

      its(:types) { should be_kind_of SOAP::XSD }

      its(:messages) { should be_kind_of WSDL::Reader::Messages }

      its(:port_types) { should be_kind_of WSDL::Reader::PortTypes }

      its(:bindings) { should be_kind_of WSDL::Reader::Bindings }

      its(:services) { should be_kind_of WSDL::Reader::Services }
    end

    context "attributes values" do
      #its(:document) { clean_xml(subject.document.to_s).should eql clean_xml(File.read('spec/fixtures/UserService.wsdl')) }

      its(:prefixes) do
        should eq "soap"        => "http://schemas.xmlsoap.org/wsdl/soap/",
                  "tns"         => "http://example.com/UserService/",
                  "xs"          => "http://www.w3.org/2001/XMLSchema",
                  "__default__" => "http://schemas.xmlsoap.org/wsdl/"
      end

      its(:target_namespace) { should eq "http://example.com/UserService/" }

      its(:types) { should eq SOAP::XSD.new }

      its('messages.keys') { should eq %w{getFirstNameRequest getLastNameRequest userNameResponse} }

      its('port_types.keys') { should eq %w{UserService} }

      its('bindings.keys') { should eq %w{UserServicePortBinding UserServicePortBinding2} }

      its('services.keys') { should eq %w{UserService} }
    end

    context "methods" do

      its(:operations) { should eql parser.bindings.operations }

      it "should delegate lookup_operation_by_element! to messages" do
        subject.messages.should_receive(:lookup_operation_by_element!).with(1,2,3)
        subject.lookup_operation_by_element! 1,2,3
      end

    end
  end

end
