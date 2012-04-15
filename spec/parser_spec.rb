require "spec_helper"

describe "WSDL Parser" do

  it "parsing fake uri" do
    expect { WSDL::Reader::Parser.new('spec/fixtures/Fake.wsdl') }.to raise_error WSDL::Reader::FileOpenError
  end

  context "parsing 'spec/fixtures/UserService.wsdl'" do
    subject { WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl') }

    context "attributes types" do
      it { should be_a WSDL::Reader::Parser }

      its(:document) { should be_a REXML::Document }

      its(:prefixes) { should be_a Hash }

      its(:target_namespace) { should be_a String }

      its(:types) { should be_a SOAP::XSD }

      its(:messages) { should be_a WSDL::Reader::Messages }

      its(:portTypes) { should be_a SOAP::WSDL::PortTypes }

      its(:bindings) { should be_a SOAP::WSDL::Bindings }

      its(:services) { should be_a SOAP::WSDL::Services }
    end

    context "attributes values" do
      #its(:document) { clean_xml(subject.document.to_s).should eql clean_xml(File.read('spec/fixtures/UserService.wsdl')) }

      its(:prefixes) do
        should eq "soap"         => "http://schemas.xmlsoap.org/wsdl/soap/",
                   "tns"          => "http://example.com/UserService/",
                   "xs"           => "http://www.w3.org/2001/XMLSchema",
                   "__default__"  => "http://schemas.xmlsoap.org/wsdl/"
      end

      its(:target_namespace) { should eq "http://example.com/UserService/" }

      its(:types) { should eq SOAP::XSD.new }

      its('messages.keys') { should eq %w{getFirstName getLastName UserNameResponse} }

      its('portTypes.keys') { should eq %w{UserService} }

      its('bindings.keys') { should eq %w{UserServicePortBinding} }

      its('services.keys') { should eq %w{UserService} }
    end
  end

end
