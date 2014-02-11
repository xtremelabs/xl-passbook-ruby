
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


module Passbook
  # @private
  def self.pass_type_id_to_class pass_type_id
    Passbook::Config.instance.pass_config[pass_type_id]['class'].constantize
  end

  # Determine the pass type the object represents.
  #
  # obj - Object to try to match a passport type for.
  #
  # Returns the string ID for the pass type, or nil if no match is found.
  def self.object_to_pass_type_id(obj)
    Passbook.Config.instance.pass_config.each do |pass_type_id, config|
      is_match = if obj.respond_to? :pass_type_id
                   obj.pass_type_id == pass_type_id
                 else
                   obj.class.to_s == config["class"]
                 end

      return pass_type_id if is_match
    end
  end

  # Registers a custom renderer for .pkpass files
  # (executed at load time)
  #
  # example:
  #   render :pkpass ticket
  #
  # (where `ticket` is an instance of a model that is configured with passbook-ruby gem)
  def self.register_pkpass
    Mime::Type.register 'application/vnd.apple.pkpass', :pkpass

    ActionController::Renderers.add :pkpass do |obj, options|
      pkpass = Passbook::Pkpass.new Passbook.object_to_pass_type_id(obj), obj.serial_number
      obj.update_pass pkpass if obj.respond_to? :update_pass
      pkpass_io = pkpass.package
      response.headers["last-modified"] = obj.updated_at.strftime("%Y-%m-%d %H:%M:%S")
      send_data(pkpass_io.sysread, :type => 'application/vnd.apple.pkpass', :disposition=>'inline', :filename=>"#{obj.serial_number}.pkpass")
    end
  end
  self.register_pkpass

end

