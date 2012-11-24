
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




require "passbook/config"
require "passbook/pkpass"
require "passbook/engine"

require "action_controller"
Mime::Type.register 'application/vnd.apple.pkpass', :pkpass

ActionController::Renderers.add :pkpass do |obj, options|
  pkpass = Passbook::Pkpass.new Passbook.class_name_to_pass_type_id(obj.class.to_s), obj.id
  obj.update_pass pkpass if obj.respond_to? :update_pass
  pkpass_io = pkpass.package
  response.headers["last-modified"] = obj.updated_at.strftime("%Y-%m-%d %H:%M:%S")
  send_data(pkpass_io.sysread, :type => 'application/vnd.apple.pkpass', :disposition=>'inline', :filename=>"#{obj.id}.pkpass")
end

module Passbook
  def self.pass_type_id_to_class pass_type_id
    Passbook::Config.instance.pass_config[pass_type_id]['class'].constantize
  end

  def self.class_name_to_pass_type_id class_name
    Passbook::Config.instance.pass_config.each do |pass_type_id, config|
      return pass_type_id if config['class']==class_name
    end
  end
end

