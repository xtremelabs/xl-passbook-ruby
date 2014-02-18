
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
  def self.pass_type_id_to_class pass_id
    Passbook::Config.instance.pass_config[pass_id]['class'].constantize
  end

  # Public: Determine if the given object matches the specified config.
  #
  # obj         - Object to determine what config to use.
  # pass_id     - The key that the config was found under, defining a pass
  # pass_config - Config to match against.
  #
  # Returns true if the object represents the pass in the config.
  def self.object_matches_pass_config(obj, pass_id, pass_config)
    if obj.respond_to? :pass_id
      # Allow 1 class type to represent any pass (good for multiple pass templates)
      obj.pass_id == pass_id
    else
      # Fallback. Bind a class to a pass by type. This will only match the first
      # found in the case of multiple pass definitions. This exists for
      # backwards compatibility.
      obj.class.to_s == pass_config["class"]
    end
  end

  # Public: Determine what pass to use for the specified object.
  # Returns a string id for the pass configuration.
  def self.find_pass_id_for(obj)
    Passbook::Config.instance.pass_config.each do |pass_id, pass_config|
      return pass_id if object_matches_pass_config obj, pass_id, pass_config
    end

    nil
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
      pkpass = Passbook::Pkpass.new Passbook.find_pass_id_for(obj), obj.serial_number
      obj.update_pass pkpass if obj.respond_to? :update_pass
      pkpass_io = pkpass.package
      response.headers["last-modified"] = obj.updated_at.strftime("%Y-%m-%d %H:%M:%S")
      send_data(pkpass_io.sysread, :type => 'application/vnd.apple.pkpass', :disposition=>'inline', :filename=>"#{obj.serial_number}.pkpass")
    end
  end
  self.register_pkpass

end

