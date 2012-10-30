
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




require 'fileutils'

module Passbook
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      argument :wwdr_certificate_path, type: :string, optional: true, banner: "Absolute path to your WWDR certification file"

      desc 'Create Passbook initializer'
      def create_initializer_file
        path = "#{Rails.root}/data/certificates"
        FileUtils.mkdir_p path if wwdr_certificate_path.blank? && !File.exists?(path)
        template 'initializer.rb', File.join('config', 'initializers', 'passbook.rb')
        template 'migration.rb', File.join('db', 'migrate', "#{Time.now.strftime("%Y%m%d%H%M%S")}_create_passbook_registrations.rb")
      end
    end
  end
end
