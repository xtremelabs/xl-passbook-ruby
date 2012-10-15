require 'spec_helper'

describe Passbook::Config do
  it "should throw ArgumentError because wwdr_intermediate_certificate_path is missing"  do
    expect {Passbook::Config.instance.configure {}}.to raise_error(ArgumentError)
  end

  it "should throw ArgumentError because template_path is missing" do
    expect{ Passbook::Config.instance.configure do |passbook|
      passbook.wwdr_intermediate_certificate_path = "#{Dir.pwd}/spec/data/certificates/wwdr.pem"
      passbook.pass_config['pass.com.acme'] = {}
    end}.to raise_error(ArgumentError)
  end

  it "should throw ArgumentError because cert_path is missing" do
    expect{ Passbook::Config.instance.configure do |passbook|
      passbook.wwdr_intermediate_certificate_path = "test"
      passbook.pass_config["pass.com.acme"] = {"template_path"=>"tmp"}
    end}.to raise_error(ArgumentError)
  end

  it "should throw ArgumentError because cert_password is missing" do
    expect{ Passbook::Config.instance.configure do |passbook|
      passbook.wwdr_intermediate_certificate_path = "test"
      passbook.pass_config["pass.com.acme"] = {
                                                "template_path"=>"tmp",
                                                "cert_path"=>"tmp"
                                              }
    end}.to raise_error(ArgumentError)
  end

end

