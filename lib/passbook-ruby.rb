require "passbook/config"
require "passbook/pkpass"
require "passbook/engine"

require "action_controller"
Mime::Type.register 'application/vnd.apple.pkpass', :pkpass

ActionController::Renderers.add :pkpass do |obj, options|
  pkpass = Passbook::Pkpass.new Passbook.class_name_to_pass_type_id(obj.class.to_s), obj.serial_number
  obj.update_pass pkpass
  pkpass_io = pkpass.package
  response.headers["last-modified"] = obj.updated_at.strftime("%Y-%m-%d %H:%M:%S")
  send_data(pkpass_io.sysread, :type => 'application/vnd.apple.pkpass', :disposition=>'inline', :filename=>"#{obj.serial_number}.pkpass")
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

