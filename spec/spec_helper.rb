require_relative '../lib/passbook-ruby'
require_relative '../lib/passbook/config'
require_relative '../lib/passbook/pkpass'


module Helpers

  def zip_io zip_file_io
    File.open("test.zip", 'w') do |file|
      zip_file_io.rewind
      file.write zip_file_io.sysread
    end
    Zip::ZipInputStream::open("test.zip")
  end

  def file_from_zip zip_file_io, filename
    io = zip_io zip_file_io
    while (entry = io.get_next_entry) do
      return io.read if entry.name == filename
    end
    nil
  end

  def check_file_in_zip zip_file_io, filename
    io = zip_io zip_file_io
    while (entry = io.get_next_entry) do
      return true if entry.name == filename
    end
    false

    # def zip_file_io.path
    #   'bypass_rubyzip_issue'
    # end
    # puts "We got #{zip_file_io.size}"

    # Zip::ZipInputStream::open_buffer(zip_file_io) do |io|
    #   entry = io.get_next_entry
    #   # while (entry = io.get_next_entry) do
    #   #     puts "entry: #{entry.name}"
    #   # end
    # end
  end

  def create_p12
    root_key = OpenSSL::PKey::RSA.new 2048 # the CA's public/private key
    root_ca = OpenSSL::X509::Certificate.new
    root_ca.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
    root_ca.serial = 1
    root_ca.subject = OpenSSL::X509::Name.parse "/DC=org/DC=ruby-lang/CN=Ruby CA"
    root_ca.issuer = root_ca.subject # root CA's are "self-signed"
    root_ca.public_key = root_key.public_key
    root_ca.not_before = Time.now
    root_ca.not_after = root_ca.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = root_ca
    ef.issuer_certificate = root_ca
    root_ca.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
    root_ca.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
    root_ca.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
    root_ca.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
    root_ca.sign(root_key, OpenSSL::Digest::SHA256.new)
    OpenSSL::PKCS12.create("test", "test", root_key, root_ca)
  end
end
