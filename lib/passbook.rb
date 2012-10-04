require "passbook/pk_pass"
require 'fileutils'

module Passbook
  mattr_accessor :pass_config, :wwdr_intermediate_certificate_path, :wwdr_certificate

  def self.configure
    yield self
    read_template
    read_certificates
  end

  def self.read_template
    pass_config.each do |pass_type_id, config|
      config['files'] = Hash.new
      Dir.glob(config['template_path']+"/**/**").each do |file|
        next if File.directory? file
        content = File.read(file)
        filename = Pathname.new(file).relative_path_from(Pathname.new(config['template_path']))
        config['files'][filename.to_s]=content
      end
    end
  end

  def self.read_certificates
    pass_config.each do |pass_type_id, config|
      config['p12_certificate'] =  OpenSSL::PKCS12::new(File.read(config['cert_path']), config['cert_password'])
    end
    self.wwdr_certificate = OpenSSL::X509::Certificate.new(File.read(wwdr_intermediate_certificate_path))
  end

end


