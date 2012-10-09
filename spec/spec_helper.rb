require_relative '../lib/passbook'
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
end
