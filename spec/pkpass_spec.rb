
#  Copyright 2012 Xtreme Labs

#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.




require 'spec_helper'
require 'json'


RSpec.configure do |c|
  c.include Helpers
end

describe Passbook::Pkpass do
  before :all do
    Passbook::Config.instance.configure do |passbook|
      passbook.wwdr_certificate = OpenSSL::X509::Certificate.new
    end

    Passbook::Config.instance.add_pkpass do |passbook|
      template_path =  "#{Dir.pwd}/spec/data/templates"
      cert_path = "#{Dir.pwd}/spec/data/certificates"
      passbook.pass_config["pass.com.acme"]={
                                  "cert_path"=>"#{cert_path}/pass.com.acme.p12",
                                  "cert_password"=>"test",
                                  "template_path"=>"#{template_path}/pass.com.acme",
                                  "p12_certificate"=>create_p12
                                }
      passbook.wwdr_intermediate_certificate_path = "#{Dir.pwd}/spec/data/certificates/wwdr.pem"
    end
  end

  before :each do
    @pass = Passbook::Pkpass.new("pass.com.acme", "test")
  end


  it "should throw ArgumentError because there is no config for 'test'" do
    expect {Passbook::Pkpass.new("test", "test")}.to raise_error(ArgumentError, /configuration for test/)
  end

  it "should make an instance of Pkpass" do
    expect {Passbook::Pkpass.new("pass.com.acme", "test")}.to_not raise_error
  end

  it "should have the added file in zip file" do
    @pass.add_file "andrei.png", "haha"
    pkpass_io = @pass.package
    check_file_in_zip(pkpass_io, "andrei.png").should be_true
  end

  it "should have the added file in zip file(in a folder)" do
    @pass.add_file "fr.lproj/andrei.png", "haha"
    pkpass_io = @pass.package
    check_file_in_zip(pkpass_io, "fr.lproj/andrei.png").should be_true
  end

  it "should add an entry in the right pass.strings file" do
    @pass.add_translation_string "yes", "qui", "fr"
    pass_strings = file_from_zip(@pass.package, "fr.lproj/pass.strings")
    pass_strings.should_not be_nil
    pass_strings.should match /\"yes\" = \"qui\";/
  end

  it "should only append to strings file" do
    @pass.add_file "fr.lproj/pass.strings", "\"not\" = \"not\";"
    @pass.add_translation_string "yes", "qui", "fr"
    pass_strings = file_from_zip(@pass.package, "fr.lproj/pass.strings")
    pass_strings.should_not be_nil
    pass_strings.should match /\"not\" = \"not\";/
    pass_strings.should match /\"yes\" = \"qui\";/
  end

  it "should include all the files from template_path" do
    pkpass_io = @pass.package
    Dir.glob(@pass.config["template_path"]+"/**/**").each do |file|
      next if File.directory? file
      filename = Pathname.new(file).relative_path_from(Pathname.new(@pass.config['template_path']))
      check_file_in_zip(pkpass_io, filename.to_s).should be_true
    end
  end

  it "should include manifest.json" do
    check_file_in_zip(@pass.package, "manifest.json").should be_true
  end

  it "should have all the files in manifest.json and none more" do
    files_json = JSON.parse(file_from_zip(@pass.package, "manifest.json"))
    Dir.glob(@pass.config["template_path"]+"/**/**").each do |file|
      next if File.directory? file
      filename = Pathname.new(file).relative_path_from(Pathname.new(@pass.config['template_path'])).to_s
      if files_json.include? filename
        files_json.delete filename
      else
        fail
      end
    end
    files_json.should be_empty
  end

  it "should have a signature" do
    check_file_in_zip(@pass.package, "signature").should be_true
  end
end
