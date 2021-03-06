# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wsdl-reader/version"

Gem::Specification.new do |s|
  s.name        = "wsdl-reader"
  s.version     = Wsdl::Reader::VERSION
  s.authors     = ["Anton"]
  s.email       = ["a.sozontov@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{WSDL for ruby}
  s.description = %q{Read WSDL file and parse messages, bindings, portTypes and services}

  s.rubyforge_project = "wsdl-reader"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard-rspec"

  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "nokogiri"
  #s.add_runtime_dependency "rest-client"
end
