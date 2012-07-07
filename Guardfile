# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :version => 2, all_after_pass: false, all_on_start: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/wsdl-reader/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/xsd/(.+)\.rb$})     { |m| "spec/xsd/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
  watch(%r{spec/fixtures/.+})  { "spec" }
end