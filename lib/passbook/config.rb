require 'fileutils'
require 'singleton'

module Passbook
  class Config
    include Singleton
    attr_accessor :pass_config, :wwdr_intermediate_certificate_path, :wwdr_certificate

    def configure
      self.pass_config = Hash.new unless self.pass_config
      yield self
      read_template
      read_certificates
    end

    def read_template
      self.pass_config.each do |pass_type_id, config|
        raise(ArgumentError, "Please specify a template_path in your configuration (in initializer)") unless config['template_path']
        unless config['files']
          config['files'] = Hash.new
          Dir.glob(config['template_path']+"/**/**").each do |file|
            next if File.directory? file
            content = File.read(file)
            filename = Pathname.new(file).relative_path_from(Pathname.new(config['template_path']))
            config['files'][filename.to_s]=content
          end
        end
      end
    end

    def read_certificates
      pass_config.each do |pass_type_id, config|
        raise(ArgumentError, "Please specify cert_path (certificate path) in your configuration (in initializer)") unless config['cert_path']
        # p config
        raise(ArgumentError, "Please specify cert_password (certificate password) in your configuration (in initializer)") unless config['cert_password']
        unless config['p12_certificate']
          config['p12_certificate'] =  OpenSSL::PKCS12::new(File.read(config['cert_path']), config['cert_password'])
        end
      end
      raise(ArgumentError, "Please specify the WWDR Intermediate certificate in your initializer") unless self.wwdr_intermediate_certificate_path
      unless self.wwdr_certificate
        self.wwdr_certificate = OpenSSL::X509::Certificate.new(File.read(self.wwdr_intermediate_certificate_path))
      end
    end

  end
end

