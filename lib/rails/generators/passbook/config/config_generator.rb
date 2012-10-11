module Passbook
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      argument :pass_type_id, type: :string, default: 'pass.com.acme', optional: true, banner: "The Pass Type ID you registered at iOS Provisioning Portal"
      argument :template_path, type: :string, default: '#{Rails.root}/data/templates/pass.com.acme', optional: true, banner: "Absolute path to the pass template"
      argument :cert_path, type: :string, default: '#{Rails.root}/data/certificates/pass.com.acme.p12', optional: true, banner: "Absolute path to your pass.com.acme.p12 file"
      argument :cert_password, type: :string, default: 'password', optional: true, banner: "Password for your P12 certificate"
      argument :wwdr_certificate_path, type: :string, default: '#{Rails.root}/data/certificates/wwdr.pem', optional: true, banner: "Absolute path to your WWDR certification file"

      desc 'Create Passbook initializer'
      def create_initializer_file
        template 'initializer.rb', File.join('config', 'initializers', 'passbook.rb')
      end
    end
  end
end
