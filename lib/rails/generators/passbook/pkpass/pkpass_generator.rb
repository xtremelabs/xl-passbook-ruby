
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




module Passbook
  module Generators
    class PkpassGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :pass_type_id, type: :string, default: 'pass.com.acme', optional: true, banner: "The Pass Type ID you registered at iOS Provisioning Portal"
      argument :team_id, type: :string, optional: true, banner: "Team ID you got at the iOS Provisioning Portal when you registered the pass type id"
      argument :cert_path, type: :string, optional: true, banner: "Absolute path to your pass.com.acme.p12 file"
      argument :cert_password, type: :string, default: 'password', optional: true, banner: "Password for your P12 certificate"

      desc 'Create and configure a model for a particular pkpass (ie. ticket)'
      def create_initializer_file
        template 'initializer.rb', File.join('config', 'initializers', "passbook_#{plural_name.singularize}.rb")
        template 'model.rb', File.join('app', 'models', "#{plural_name.singularize}.rb")
        route "get '/v1/passes/#{plural_name.singularize}' => 'Passbook::Passes#get_pkpass', :defaults => { :pass_type_id => '#{pass_type_id}' }"
        template 'migration.rb', File.join('db', 'migrate', "#{Time.now.strftime("%Y%m%d%H%M%S")}_create_#{plural_name}.rb")
        template 'pass.json', File.join('data', 'templates', pass_type_id, "pass.json")
        template 'icon.png', File.join('data', 'templates', pass_type_id, "icon.png")
        template 'icon@2x.png', File.join('data', 'templates', pass_type_id, "icon@2x.png")
      end
    end
  end
end
