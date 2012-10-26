module Passbook
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      argument :wwdr_certificate_path, type: :string, default: '#{Rails.root}/data/certificates/wwdr.pem', optional: true, banner: "Absolute path to your WWDR certification file"

      desc 'Create Passbook initializer'
      def create_initializer_file
        template 'initializer.rb', File.join('config', 'initializers', 'passbook.rb')
        template 'migration.rb', File.join('db', 'migrate', "#{Time.now.strftime("%Y%m%d%H%M%S")}_create_passbook_registrations.rb")
      end
    end
  end
end
