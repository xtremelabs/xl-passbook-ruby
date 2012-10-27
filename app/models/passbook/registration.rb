module Passbook
  class Registration < ActiveRecord::Base
    set_table_name "passbook_registrations"
    attr_accessible :device_id, :pass_type_id, :push_token, :serial_number, :uuid
  end
end
