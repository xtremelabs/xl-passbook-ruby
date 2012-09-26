require "passbook/pk_pass"

module Passbook
  mattr_accessor :pass_config, :wwdr_intermediate_certificate_path

  def self.configure
    yield self
  end
end


