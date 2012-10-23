require "passbook/config"
require "passbook/pkpass"
require "passbook/engine"

require "action_controller"
Mime::Type.register 'application/vnd.apple.pkpass', :pkpass

ActionController::Renderers.add :pkpass do |obj, options|
  pkpass = Passbook::Pkpass.new obj.pass_type_id, obj.serial_number
  obj.update_pass pkpass
  pkpass_io = pkpass.package
  response.headers["last-modified"] = obj.updated_at.strftime("%Y-%m-%d %H:%M:%S")
  send_data(pkpass_io.sysread, :type => 'application/vnd.apple.pkpass', :disposition=>'inline', :filename=>"#{obj.serial_number}.pkpass")
end

module Passbook
end

