require 'rubygems'
require 'fileutils'
require 'tmpdir'
require 'digest/sha1'
require 'json'
require 'openssl'
require 'zip/zip'
require 'zip/zipfilesystem'

#TODO: warn about requirements for different pass types

module Passbook

  class Pkpass
    attr_accessor :translations, :json, :template_path, :pass_type_id, :wwdr_intermediate_certificate_path, :serial_number, :certificate_url, :certificate_password, :temporary_directory, :temporary_path, :manifest_url

    def initialize(pass_type_id, serial_number, template_path)
      self.pass_type_id = pass_type_id
      self.serial_number = serial_number
      self.template_path = template_path
      self.translations = Hash.new

      self.create_temporary_directory
      self.copy_template_to_temporary_directory
      self.read_json
    end

    def add_file content, file_name
      if file_name.include? "/"
        folder_name = file_name.gsub(file_name.split("/").last, "")
        folder_path = self.temporary_path+"/"+folder_name
        FileUtils.mkdir_p(folder_path) unless File.directory?(folder_path)
      end
      file_path = self.temporary_path+"/"+file_name
      File.open(file_path, "w") do |f|
        f.write content.force_encoding('UTF-8')
      end
    end

    def add_translation_string source, destination, language
      self.translations[language] = Hash.new unless self.translations.include?(language)
      self.translations[language][source] = destination
    end

    def package
      self.write_json
      self.write_translation_strings
      self.clean_ds_store_files
      self.generate_json_manifest
      self.sign_manifest
      self.compress_pass_file
    end

    def output_url
      self.temporary_directory+"/"+self.serial_number+".pkpass"
    end



    def read_json
      self.json = JSON.parse(File.read("#{self.temporary_path}/pass.json"))
    end

    def write_json
      File.open(self.temporary_path+"/pass.json", "w") do |f|
        f.write JSON.pretty_generate(self.json)
      end
    end

    def copy_template_to_temporary_directory
      puts "copying from #{self.template_path} to #{self.temporary_directory}"
      FileUtils.cp_r(self.template_path, self.temporary_directory)
    end

    def write_translation_strings
      self.translations.each do |language, trans|
        translations_path = "#{self.temporary_path}/#{language}.lproj"
        FileUtils.mkdir_p(translations_path) unless File.directory?(translations_path)
        File.open("#{translations_path}/pass.strings", "a") do |f|
          trans.each do |key, value|
            f.puts "\"#{key}\" = \"#{value}\";"
          end
        end
      end
    end

    # Creates a temporary place to work with the pass files without polluting the original
    def create_temporary_directory
      self.temporary_directory = Dir.mktmpdir
      puts "Creating temp dir at #{self.temporary_directory}"
      self.temporary_path = self.temporary_directory + "/" + self.pass_type_id
      # Check if the directory exists
      if File.directory?(self.temporary_path)
        # Need to clean up the directory
        FileUtils.rm_rf(self.temporary_path)
      end
      FileUtils.mkdir_p(self.temporary_path)
    end

    def clean_ds_store_files
      puts "Cleaning .DS_Store files"
      Dir.glob(self.temporary_path + "**/.DS_Store").each do |file|
        File.delete(file)
      end
    end

    # Creates a json manifest where each files contents has a SHA1 hash
    def generate_json_manifest
      puts "Generating JSON manifest"
      manifest = {}

      # Gather all the files and generate a sha1 hash
      Dir.glob(self.temporary_path + "/**/**").each do |file|
        manifest[file[self.temporary_path.length+1..-1].gsub("/", "\/")] = Digest::SHA1.hexdigest(File.read(file)) unless File.directory?(file)
      end

      # Write the hash dictionary out to a manifest file
      self.manifest_url = self.temporary_path + "/manifest.json"
      File.open(self.manifest_url, "w") do |f|
        f.write(JSON.pretty_generate(manifest))
      end
    end

    def sign_manifest
      puts "Signing the manifest"
      # Import the certificate
      p12_certificate = OpenSSL::PKCS12::new(File.read(self.certificate_url), self.certificate_password)
      wwdr_certificate = OpenSSL::X509::Certificate.new(File.read(self.wwdr_intermediate_certificate_path))

      # Sign the data
      flag = OpenSSL::PKCS7::BINARY|OpenSSL::PKCS7::DETACHED
      signed = OpenSSL::PKCS7::sign(p12_certificate.certificate, p12_certificate.key, File.read(self.manifest_url), [wwdr_certificate], flag)

      # Create an output path for the signed data
      signature_url = self.temporary_path + "/signature"

      # Write out the data
      File.open(signature_url, "w") do |f|
        f.write signed.to_der.force_encoding('UTF-8')
      end
    end

    def compress_pass_file
      puts "Compressing the pass"
      zipped_file = File.open(self.output_url, "w")

      #Matching pattern was "/**" and now changed to ".*"
      Zip::ZipOutputStream.open(zipped_file.path) do |z|
        Dir.glob(self.temporary_path + "/**/**").each do |file|
          unless File.directory?(file)
            z.put_next_entry(file[self.temporary_path.length+1..-1])
            z.print IO.read(file)
          end
        end
      end
      zipped_file
    end
  end
end
