module Passbook
  module Generators
    class PkpassGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :pass_type_id, type: :string, default: 'pass.com.acme', optional: true, banner: "The Pass Type ID you registered at iOS Provisioning Portal"
      argument :template_path, type: :string, default: '#{Rails.root}/data/templates/pass.com.acme', optional: true, banner: "Absolute path to the pass template"
      argument :cert_path, type: :string, default: '#{Rails.root}/data/certificates/pass.com.acme.p12', optional: true, banner: "Absolute path to your pass.com.acme.p12 file"
      argument :cert_password, type: :string, default: 'password', optional: true, banner: "Password for your P12 certificate"

      desc 'Create and configure a model for a particular pkpass (ie. ticket)'
      def create_initializer_file
        template 'initializer.rb', File.join('config', 'initializers', "passbook_#{plural_name.singularize}.rb")
        template 'model.rb', File.join('app', 'models', "#{plural_name.singularize}.rb")
        route "get 'passes/#{plural_name.singularize}' => 'Passbook::passes#get_pkpass', :defaults => { :pass_type_id => '#{pass_type_id}' }"
        template 'migration.rb', File.join('db', 'migrate', "#{Time.now.strftime("%Y%m%d%H%M%S")}_create_#{plural_name}.rb")
      end
    end
  end
end
