
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




require 'digest/sha1'
require 'json'
require 'openssl'
require 'zip'

module Passbook
  # Pkpass is the class responsible for managing the contect of a pkpass and also signing the package
  class Pkpass
    attr_accessor :files, :translations, :json, :pass_type_id, :serial_number,  :config

    def initialize(pass_type_id, serial_number)
      self.pass_type_id = pass_type_id
      self.serial_number = serial_number
      self.translations = Hash.new
      raise(ArgumentError, "Don't forget to run the generator to create the initializer") unless Config.instance.pass_config
      self.config = Config.instance.pass_config[self.pass_type_id]
      raise(ArgumentError, "Could not find configuration for #{self.pass_type_id}") unless self.config

      if self.config.include? :files
        self.files = self.config['files'].dup
      else
        self.files = Config.instance.load_files self.config['template_path']
      end

      if self.files.include? 'pass.json'
        self.json = JSON.parse(self.files['pass.json'])
      else
        self.json = {}
        puts "Warning: your template_path does not contain pass.json"
      end
    end

    # Add a file to your pkpass
    #
    # example:
    #   pass.add_file "stripe.png", image_content
    #
    # == Parameters:
    # filename::
    #   A String for the name of the file. It can contain a folder, so it is really a relative path within the pkpass
    # content::
    #   Binary content for what will be inside that file
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

    # @private
    def write_json
      self.files['pass.json'] = JSON.pretty_generate(self.json)
    end

    # @private
    def write_translation_strings
      self.translations.each do |language, trans|
        self.files["#{language}.lproj/pass.strings"] ||= ""
        trans.each do |key, value|
          #TODO: escape key and value
          self.files["#{language}.lproj/pass.strings"] << "\n\"#{key}\" = \"#{value}\";"
        end
      end
    end

    # @private
    def generate_json_manifest
      manifest = {}
      self.files.each do |filename, content|
        manifest[filename] = Digest::SHA1.hexdigest(content)
      end
      self.files['manifest.json'] = JSON.pretty_generate(manifest)
    end

    # @private
    def sign_manifest
      flag = OpenSSL::PKCS7::BINARY|OpenSSL::PKCS7::DETACHED
      signed = OpenSSL::PKCS7::sign(config['p12_certificate'].certificate, config['p12_certificate'].key, self.files['manifest.json'], [Config.instance.wwdr_certificate], flag)
      self.files['signature'] = signed.to_der.force_encoding('UTF-8')
    end

    # @private
    def compress_pass_file
      stringio = Zip::OutputStream::write_buffer do |z|
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
