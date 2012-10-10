require 'digest/sha1'
require 'json'
require 'openssl'
require 'zip/zip'
require 'zip/zipfilesystem'

module Passbook
  class Pkpass
    attr_accessor :files, :translations, :json, :pass_type_id, :serial_number,  :config

    def initialize(pass_type_id, serial_number)
      self.pass_type_id = pass_type_id
      self.serial_number = serial_number
      self.translations = Hash.new
      raise(ArgumentError, "Don't forget to run the generator to create the initializer") unless Config.instance.pass_config
      self.config = Config.instance.pass_config[self.pass_type_id]
      raise(ArgumentError, "Could not find configuration for #{self.pass_type_id}") unless self.config

      self.files = self.config['files'].dup
      if self.files.include? 'pass.json'
        self.json = JSON.parse(self.files['pass.json'])
      else
        self.json = {}
        puts "Warning: your template_path does not contain pass.json"
      end
    end

    def add_file filename, content
      self.files[filename] = content
    end

    def add_translation_string source, destination, language
      self.translations[language] = Hash.new unless self.translations.include?(language)
      self.translations[language][source] = destination
    end

    def package
      #TODO: write a library that checks that all the right files are included in the package
      #those requirements are going to be different depending on pass_type_id
      self.write_json
      self.write_translation_strings
      self.generate_json_manifest
      self.sign_manifest
      self.compress_pass_file
    end

    def write_json
      self.files['pass.json'] = JSON.pretty_generate(self.json)
    end

    def write_translation_strings
      self.translations.each do |language, trans|
        self.files["#{language}.lproj/pass.strings"] ||= ""
        trans.each do |key, value|
          #TODO: escape key and value
          self.files["#{language}.lproj/pass.strings"] << "\n\"#{key}\" = \"#{value}\";"
        end
      end
    end

    def generate_json_manifest
      manifest = {}
      self.files.each do |filename, content|
        manifest[filename] = Digest::SHA1.hexdigest(content)
      end
      self.files['manifest.json'] = JSON.pretty_generate(manifest)
    end

    def sign_manifest
      flag = OpenSSL::PKCS7::BINARY|OpenSSL::PKCS7::DETACHED
      signed = OpenSSL::PKCS7::sign(config['p12_certificate'].certificate, config['p12_certificate'].key, self.files['manifest.json'], [Config.instance.wwdr_certificate], flag)
      self.files['signature'] = signed.to_der.force_encoding('UTF-8')
    end

    def compress_pass_file
      stringio = Zip::ZipOutputStream::write_buffer do |z|
        self.files.each do |filename, content|
          z.put_next_entry filename
          z.print content
        end
      end
      stringio.set_encoding "binary"
      stringio.rewind
      stringio
      # stringio.sysread
    end
  end
end
