require 'rubygems'
require 'digest/sha1'
require 'json'
require 'openssl'
require 'zip/zip'
require 'zip/zipfilesystem'

#TODO: warn about requirements for different pass types

module Passbook

  class Pkpass
    attr_accessor :files, :translations, :json, :pass_type_id, :serial_number,  :config

    def initialize(pass_type_id, serial_number)
      self.pass_type_id = pass_type_id
      self.serial_number = serial_number
      self.translations = Hash.new
      self.config = Passbook.pass_config[self.pass_type_id]

      self.files = self.config['files'].dup
      self.json = JSON.parse(self.files['pass.json'])
    end

    def add_file filename, content
      self.files[filename] = content
    end

    def add_translation_string source, destination, language
      self.translations[language] = Hash.new unless self.translations.include?(language)
      self.translations[language][source] = destination
    end

    def package
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
          self.files["#{language}.lproj/pass.strings"] << "\"#{key}\" = \"#{value}\";\n"
        end
      end
    end

    # Creates a json manifest where each files contents has a SHA1 hash
    def generate_json_manifest
      puts "Generating JSON manifest"
      manifest = {}
      # Gather all the files and generate a sha1 hash
      self.files.each do |filename, content|
        manifest[filename] = Digest::SHA1.hexdigest(content)
      end

      self.files['manifest.json'] = JSON.pretty_generate(manifest)
    end

    def sign_manifest
      puts "Signing the manifest"

      flag = OpenSSL::PKCS7::BINARY|OpenSSL::PKCS7::DETACHED
      signed = OpenSSL::PKCS7::sign(config['p12_certificate'].certificate, config['p12_certificate'].key, self.files['manifest.json'], [Passbook.wwdr_certificate], flag)

      self.files['signature'] = signed.to_der.force_encoding('UTF-8')
    end

    def compress_pass_file
      puts "Compressing the pass"
      stringio = Zip::ZipOutputStream::write_buffer do |z|
        self.files.each do |filename, content|
          z.put_next_entry filename
          z.print content
        end
      end
      stringio.rewind
      stringio.sysread
    end
  end
end
