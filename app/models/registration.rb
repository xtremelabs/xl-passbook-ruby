class Registration < ActiveRecord::Base
  attr_accessible :device_id, :pass_type_id, :push_token, :serial_number, :uuid
end
